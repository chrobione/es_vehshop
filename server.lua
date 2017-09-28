local version = "v1.1"

TriggerEvent('es:exposeDBFunctions', function(db)
  db.createDatabase('es_vehshop', function()end)
end)

RegisterServerEvent('CheckMoneyForVeh')
AddEventHandler('CheckMoneyForVeh', function(vehicle, price)
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.getIdentifier()
    if (tonumber(user.getMoney()) >= tonumber(price)) then
      TriggerClientEvent('FinishMoneyCheckForVeh', source, true)
      user.removeMoney(tonumber(price))

      TriggerEvent('es:exposeDBFunctions', function(db)
       db.getDocumentByRow('es_vehshop', 'identifier', player, function(vehshopuser)
        local myVehicles = false
        
        if (vehshopuser.personalvehicle == vehicle) then
          myVehicles = true
        end

       if not myVehicles then           
           db.updateDocument('es_vehshop', vehshopuser._id, {personalvehicle = vehicle}, function()  end) 
         end
       end)
       end)
    else
      TriggerClientEvent('FinishMoneyCheckForVeh', source, false)
    end
  end)
end)

RegisterServerEvent('GetVehicle')
AddEventHandler('GetVehicle', function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local player = user.getIdentifier()
    TriggerEvent('es:exposeDBFunctions', function(db)
      db.getDocumentByRow('es_vehshop', 'identifier', player, function(vehshopuser)
          myCarLoaded = vehshopuser.personalvehicle
        end)
      TriggerClientEvent('vehshop:spawnVehicle', source, myCarLoaded)
      end)
    end)
  end)

AddEventHandler('es:newPlayerLoaded', function(source, user)
  TriggerEvent('es:exposeDBFunctions', function(db)
    db.createDocument('es_vehshop', {identifier = user.get("identifier"), personalvehicle = {}}, function()
      end)
    end)
end)

PerformHttpRequest("https://updates.fivem-scripts.org/verify/" .. GetCurrentResourceName(), function(err, rData, headers)
	if err == 404 or err == 403 then
		print("\nUPDATE ERROR: your version could not be verified\n")		
	else
		local vData = json.decode(rData)
		for k,v in pairs(vData) do		
		if v.version ~= version then
			print("\n************************************************************************************************")
			print("You are running an outdated version of " .. GetCurrentResourceName())
			print("************************************************************************************************\n")
		end
		end
	end
end, "GET", "", {["Content-Type"] = 'application/json'})
