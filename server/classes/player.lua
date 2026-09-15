Player = {}
Player.__index = Player

---@class Player
---@field source number
---@field name string
---@field ip string
---@field license string
---@field discord string
---@field permid number
---@field characterId number
---@field loaded boolean
---@field group string

---@param data table
---@return Player
function Player:New(data)
    data = data or {}

    local self = setmetatable({}, Player)

    self.playerId = data.playerId
    self.name = data.name

    self.ip = data.ip
    self.license = data.license
    self.discord = data.discord

    self.permId = data.permId
    self.characterId = data.characterId

    self.loaded = false

    self.group = data.group or "user"


    function self:Load()
        self.loaded = true
    end

    ---@return string
    function self:GetName()
        return self.name
    end

    ---@return string
    function self:GetGroup()
        return self.group
    end

    ---@return number
    function self:GetId()
        return self.permId
    end

    ---@return string
    function self:GetLicense()
        return self.license
    end

    ---@return string
    function self:GetDiscord()
        return self.discord
    end

    ---@param reason string
    function self:Kick(reason)
        DropPlayer(self.source, reason)
    end

    ---@param new_group string
    function self:SetGroup(new_group)
        local last_group = self.group

        ExecuteCommand("remove_principal identifier.license:" .. self.license .. " group." .. last_group)

        self.group = new_group

        --Systeme de logs

        ExecuteCommand("add_principal identifier.license:" .. self.license .. " group." .. new_group)
    end

    return self
end
