wx = {}

wx.Locations = {
    {
        label = "PDM",
        npc = `a_m_y_business_01`,
        coords = vec4(-34.0331, -1101.2819, 25.4224, 91.1670),
        vehicleCategory = "cars",
        spawn = vec4(-12.6930, -1089.3223, 25.6723, 159.7420),
        testDrive = vec4(-20.5810, -1084.3883, 25.6360, 70.6164),
        targetIcon = "car-side"
    }
}

wx.Categories = {
    ["cars"] = {
        {
            model = `adder`,
            price = 20000,
            canTestDrive = true,
            image = false
        }
    }
}
