-- powerType is the number of power type e.g. Enum.PowerType.Energy which is the same as 3
-- resourceType is "primary", "secondary", etc and gets looked up from Utils/ClassResources

-- Retrieve the type of resource that counts as primary / secondary for this class/spec
local function GetResources(resourceType)
    local powerType, startsAtZero = AptoUI.Utils.GetPowerType(resourceType)
    return powerType, startsAtZero
end

-- Get secret power values
local function GetPowerPercent(unitName, resourceType)
    local powerType, startsAtZero = GetResources(resourceType)
    if powerType == nil then
        return nil
    end
    local curveType = CurveConstants.ZeroToOne
    -- if startsAtZero then
    --     local curveType = CurveConstants.ZeroToOne
    -- else
    --     local curveType = CurveConstants.Reverse
    -- end
    local perc1 = UnitPowerPercent(unitName, powerType, false, curveType)
    return perc1
end

-- Updates the mask based on power values
-- PowerBarColor is a Blizzard lookup
local function UpdatePowerTextureUsingPercent(unitName, textureItem, resourceType)
    local powerType = GetResources(resourceType)
    local colour = PowerBarColor[powerType] or {r = 1, g = 1, b = 1}
    local perc1 = GetPowerPercent(unitName, resourceType)
    if not perc1 then
        textureItem:Hide()
        return
    end
    textureItem:Show()
    textureItem:SetVertexColor(colour.r, colour.g, colour.b, perc1)
end

function AptoUI.HUD.CreateHexSegmentPlayerPower(parent, resourceType, texturePath, textureBorderPath)
    if not AptoUI.HUD.powerHUDPersistentAlpha then
        AptoUI.HUD.powerHUDPersistentAlpha = AptoUI.HUD.HUDAlpha.Main.NoCombat
    end
    local frame = CreateFrame("Frame", nil, parent)
    local xSize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
    local ySize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
    frame:SetSize(xSize, ySize)
    frame:SetPoint("CENTER", parent, "CENTER", AptoUI.HUD.Offset.X, AptoUI.HUD.Offset.Y)
    frame:SetAlpha(AptoUI.HUD.powerHUDPersistentAlpha)

    AptoUI.HUD.CreateBorder(frame, textureBorderPath)

    local mask = frame:CreateMaskTexture()
    mask:SetTexture(texturePath, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints()

    local fill = frame:CreateTexture(nil, "ARTWORK")
    fill:SetColorTexture(1, 1, 1, 1)
    fill:SetAllPoints()
    fill:AddMaskTexture(mask)

    local unitName = "player"
    UpdatePowerTextureUsingPercent(unitName, fill, resourceType)

    frame:SetScript("OnEvent", function(_, event, eventUnit)
        if eventUnit == unitName then
            UpdatePowerTextureUsingPercent(unitName, fill, resourceType)
        end
        if event == "PLAYER_REGEN_DISABLED" then
            frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.Combat)
            AptoUI.HUD.powerHUDPersistentAlpha = AptoUI.HUD.HUDAlpha.Main.Combat
        elseif event == "PLAYER_REGEN_ENABLED" then
            frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.NoCombat)
            AptoUI.HUD.powerHUDPersistentAlpha = AptoUI.HUD.HUDAlpha.Main.NoCombat
        end
    end)

    local regEvents = AptoUI.HUD.PlayerPowerUpdateEvents
    for _, eventName in ipairs(regEvents) do
        frame:RegisterEvent(eventName)
    end

    UpdatePowerTextureUsingPercent(unitName, fill, resourceType)
    return frame
end

-- Specific power handling

-- Runes for death knights
-- GetRuneCooldown is Blizzard function
local function GetRuneOffCooldownCount()
    local maxRunes = UnitPowerMax("player", Enum.PowerType.Runes)
    local currentRunes = 0
    for i = 1, maxRunes do
        local start, duration, available = GetRuneCooldown(i)
        if available then
            currentRunes = currentRunes + 1
        end
    end
    return currentRunes, maxRunes
end

-- Supercharged combo points have their own system
-- GetUnitChargedPowerPoints is a Blizzard function returning a table with
-- index numbers of each charged combo point
-- UnitPowerMax is a Blizzard function
local function GetSuperchargedComboPoints()
    local chargedIndices = GetUnitChargedPowerPoints("player")
    local chargeCount = 0
    if type(chargedIndices) == "table" then
        for _, idx in ipairs(chargedIndices) do
            chargeCount = chargeCount + 1
        end
    end
    return chargeCount, UnitPowerMax("player", Enum.PowerType.ComboPoints)
end

-- returns current and max resource count
-- UnitPower and UnitPowerMax are Blizzard functions
local function GetResourceCount(resourceType)
    local powerType = AptoUI.Utils.GetPowerType(resourceType)
    return UnitPower("player", powerType), UnitPowerMax("player", powerType)
end

-- there should probably be more special cases in here for other specs
-- but i don't play most of them
-- e.g. Stagger, Tip of the Spear
local resourceHandlers = {
    primary = { func = GetResourceCount, args = { "primary" } },
    secondary = { func = GetResourceCount, args = { "secondary" } },
    rogue_charged = { func = GetSuperchargedComboPoints, args = {} },
    dk_runes = { func = GetRuneOffCooldownCount, args = {} },
}

local function ResourceGetter(resourceType)
    local entry = resourceHandlers[resourceType]
    if not entry then return nil end
    return entry.func(unpack(entry.args))
end

local function UpdatePowerTextureUsingCount(iconNumber, unitName, textureItem, resourceType)
    local powerType = GetResources(resourceType)
    local powerCount, _ = ResourceGetter(resourceType)
    -- mid grey
    local colour = {r = 0.5, g = 0.5, b = 0.5}
    local alpha = 0
    if resourceType == "secondary" or resourceType == "dk_runes" then
        alpha = 0.25
    end
    -- if we get an error trying to get the power value (such as for a brief moment as combat starts)
    -- we want to just skip updating for a moment.
    local noError, err = pcall(function()
        if type(powerCount) == "number" then
            if powerCount >= iconNumber then
                colour = AptoUI.Utils.GetPowerColour(powerType)
                alpha = 1
            end
        end
    end)

    textureItem:Show()
    textureItem:SetVertexColor(colour.r, colour.g, colour.b, alpha)
end

function AptoUI.HUD.ResourceIcons(parent, resourceType)
    if not AptoUI.HUD.resourceIconsPersistentAlpha then
        AptoUI.HUD.resourceIconsPersistentAlpha = AptoUI.HUD.HUDAlpha.Main.NoCombat
    end
    local _, countMax = ResourceGetter(resourceType)
    if countMax == nil then return nil end
    local frameLayer = 0
    local texturePath = AptoUI.HUD.Textures.HexSmallRing
    if resourceType == "rogue_charged" then
        frameLayer = 1
        texturePath = AptoUI.HUD.Textures.HexSmallFill
    end
    local frames = AptoUI.HUD.IconStrip(parent, countMax, 3, false, frameLayer, texturePath)

    -- link frames to event handlers
    for iconNumber, frameData in ipairs(frames) do
        local unitName = "player"
        local frame = frameData["frame"]
        local fill = frameData["fill"]
        UpdatePowerTextureUsingCount(iconNumber, unitName, fill, resourceType)

        frame:SetScript("OnEvent", function(_, event, eventUnit)
            if eventUnit == unitName or event == "RUNE_POWER_UPDATE" or event == "RUNE_TYPE_UPDATE" then
                UpdatePowerTextureUsingCount(iconNumber, unitName, fill, resourceType)
            end
            if event == "PLAYER_REGEN_DISABLED" then
                frame:SetAlpha(AptoUI.HUD.HUDAlpha.Icon.Combat)
                AptoUI.HUD.resourceIconsPersistentAlpha = AptoUI.HUD.HUDAlpha.Icon.Combat
            elseif event == "PLAYER_REGEN_ENABLED" then
                frame:SetAlpha(AptoUI.HUD.HUDAlpha.Icon.NoCombat)
                AptoUI.HUD.resourceIconsPersistentAlpha = AptoUI.HUD.HUDAlpha.Icon.NoCombat
            end
        end)

        local genericEvents = AptoUI.HUD.PlayerPowerUpdateEvents
        local specificEvents = AptoUI.Utils.GetPowerEvents(GetResources(resourceType))
        for _, eventName in ipairs(genericEvents) do
            frame:RegisterEvent(eventName)
        end
        for _, eventName in ipairs(specificEvents) do
            frame:RegisterEvent(eventName)
        end

        UpdatePowerTextureUsingCount(iconNumber, unitName, fill, resourceType)
    end
    return frames
end
