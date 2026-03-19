-- Get secret health values
local function GetHealthColor(unitName, maxPercent)
    local curveHealth = C_CurveUtil.CreateColorCurve();
    curveHealth:SetType(Enum.LuaCurveType.Step);
    curveHealth:AddPoint(0, CreateColor(1, 1, 1, 0)); -- hidden
    if maxPercent < 3 then
        curveHealth:AddPoint(max(0, maxPercent / 10), CreateColor(1, 0, 0, 1)); -- red
    end
    if maxPercent < 6 then
        curveHealth:AddPoint(max(0.3, maxPercent / 10), CreateColor(1, 0.6, 0, 0.8));  -- orange
    end
    if maxPercent < 9 then
        curveHealth:AddPoint(max(0.6, maxPercent / 10), CreateColor(1, 1, 0, 0.6));  -- yellow
    end
    if IsResting() then
        curveHealth:AddPoint(0.9, CreateColor(0.8, 0.6, 1, 1))
    else
        curveHealth:AddPoint(0.9, CreateColor(0, 1, 0, 0.4));  -- green
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
        UpdateHealthTextureUsingPercent(unitName, fill, maxPercent)

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

        local regEvents = AptoUI.HUD.PlayerHealthUpdateEvents
        for _, eventName in ipairs(regEvents) do
            frame:RegisterEvent(eventName)
        end

        UpdateHealthTextureUsingPercent(unitName, fill, maxPercent)
    end
end
