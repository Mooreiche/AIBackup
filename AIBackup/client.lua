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
police        = GetHashKey('police')
policeman     = GetHashKey("s_m_y_cop_01")
companyName   = "Dispatch"
companyIcon   = "CHAR_CALL911"
drivingStyle  = 537133628 -- https://www.vespura.com/fivem/drivingstyle/
playerSpawned = false
active        = false
arrived       = false
vehicle       = nil
driver_ped    = nil
passenger_ped = nil
vehBlip       = nil


-- spawning events --

RegisterNetEvent('POL:Spawn')

-- AddEventHandler('playerSpawned', function(spawn)  
    playerSpawned = true
-- end)

-- keybinds --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if playerSpawned then
            if IsControlJustPressed(1, 314) --[[ Num+ ]] then
                TriggerEvent('POL:Spawn')
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if playerSpawned then
            if IsControlJustPressed(1, 315) --[[ Num- ]] then
                LeaveScene()
            end
        end
    end
end)

-- spawning events handlers --
AddEventHandler('POL:Spawn', function(player)
    if not active then
        if player == nil then
            player = PlayerPedId()
        end

        Citizen.CreateThread(function()
            active = true
            local pc = GetEntityCoords(player)

            RequestModel(policeman)
            while not HasModelLoaded(policeman) do
                RequestModel(policeman)
                Citizen.Wait(1)
            end

            RequestModel(police)
            while not HasModelLoaded(police) do
                RequestModel(police)
                Citizen.Wait(1)
            end            

            local offset = GetOffsetFromEntityInWorldCoords(player, 50, 50, 0)
            local heading, spawn = GetNthClosestVehicleNodeFavourDirection(offset.x, offset.y, offset.z, pc.x, pc.y, pc.z, 20, 1, 0x40400000, 0)

            vehicle         = CreateVehicle(police, spawn.x, spawn.y, spawn.z, heading, true, true)
            driver_ped      = CreatePedInsideVehicle(vehicle, 6, policeman, -1, true, true)
            passenger_ped   = CreatePedInsideVehicle(vehicle, 6, policeman, 0, true, true)

            SetEntityAsMissionEntity(vehicle)
            SetEntityAsMissionEntity(driver_ped)
            SetEntityAsMissionEntity(passenger_ped)     
            
            SetModelAsNoLongerNeeded(police)
            SetModelAsNoLongerNeeded(policeman)            

            GiveWeaponToPed(driver_ped, GetHashKey("WEAPON_COMBATPISTOL"), math.random(20, 100), false, true) -- Fahrer/Driver/YYY
            GiveWeaponToPed(passenger_ped, GetHashKey("WEAPON_PUMPSHOTGUN"), math.random(20, 100), false, true) -- Beifahrer/Passenger/XXX

            LoadAllPathNodes(true)
            while not AreAllNavmeshRegionsLoaded() do
                Wait(1)
            end   

            -- AI BACKUP Settings --
            local playerGroupId = GetPedGroupIndex(player)
            SetPedAsGroupMember(driver_ped, playerGroupId) -- Fahrer/Driver/YYY
            SetPedAsGroupMember(passenger_ped, playerGroupId) -- Beifahrer/Passenger/XXX

            NetworkRequestControlOfEntity(driver_ped) -- Fahrer/Driver/YYY
            NetworkRequestControlOfEntity(passenger_ped) -- Beifahrer/Passenger/XXX
            ClearPedTasksImmediately(driver_ped) -- Fahrer/Driver/YYY
            ClearPedTasksImmediately(passenger_ped) -- Beifahrer/Passenger/XXX
            
            local _, relHash = AddRelationshipGroup("POL8")
            SetPedRelationshipGroupHash(driver_ped, relHash)
            SetPedRelationshipGroupHash(passenger_ped, relHash)            
            SetRelationshipBetweenGroups(0, relHash, GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), relHash)

            vehBlip = AddBlipForEntity(vehicle)
            SetBlipSprite(vehBlip,3)

            SetVehicleSiren(vehicle, true)
            EnterVehicle()
            TaskVehicleDriveToCoordLongrange(driver_ped, vehicle, pc.x, pc.y, pc.z, 15.0, drivingStyle, 15.0)
            ShowAdvancedNotification(companyIcon, companyName, "Panic Button", "Your Panic Button was triggered. A CODE3 Unit has been dispatched to your location.")
            arrived = false
            while not arrived do
                Citizen.Wait(0)
                local coords = GetEntityCoords(vehicle)
                local distance = #(coords - pc) -- faster than Vdist
                if distance < 25.0 then
                    arrived = true
                end
            end
            while GetEntitySpeed(vehicle) > 0 do
                Wait(1)
            end
            LeaveVehicle()        
        end)
    end
end)

-- command --
RegisterCommand("aib", function()
    local player = PlayerPedId()
    if player~=nil then
        TriggerEvent('POL:Spawn', player)
    end
end, false)

RegisterCommand("CB", function()
    local player = PlayerPedId()
    if player~=nil and active then
        LeaveScene()
    end
end, false)

RegisterCommand("getout", function()
    local player = PlayerPedId()
    if player~=nil and active then
        LeaveVehicle()
    end
end, false)

-- functions --
function EnterVehicle()
    if vehicle ~= nil then
        TaskEnterVehicle(driver_ped, vehicle, 2000, -1, 20, 1, 0)
        while GetIsTaskActive(driver_ped, 160) do
            Wait(1)
        end
        TaskEnterVehicle(passenger_ped, vehicle, 2000, 0, 20, 1, 0)
        while GetIsTaskActive(passenger_ped, 160) do
            Wait(1)
        end      
    end
end

function LeaveVehicle()
    if vehicle ~= nil then
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
    end
end

function LeaveScene()
    if active then
        ShowAdvancedNotification(companyIcon, companyName, "Panic Button", "Backup Dispatch has been cancelled.")

        EnterVehicle()

        TaskVehicleDriveWander(driver_ped, vehicle, 17.0, 262315)
        SetEntityAsNoLongerNeeded(vehicle)
        SetPedAsNoLongerNeeded(driver_ped)
        SetPedAsNoLongerNeeded(passenger_ped)
        SetVehicleSiren(vehicle, false)
        RemoveBlip(vehBlip)

        -- reset --
        active        = false
        arrived       = false
    end
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
