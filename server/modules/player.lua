Players = {}

AddEventHandler("PlayerConnecting", function(name, setKickReason, deferrals)
    local _source = source
    local license = license
    local discord = discord
    local ip = GetPlayerEndpoint(_source)
    local name = GetPlayerName(_source)

    print(string.format("Player %s (%s) is connecting with IP %s, license %s, discord %s", name, _source, ip, license,
        discord))

    local player = Player:New({
        source = _source,
        name = name,
        ip = ip,
        license = license,
        discord = discord
    })
    Players[_source] = player
end)
