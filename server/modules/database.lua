DB = {
  Connected = false
}


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
