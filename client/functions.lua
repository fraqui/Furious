FUR = {}

function FUR.DisableSpawnManager()
    if GetResourceState("spawnanager") == "started" then
        exports.spawnmanager:SetAutoSpawn(false)
    end
end

function FUR.EnablePvp()
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end
