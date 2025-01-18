local show3DText = true



RegisterNetEvent('esx:onPlayerLogout', function (xPlayer)
    Wait(2000)
    TriggerServerEvent('texiting:server:getskin')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    print('debugstart')
    TriggerServerEvent('texiting:server:getskin')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Wait(2000)
    TriggerServerEvent('texiting:server:getskin')
  end)

CreateThread(function()
    while true do
        Wait(Config.GetSkinTime)
        TriggerServerEvent('texiting:server:getskin')
    end
end)

SetSkin = function(ped, skn)
    if Config.skin == 'fivem-appearance' then
        exports['fivem-appearance']:setPedAppearance(ped, skn)
    elseif Config.skin == 'illenium-appearance' then
        exports['illenium-appearance']:setPedAppearance(ped, skn)
    elseif Config.skin == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:loadPlayerClothing', skn, ped)
    end
end

lib.callback.register('texiting:callback:getskin', function()
    local playerPed = PlayerPedId()
    return GetSkin(playerPed)
end)

GetSkin = function(playerPed)
    if Config.skin == 'fivem-appearance' then
        return exports['fivem-appearance']:getPedAppearance(playerPed)
    elseif Config.skin == 'illenium-appearance' then
        return exports['illenium-appearance']:getPedAppearance(playerPed)
    elseif Config.skin == 'qb-clothing' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local p = promise.new()
        QBCore.Functions.TriggerCallback('qb-clothing:server:getOutfit', function(skinData)
            p:resolve(skinData)
        end)
        return Citizen.Await(p)
    end
end

function PlayWaveAnimation(ped)
    local dict = Config.Anim.dict
    local anim = Config.Anim.anim
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
end


RegisterNetEvent("texiting:client:show")
AddEventHandler("texiting:client:show", function(id, crds, identifier, reason, skinplayer, heading)
    Display(id, crds, identifier, reason, skinplayer, heading)
end)

function Display(id, crds, identifier, reason, skinplayer, heading)
    local displaying = true
    Citizen.CreateThread(function()
        Wait(Config.DrawingTime)
        displaying = false
    end)
    local spawnedPed = SpawnPedSkin(crds, skinplayer, heading)

    Citizen.CreateThread(function()
        while displaying do
            Wait(1)
            local pcoords = GetEntityCoords(PlayerPedId())
            if GetDistanceBetweenCoords(crds.x, crds.y, crds.z, pcoords.x, pcoords.y, pcoords.z, true) < 15.0 and show3DText then
                DrawText3DSecond(crds.x, crds.y, crds.z + 0.15, "Player Left Game")
                DrawText3D(crds.x, crds.y, crds.z, "ID: " .. id .. " (" .. identifier .. ")\nReason: " .. reason)
            else
                Citizen.Wait(2000)
            end
        end

        if DoesEntityExist(spawnedPed) then
            DeletePed(spawnedPed)
        end
    end)
end

function SpawnPedSkin(coords, skinplayer)
    local playerPed = PlayerPedId()
    local pedAppearance = skinplayer
    if not pedAppearance or not pedAppearance.model then
        print("^1[ERROR] Gagal mengambil data skin!^0")
        return nil
    end

    local modelHash = joaat(pedAppearance.model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end
    local heading = GetEntityHeading(playerPed)
    local clonePed = CreatePed(4, modelHash, coords.x, coords.y, coords.z-1, heading, false, false)
    SetSkin(clonePed, pedAppearance)
    SetEntityAlpha(clonePed, 150, false)
    SetEntityInvincible(clonePed, true)
    FreezeEntityPosition(clonePed, true)
    SetBlockingOfNonTemporaryEvents(clonePed, true)
    SetEntityAsMissionEntity(clonePed, true, true)
    PlayWaveAnimation(clonePed)

    return clonePed
end

function DrawText3DSecond(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.45, 0.45)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(Config.AlertTextColor.r, Config.AlertTextColor.g, Config.AlertTextColor.b, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.45, 0.45)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(Config.TextColor.r, Config.TextColor.g, Config.TextColor.b, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end
