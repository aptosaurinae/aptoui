-- Get secret health values
local function GetHealthColor(unitName, maxPercent)
    local curveHealth = C_CurveUtil.CreateColorCurve();
    curveHealth:SetType(Enum.LuaCurveType.Step);
    local restingColor = CreateColor(0.8, 0.6, 1, 1)
    local redColor = CreateColor(1, 0, 0, 1)
    local orangeColor = CreateColor(1, 0.6, 0, 0.8)
    local yellowColor = CreateColor(1, 1, 0, 0.6)
    local greenColor = CreateColor(0, 1, 0, 0.4)
    local hiddenColor = CreateColor(0, 0, 0, 0)
    curveHealth:AddPoint(0, hiddenColor)
    if IsResting() then
        curveHealth:AddPoint(maxPercent / 10, restingColor)
    elseif maxPercent < 3 then
        curveHealth:AddPoint(maxPercent / 10, redColor)
        curveHealth:AddPoint(0.3, orangeColor)
        curveHealth:AddPoint(0.6, yellowColor)
        curveHealth:AddPoint(0.9, greenColor)
    elseif maxPercent < 6 then
        curveHealth:AddPoint(maxPercent / 10, orangeColor)
        curveHealth:AddPoint(0.6, yellowColor)
        curveHealth:AddPoint(0.9, greenColor)
    elseif maxPercent < 9 then
        curveHealth:AddPoint(maxPercent / 10, yellowColor)
        curveHealth:AddPoint(0.9, greenColor)
    else
        curveHealth:AddPoint(maxPercent / 10, greenColor)
    end
    return UnitHealthPercent(unitName, false, curveHealth)
end

-- Updates the mask based on health values
local function UpdateHealthTextureUsingPercent(unitName, textureItem, maxPercent)
    local color = GetHealthColor(unitName, maxPercent)
    if not color then
        textureItem:Hide()
        return
    end
    textureItem:Show()
    textureItem:SetVertexColor(color:GetRGBA())
end

function AptoUI.HUD.CreateHexSegmentPlayerHP(parent)
    for maxPercent = 1, 10, 1 do
        local frame = CreateFrame("Frame", nil, parent)
        local xSize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
        local ySize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
        frame:SetSize(xSize, ySize)
        frame:SetPoint("CENTER", parent, "CENTER", AptoUI.HUD.Offset.X, AptoUI.HUD.Offset.Y)
        frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.NoCombat)

        if maxPercent == 1 then
            AptoUI.HUD.CreateBorder(frame, AptoUI.HUD.Textures.HexBottomLeftBorder)
        end

        local mask = frame:CreateMaskTexture()
        local maskNumber = maxPercent
        mask:SetTexture(AptoUI.HUD.Textures.HexBottomLeftSegments[maskNumber], "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints()

        local fill = frame:CreateTexture(nil, "ARTWORK", nil, 1)
        fill:SetColorTexture(1, 1, 1, 1)
        fill:SetAllPoints()
        fill:AddMaskTexture(mask)

        local unitName = "player"

        frame:SetScript("OnEvent", function(_, event, eventUnit)
            if eventUnit == unitName then
                UpdateHealthTextureUsingPercent(unitName, fill, maxPercent)
            end
            if event == "PLAYER_REGEN_DISABLED" then
                frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.Combat)
            elseif event == "PLAYER_REGEN_ENABLED" then
                frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.NoCombat)
            end
        end)

        for _, eventName in ipairs(AptoUI.HUD.PlayerHealthUpdateEvents) do
            frame:RegisterEvent(eventName)
        end
        for _, eventName in ipairs(AptoUI.HUD.PlayerCombatEvents) do
            frame:RegisterEvent(eventName)
        end

        UpdateHealthTextureUsingPercent(unitName, fill, maxPercent)
    end
end
