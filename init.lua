if not IsDuplicityVersion() then
    local config = require("config.shared")
    local playerStatusClass = require("modules.threads.client.player_status")
    local vehicleStatusClass = require("modules.threads.client.vehicle_status")
    local seatbeltLogicClass = require("modules.seatbelt.client")
    local utility = require("modules.utility.shared.main")
    local logger = require("modules.utility.shared.logger")
    local interface = require("modules.interface.client")

    local seatbeltLogic = seatbeltLogicClass.new()
    local playerStatusThread = playerStatusClass.new()
    local vehicleStatusThread = vehicleStatusClass.new(playerStatusThread, seatbeltLogic)
    local framework = utility.isFrameworkValid() and require("modules.frameworks." .. config.framework:lower()).new() or false

    playerStatusThread:start(vehicleStatusThread, seatbeltLogic, framework)

    _G.minimapVisible = config.minimapAlways

    exports("toggleHud", function(state)
        interface:toggle(state or nil)
        DisplayRadar(state)
        logger.info("(exports:toggleHud) Toggled HUD to state: ", state)
    end)

    local function toggleMap(state)
        _G.minimapVisible = state
        DisplayRadar(state)
        logger.info("(toggleMap) Toggled map to state: ", state)
    end

    exports("toggleMap", toggleMap)

    RegisterCommand("togglehud", function()
        interface:toggle()
    end, false)

    -- Toggle HUD when pause menu is active
    local isPauseMenuOpen = false
    CreateThread(function()
        while true do
            local currentPauseMenuState = IsPauseMenuActive()

            if currentPauseMenuState ~= isPauseMenuOpen then
                isPauseMenuOpen = currentPauseMenuState

                if isPauseMenuOpen then
                    interface:toggle(false)
                else
                    interface:toggle(true)
                end
            end
            Wait(isPauseMenuOpen and 250 or 500)
        end
    end)

    interface:on("APP_LOADED", function(_, cb)
        local data = {
            config = config,
            minimap = utility.calculateMinimapSizeAndPosition(),
        }

        cb(data)

        CreateThread(utility.setupMinimap)
        toggleMap(config.minimapAlways)
    end)

    return
end

local sv_utils = require("modules.utility.server.main")

CreateThread(function()
    if not sv_utils.isInterfaceCompiled() then
        print("^1UI not compiled, either compile the UI or download a compiled version here: ^0https://github.com/ThatMadCap/minimal-hud/releases/latest")
    end

    assert(GetResourceState('ox_lib') == 'started', 'ox_lib is not started. Please ensure ox_lib is installed and started before minimal-hud.')
    assert(lib.checkDependency('ox_lib', '3.27.0', true), 'Upgrade ox_lib to 3.27.0 or higher')

    local repName = 'minimal-hud'
    local resName = GetCurrentResourceName()
    if resName == repName then
        local repo = ('thatmadcap/%s'):format(resName)
        lib.versionCheck(repo)
    else
        lib.print.info(('Skipping resource version check (resource renamed to "%s").'):format(resName))
    end
end)
