local config = require("config.shared")

local SeatbeltLogic = {}
SeatbeltLogic.__index = SeatbeltLogic

function SeatbeltLogic.new()
    if not config.useBuiltInSeatbeltLogic then
        lib.print.debug("(SeatbeltLogic.new) Config.useBuiltInSeatbeltLogic is disabled.")
        return
    end

    local self = setmetatable({}, SeatbeltLogic)

    self.seatbeltState = false
    self.speedConversion = string.lower(config.speedUnit) == "mph" and 2.236936 or 3.6
    self.ejectVelocity = config.ejectMinSpeed / self.speedConversion
    self.unknownEjectVelocity = 1.0
    self.unknownModifier = 17.0
    self.minDamage = 10.0

    RegisterCommand("-toggle_seatbelt", function()
        local ped = PlayerPedId()

        if not IsPedInAnyVehicle(ped, false) or IsPedOnAnyBike(ped) then
            return lib.print.debug("(SeatbeltLogic:toggle) Seatbelt is not available either due to the fact that the player is not in a vehicle or on a bike.")
        end

        self:toggle(not self.seatbeltState)
        lib.print.debug("(commands:toggleSeatbelt) Toggled seatbelt.")
    end, false)

    SetPedConfigFlag(PlayerPedId(), 32, true)
    SetFlyThroughWindscreenParams(self.ejectVelocity, self.unknownEjectVelocity, self.unknownModifier, self.minDamage)
    RegisterKeyMapping("-toggle_seatbelt", "Toggle Seatbelt", "keyboard", "B")

    return self
end

---@param state boolean
function SeatbeltLogic:toggle(state)
    self.seatbeltState = state

    if state then
        SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0)
        self:disableVehicleExitControlThread()
        return
    end

    SetFlyThroughWindscreenParams(self.ejectVelocity, self.unknownEjectVelocity, self.unknownModifier, self.minDamage)
end

function SeatbeltLogic:disableVehicleExitControlThread()
    Citizen.CreateThread(function()
        lib.print.debug("(SeatbeltLogic:disableVehicleExitControlThread) Thread enabled.")
        while self.seatbeltState do
            DisableControlAction(0, 75, true) -- 75: INPUT_VEH_EXIT
            Wait(0)
        end
        lib.print.debug("(SeatbeltLogic:disableVehicleExitControlThread) Thread disabled.")
    end)
end

function SeatbeltLogic:isSeatbeltOn()
    lib.print.debug("(SeatbeltLogic:isSeatbeltOn) Returning: ", self.seatbeltState)

    return self.seatbeltState
end

return SeatbeltLogic
