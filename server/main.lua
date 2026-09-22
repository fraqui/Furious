CreateThread(function()
    DB.Start()
    if DB.CheckConnection() then
        Variables.load()
    end
end)
