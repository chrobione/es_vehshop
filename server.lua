local version = "2.0"
local carList = {}
local personalvehicles = {}

AddEventHandler('es:playerLoaded', function(source, user)
  TriggerEvent('es:exposeDBFunctions', function(db)
    db.getDocumentByRow('es_vehshop', 'identifier', user.get('identifier'), function(vehshopuser)
      if(vehshopuser)then
        personalvehicles = vehshopuser.personalvehicles
      else
        personalvehicles = {}
      end

      TriggerClientEvent('es_vehshop:myVehicles', source, personalvehicles)
    end)
  end)
end)

RegisterServerEvent('es_vehshop:GetVehicles')
AddEventHandler('es_vehshop:GetVehicles', function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    TriggerEvent('es:exposeDBFunctions', function(db)
      db.getDocumentByRow('es_vehshop', 'identifier', user.get('identifier'), function(vehshopuser)
        if(vehshopuser)then
          personalvehicles = vehshopuser.personalvehicles
        else
          personalvehicles = {}
        end
        TriggerClientEvent('es_vehshop:myVehicles', source, personalvehicles)
        end)
      end)
    end)
  end)

TriggerEvent('es:exposeDBFunctions', function(db)
  db.createDatabase('es_vehshop', function()end)
end)

RegisterServerEvent('CheckMoneyForVeh')
AddEventHandler('CheckMoneyForVeh', function(vehicle, price)
  TriggerEvent('es:getPlayerFromId', source, function(user)    
    local player = user.getIdentifier()

    if user.getMoney() >= tonumber(price) then
      personalvehicles[#personalvehicles + 1] = vehicle
      TriggerClientEvent('es_vehshop:myVehicles', source, personalvehicles)
      TriggerClientEvent('FinishMoneyCheckForVeh', source, true)
      user.removeMoney(tonumber(price))

      TriggerEvent('es:exposeDBFunctions', function(db)
        db.getDocumentByRow('es_vehshop', 'identifier', player, function(vehshopuser)
          local myVehicles = false
         
        for k,v in ipairs(vehshopuser.personalvehicles) do
          if (v == vehicle) then
            myVehicles = true
          end
        end 

        if not myVehicles then          
            vehshopuser.personalvehicles[#vehshopuser.personalvehicles+1] = vehicle            
            db.updateDocument('es_vehshop', vehshopuser._id, {personalvehicles = vehshopuser.personalvehicles}, function()  end) 
          end
        end)
      end)
       else
      TriggerClientEvent('FinishMoneyCheckForVeh', source, false)
    end
  end)
end)

AddEventHandler('es:newPlayerLoaded', function(source, user)
  TriggerEvent('es:exposeDBFunctions', function(db)
    db.createDocument('es_vehshop', {identifier = user.get("identifier"), personalvehicles = {}}, function()
      end)
    end)
end)

PerformHttpRequest("https://updates.fivem-scripts.org/verify/" .. GetCurrentResourceName(), function(err, rData, headers)
  if err == 404 or err == 403 then
    print("\nUPDATE ERROR: your version could not be verified\n")   
  else
    local vData = json.decode(rData)
    if vData.version ~= version then
      print("\n************************************************************************************************")
      print("You are running an outdated version of " .. GetCurrentResourceName())
      print("************************************************************************************************\n")
    end
  end
end, "GET", "", {["Content-Type"] = 'application/json'})