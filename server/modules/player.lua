AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local _source = source
    local license = _Func.GetIdentifier(_source, "license:")
    local discord = _Func.GetIdentifier(_source, "discord:")
    local ip = GetPlayerEndpoint(_source)
    local name = GetPlayerName(_source)

    local xPlayer = Player:CreateExtendedPlayer({
        source = _source,
        name = name,
        ip = ip,
        license = license,
        discord = discord
    })

    local row = DB.Single('SELECT * FROM players WHERE license = ?', { license })
    if row then
        xPlayer.PermId = row.PermId
    else
        local result = DB.Insert([[ INSERT INTO players (name, ip, license, discord, `group`) VALUES (?, ?, ?, ?, ?) ]],
            { name, ip, license, discord, "user" })
        if not result then return print("Erreur de création du joueur dans la DB.") end
        xPlayer.PermId = result
    end

    Utils.DebugPrint(xPlayer)

    Players[_source] = xPlayer
end)

AddEventHandler("playerDropped", function(reason)
    local _source = source
    Players[_source] = nil
    ---Faire une logs de déconnexion
end)


function GetPlayerById(source)
    if not source then return end
    return Players[source]
end

function GetAllXPlayer()
    return Players
end

RegisterCommand("xinfos", function(source, args, rawCommand)
    for k, v in pairs(GetAllXPlayer()) do
        Utils.DebugPrint(v)
    end
end)

RegisterCommand("xinfo", function(source, args, rawCommand)
    local xPlayer = GetPlayerById(tonumber(args[1]))
    if not xPlayer then return print("Joueur introuvable.") end

    Utils.DebugPrint(xPlayer)
end)

RegisterCommand("xsave", function(source, args, rawCommand)
    local xPlayer = GetPlayerById(tonumber(args[1]))
    if not xPlayer then return print("Joueur introuvable.") end

    xPlayer:Save()
end)
