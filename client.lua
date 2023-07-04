-- Config --

CodeStudio = {
    Modes = {    -- You can Enable/Disable modes
        SemiAutoMode = true,
        SafetyMode = true
    },
    KeyBinds = {
        Command = 'wep_mode',
        Key = 'H',
        Info_Text = 'Change Weapon Mode'
    },
    Language = {
        auto_mode = 'Auto Mode',
        semi_auto = 'Semi-Auto Mode',
        safety_mode = 'Safety Mode',
    }
}



--- Main Code ---


local shootingEnabled = true
local shootingButtonHeld = false
local Mode = false
local Safety = false
local ammoCount = 0
local click = 0


local function setSafety(ped, weapon)
    Safety = true
    ammoCount = GetAmmoInPedWeapon(ped, weapon)
    SetPedAmmo(ped, weapon, 0)
end

local function restoreAmmo(ped, weapon)
    SetPedAmmo(ped, weapon, ammoCount)
    Safety = false
end

local function semiAuto()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    Mode = true
    if Safety then
        restoreAmmo(ped, weapon)
    end
    while Mode do
        Wait(0)
        if shootingButtonHeld then
            DisablePlayerFiring(PlayerId(), true)
            shootingEnabled = false
        end
        
        if IsDisabledControlJustReleased(0, 24) and shootingButtonHeld then
            DisablePlayerFiring(PlayerId(), false)
            shootingEnabled = true
            shootingButtonHeld = false
        end
    
        if shootingEnabled and IsControlPressed(0, 24) then
            if IsPedShooting(PlayerPedId()) then
                shootingButtonHeld = true
            end
        end
    end
end

local function automaticMode()
    Mode = false
    shootingEnabled = true
    shootingButtonHeld = false
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if Safety then
        restoreAmmo(ped, weapon)
    end
    DisablePlayerFiring(PlayerId(), false)
end

local function safetyMode()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    setSafety(ped, weapon)
    Mode = false
    shootingEnabled = true
    shootingButtonHeld = false
end

local function Notification(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(0, 1)

    -- exports['cs_notification']:Notify({  -- https://codestudio.tebex.io/package/5680775 
    --     title = 'Weapon Mode',
    --     description = msg
    -- })
end


RegisterCommand(CodeStudio.KeyBinds.Command, function()
    if not CodeStudio.Modes.SemiAutoMode and not CodeStudio.Modes.SafetyMode then
        return
    end
    local modeNames = {CodeStudio.Language.semi_auto, CodeStudio.Language.safety_mode, CodeStudio.Language.auto_mode}
    local modes = {semiAuto, safetyMode, automaticMode}
    local modeIndex = click % 3

    if not CodeStudio.Modes.SemiAutoMode then
        modeNames = {CodeStudio.Language.safety_mode, CodeStudio.Language.auto_mode}
        modes = {safetyMode, automaticMode}
        modeIndex = click % 2
    elseif not CodeStudio.Modes.SafetyMode then
        modeNames = {CodeStudio.Language.semi_auto, CodeStudio.Language.auto_mode}
        modes = {semiAuto, automaticMode}
        modeIndex = click % 2
    end
    
    local selectedMode = modes[modeIndex + 1]
    local modeName = modeNames[modeIndex + 1]
    click = click + 1
    if selectedMode then
        Notification(modeName)
        selectedMode()
    end
end)

RegisterKeyMapping(CodeStudio.KeyBinds.Command, CodeStudio.KeyBinds.Info_Text, 'keyboard', CodeStudio.KeyBinds.Key)
