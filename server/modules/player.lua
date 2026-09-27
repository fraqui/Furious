AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update("Vérification de vos informations...")
    local _source = source
    local license = _Func.GetIdentifier(_source, "license:")
    local discord = _Func.GetIdentifier(_source, "discord:")
    local fivem = _Func.GetIdentifier(_source, "fivem:")
    local ip = GetPlayerEndpoint(_source)
    local name = GetPlayerName(_source)

    local xPlayer

    local row = DB.Single('SELECT * FROM players WHERE license = ?', { license })
    if row then
        xPlayer = Player:CreateExtendedPlayer({
            source = _source,
            name = name,
            ip = ip,
            license = license,
            discord = discord,
            fivem = fivem,
            PermId = row.PermId,
            group = row.group
        })
        deferrals.update("Connexion en cours... | Perm Id : " .. xPlayer.PermId)
    else
        local result = DB.Insert(
            [[ INSERT INTO players (name, ip, license, discord, fivem, `group`) VALUES (?, ?, ?, ?, ?, ?) ]],
            { name, ip, license, discord, "user" })
        if not result then
            deferrals.done("Erreur au moment de créer votre compte.")
            print("Erreur de création du joueur dans la DB.")
            return
        end
        xPlayer = Player:CreateExtendedPlayer({
            source = _source,
            name = name,
            ip = ip,
            license = license,
            discord = discord,
            fivem = fivem,
            PermId = result,
            group = "user"
        })
        deferrals.update("Connexion en cours... | Perm Id : " .. xPlayer.PermId)
    end

    local ok, result = pcall(function()
        ExecuteCommand("add_principal identifier.license:" .. xPlayer.license .. " group." .. xPlayer.group)
    end)

    if not ok then
        print("Erreur de chargement du groupe en jeu pour le joueur " .. xPlayer.name .. " | PermId : " .. xPlayer
            .PermId)
        return deferrals.done(
            "Erreur de chargement de votre group de permission...\n Merci de relancer la connexion, si le problème persiste contacter un administrateur du serveur sur le discord.")
    end

    Utils.DebugPrint(xPlayer)

    Variables.SyncPlayer(xPlayer.source)

    Players[_source] = xPlayer
    deferrals.done()
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

RegisterCommand("xSetGroup", function(source, args, rawCommand)
    local xPlayer = GetPlayerById(tonumber(args[1]))
    if not xPlayer then return print("Joueur introuvable.") end
    local newgroup = xPlayer:SetGroup(tostring(args[2]))
end)
