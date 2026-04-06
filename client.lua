local defaultText = Config.DefaultText or 'Interact'
local defaultKey = Config.DefaultKey or 'E'
local defaultPosition = (Config.Style and Config.Style.position) or 'center-bottom'
local defaultId = 'default'

local activeTextUis = {}

local function normalizeId(id)
    if id == nil or id == '' then
        return defaultId
    end

    return tostring(id)
end

local function SendTextUi(action, data)
    SendNUIMessage({
        action = action,
        data = data or {}
    })
end

local function buildEntry(id, data)
    data = data or {}

    return {
        id = normalizeId(id),
        text = data.text or defaultText,
        key = data.key or defaultKey,
        position = data.position or defaultPosition
    }
end

local function showEntry(id, data)
    local entry = buildEntry(id, data)
    activeTextUis[entry.id] = entry

    SendTextUi('show', entry)
end

local function hideEntry(id)
    local normalizedId = normalizeId(id)

    if not activeTextUis[normalizedId] then
        return
    end

    activeTextUis[normalizedId] = nil

    SendTextUi('hide', {
        id = normalizedId
    })
end

local function updateEntry(id, data)
    local normalizedId = normalizeId(id)
    local current = activeTextUis[normalizedId]

    if not current then
        return
    end

    if data.text ~= nil then
        current.text = data.text
    end

    if data.key ~= nil then
        current.key = data.key
    end

    if data.position ~= nil then
        current.position = data.position
    end

    SendTextUi('update', current)
end

local function DrawText(text, key)
    showEntry(defaultId, {
        text = text,
        key = key,
        position = defaultPosition
    })
end

exports('DrawText', DrawText)

local function ShowTextUI(data)
    if type(data) ~= 'table' then return end

    showEntry(data.id, {
        text = data.text,
        key = data.key,
        position = data.position
    })
end

exports('ShowTextUI', ShowTextUI)

local function HideText(id)
    hideEntry(id)
end

exports('HideText', HideText)

local function UpdateText(text, id)
    updateEntry(id, {
        text = text
    })
end

exports('UpdateText', UpdateText)

local function UpdateKey(key, id)
    updateEntry(id, {
        key = key
    })
end

exports('UpdateKey', UpdateKey)

local function UpdateTextUI(data)
    if type(data) ~= 'table' then return end

    updateEntry(data.id, {
        text = data.text,
        key = data.key,
        position = data.position
    })
end

exports('UpdateTextUI', UpdateTextUI)

local function IsTextUiOpen(id)
    if id ~= nil then
        return activeTextUis[normalizeId(id)] ~= nil
    end

    for _ in pairs(activeTextUis) do
        return true
    end

    return false
end

exports('IsTextUiOpen', IsTextUiOpen)

if Config.UseCommandTest then
    RegisterCommand(Config.TestCommand, function()
        if IsTextUiOpen('stash') or IsTextUiOpen('garage') then
            HideText('stash')
            HideText('garage')
        else
            ShowTextUI({
                id = 'stash',
                text = 'Open stash',
                key = 'E',
                position = 'center-bottom'
            })

        end
    end, false)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    activeTextUis = {}

    SendNUIMessage({
        action = 'forceHide'
    })
end)