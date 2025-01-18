local webhook = Config.Webhook or ""
local PlayerSkins = {}
local getSkin

RegisterNetEvent("texiting:server:getskin", function()
    local src = source
    getSkin = lib.callback.await("texiting:callback:getskin", src)
    PlayerSkins[src] = getSkin
    return PlayerSkins[src]
end)

local function OnPlayerDisconnected(reason, src)
    local reason = reason or "exiting"
    local crds = GetEntityCoords(GetPlayerPed(src))
    local heading = GetEntityHeading(GetPlayerPed(src))
    local id = src
    local identifier = ""
    if Config.UseSteam then
        identifier = GetPlayerIdentifier(src, 0)
    else
        identifier = GetPlayerIdentifier(src, 1)
    end
    TriggerClientEvent("texiting:client:show", -1, id, crds, identifier, reason, PlayerSkins[src], heading)
    if Config.LogSystem then
        SendLog(id, crds, identifier, reason)
    end
end


AddEventHandler("playerDropped", function(reason)
    OnPlayerDisconnected(reason, source)
end)

RegisterCommand('combat', function(source, args, rawcmd)
    local src = source
    OnPlayerDisconnected(args[1], src)
end, false)

function SendLog(id, crds, identifier, reason)
    local name = GetPlayerName(id)
    local date = os.date('*t')
    if date.month < 10 then date.month = '0' .. tostring(date.month) end
    if date.day < 10 then date.day = '0' .. tostring(date.day) end
    if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
    if date.min < 10 then date.min = '0' .. tostring(date.min) end
    if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
    local date = ('' .. date.day .. '.' .. date.month .. '.' .. date.year .. ' - ' .. date.hour .. ':' .. date.min .. ':' .. date.sec .. '')
    local embeds = {
        {
            ["title"] = "Player Disconnected",
            ["type"] = "rich",
            ["color"] = 4777493,
            ["fields"] = {
                {
                    ["name"] = "Identifier",
                    ["value"] = identifier,
                    ["inline"] = true,
                }, {
                ["name"] = "Nickname",
                ["value"] = name,
                ["inline"] = true,
            }, {
                ["name"] = "Player's ID",
                ["value"] = id,
                ["inline"] = true,
            }, {
                ["name"] = "Cordinates",
                ["value"] = "X: " .. crds.x .. ", Y: " .. crds.y .. ", Z: " .. crds.z,
                ["inline"] = true,
            }, {
                ["name"] = "Reason",
                ["value"] = reason,
                ["inline"] = true,
            },
            },
            ["footer"] = {
                ["icon_url"] =
                "https://forum.fivem.net/uploads/default/original/4X/7/5/e/75ef9fcabc1abea8fce0ebd0236a4132710fcb2e.png",
                ["text"] = "Sent: " .. date .. "",
            },
        }
    }
    if webhook == "" then
        return print("Input your webhook in Config")
    end
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
        json.encode({ username = Config.LogBotName, embeds = embeds }), { ['Content-Type'] = 'application/json' })
end


-- RegisterCommand('getskin', function(source, args)
--     local src = source
--     PlayerSkins[src] = GetSkinByCitizenId(56)
--     print(skin)
-- end)

-- function GetSkinByCitizenId(citizenID, model)
--     local query = "SELECT skin FROM playerskins WHERE citizenid = ?"
--     local queryArgs = {citizenID}
--     if model ~= nil then
--         query = query .. " AND model = ?"
--         queryArgs[#queryArgs + 1] = model
--     else
--         query = query .. " AND active = ?"
--         queryArgs[#queryArgs + 1] = 1
--     end
--     return MySQL.scalar.await(query, queryArgs)
-- end