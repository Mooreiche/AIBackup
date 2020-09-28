--[[
DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!
DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!
DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!
DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!
DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!			DO NOT DELETE ANYONE OUT OF THE CREDITS JUST ADD YOUR NAME TO IT!!!		
	This is my first GTA Script/Mod i did myself. Like the Scripts/Mods i publish for other Games you can edit, reupload, fix, delete, sniff, smoke or what ever you want with this script.
	JUST DONT DELETE ANYONE OUT OF THE CREDITS AND ADD YOUR NAME TO IT!!!
	
	CREDITS:
	(IceHax) - for publishing an incomplete amublance script on cfx.re which gave me the idea and basic structure to create this script
	Mooreiche - Me/Original Uploader
	
	
	
	
	
	
	
	
	
	
	
	Greetings from Germany to all Capitalists around the World! What a nice Life we all have!
*********  !REMEMBER TO FIGHT AGAINST COMMUNISM! *********
]]

-- variables --
police=GetHashKey('police')
policeman=GetHashKey("s_m_y_cop_01")
companyName = "Dispatch"
companyIcon = "CHAR_CALL911"

nearesthospital=nil

-- spawning events --

RegisterNetEvent('POL:Spawn')
RegisterNetEvent('Coroner:Spawn')

-- report progress events --

RegisterNetEvent('EMS:Half')
RegisterNetEvent('Coroner:Half')
RegisterNetEvent('EMS:Arrived')
RegisterNetEvent('Coroner:Arrived')

-- spawning events handlers --

AddEventHandler('POL:Spawn', function(target)
    Citizen.CreateThread(function()
        
    local pc = GetEntityCoords(target)
    RequestModel(police)
	RequestModel(policeman)
	
	while not HasModelLoaded(police) and RequestModel(policeman) do
		RequestModel(police)
		RequestModel(policeman)
		Citizen.Wait(0)
	end
    local offset=GetOffsetFromEntityInWorldCoords(PlayerPedId(), 50, 50, 0)
    local heading, spawn = GetNthClosestVehicleNodeFavourDirection(offset.x, offset.y, offset.z, pc.x, pc.y, pc.z, 50, 1, 0x40400000, 0)
    local vehicle = CreateVehicle(police, spawn.x, spawn.y, spawn.z, heading, true, false)
    
	-- AI BACKUP Settings --
	playerGroupId = GetPedGroupIndex(player)
    SetPedAsGroupMember(driver_ped, playerGroupId) -- Fahrer/Driver/YYY
	SetPedAsGroupMember(passenger_ped, playerGroupId) -- Beifahrer/Passenger/XXX
    NetworkRequestControlOfEntity(driver_ped) -- Fahrer/Driver/YYY
	NetworkRequestControlOfEntity(passenger_ped) -- Beifahrer/Passenger/XXX
    ClearPedTasksImmediately(driver_ped) -- Fahrer/Driver/YYY
	ClearPedTasksImmediately(passenger_ped) -- Beifahrer/Passenger/XXX
    AddRelationshipGroup("POL8")
    SetRelationshipBetweenGroups(0, GetHashKey("POL8"), GetHashKey("PLAYER"))
    SetPedRelationshipGroupHash(driver_ped, GetHashKey("POL8")) -- Fahrer/Driver/YYY
	SetPedRelationshipGroupHash(passenger_ped, GetHashKey("POL8")) -- Beifahrer/Passenger/XXX
	
    driver_ped = CreatePedInsideVehicle(vehicle ,6 , policeman, -1, true, true)
	passenger_ped = CreatePedInsideVehicle(vehicle ,6 , policeman, 0, true, true)
	GiveWeaponToPed(driver_ped, GetHashKey("WEAPON_COMBATPISTOL"), math.random(20, 100), false, true)
	GiveWeaponToPed(passenger_ped, GetHashKey("WEAPON_PUMPSHOTGUN"), math.random(20, 100), false, true)
	
    vehBlip = AddBlipForEntity(vehicle)
	SetBlipSprite (vehBlip,3)
	
    SetVehicleSiren(vehicle, true)
    LoadAllPathNodes(true)
    while not AreAllNavmeshRegionsLoaded() do
        Wait(1)
    end
    TaskEnterVehicle(driver_ped, vehicle, 1000, -1, 20, 1, 0)
    while GetIsTaskActive(driver_ped, 160) do
    Wait(1)
	end
	TaskEnterVehicle(passenger_ped, vehicle, 1000, 0, 20, 1, 0)
	while GetIsTaskActive(passenger_ped, 160) do
    Wait(1)
    end
    TaskVehicleDriveToCoordLongrange(driver_ped, vehicle, pc.x, pc.y, pc.z, 15.0, 537133612, 15.0)
	ShowAdvancedNotification(companyIcon, companyName, "Panic Button", "Your Panic Button was triggered. A CODE3 Unit has been dispatched to your location.")
    local arrived = false
    while not arrived do
	Citizen.Wait(0)
        local coords = GetEntityCoords(driver_ped, true)
    local distance=Vdist(coords.x, coords.y, coords.z, pc.x, pc.y, pc.z)
    if distance < 25.0 then
    break
    end
    end
    while GetEntitySpeed(vehicle)>0 do
        Wait(1)
    end  
    ClearPedTasks(driver_ped)
      TaskLeaveVehicle(driver_ped, vehicle, 0)
      while IsPedInAnyVehicle(driver_ped, false) do
        Wait(1)
    end
    ClearPedTasks(passenger_ped)
      TaskLeaveVehicle(passenger_ped, vehicle, 0)
      while IsPedInAnyVehicle(passenger_ped, false) do
        Wait(1)
    end	
	
end)
    
end)


-- command --
RegisterCommand("aib", function()
    
  
    local target = PlayerPedId()
    if target~=nil then
    TriggerEvent('POL:Spawn', target)
    end

end, false)

RegisterCommand("CB", function()
    
  
    local target = PlayerPedId()
    if target~=nil then
    LeaveScene(vehicle, driver_ped, passenger_ped)
	SetVehicleSiren(vehicle, false)
	ShowAdvancedNotification(companyIcon, companyName, "Panic Button", "Backup Dispatch has been cancelled.")
    end
	
end, false)

RegisterCommand("getout", function()
    
  
    local target = PlayerPedId()
    if target~=nil then
    if TaskLeaveAnyVehicle(driver_ped, vehicle, 1) then
	TaskLeaveAnyVehicle(Passenger_ped, vehicle, 1)
    end
end
end, false)



-- functions --
function LeaveScene(vehicle, driver_ped, passenger_ped)
	TaskEnterVehicle(passenger_ped, vehicle, 1000, 0, 20, 1, 0)
	while GetIsTaskActive(passenger_ped, 160) do
    Wait(1)
	end
	TaskEnterVehicle(passenger_ped, vehicle, 1000, 0, 20, 1, 0)
	while GetIsTaskActive(passenger_ped, 160) do
    Wait(1)
	end
	TaskVehicleDriveWander(driver_ped, vehicle, 17.0, drivingStyle)
	SetEntityAsNoLongerNeeded(vehicle)
	SetPedAsNoLongerNeeded(driver_ped)
	SetPedAsNoLongerNeeded(passenger_ped)
	SetVehicleSiren(vehicle, false)
	RemoveBlip(vehBlip)
end

function LeaveVehicle(vehicle, driver_ped, passenger_ped)
	TaskLeaveAnyVehicle(driver_ped, vehicle, 1)
	TaskLeaveAnyVehicle(passenger_ped, vehicle, 1)
end

-- Notifications --
function ShowAdvancedNotification(icon, sender, title, text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, true, 4, sender, title, text)
    DrawNotification(false, true)
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end