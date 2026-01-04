ESX = exports["es_extended"]:getSharedObject()

local esxFramework = {}
esxFramework.__index = esxFramework

function esxFramework.new()
    local self = setmetatable({}, esxFramework)
    self.values = {}

    AddEventHandler("esx_status:onTick", function(data)
        for i = 1, #data do
            if data[i].name == "hunger" then
                self.values.hunger = math.floor(data[i].percent)
            end

            if data[i].name == "thirst" then
                self.values.thirst = math.floor(data[i].percent)
            end

            if data[i].name == "stress" then
                self.values.stress = math.floor(data[i].percent)
            end
        end
    end)

    return self
end

function esxFramework:getPlayerHunger()
    return self.values.hunger
end

function esxFramework:getPlayerThirst()
    return self.values.thirst
end

function esxFramework:getPlayerStress()
    return self.values.stress
end

function esxFramework:getPlayerOxygen()
    return self.values.oxygen
end

function esxFramework:getPlayerStamina()
    return self.values.stamina
end

ESX.SecureNetEvent("esx:playerLoaded", function()
    lib.print.debug("[esxFramework] Player loaded. Toggling HUD on.")
    interface:toggle(true)
end)

ESX.SecureNetEvent("esx:onPlayerLogout", function()
    lib.print.debug("[esxFramework] Player logged out. Toggling HUD off.")
    interface:toggle(false)
end)

return esxFramework
