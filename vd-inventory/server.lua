droppedItems = {}

RegisterNetEvent('vd-inventory:server:giveItem')
AddEventHandler('vd-inventory:server:giveItem', function(target, item, quantity) 
    TriggerClientEvent('vd-inventory:client:giveItem', tonumber(target), item, quantity)
end)

RegisterNetEvent('vd-inventory:server:dropItem')
AddEventHandler('vd-inventory:server:dropItem', function(stash)
    table.insert(droppedItems, stash)
    TriggerClientEvent('vd-inventory:client:dropItem', -1, stash)
end)

RegisterNetEvent('vd-inventory:server:getStashes')
AddEventHandler('vd-inventory:server:getStashes', function(source)
    stashes = {}

    for i,v in pairs(droppedItems) do 
        table.insert(stashes, droppedItems[i])
        print(stashes[i])
        print(droppedItems[i])
    end
    TriggerClientEvent('vd-inventory:client:getStashes', tonumber(source), stashes)
end)

RegisterNetEvent('vd-inventory:server:updateStash')
AddEventHandler('vd-inventory:server:updateStash', function(stashIndex, occupation, contents) 
    droppedItems[stashIndex].occupied = occupation
    droppedItems[stashIndex].contents = contents
    TriggerClientEvent('vd-inventory:client:updateStash', -1, stashIndex, occupation, contents)
end)

RegisterNetEvent('vd-inventory:server:saveInventory')
AddEventHandler('vd-inventory:server:saveInventory', function(citizenID, contents) 
    print(contents)
    print(citizenID)

    MySQL.Async.fetchAll("SELECT * FROM `vd-inventory` WHERE citizenID = @citizenID", {['@citizenID'] = citizenID}, function(result) 
        if result[1] == nil then 
            MySQL.Async.execute("INSERT INTO `vd-inventory` (citizenID, inventory) VALUES(@citizenID, @inventory)", {['@citizenID'] = citizenID, ['@inventory'] = contents})
        else 
            MySQL.Async.execute("UPDATE `vd-inventory` SET inventory = @inventory WHERE citizenID = @citizenID", {['@inventory'] = contents, ['@citizenID'] = citizenID})
        end
    end)
end)

RegisterNetEvent('vd-inventory:server:getInventory')
AddEventHandler('vd-inventory:server:getInventory', function(citizenID) 
    target = source
    MySQL.Async.fetchAll("SELECT * FROM `vd-inventory` WHERE citizenID = @citizenID", {['@citizenID'] = citizenID}, function(result) 
        if result[1] ~= nil then 
            TriggerClientEvent('vd-inventory:client:getInventory', target, result[1].inventory)
        else
            TriggerClientEvent('vd-inventory:client:registerInventory', target)
        end
    end)
end)