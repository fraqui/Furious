Player = {}
Player.__index = Player

function Player:New(data)
    data = data or {}

    local self = setmetatable({}, Player)

    self.source = data.source
    self.name = data.name

    self.ip = data.ip

    self.license = data.license
    self.discord = data.discord

    self.permid = data.permid

    self.character = data.character

    self.loaded = false

    return self
end
