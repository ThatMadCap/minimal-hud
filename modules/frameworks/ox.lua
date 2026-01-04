local oxFramework = {}
oxFramework.__index = oxFramework

local setmetatable = setmetatable
local AddEventHandler = AddEventHandler

function oxFramework.new()
    local self = setmetatable({}, oxFramework)
    self.values = {}

    AddEventHandler("ox:statusTick", function(data)
        self.values.hunger = 100 - data.hunger
        self.values.thirst = 100 - data.thirst
        self.values.stress = data.stress
        self.values.stamina = 100 - (data.stamina or 0)
        self.values.oxygen = 100 - (data.oxygen or 0)
    end)

    return self
end

function oxFramework:getPlayerHunger()
    return self.values.hunger
end

function oxFramework:getPlayerThirst()
    return self.values.thirst
end

function oxFramework:getPlayerStress()
    return self.values.stress
end

function oxFramework:getPlayerOxygen()
    return self.values.oxygen
end

function oxFramework:getPlayerStamina()
    return self.values.stamina
end

AddEventHandler('ox:playerLoaded', function()
    lib.print.debug("[oxFramework] Player loaded. Toggling HUD on.")
    interface:toggle(true)
end)

AddEventHandler('ox:playerLogout', function()
    lib.print.debug("[oxFramework] Player logged out. Toggling HUD off.")
    interface:toggle(false)
end)

return oxFramework
