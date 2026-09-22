Player = {}
Player.__index = Player


Players = {}


RegisterCommand("testp1", function()
    DebugPrint(Player)
end)

RegisterCommand("testp2", function()
    DebugPrint(Players)
end)
