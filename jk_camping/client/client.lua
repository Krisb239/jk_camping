local prevtent = nil
local prevfire = nil
local campfireZones = {}
local TentZoneId = {}


function SpawnObjectWithGizmo(model, coords, heading, onConfirm, onCancel)
        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
        local gizmoObj = CreateObject(hash, coords.x, coords.y, coords.z, true, false, false)
        SetEntityHeading(gizmoObj, heading)
        SetEntityAsMissionEntity(gizmoObj, true, true)
        exports.object_gizmo:useGizmo(gizmoObj)
        CreateThread(function()
            while true do
                Wait(0)
                if IsControlJustReleased(0, 191) then
                    local finalCoords = GetEntityCoords(gizmoObj)
                    local finalRotation = GetEntityRotation(gizmoObj, 2)
                    DeleteObject(gizmoObj)
                    local realObj = CreateObject(hash, finalCoords.x, finalCoords.y, finalCoords.z, true, false, false)
                    SetEntityAsMissionEntity(realObj, true, true)
                    SetEntityRotation(realObj, finalRotation.x, finalRotation.y, finalRotation.z, 2, true)  
                    FreezeEntityPosition(realObj, true)
                    if onConfirm then
                        onConfirm(realObj, finalCoords, finalRotation)
                    end
                    break
                elseif IsControlJustReleased(0, 73) then
                    DeleteObject(gizmoObj)
                    if onCancel then
                        onCancel()
                    end
                    break
                end
            end
        end)
    end
--------------------------------------------------------------------------------
--  TENT
--------------------------------------------------------------------------------

RegisterNetEvent('camping:client:useTent', function()
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 6.0, 0.0)
    local heading = GetEntityHeading(ped)
    TriggerServerEvent('camping:server:SpawnTent', coords, heading)
end)

RegisterNetEvent('camping:client:SpawnTent', function(coords, heading, lockerID)
    local tentModel = 'ba_prop_battle_tent_02'
    local itemName = 'tent'

    SpawnObjectWithGizmo(tentModel, coords, heading,
        function(realTent, finalCoords, finalHeading)
            exports.ox_target:addLocalEntity(realTent, {
                {
                    name = 'tent_menu',
                    icon = 'fa-solid fa-tent',
                    label = 'Tent Options',
                    onSelect = function()
                        lib.registerContext({
                            id = 'tent_menu',
                            title = 'Tent Options',
                            options = {
                                {
                                    title = 'Pack Tent',
                                    icon = 'fa-solid fa-box',
                                    onSelect = function()
                                        TriggerServerEvent("camping:server:GiveItem", itemName, 1)
                                        TriggerServerEvent('camping:server:RemoveActiveItem', 'tent')
                                        DeleteObject(realTent)
                                        lib.notify({
                                            title = 'Camping',
                                            description = 'Tent removed.',
                                            type = 'success'
                                        })
                                    end
                                },
                                {
                                    title = 'Open Stash',
                                    icon = 'fa-solid fa-tent',
                                    onSelect = function()
                                        TriggerServerEvent('camping:server:OpenStash', lockerID)
                                        lib.notify({
                                            title = 'Camping',
                                            description = 'Stash Opened.',
                                            type = 'success'
                                        })
                                    end
                                }
                            }
                        })
                        lib.showContext('tent_menu')
                    end
                }
            })

            lib.notify({
                title = 'Camping',
                description = 'Tent placed successfully.',
                type = 'success'
            })
        end,
        function() -- onCancel
            lib.notify({
                title = 'Camping',
                description = 'Tent placement cancelled.',
                type = 'error'
            })
        end
    )
end)

RegisterNetEvent('camping:client:OpenTentStash', function()
    TriggerServerEvent('camping:server:OpenTentStash')
end)

--------------------------------------------------------------------------------
--  CAMPFIRE
--------------------------------------------------------------------------------
RegisterNetEvent('camping:client:useCampfire', function()
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local heading = GetEntityHeading(ped)
    TriggerServerEvent('camping:server:SpawnCampfire', coords, heading)
end)

RegisterNetEvent('camping:client:SpawnCampfire', function(coords, heading)
    local campfireModel = 'prop_beach_fire'
    local itemName = 'campfire'

    SpawnObjectWithGizmo(campfireModel, coords, heading,
        function(realCampfire, finalCoords)
            local x, y, z = table.unpack(finalCoords)
            SetEntityCoords(realCampfire, x, y, z, false, false, false, false)


            local zoneName = 'campfire_menu_' .. realCampfire
            local zoneId = exports.ox_target:addSphereZone({
                coords = vector3(x, y, z),
                radius = 1.0,
                debug = false,
                name = zoneName,
                options = {
                    {
                        name = 'campfire_menu',
                        icon = 'fa-solid fa-fire',
                        label = 'Campfire Options',
                        onSelect = function()
                            lib.registerContext({
                                id = 'campfire_menu',
                                title = 'Campfire Options',
                                options = {
                                    {
                                        title = 'Cook',
                                        icon = "fa-solid fa-utensils",
                                        onSelect = function()
                                            ShowRecipeMenu()
                                        end
                                    },
                                    {
                                        title = 'Extinguish Campfire',
                                        icon = 'fa-solid fa-water',
                                        onSelect = function()
                                            TriggerServerEvent("camping:server:GiveItem", itemName, 1)
                                            TriggerServerEvent('camping:server:RemoveActiveItem', 'campfire')
                                            DeleteObject(realCampfire)
                                            exports.ox_target:removeZone(zoneName)
                                            lib.notify({
                                                title = 'Camping',
                                                description = 'Campfire extinguished.',
                                                type = 'success'
                                            })
                                        end
                                    }
                                }
                            })
                            lib.showContext('campfire_menu')
                        end
                    }
                }
            })


            table.insert(campfireZones, zoneId)

    
            CreateThread(function()
                while DoesEntityExist(realCampfire) do
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    if #(playerCoords - vector3(x, y, z)) < 2.0 then
                        -- Make player fireproof near the campfire
                        SetEntityProofs(PlayerPedId(), false, true, false, false, false, false, false, false)
                    else
                        SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
                    end
                    Wait(500)
                end
                SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
            end)

            lib.notify({
                title = 'Camping',
                description = 'Campfire placed successfully.',
                type = 'success'
            })
        end,
        function()
            lib.notify({
                title = 'Camping',
                description = 'Campfire placement cancelled.',
                type = 'error'
            })
        end
    )
end)


--------------------------------------------------------------------------------
--  CHAIR
--------------------------------------------------------------------------------

RegisterNetEvent('camping:client:useChair', function()
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local heading = GetEntityHeading(ped)
    TriggerServerEvent('camping:server:SpawnChair', coords, heading)
end)

RegisterNetEvent('camping:client:SpawnChair', function(coords, heading)
    local chairModel = 'prop_skid_chair_01'
    local itemName   = 'campingchair'

    SpawnObjectWithGizmo(chairModel, coords, heading,
        function(realChair, finalCoords, finalRotation)
            SetEntityCoords(realChair, finalCoords.x, finalCoords.y, finalCoords.z, false, false, false, false)
            SetEntityRotation(realChair, finalRotation.x, finalRotation.y, finalRotation.z, 2, true)

       
            exports.ox_target:addLocalEntity(realChair, {
                {
                    name  = 'chair_menu',
                    icon  = 'fa-solid fa-box',
                    label = 'Pack Chair',
                    onSelect = function()
                        DeleteObject(realChair)
                        TriggerServerEvent('camping:server:RemoveActiveItem', 'chair')
                        TriggerServerEvent('camping:server:GiveItem', itemName, 1)

                        lib.notify({
                            title       = 'Camping',
                            description = 'Chair removed.',
                            type        = 'success'
                        })
                    end
                }
            })

            lib.notify({
                title       = 'Camping',
                description = 'Chair placed successfully.',
                type        = 'success'
            })
        end,
        function()
            lib.notify({
                title       = 'Camping',
                description = 'Chair placement cancelled.',
                type        = 'error'
            })
        end
    )
end)



RegisterNetEvent('camping:client:DeleteEntity', function(entity)
    if DoesEntityExist(entity) then
        DeleteObject(entity)
    end
end)

function CookRecipe(recipe)
    lib.progressBar({
        duration = recipe.cookTime or 5000,
        label = "Cooking " .. recipe.title .. "...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
        },
        anim = { 
            dict = "amb@world_human_gardener_plant@male@base", 
            clip = "base", 
            flag = 1 
        },
    }, function(canceled)
        print("ProgressBar Callback Triggered. Canceled: ", canceled)

        if not canceled then
            print("Triggering GiveItem Event: ", recipe.itemName, recipe.itemAmount or 1)
            TriggerServerEvent('camping:server:GiveItem', recipe.itemName, recipe.itemAmount or 1)
            lib.notify({
                title = 'Cooking',
                description = 'You successfully cooked ' .. recipe.title .. '!',
                type = 'success'
            })
        else
            lib.notify({
                title = 'Cooking',
                description = 'Cooking was canceled.',
                type = 'error'
            })
        end
    end)
end


function ShowRecipeMenu()
    local recipeOptions = {}
    for _, recipe in ipairs(Config.Recipes) do
        table.insert(recipeOptions, {
            title = recipe.title,
            icon = recipe.icon,
            description = "Requires: " .. GetRequirementsText(recipe.requiredItems),
            onSelect = function()
                TriggerServerEvent('camping:server:CheckRequiredItems', recipe.requiredItems, 'camping:client:StartCooking')

                RegisterNetEvent('camping:client:StartCooking', function(hasAllItems)
                    if hasAllItems then
                        TriggerServerEvent('camping:server:RemoveItems', recipe.requiredItems)
                        CookRecipe(recipe)
                        TriggerServerEvent('camping:server:GiveItem', recipe.itemName, recipe.itemAmount or 1)
                    else
                        lib.notify({
                            title = 'Cooking',
                            description = 'You are missing required items.',
                            type = 'error'
                        })
                    end
                end)
            end
        })
    end

    lib.registerContext({
        id = 'cook_recipes_menu',
        title = 'Available Recipes',
        options = recipeOptions
    })
    lib.showContext('cook_recipes_menu')
end


function GetRequirementsText(requiredItems)
    local textParts = {}
    for _, item in ipairs(requiredItems) do
        table.insert(textParts, item.amount .. "x " .. item.name)
    end
    return table.concat(textParts, ", ")
end


    return table.concat(textParts, ", ")
end
