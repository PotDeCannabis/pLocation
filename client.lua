ESX = nil
 
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Intéraction [E]

Citizen.CreateThread(function()
    while true do
        local wait = 900
        for k,v in pairs(Config.Positions) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)
            if dist <= 5 then 
                wait = 1                                                 
                DrawMarker(6, v.x, v.y, v.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 230, 230, 0 , 120)
             end
            if dist <= 2 then
                wait = 1
                Visual.Subtitle("Appuyer sur ~y~[E]~s~ pour accèder à la ~y~location de véhicules ~s~!", 1) 
                if IsControlJustPressed(1,51) then
                    OpenLocation()
                end
            end 
        end
    Citizen.Wait(wait)
    end
end)

-- Blips

Citizen.CreateThread(function()
    for k, v in pairs(Config.Positions) do
        local pos = Config.Positions
        local Blips = AddBlipForCoord(pos[k].x, pos[k].y, pos[k].z)
        SetBlipSprite(Blips, 523)
        SetBlipColour(Blips, 5)
        SetBlipScale(Blips, 0.7)
        SetBlipAsShortRange(Blips, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Locations de véhicules")
        EndTextCommandSetBlipName(Blips)
    Citizen.Wait(1)
    end
end)

-- NPC

CreateThread(function()
    local canCallJob = false
    for k, v in pairs(Config.NPC) do
        RequestModel(GetHashKey(v.typePed))
        while not HasModelLoaded(GetHashKey(v.typePed)) do
            Wait(1)
        end
        local npc = CreatePed(4, v.typePed, v.position.x, v.position.y, v.position.z-0.98, v.heading,  false, true)
        SetPedFleeAttributes(npc, 0, 0)
        SetPedDropsWeaponsWhenDead(npc, false)
        SetPedDiesWhenInjured(npc, false)
        SetEntityInvincible(npc , true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, false)
    end
end)

-- Spawn Véhicule

RegisterNetEvent("pLocation:spawnvehicule")
AddEventHandler("pLocation:spawnvehicule", function(SpawnZones, Models, Prix, Headings)
    CreateThread(function()
        if not ESX.Game.IsSpawnPointClear(vector3(SpawnZones.x, SpawnZones.y, SpawnZones.z), Headings) then
            ESX.ShowNotification("~r~La sortie du garage est bloquer.")
        else
            local model = GetHashKey(Models)

            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            local distanceFromPed = #(v.Position - GetEntityCoords(PlayerPedId()))
            if distanceFromPed < 3 then
                local vehiculelocation = CreateVehicle(model, SpawnZones.x, SpawnZones.y, SpawnZones.z, Headings, true, false)
                SetVehicleNumberPlateText(vehiculelocation, "location"..math.random(50, 999))
                SetVehicleFixed(vehiculelocation)
                TaskWarpPedIntoVehicle(PlayerPedId(), vehiculelocation, -1)
                SetVehRadioStation(vehiculelocation, 0)

                TriggerEvent("esx:showNotification", "Vous avez louer un ~y~véhicule ~s~ pour ~y~" ..Prix.. "$~s~.")
            end

            RageUI.CloseAll()
        end
    end)
end)

-- Menu

local open = false 
local mainMenu = RageUI.CreateMenu('Location', 'LOUER UN VÉHICULE')
local mainMenu2 = RageUI.CreateSubMenu(mainMenu, 'Location', 'LOUER UN VÉHICULE')
local mainMenu3 = RageUI.CreateSubMenu(mainMenu, 'Location', 'LOUER UN VÉHICULE')
mainMenu.Display.Header = true 
mainMenu.Closed = function()
  FreezeEntityPosition(PlayerPedId(), false)
  open = false
end

function OpenLocation()
    if open then 
        open = false
        RageUI.Visible(mainMenu, false)
        return
    else
        open = true 
        RageUI.Visible(mainMenu, true)
        CreateThread(function()
            while open do 

                RageUI.IsVisible(mainMenu, function() 
                          
                    RageUI.Separator("↓ ~y~ Location ~s~↓")

                    RageUI.Button("Liquide", nil, {RightLabel = "→"}, true , {
                    onSelected = function() 
                    end
                    }, mainMenu2)

                    RageUI.Button("Banque", nil, {RightLabel = "→"}, true , {
                    onSelected = function() 
                    end
                    }, mainMenu3)

                end)

                RageUI.IsVisible(mainMenu2, function() 

                    RageUI.Separator("→ Mode de Paiement : ~y~Liquide ~s~ ←")

                    for k,v in pairs(Config.Vehicules) do
                        RageUI.Button(v.Label, nil, {RightLabel = "~y~" ..v.Prix.. "$"}, true , {
                            onSelected = function()
                                SpawnZone = v.SpawnZone
                                Model = v.Model
                                Prix = v.Prix
                                Heading = v.Heading
                                TriggerServerEvent("pLocation:verifachatliquide", SpawnZone, Model, Prix, Heading)
                            end
                        })
                    end
                end)

                RageUI.IsVisible(mainMenu3, function() 

                    RageUI.Separator("→ Mode de Paiement : ~y~Banque ~s~ ←")

                    for k,v in pairs(Config.Vehicules) do
                        RageUI.Button(v.Label, nil, {RightLabel = "~y~" ..v.Prix.. "$"}, true , {
                            onSelected = function()
                                SpawnZone = v.SpawnZone
                                Model = v.Model
                                Prix = v.Prix
                                Heading = v.Heading
                                TriggerServerEvent("pLocation:verifachatbanque", SpawnZone, Model, Prix, Heading)
                            end
                        })
                    end
                end)

            Wait(0)
            end
        end)
    end
end