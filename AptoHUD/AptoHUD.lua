-- Settings
AptoUI.HUD.PlayerHealthUpdateEvents = {
    "UNIT_HEALTH",
    "UNIT_MAXHEALTH",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "PLAYER_TARGET_CHANGED",
    "UNIT_SPELLCAST_SUCCEEDED",
    "BAG_UPDATE_DELAYED",
}
AptoUI.HUD.PlayerPowerUpdateEvents = {
    "UNIT_POWER_UPDATE",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "UNIT_MAXPOWER",
    "PLAYER_TARGET_CHANGED",
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
local combatEvent = "PLAYER_REGEN_DISABLED"
local outOfCombatEvent = "PLAYER_REGEN_ENABLED"
frame:RegisterEvent(combatEvent)
frame:RegisterEvent(outOfCombatEvent)

local healthFrame = nil
local powerFrame = nil
local powerIcons = nil

local playerLoggedIn = false

frame:SetScript("OnEvent", function(self, event)
    -- if event == combatEvent then
    --     PlayerFrame:SetAlpha(0)
    -- end
    -- if event == outOfCombatEvent then
    --     PlayerFrame:SetAlpha(1)
    -- end
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
