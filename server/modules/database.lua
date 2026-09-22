---@class DB
DB = {}

---@type boolean
DB.Connected = false

function DB.Connect()
  print("^3 Connexion à la base de données...^7")

  CreateThread(function()
    local succes, result = pcall(function()
      return MySQL.scalar.await("SELECT 1")
    end)
    if succes and result == 1 then
      DB.Connected = true
      print("^3 Connexion à la base de données réussie.^7")
    else
      DB.Connected = false
      print("^1 Connexion à la base de données échouée.^7")
    end
  end)
end

function DB.CheckConnection()
  local succes, result = pcall(function()
    return MySQL.scalar.await("SELECT 1")
  end)

  if succes and result == 1 then
    if not DB.Connected then
      print("^3 Connexion à la base de données réussie.^7")
    end
    DB.Connected = true
    return true
  else
    DB.Connected = false
    return false
  end

  DB.Connected = false
  return false
end

function DB.Start()
  CreateThread(function()
    while true do
      DB.CheckConnection()
      Wait(10000)
    end
  end)
end

local function execute(operation, query, params)
  if not DB.Connected then return nil end

  local ok, result = pcall(function()
    return MySQL[operation].await(query, params or {})
  end)

  if not ok then
    print(('^1[DATABASE] Échec SQL (%s).^7'):format(operation))
    Utils.DebugPrint({
      query = query,
      params = params,
      error = result
    })
    return nil
  end

  return result
end

function DB.Query(query, params) return execute('query', query, params) end

function DB.Single(query, params) return execute('single', query, params) end

function DB.Insert(query, params) return execute('insert', query, params) end

function DB.Update(query, params) return execute('update', query, params) end
