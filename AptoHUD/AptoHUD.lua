-- Settings
AptoUI.HUD.PlayerHealthUpdateEvents = {
    "UNIT_HEALTH",
    "UNIT_MAXHEALTH",
    "PLAYER_TARGET_CHANGED",
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_SUCCEEDED",
    "BAG_UPDATE_DELAYED",
    "PLAYER_UPDATE_RESTING"
}
AptoUI.HUD.CastingStartEvents = {
    UNIT_SPELLCAST_START = true,
    UNIT_SPELLCAST_CHANNEL_START = true,
}
AptoUI.HUD.CastingStopEvents = {
    UNIT_SPELLCAST_INTERRUPTED = true,
    UNIT_SPELLCAST_STOP = true,
    UNIT_SPELLCAST_CHANNEL_STOP = true,
    PLAYER_FOCUS_CHANGED = true,
}
AptoUI.HUD.PlayerPowerUpdateEvents = {
    "UNIT_POWER_UPDATE",
    "UNIT_MAXPOWER",
    "PLAYER_TARGET_CHANGED",
}
AptoUI.HUD.PlayerCombatEvents = {
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
}
AptoUI.HUD.HUDAlpha = {
    Main = {
        Combat = .8,
        NoCombat = .2,
        Border = .5,
    },
    Icon = {
        Combat = 1,
        NoCombat = .5,
    },
}
AptoUI.HUD.Textures = {
    HexBottomLeft = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl",
    HexBottomLeftSegments = {
        [1] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-1",
        [2] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-2",
        [3] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-3",
        [4] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-4",
        [5] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-5",
        [6] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-6",
        [7] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-7",
        [8] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-8",
        [9] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-9",
        [10] = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-10",
    },
    HexBottomLeftBorder = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-bl-border",
    HexBottomRight = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-br",
    HexBottomRightBorder = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-br-border",
    HexTop = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-top",
    HexTopBorder = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-512-top-border",
    HexSmallRing = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-64",
    HexSmallFill = "Interface\\AddOns\\AptoHUD\\Textures\\hex-ring-inner-64",
}

-- ----- Apply HUD

local hudHealthFrameRebuildEvents = {
    PLAYER_LOGIN = true,
}
local hudFocusCastingFrameRebuildEvents = {
    PLAYER_LOGIN = true,
    PLAYER_FOCUS_CHANGED = true,
}
local hudPowerFrameRebuildEvents = {
    PLAYER_LOGIN = true,
    UNIT_MAXPOWER = true,
    UPDATE_SHAPESHIFT_FORM = true,
    UPDATE_SHAPESHIFT_FORMS = true,
    PLAYER_TALENT_UPDATE = true,
    UNIT_DISPLAYPOWER = true,
    RUNE_TYPE_UPDATE = true,
}

local frame = CreateFrame("Frame")
for eventName, _ in pairs(hudHealthFrameRebuildEvents) do
    frame:RegisterEvent(eventName)
end
for eventName, _ in pairs(hudPowerFrameRebuildEvents) do
    frame:RegisterEvent(eventName)
end
for eventName, _ in pairs(hudFocusCastingFrameRebuildEvents) do
    frame:RegisterEvent(eventName)
end
for _, eventName in ipairs(AptoUI.HUD.PlayerCombatEvents) do
    frame:RegisterEvent(eventName)
end

local healthFrame = nil
local powerFrame = nil
local powerIcons = nil
local focusCastingFrame = nil

local playerLoggedIn = false

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        playerLoggedIn = true
        PlayerFrame:SetAlpha(0)
    end
    if playerLoggedIn then
        if AptoUI.Utils.isUpdateEvent(hudHealthFrameRebuildEvents, event) then
            -- Health
            if healthFrame then
                AptoUI.Utils.DestroyHUDFrame(healthFrame)
            end
            healthFrame = AptoUI.Utils.CreateHUDFrame("healthFrame")
            AptoUI.HUD.CreateHexSegmentPlayerHP(healthFrame)
        end
        if AptoUI.Utils.isUpdateEvent(hudFocusCastingFrameRebuildEvents, event) then
            -- Focus target casting
            if focusCastingFrame then
                AptoUI.Utils.DestroyHUDFrame(focusCastingFrame)
            end
            focusCastingFrame = AptoUI.Utils.CreateHUDFrame("focusCastingFrame")
            AptoUI.HUD.CreateHexSegmentCasting(focusCastingFrame, "focus")
        end
        if AptoUI.Utils.isUpdateEvent(hudPowerFrameRebuildEvents, event) then
            if powerFrame then
                AptoUI.Utils.DestroyHUDFrame(powerFrame)
            end
            powerFrame = AptoUI.Utils.CreateHUDFrame("powerFrame")
            AptoUI.HUD.CreateHexSegmentPlayerPower(
                powerFrame,
                "primary",
                AptoUI.HUD.Textures.HexBottomRight,
                AptoUI.HUD.Textures.HexBottomRightBorder
            )

            if powerIcons then
                AptoUI.Utils.DestroyHUDFrame(powerIcons)
            end
            powerIcons = AptoUI.Utils.CreateHUDFrame("powerIcons")
            local resources = AptoUI.Utils.GetResourceTypes()
            for resourceType, _ in pairs(resources) do
                if resourceType ~= "primary" then
                    AptoUI.HUD.ResourceIcons(powerIcons, resourceType)
                end
            end
        end
    end
end);
