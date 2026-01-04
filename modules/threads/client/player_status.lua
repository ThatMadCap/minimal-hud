---@diagnostic disable: cast-local-type
local interface = lib.require("modules.interface.client")
local config = lib.require("config.shared")
local utility = lib.require("modules.utility.shared.main")
local sharedFunctions = lib.require("config.functions")

math = lib.math

local PlayerStatusThread = {}
PlayerStatusThread.__index = PlayerStatusThread

---@return table
function PlayerStatusThread.new()
    local self = setmetatable({
        isVehicleThreadRunning = false,
        source = {
            server_id = GetPlayerServerId(PlayerId()),
        },
    }, PlayerStatusThread)

    return self
end

-- What was this here for?
-- AddStateBagChangeHandler("stress", ("player:%s"):format(self.source.server_id), function(_, _, value)
--     stress = value
-- end)

function PlayerStatusThread:getIsVehicleThreadRunning()
    return self.isVehicleThreadRunning
end

---@param value boolean
function PlayerStatusThread:setIsVehicleThreadRunning(value)
    lib.print.verbose("(PlayerStatusThread:setIsVehicleThreadRunning) Setting: ", value)
    self.isVehicleThreadRunning = value
end

function PlayerStatusThread:start(vehicleStatusThread, seatbeltLogic, framework)
    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            local playerId = PlayerId()
            local talking = NetworkIsPlayerTalking(playerId)
            local voice = 0
            local coords = GetEntityCoords(ped)

            local currentStreet = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
            local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))

            local camRot = GetGameplayCamRot(0)
            local heading = math.round(360.0 - ((camRot.z + 360.0) % 360.0))
            local compass = " "

            local headingRanges = {
                { min = 315, max = 360, dir = "N" },
                { min = 0, max = 45, dir = "N" },
                { min = 45, max = 135, dir = "E" },
                { min = 135, max = 225, dir = "S" },
                { min = 225, max = 315, dir = "W" },
            }

            for _, range in ipairs(headingRanges) do
                if heading >= range.min and heading < range.max then
                    compass = range.dir
                    break
                end
            end

            local voiceModes = {
                Whisper = 15,
                Normal = 50,
                Shouting = 100,
            }

            if LocalPlayer.state["proximity"] then
                voice = voiceModes[LocalPlayer.state["proximity"].mode] or 0
            else
                voice = 0
            end

            local pedArmor = GetPedArmour(ped)
            local pedMaxHealth = GetEntityMaxHealth(ped)
            local pedCurrentHealth = GetEntityHealth(ped)
            local pedHealthPercentage = math.floor(((pedCurrentHealth - 100) / (pedMaxHealth - 100)) * 100)
            pedHealthPercentage = math.max(0, math.min(100, pedHealthPercentage))
            local pedHunger = framework and framework:getPlayerHunger() or nil
            local pedThirst = framework and framework:getPlayerThirst() or nil
            local pedStress = framework and framework:getPlayerStress() or nil
            local pedOxygen = math.floor(GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10) or nil
			local pedStamina = math.floor(100 - GetPlayerSprintStaminaRemaining(PlayerId())) or nil

            local isInVehicle = IsPedInAnyVehicle(ped, false)
            local isSeatbeltOn = config.useBuiltInSeatbeltLogic and seatbeltLogic.seatbeltState or sharedFunctions.isSeatbeltOn()

            if isInVehicle then
                if not self:getIsVehicleThreadRunning() and vehicleStatusThread then
                    vehicleStatusThread:start()
                    DisplayRadar(true)
                    lib.print.verbose("(playerStatus) (vehicleStatusThread) Vehicle status thread started.")
                else
                    DisplayRadar(true)
                end
            else
                DisplayRadar(_G.minimapVisible)
            end

            local player_data = {
                health = pedHealthPercentage,
                armor = pedArmor,
                hunger = pedHunger,
                thirst = pedThirst,
                stress = pedStress,
                oxygen = pedOxygen,
				stamina = pedStamina,
                streetLabel = currentStreet,
                areaLabel = zone,
                heading = compass,
                voice = voice,
                mic = talking,
                isSeatbeltOn = isSeatbeltOn,
                isInVehicle = isInVehicle,
            }

            interface:message("state::global::set", {
                minimap = utility.calculateMinimapSizeAndPosition(),
                player = player_data,
            })

            Wait(300)
        end
    end)
end

return PlayerStatusThread
