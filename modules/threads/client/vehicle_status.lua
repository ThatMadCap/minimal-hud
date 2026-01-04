local interface = lib.require("modules.interface.client")
local utility = lib.require("modules.utility.shared.main")
local functions = lib.require("config.functions")
local config = lib.require("config.shared")

local VehicleStatusThread = {}
VehicleStatusThread.__index = VehicleStatusThread

local math = (lib and lib.math) and lib.math or math
local max = math.max
local min = math.min
local floor = math.floor
local string = string
local lower = string.lower
local tostring = tostring
local setmetatable = setmetatable
local Wait = Wait
local SetHudComponentPosition = SetHudComponentPosition
local CreateThread = CreateThread
local PlayerPedId = PlayerPedId
local IsPedInAnyVehicle = IsPedInAnyVehicle
local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetVehicleTypeRaw = GetVehicleTypeRaw
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
local GetVehicleHighGear = GetVehicleHighGear
local GetVehicleDashboardCurrentGear = GetVehicleDashboardCurrentGear
local GetVehicleLightsState = GetVehicleLightsState
local GetEntitySpeed = GetEntitySpeed
local GetVehicleCurrentRpm = GetVehicleCurrentRpm

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
        noslevel = floor(noslevelraw)
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
            local fuelValue = max(0, min(rawFuelValue or 0, 100))
            local engineState = GetIsVehicleEngineRunning(vehicle)
            local fuel = floor(fuelValue)
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
                gearString = tostring(floor(currentGear))
            end
            -- Fix for vehicles that only have 1 gear
            if highGear == 1 then
                gearString = ""
            end

            -- Handle MPH and KPH
            local speed
            local normalizedSpeedUnit = lower(config.speedUnit)
            if normalizedSpeedUnit == "kph" then
                speed = floor(GetEntitySpeed(vehicle) * 3.6) -- Convert m/s to KPH
            elseif normalizedSpeedUnit == "mph" then
                speed = floor(GetEntitySpeed(vehicle) * 2.236936) -- Convert m/s to MPH
            else
                lib.print.error("Invalid speed unit in config. Expected 'kph' or 'mph', but got:", config.speedUnit)
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
            lib.print.verbose("(vehicleStatusThread) seatbelt found, toggling to false")
            self.seatbelt:toggle(false)
        end

        playerStatusThread:setIsVehicleThreadRunning(false)
        lib.print.verbose("(vehicleStatusThread) Vehicle status thread ended.")
    end)
end

return VehicleStatusThread
