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
function Player:CreateExtendedPlayer(data)
    data = data or {}

    local self = setmetatable({}, Player)

    self.playerId = data.playerId
    self.source = data.source
    self.name = data.name

    self.ip = data.ip
    self.license = data.license
    self.discord = data.discord
    self.fivem = data.fivem

    self.PermId = data.PermId
    self.characterId = data.characterId

    self.loaded = false
    self.spawned = false

    self.group = data.group or "user"

    return self
end

function Player:Load()
    self.loaded = true
end

---@return string
function Player:GetName()
    return self.name
end

---@return string
function Player:GetGroup()
    return self.group
end

---@return number
function Player:GetPermId()
    return self.PermId
end

---@return string
function Player:GetLicense()
    return self.license
end

---@return string
function Player:GetDiscord()
    return self.discord
end

---@param reason string
function Player:Kick(reason)
    DropPlayer(self.source, reason)
end

---@param new_group string
function Player:SetGroup(new_group)
    local last_group = self.group

    ExecuteCommand("remove_principal identifier.license:" .. self.license .. " group." .. last_group)

    self.group = new_group

    local ok, result = pcall(function()
        DB.Update([[ UPDATE players SET `group` = ? WHERE PermId = ? ]], {
            self.group,
            self.PermId
        })
    end)

    if ok then
        print("Changement de group pour " .. self.PermId .. " | Ancien : " .. last_group .. " | nouveau : " .. new_group)
        --Systeme de logs

        ExecuteCommand("add_principal identifier.license:" .. self.license .. " group." .. new_group)
    else
        --Systeme de logs
        print("Le changement du groupe pour " .. self.PermId .. " à échoué niveau SQL.")
    end
end
