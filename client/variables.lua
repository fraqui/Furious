_Var = {
    Cache = {}
}

local function VarSync(data)
    for v, k in pairs(data) do
        print(v)
        _Var.Cache[v] = k
    end
end

RegisterNetEvent("Furious:client:Variables:Syncbyserver", function(data)
    VarSync(data)
end)

function _Var.Sync()
    TriggerServerEvent("Furious:server:Variables:Syncbyclient")
end

AddEventHandler("Furious:client:Variables:Syncbyclient", function(data)
    VarSync(data)
end)
