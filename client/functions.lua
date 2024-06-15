---Spawn Vehicle
---@param model string
---@param coords vector4 | vector3
---@param data table
---@return number | integer
function wx.SpawnVehicle(model, coords, data)
    if not data or data == nil then
        data = {
            locked = false,
            color = { 0, 0, 0 }
            ---@todo: more options
        }
    end
    if not IsModelValid(model) then -- Return an error if the vehicle model doesn't exist
        return ("[ERROR] The specified vehicle model - [%s] doesn't exist!"):format(model)
    end
    RequestModel(model)                                             -- Request the vehicle model
    while not HasModelLoaded(model) do Wait(5) end                  -- Wait for the vehicle to load
    local spawnedvehicle = CreateVehicle(model, coords, true, true) -- Finally spawn the vehicle
    if data.locked then
        SetVehicleDoorsLocked(spawnedvehicle, 2)
    end
    if data.color then
        SetVehicleCustomPrimaryColour(spawnedvehicle, data.color[1], data.color[2], data.color[3])
    end

    return spawnedvehicle
end

---Simplified function for spawning peds
---@param model string Ped model
---@param coords vector3 | vector4 Coords of the ped
---@param data table
---@return integer
function wx.SpawnPed(model, coords, data)
    if not data then
        data = {
            freeze = false,
            reactions = true,
            god = false,
            scenario = nil
        }
    end
    if not IsModelValid(model) then -- Return an error if the vehicle model doesn't exist
        return ("[ERROR] The specified ped model - [%s] doesn't exist!"):format(model)
    end
    RequestModel(model)                            -- Request the ped model
    while not HasModelLoaded(model) do Wait(5) end -- Wait for the ped to load
    local spawnedped = CreatePed(0, model, coords, false, false)
    if data.freeze then
        FreezeEntityPosition(spawnedped, true)
    end
    if not data.reactions then
        SetBlockingOfNonTemporaryEvents(spawnedped, true)
    end
    if data.god then
        SetEntityInvincible(spawnedped, true)
    end
    if data.anim then
        RequestAnimDict(data.anim[1])
        TaskPlayAnim(spawnedped, data.anim[1], data.anim[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    end
    if data.scenario then
        TaskStartScenarioInPlace(spawnedped, data.scenario, 0, true)
    end
    return spawnedped
end

wx.FormatPrice = function(price)
    return tostring(math.floor(price)):reverse():gsub("(%d%d%d)", "%1,"):gsub(",(%-?)$", "%1"):reverse()
end

wx.GetVehicleImage = function(model)
    return ("https://raw.githubusercontent.com/SrPeterr/okokvehicle-images/main/vehicles-all/%s.png"):format(model)
end

wx.FormatVehicleName = function(vehicle)
    local lower = vehicle:lower()
    local firstLetter = (lower:sub(1, 1)):upper()
    local final = firstLetter .. lower:sub(2)
    return final
end

function wx.GetItemCount(item)
    return lib.callback.await('ox_inventory:getItemCount', false, item)
end

function wx.Notify(message, notifyType)
    return lib.notify({
        title = "Vehicle Shop",
        description = message,
        type = notifyType or "info",
        icon = "car-side"
    })
end
