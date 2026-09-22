Variables = {
    Data = {},
    Registered = {},
    Loaded = false,
}

local function EncodedValue(type, value)
    if type == "boolean" then
        return value and "true" or "false"
    end

    if type == "number" then
        return tostring(value)
    end

    if type == "string" then
        return value
    end

    if type == "json" then
        return json.encode(value)
    end

    error(("type non pris en charge '%s'"):format(type))
end

local function DecodeValue(type, value)
    if type == "boolean" then
        if value == "true" or value == "1" then
            return true
        end

        if value == "false" or value == "0" then
            return false
        end

        return nil
    end

    if type == "number" then
        return tonumber(value)
    end

    if type == "string" then
        return value
    end

    if type == "json" then
        return json.decode(value)
    end

    return nil
end

function Variables.load()
    if Variables.Loaded then
        print("variables déjà lier. ")
    end

    local rows = DB.Query([[SELECT * FROM variables]])

    if not rows then return error("Erreur de chargement depuis la base de données.") end

    local sqlVariables = {}

    for _, rw in ipairs(rows) do
        sqlVariables[rw.name] = rw
    end

    local stats = {
        total = 0,
        registered = 0,
        loaded = 0,
        sqlOnly = 0,
        created = 0
    }

    for name, config in pairs(Variables.Registered) do
        stats.registered += 1
        local row = sqlVariables[name]

        if row then
            if row.type ~= config.type then
                error((
                    "type mismatch for '%s' (SQL: %s | Code: %s)"
                ):format(
                    name,
                    row.type,
                    config.type
                ))
            end

            local value = DecodeValue(config.type, row.data)

            if value == nil then
                error((
                    "failed to decode variable '%s'"
                ):format(name))
            end

            Variables.Data[name] = { value = value }
            stats.loaded += 1
        else
            local data = EncodedValue(config.type, config.value)

            local id = DB.Insert([[ INSERT INTO variables (name, type, data, replicated) VALUES (?,?,?,?)]], {
                name, config.type, data, config.replicated
            })

            if not id then error(("Création de la variable '%s' échouée"):format(name)) end
            stats.created += 1
        end
        for _name, _row in pairs(sqlVariables) do
            if not Variables.Registered[_name] then
                stats.sqlOnly += 1
            end
        end
        stats.total = stats.registered + stats.sqlOnly
    end
    Variables.Loaded = true
    print(("^2[Variables]^7 Total: ^3%d^7 | Code: ^3%d^7 | Loaded: ^3%d^7 | SQL only: ^3%d^7 | Created: ^3%d^7"):format(
        stats.total,
        stats.registered,
        stats.loaded,
        stats.sqlOnly,
        stats.created
    ))
    return true
end

function Variables.Register(name, options)
    if type(name) ~= "string" then
        error("le nom doit être une chaîne de caractères")
    end
    if type(options) ~= "table" then
        error(("options invalides pour '%s'"):format(name))
    end
    if options.type == nil then
        error(("type manquant pour '%s'"):format(name))
    end
    if options.value == nil then
        error(("valeur par défaut manquante pour '%s'"):format(name))
    end
    if Variables.Registered[name] then
        error(("la variable '%s' est déjà enregistrée"):format(name))
    end

    Variables.Registered[name] = {
        type = options.type,
        value = options.value,
        replicated = options.replicated
    }

    return true
end

function Variables.Get(name)
    local variable = Variables.Data[name]
    if not variable then return nil end
    return variable.value, variable.replicated
end

function Variables.Set(name, value)
    local config = Variables.Registered[name]

    if not config then
        return (("Variable %s non enregistré."):format(name))
    end

    local expectedTypes = {
        boolean = "boolean",
        number  = "number",
        string  = "string",
        json    = "table"
    }

    local expectedType = expectedTypes[config.type]

    if expectedType and type(value) ~= expectedType then
        return (("La variable '%s' attend une valeur de type %s"):format(name, expectedType))
    end

    local variable = Variables.Data[name]

    if not variable then
        return (("Variable %s non chargé."):format(name))
    end

    if config.type ~= "json" and variable.value == value then
        return false
    end

    if config.type == "json" then
        local oldData = json.encode(variable.value)
        local newData = json.encode(value)

        if oldData == newData then
            return false
        end
    end

    local data = EncodedValue(config.type, value)

    local affrow = DB.Update([[ UPDATE variables SET data = ? WHERE name = ?]], { data, name })

    if affrow == nil then
        error(("Erreur au moment de modifier %s dans la base de données"):format(name))
    end

    variable.value = value

    return true
end

RegisterCommand("setvar", function(source, args)
    if source ~= 0 then
        print("^1[Variables]^7 Cette commande est utilisable uniquement depuis la console serveur.")
        return
    end

    local name = args[1]
    local rawValue = args[2]

    if not name then
        print("^3[Variables]^7 Usage : setvar <name> <value>")
        return
    end

    if not rawValue then
        print("^3[Variables]^7 Valeur manquante.")
        return
    end

    local config = Variables.Registered[name]

    if not config then
        print(("^1[Variables]^7 Variable ^3%s^7 non enregistrée."):format(name))
        return
    end

    local value

    if config.type == "boolean" then
        if rawValue == "true" then
            value = true
        elseif rawValue == "false" then
            value = false
        else
            print(("^1[Variables]^7 '%s' attend ^3true^7 ou ^3false^7."):format(name))
            return
        end
    elseif config.type == "number" then
        value = tonumber(rawValue)

        if not value then
            print(("^1[Variables]^7 '%s' attend un nombre."):format(name))
            return
        end
    elseif config.type == "string" then
        value = table.concat(args, " ", 2)
    elseif config.type == "json" then
        local jsonValue = table.concat(args, " ", 2)

        local success, decoded = pcall(json.decode, jsonValue)

        if not success or type(decoded) ~= "table" then
            print(("^1[Variables]^7 '%s' attend un JSON valide."):format(name))
            return
        end

        value = decoded
    else
        print(("^1[Variables]^7 Type '%s' non supporté."):format(config.type))
        return
    end

    local result = Variables.Set(name, value)

    if result == true then
        print((
            "^2[Variables]^7 '%s' modifiée avec succès."
        ):format(name))
    elseif result == false then
        print((
            "^3[Variables]^7 '%s' possède déjà cette valeur."
        ):format(name))
    elseif type(result) == "string" then
        print((
            "^1[Variables]^7 %s"
        ):format(result))
    end
end, true)
