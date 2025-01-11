local QBCore = exports['qb-core']:GetCoreObject()
local activeCampingItems = {}
local tentStashes = {}

RegisterNetEvent('camping:server:CheckRequiredItems', function(requiredItems, callbackEvent)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasAllItems = true

    for _, item in ipairs(requiredItems) do
        if not Player.Functions.HasItem(item.name, item.amount) then
            hasAllItems = false
            TriggerClientEvent('QBCore:Notify', src, 'You are missing ' .. item.amount .. 'x ' .. item.name, 'error')
            break
        end
    end
    TriggerClientEvent(callbackEvent, src, hasAllItems)
end)


RegisterNetEvent('camping:server:RemoveItems', function(requiredItems)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        for _, item in ipairs(requiredItems) do
            Player.Functions.RemoveItem(item.name, item.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "remove")
        end
    end
end)

RegisterNetEvent('camping:server:GiveItem', function(itemName, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem(itemName, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add")
    else
        print("Player not found for source: ", src)
    end
end)


QBCore.Functions.CreateUseableItem('tent', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if activeCampingItems[source] and activeCampingItems[source].tent then
        TriggerClientEvent('QBCore:Notify', source, 'You already have a tent placed. Pack it up before placing another.', 'error')
        return
    end
    if Player.Functions.GetItemByName('tent') then
        Player.Functions.RemoveItem('tent')
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['tent'], 'remove')
        TriggerClientEvent('camping:client:useTent', source)
    end
end)

QBCore.Functions.CreateUseableItem('campingchair', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not (activeCampingItems[source] and activeCampingItems[source].tent) then
        TriggerClientEvent('QBCore:Notify', source, 'You must place a tent first!', 'error')
        return
    end
    if activeCampingItems[source] and activeCampingItems[source].chair then
        TriggerClientEvent('QBCore:Notify', source, 'You already have a chair placed. Pack it up before placing another.', 'error')
        return
    end
    if Player.Functions.GetItemByName('campingchair') then
        Player.Functions.RemoveItem('campingchair')
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['campingchair'], 'remove')
        TriggerClientEvent('camping:client:useChair', source)
    end
end)

QBCore.Functions.CreateUseableItem('campfire', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not (activeCampingItems[source] and activeCampingItems[source].tent) then
        TriggerClientEvent('QBCore:Notify', source, 'You must place a tent first!', 'error')
        return
    end
    if activeCampingItems[source] and activeCampingItems[source].campfire then
        TriggerClientEvent('QBCore:Notify', source, 'You already have a campfire placed. Extinguish it before placing another.', 'error')
        return
    end
    if Player.Functions.GetItemByName('campfire') then
        Player.Functions.RemoveItem('campfire')
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['campfire'], 'remove')
        TriggerClientEvent('camping:client:useCampfire', source)
    end
end)


RegisterNetEvent('camping:server:SpawnTent', function(coords, heading)
    local src = source
    if activeCampingItems[src] and activeCampingItems[src].tent then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a tent active!', 'error')
        return
    end
    TriggerClientEvent('camping:client:SpawnTent', src, coords, heading)
    activeCampingItems[src] = activeCampingItems[src] or {}
    activeCampingItems[src].tent = true
end)


RegisterNetEvent('camping:server:SpawnChair', function(coords, heading)
    local src = source
    if not (activeCampingItems[src] and activeCampingItems[src].tent) then
        TriggerClientEvent('QBCore:Notify', src, 'You must place a tent first!', 'error')
        return
    end
    if activeCampingItems[src] and activeCampingItems[src].chair then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a chair active!', 'error')
        return
    end
    TriggerClientEvent('camping:client:SpawnChair', src, coords, heading)
    activeCampingItems[src] = activeCampingItems[src] or {}
    activeCampingItems[src].chair = true
end)


RegisterNetEvent('camping:server:SpawnCampfire', function(coords, heading)
    local src = source
    if not (activeCampingItems[src] and activeCampingItems[src].tent) then
        TriggerClientEvent('QBCore:Notify', src, 'You must place a tent first!', 'error')
        return
    end
    if activeCampingItems[src] and activeCampingItems[src].campfire then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a campfire active!', 'error')
        return
    end
    TriggerClientEvent('camping:client:SpawnCampfire', src, coords, heading)
    activeCampingItems[src] = activeCampingItems[src] or {}
    activeCampingItems[src].campfire = true
end)


RegisterNetEvent('camping:server:RemoveActiveItem', function(itemType)
    local src = source
    if activeCampingItems[src] and activeCampingItems[src][itemType] then
        activeCampingItems[src][itemType] = nil
    end
end)


AddEventHandler('playerDropped', function()
    local src = source
    if activeCampingItems[src] then
        for itemType, _ in pairs(activeCampingItems[src]) do
            TriggerClientEvent('camping:client:DeleteEntity', -1, itemType)
        end
        activeCampingItems[src] = nil
    end
end)


RegisterNetEvent('camping:server:OpenStash', function()
    local src = source
    local playerID = GetPlayerIdentifiers(src)[1]
    local lockerID = "Tent_" .. playerID
    exports['qs-inventory']:RegisterStash(src, lockerID, 5, 5000)
end)
