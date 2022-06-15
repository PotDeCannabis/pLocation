ESX = nil

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

-- Liquide

RegisterNetEvent("pLocation:verifachatliquide") 
AddEventHandler("pLocation:verifachatliquide", function(SpawnZone, Model, Prix, Heading) 
	local joueur = ESX.GetPlayerFromId(source)  
	local argent = joueur.getMoney()

	if argent >= Prix then 
		joueur.removeMoney(Prix) 

		SpawnZones = SpawnZone
		Models = Model
		Headings = Heading

		TriggerClientEvent("pLocation:spawnvehicule", source, SpawnZones, Models, Prix, Headings)
	else 
		TriggerClientEvent("esx:showNotification", source, "~r~Vous n'avez pas assez d'argent.")
	end
end)

-- Banque

RegisterNetEvent('pLocation:verifachatbanque') 
AddEventHandler('pLocation:verifachatbanque', function(SpawnZone, Model, Prix, Heading)
	local joueur = ESX.GetPlayerFromId(source)  
	local argent = joueur.getAccount('bank').money

	if argent >= Prix then 
		joueur.removeAccountMoney('bank', Prix)

		SpawnZones = SpawnZone
		Models = Model
		Headings = Heading

		TriggerClientEvent("pLocation:spawnvehicule", source, SpawnZones, Models, Prix, Headings)
	else 
		TriggerClientEvent("esx:showNotification", source, "~r~Vous n'avez pas assez d'argent.")
	end
end)