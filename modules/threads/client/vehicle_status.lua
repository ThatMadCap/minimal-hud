local interface = require("modules.interface.client")
local utility = require("modules.utility.shared.main")
local logger = require("modules.utility.shared.logger")
local functions = require("config.functions")
local config = require("config.shared")

local VehicleStatusThread = {}
VehicleStatusThread.__index = VehicleStatusThread

function VehicleStatusThread.new(playerStatus, seatbeltLogic)
    local self = setmetatable({}, VehicleStatusThread)
    self.playerStatus = playerStatus
    self.seatbelt = seatbeltLogic

    SetHudComponentPosition(6, 999999.0, 999999.0) -- VEHICLE NAME
    SetHudComponentPosition(7, 999999.0, 999999.0) -- AREA NAME
    SetHudComponentPosition(8, 999999.0, 999999.0) -- VEHICLE CLASS
    SetHudComponentPosition(9, 999999.0, 999999.0) -- STREET NAME

    return self
end

function GetNosLevel(veh)
    local noslevelraw = functions.getNosLevel(veh)
    local noslevel

    if noslevelraw == nil then
        noslevel = 0
    else
        noslevel = math.floor(noslevelraw)
    end

    return noslevel
end

function VehicleStatusThread:start()
    CreateThread(function()
        local ped = PlayerPedId()
        local playerStatusThread = self.playerStatus
        local convertRpmToPercentage = utility.convertRpmToPercentage
        local convertEngineHealthToPercentage = utility.convertEngineHealthToPercentage

        playerStatusThread:setIsVehicleThreadRunning(true)

        while IsPedInAnyVehicle(ped, false) do
            local vehicle = GetVehiclePedIsIn(ped, false)
            local vehicleType = GetVehicleTypeRaw(vehicle)
            local engineHealth = convertEngineHealthToPercentage(GetVehicleEngineHealth(vehicle))
            local noslevel = GetNosLevel(vehicle)
            local rawFuelValue = functions.getVehicleFuel(vehicle)
            local fuelValue = math.max(0, math.min(rawFuelValue or 0, 100))
            local engineState = GetIsVehicleEngineRunning(vehicle)
            local fuel = math.floor(fuelValue)
            local highGear = GetVehicleHighGear(vehicle)
            local currentGear = GetVehicleDashboardCurrentGear()
            local newGears = highGear
            local retval, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)

            -- Fix for vehicles that only have 1 gear
            if highGear == 1 then
                newGears = 0
            end

            -- Display vehicle gear
            local gearString = "N"
            if not engineState then
                gearString = ""
            elseif currentGear == 0 and GetEntitySpeed(vehicle) > 0 then
                gearString = "R"
            elseif currentGear == 1 and GetEntitySpeed(vehicle) < 0.1 and engineState then
                gearString = "N"
            elseif currentGear == 1 then
                gearString = "1"
            elseif currentGear > 1 then
                gearString = tostring(math.floor(currentGear))
            end
            -- Fix for vehicles that only have 1 gear
            if highGear == 1 then
                gearString = ""
            end

            -- Handle MPH and KPH
            local speed
            local normalizedSpeedUnit = string.lower(config.speedUnit)
            if normalizedSpeedUnit == "kph" then
                speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Convert m/s to KPH
            elseif normalizedSpeedUnit == "mph" then
                speed = math.floor(GetEntitySpeed(vehicle) * 2.236936) -- Convert m/s to MPH
            else
                logger.error("Invalid speed unit in config. Expected 'kph' or 'mph', but got:", config.speedUnit)
            end

            local rpm
            if vehicleType == 8 then -- Helicopters: Simulate RPM based on speed
                rpm = math.min(speed / 150, 1) * 100
            else -- All other vehicles: Use actual RPM
                rpm = convertRpmToPercentage(GetVehicleCurrentRpm(vehicle))
            end

            -- Vehicle headlights
            local headlights = (lightsOn and highbeamsOn) and 100 or (lightsOn or highbeamsOn) and 50 or 0

            interface:message("state::vehicle::set", {
                speedUnit = config.speedUnit,
                speed = speed,
                rpm = rpm,
                engineHealth = engineHealth,
                engineState = engineState,
                gears = newGears,
                currentGear = gearString,
                fuel = fuel,
                nos = noslevel,
                headlights = headlights
            })

            Wait(100)
        end

        if self.seatbelt then
            logger.verbose("(vehicleStatusThread) seatbelt found, toggling to false")
            self.seatbelt:toggle(false)
        end

        playerStatusThread:setIsVehicleThreadRunning(false)
        logger.verbose("(vehicleStatusThread) Vehicle status thread ended.")
    end)
end

return VehicleStatusThread
