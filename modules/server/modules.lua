Modules = {
    Registered = {},
    Loaded = {}
}

local RESOURCE = GetCurrentResourceName()

--------------------------------------------------
-- REGISTER
--------------------------------------------------

function Modules.Register(name, config)
    if type(name) ~= "string" then
        error("[Modules] Module name must be a string")
    end

    if type(config) ~= "table" then
        error(("[Modules] Invalid config for '%s'"):format(name))
    end

    if Modules.Registered[name] then
        print(("[Modules] Module '%s' already registered"):format(name))
        return false
    end

    Modules.Registered[name] = {
        name = name,
        server = config.server,
        client = config.client
    }

    Utils.DeV(("[Modules] enregistré: %s"):format(name))

    return true
end

--------------------------------------------------
-- GET
--------------------------------------------------

function Modules.Get(name)
    return Modules.Registered[name]
end

--------------------------------------------------
-- LOAD LUA
--------------------------------------------------

function Modules.LoadLua(path)
    if not path then
        return false, "Missing path"
    end

    local content = LoadResourceFile(RESOURCE, path)

    if not content then
        return false, ("File not found: %s"):format(path)
    end

    local chunk, err = load(
        content,
        ("@%s"):format(path)
    )

    if not chunk then
        return false, err
    end

    local success, result = pcall(chunk)

    if not success then
        return false, result
    end

    return true, result
end

--------------------------------------------------
-- START
--------------------------------------------------

function Modules.Start(name)
    local module = Modules.Registered[name]

    if not module then
        return false, ("Unknown module: %s"):format(name)
    end

    if Modules.Loaded[name] then
        return false, ("Module '%s' already loaded"):format(name)
    end

    if not module.server then
        print(("[Modules] %s has no server.lua"):format(name))
        return true
    end

    local success, object = Modules.LoadLua(module.server)

    if not success then
        print((
            "^1[Modules] Failed to load '%s'^0\n%s"
        ):format(name, object))

        return false
    end

    Modules.Loaded[name] = {
        object = object
    }

    if type(object) == "table" and object.start then
        local started, err = pcall(object.start)

        if not started then
            print((
                "^1[Modules] Start error '%s'^0\n%s"
            ):format(name, err))

            return false
        end
    end

    print((
        "^2[Modules] Server loaded: %s^0"
    ):format(name))

    return true
end

--------------------------------------------------
-- STOP
--------------------------------------------------

function Modules.Stop(name)
    local loaded = Modules.Loaded[name]

    if not loaded then
        return true
    end

    local object = loaded.object

    if type(object) == "table" and object.stop then
        local success, err = pcall(object.stop)

        if not success then
            print((
                "^1[Modules] Stop error '%s'^0\n%s"
            ):format(name, err))

            return false
        end
    end

    Modules.Loaded[name] = nil

    print((
        "^3[Modules] Server stopped: %s^0"
    ):format(name))

    return true
end

--------------------------------------------------
-- RELOAD
--------------------------------------------------

function Modules.Reload(name)
    local module = Modules.Registered[name]

    if not module then
        print((
            "^1[Modules] Unknown module: %s^0"
        ):format(name))

        return false
    end

    print((
        "^3[Modules] Reloading: %s^0"
    ):format(name))

    --------------------------------------------------
    -- SERVER
    --------------------------------------------------

    Modules.Stop(name)

    if module.server then
        local success = Modules.Start(name)

        if not success then
            print((
                "^1[Modules] Server reload failed: %s^0"
            ):format(name))
        end
    end

    --------------------------------------------------
    -- CLIENT
    --------------------------------------------------

    if module.client then
        TriggerClientEvent(
            "Furious:Modules:Reload",
            -1,
            name
        )

        print((
            "^2[Modules] Client reload requested: %s^0"
        ):format(name))
    end

    return true
end

--------------------------------------------------
-- LOAD ALL
--------------------------------------------------

function Modules.LoadAll()
    for name in pairs(Modules.Registered) do
        Modules.Start(name)
    end
end

--------------------------------------------------
-- RELOAD ALL
--------------------------------------------------

function Modules.ReloadAll()
    for name in pairs(Modules.Registered) do
        Modules.Reload(name)
    end
end

--------------------------------------------------
-- COMMAND
--------------------------------------------------

RegisterCommand("reload", function(source, args)
    -- uniquement console serveur
    if source ~= 0 then
        print("^1[Modules] /reload is console only.^0")
        return
    end

    local name = args[1]

    if not name then
        print("^3[Modules] Usage: reload <module|all>^0")
        return
    end

    if name == "all" then
        Modules.ReloadAll()
        return
    end

    Modules.Reload(name)
end, false)
