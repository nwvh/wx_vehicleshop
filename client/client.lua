function OpenShop(label, category, spawnpoint)
    local opt = {}
    if not wx.Categories[category] then
        return error(("Attempted to open unregistered shop category (%s) from shop: %s"):format(category, label))
    end
    for _, vehicle in pairs(wx.Categories[category]) do
        table.insert(opt, {
            title = wx.FormatVehicleName(GetDisplayNameFromVehicleModel(vehicle.model) or vehicle.model),
            description = ("Price: $%s\nClick to show more info or purchase"):format(wx.FormatPrice(vehicle.price)),
            image = wx.GetVehicleImage(tostring(GetDisplayNameFromVehicleModel(vehicle.model)):lower()),
            menu = ("vehicle_%s"):format(GetDisplayNameFromVehicleModel(vehicle.model):lower())
            -- metadata = {
            --     {
            --         label = "Price",
            --         value = ("$%s"):format(wx.FormatPrice(vehicle.price))
            --     },
            -- }
        })
        lib.registerContext({
            title = wx.FormatVehicleName(GetDisplayNameFromVehicleModel(vehicle.model) or vehicle.model),
            id = ("vehicle_%s"):format(GetDisplayNameFromVehicleModel(vehicle.model):lower()),
            options = {
                {
                    title = "Purchase Vehicle",
                    icon = "cart-shopping",
                    description = ("Purchase for $%s"):format(wx.FormatPrice(vehicle.price)),
                    onSelect = function()
                        local method = lib.inputDialog("Payment method", {
                            {
                                type = 'select',
                                label = "Please select your preferred payment method",
                                options = {
                                    { value = 'money', label = "Cash" },
                                    { value = 'bank',  label = "Bank" },
                                }
                            },
                        })
                        if not method then return end
                        if method[1] == "money" then
                            if wx.GetItemCount("money") < vehicle.price then
                                return wx.Notify("You don't have enough cash on you!", "error")
                            end
                        end
                        local confirm = lib.alertDialog({
                            header = 'Confirmation',
                            content = ('Are you sure you want to purchase %s for $%s?'):format(
                                wx.FormatVehicleName(GetDisplayNameFromVehicleModel(vehicle.model) or vehicle.model),
                                wx.FormatPrice(vehicle.price)),
                            centered = true,
                            cancel = true,
                            labels = {
                                confirm = "Yes",
                                cancel = "No, take me back!"
                            }
                        })
                        if confirm == "confirm" then
                            local edits = lib.alertDialog({
                                header = 'Confirmation',
                                content = "Would you like to customize your vehicle before purchasing?",
                                centered = true,
                                cancel = true,
                                labels = {
                                    confirm = "Yes",
                                    cancel = "No, thank you"
                                }
                            })
                            if edits == "confirm" then
                                local customization = lib.inputDialog('Customize your new vehicle', {
                                    { type = 'input', label = 'License plate text', description = 'Customize your license plate (+ 5000$)', required = false, min = 3, max = 8, disabled = (wx.GetItemCount("money") < vehicle.price + 5000) },
                                    { type = 'color', label = 'Vehicle Color',      default = '#eb4034' },
                                })
                                if customization then
                                    local r, g, b = lib.math.hextorgb(tostring(customization[2]))
                                    local purchasedVehicle = wx.SpawnVehicle(vehicle.model, vec3(spawnpoint), {
                                        color = { r or 0, g or 0, b or 0 }
                                    })
                                    SetEntityHeading(purchasedVehicle, spawnpoint.w)
                                    if customization and customization[1] then
                                        SetVehicleNumberPlateText(purchasedVehicle, tostring(customization[1]))
                                    end
                                    for i = 0, 200 do
                                        if IsPedInVehicle(cache.ped, purchasedVehicle, false) then
                                            break
                                        end
                                        TaskWarpPedIntoVehicle(cache.ped, purchasedVehicle, -1)
                                    end
                                    SetEntityAsNoLongerNeeded(purchasedVehicle)
                                else
                                    local purchasedVehicle = wx.SpawnVehicle(vehicle.model, vec3(spawnpoint), {})
                                    SetEntityHeading(purchasedVehicle, spawnpoint.w)
                                    for i = 0, 200 do
                                        if IsPedInVehicle(cache.ped, purchasedVehicle, false) then
                                            break
                                        end
                                        TaskWarpPedIntoVehicle(cache.ped, purchasedVehicle, -1)
                                    end
                                    SetEntityAsNoLongerNeeded(purchasedVehicle)
                                end
                                -- lib.callback.await("wx_vehicleshop:server:purchaseVehicle", 5000)
                                wx.Notify("Thank you for your purchase, we hope you'll enjoy your new vehicle!",
                                    "success")
                            end
                        end
                    end
                },
                {
                    title = "Test Drive",
                    icon = "car-side",
                    disabled = vehicle.canTestDrive,
                    description = (vehicle.canTestDrive and "This vehicle doesn't allow test drive")
                },
            }
        })
    end
    lib.registerContext({
        title = label,
        id = ("category_%s"):format(category),
        options = opt
    })
    lib.showContext(("category_%s"):format(category))
end

CreateThread(function()
    for i, v in pairs(wx.Locations) do
        local ped = wx.SpawnPed(v.npc, v.coords, {
            freeze = true,
            god = true,
            reactions = false
        })
        exports.ox_target.addLocalEntity(
            _ENV,
            ped,
            {
                {
                    label = ("Open %s"):format(v.label),
                    name = ("wx_vehicleshop:openshop:%s"):format((v.label:gsub(" ", "")):lower()),
                    icon = ("fa-solid fa-%s"):format(v.targetIcon),
                    distance = 2.0,
                    canInteract = function(entity, distance, coords, name, bone)
                        return not IsEntityDead(cache.ped)
                    end,
                    onSelect = function(d)
                        OpenShop(v.label, v.vehicleCategory, v.spawn)
                    end
                },
            }
        )
    end
end)
