local QBCore = exports['qb-core']:GetCoreObject()
local activeCampingItems = {} -- Tracks active campfire, tent, and chair per player
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

-- Useable Items
QBCore.Functions.CreateUseableItem('tent', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    
    -- Check if the player already has an active tent
    if activeCampingItems[source] and activeCampingItems[source].tent then
        TriggerClientEvent('QBCore:Notify', source, 'You already have a tent placed. Pack it up before placing another.', 'error')
        return
    end

    -- Remove item and trigger tent placement
    if Player.Functions.GetItemByName('tent') then
        Player.Functions.RemoveItem('tent')
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['tent'], 'remove')
        TriggerClientEvent('camping:client:useTent', source)
    end
end)

QBCore.Functions.CreateUseableItem('campingchair', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    -- First, ensure the tent is placed before allowing a chair
    if not (activeCampingItems[source] and activeCampingItems[source].tent) then
        TriggerClientEvent('QBCore:Notify', source, 'You must place a tent first!', 'error')
        return
    end
    
    -- Check if the player already has an active chair
    if activeCampingItems[source] and activeCampingItems[source].chair then
        TriggerClientEvent('QBCore:Notify', source, 'You already have a chair placed. Pack it up before placing another.', 'error')
        return
    end

    -- Remove item and trigger chair placement
    if Player.Functions.GetItemByName('campingchair') then
        Player.Functions.RemoveItem('campingchair')
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['campingchair'], 'remove')
        TriggerClientEvent('camping:client:useChair', source)
    end
end)

QBCore.Functions.CreateUseableItem('campfire', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    -- First, ensure the tent is placed before allowing a campfire
    if not (activeCampingItems[source] and activeCampingItems[source].tent) then
        TriggerClientEvent('QBCore:Notify', source, 'You must place a tent first!', 'error')
        return
    end

    -- Check if the player already has an active campfire
    if activeCampingItems[source] and activeCampingItems[source].campfire then
        TriggerClientEvent('QBCore:Notify', source, 'You already have a campfire placed. Extinguish it before placing another.', 'error')
        return
    end

    -- Remove item and trigger campfire placement
    if Player.Functions.GetItemByName('campfire') then
        Player.Functions.RemoveItem('campfire')
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['campfire'], 'remove')
        TriggerClientEvent('camping:client:useCampfire', source)
    end
end)

-- Spawn a tent
RegisterNetEvent('camping:server:SpawnTent', function(coords, heading)
    local src = source

    -- Prevent spawning if a tent already exists
    if activeCampingItems[src] and activeCampingItems[src].tent then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a tent active!', 'error')
        return
    end

    -- Notify client to spawn the new tent
    TriggerClientEvent('camping:client:SpawnTent', src, coords, heading)
    activeCampingItems[src] = activeCampingItems[src] or {}
    activeCampingItems[src].tent = true -- Track the active tent
end)

-- Spawn a chair
RegisterNetEvent('camping:server:SpawnChair', function(coords, heading)
    local src = source

    -- Double-check: ensure a tent is active
    if not (activeCampingItems[src] and activeCampingItems[src].tent) then
        TriggerClientEvent('QBCore:Notify', src, 'You must place a tent first!', 'error')
        return
    end

    -- Prevent spawning if a chair already exists
    if activeCampingItems[src] and activeCampingItems[src].chair then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a chair active!', 'error')
        return
    end

    -- Notify client to spawn the new chair
    TriggerClientEvent('camping:client:SpawnChair', src, coords, heading)
    activeCampingItems[src] = activeCampingItems[src] or {}
    activeCampingItems[src].chair = true -- Track the active chair
end)

-- Spawn a campfire
RegisterNetEvent('camping:server:SpawnCampfire', function(coords, heading)
    local src = source

    -- Double-check: ensure a tent is active
    if not (activeCampingItems[src] and activeCampingItems[src].tent) then
        TriggerClientEvent('QBCore:Notify', src, 'You must place a tent first!', 'error')
        return
    end

    -- Prevent spawning if a campfire already exists
    if activeCampingItems[src] and activeCampingItems[src].campfire then
        TriggerClientEvent('QBCore:Notify', src, 'You already have a campfire active!', 'error')
        return
    end

    -- Notify client to spawn the new campfire
    TriggerClientEvent('camping:client:SpawnCampfire', src, coords, heading)
    activeCampingItems[src] = activeCampingItems[src] or {}
    activeCampingItems[src].campfire = true -- Track the active campfire
end)

-- Remove active item when packed up
RegisterNetEvent('camping:server:RemoveActiveItem', function(itemType)
    local src = source
    if activeCampingItems[src] and activeCampingItems[src][itemType] then
        activeCampingItems[src][itemType] = nil
    end
end)

-- Cleanup on disconnect
AddEventHandler('playerDropped', function()
    local src = source
    if activeCampingItems[src] then
        -- Clean up all active items
        for itemType, _ in pairs(activeCampingItems[src]) do
            TriggerClientEvent('camping:client:DeleteEntity', -1, itemType)
        end
        activeCampingItems[src] = nil
    end
end)

-- Register stash event
RegisterNetEvent('camping:server:OpenStash', function()
    local src = source
    local playerID = GetPlayerIdentifiers(src)[1]
    local lockerID = "Tent_" .. playerID

    -- Register the stash with qs-inventory
    exports['qs-inventory']:RegisterStash(src, lockerID, 5, 5000) -- 5 slots, 5000 max weight (example values)
end)
