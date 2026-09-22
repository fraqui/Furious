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

    self.permId = data.permId
    self.characterId = data.characterId

    self.loaded = false
    self.spawned = false

    self.group = data.group or "user"

    return self
end

function Player:Save()
    print("Sauvegarde du joueur " .. self.name .. " (ID: " .. self.PermId .. ")")
    local data = {
        name = self.name,
        ip = self.ip,
        license = self.license,
        discord = self.discord,
        group = self.group,
        PermId = self.permId,
    }

    if data then
        DB.Update(
            [[ UPDATE players SET name = ?, ip = ?, license = ?, discord = ?, group = ?, loaded = ? WHERE PermId = ? ]],
            {
                data.name,
                data.ip,
                data.license,
                data.discord,
                data.group,
                data.loaded,
                data.PermId
            })
    end
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
function Player:GetId()
    return self.permId
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

    --Systeme de logs

    ExecuteCommand("add_principal identifier.license:" .. self.license .. " group." .. new_group)
end
