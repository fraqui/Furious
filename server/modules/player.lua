Players = {}

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local _source = source
    local license = "abcd1234"
    local discord = "123456"
    local ip = GetPlayerEndpoint(_source)
    local name = GetPlayerName(_source)

    local xPlayer = Player:New({
        source = _source,
        name = name,
        ip = ip,
        license = license,
        discord = discord
    })

    DebugPrint(xPlayer)

    Players[_source] = xPlayer
end)
