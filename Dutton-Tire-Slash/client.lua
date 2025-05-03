local slashing = false

-- Tire Bone Names and their index
local tireBones = {
    {bone = "wheel_lf", index = 0}, -- front left
    {bone = "wheel_rf", index = 1}, -- front right
    {bone = "wheel_lr", index = 4}, -- rear left
    {bone = "wheel_rr", index = 5}, -- rear right
}

RegisterCommand('slashtire', function()
    if slashing then return end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = GetClosestVehicle(coords, 5.0, 0, 70)

    -- Check if holding a knife
    local weapon = GetSelectedPedWeapon(playerPed)
    local knifeWeapons = {
        [`WEAPON_KNIFE`] = true,
        [`WEAPON_SWITCHBLADE`] = true,
        [`WEAPON_DAGGER`] = true
    }

    if not knifeWeapons[weapon] then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"SlashTire", "You must hold a knife to slash tires!"}
        })
        return
    end

    if vehicle ~= 0 then
        slashing = true

        -- Find closest tire
        local closestTire = nil
        local minDistance = 1.5

        for _, tire in ipairs(tireBones) do
            local boneIndex = GetEntityBoneIndexByName(vehicle, tire.bone)
            if boneIndex ~= -1 then
                local tirePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
                local distance = #(coords - tirePos)

                if distance < minDistance then
                    minDistance = distance
                    closestTire = tire.index
                end
            end
        end

        if not closestTire then
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"SlashTire", "You are not close enough to any tire!"}
            })
            slashing = false
            return
        end

        -- Play slash animation and show UI
        RequestAnimDict("melee@knife@streamed_core")
        while not HasAnimDictLoaded("melee@knife@streamed_core") do
            Wait(10)
        end

        -- Show UI progress
        SendNUIMessage({action = 'show'})

        TaskPlayAnim(playerPed, "melee@knife@streamed_core", "ground_attack_on_spot", 8.0, -8.0, -1, 0, 0, false, false, false)

        -- Wait for slashing to complete
        Wait(3000)

        -- Slash the tire
        if not IsVehicleTyreBurst(vehicle, closestTire, false) then
            SetVehicleTyreBurst(vehicle, closestTire, true, 1000.0)
        end

        -- Clear animation and UI
        ClearPedTasks(playerPed)
        SendNUIMessage({action = 'hide'})

        slashing = false
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"SlashTire", "No vehicle nearby!"}
        })
    end
end, false)
