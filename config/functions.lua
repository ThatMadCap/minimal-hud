return {
    isSeatbeltOn = function()
        if GetResourceState('jim-mechanic') == 'started' then
            return exports['jim-mechanic']:seatBeltOn()
        else
            return LocalPlayer.state.isSeatbeltOn or false -- Adjust based on your framework
        end
    end

    getVehicleFuel = function(currentVehicle)
		if GetResourceState('ps-fuel') == 'started' then
			return exports['ps-fuel']:GetFuel(currentVehicle)
		elseif GetResourceState('cdn-fuel') == 'started' then
			return exports['cdn-fuel']:GetFuel(currentVehicle)
		elseif GetResourceState('LegacyFuel') == 'started' then
			return exports['LegacyFuel']:GetFuel(currentVehicle)
		else
			return Entity(currentVehicle).state.fuel or 100.0
		end
	end	
    getNosLevel = function(currentVehicle) -- Replace this with your own logic to grab the nos level of the vehicle.
        return 0
    end,
}
