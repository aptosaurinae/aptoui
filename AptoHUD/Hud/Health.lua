-- Get secret health values
local function GetHealthColor(unitName)
    local curveHealth = C_CurveUtil.CreateColorCurve();
    curveHealth:SetType(Enum.LuaCurveType.Step);
    curveHealth:AddPoint(0, CreateColor(1, 0, 0, 1)); -- red
    curveHealth:AddPoint(0.3, CreateColor(1, 0.6, 0, 0.8));  -- orange
    curveHealth:AddPoint(0.6, CreateColor(1, 1, 0, 0.6));  -- yellow
    curveHealth:AddPoint(0.9, CreateColor(0, 1, 0, 0.4));  -- green
    return UnitHealthPercent(unitName, false, curveHealth)
end

-- Updates the mask based on health values
local function UpdateHealthTextureUsingPercent(unitName, textureItem)
    local color = GetHealthColor(unitName)
    if not color then
        textureItem:Hide()
        return
    end
    textureItem:Show()
    textureItem:SetVertexColor(color:GetRGB())
end

function AptoUI.HUD.CreateHexSegmentPlayerHP(parent)
    local frame = CreateFrame("Frame", nil, parent)
    local xSize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
    local ySize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
    frame:SetSize(xSize, ySize)
    frame:SetPoint("CENTER", parent, "CENTER", AptoUI.HUD.Offset.X, AptoUI.HUD.Offset.Y)
    frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.NoCombat)

    AptoUI.HUD.CreateBorder(frame, AptoUI.HUD.Textures.HexBottomLeftBorder)

    local mask = frame:CreateMaskTexture()
    mask:SetTexture(AptoUI.HUD.Textures.HexBottomLeft, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints()

    local fill = frame:CreateTexture(nil, "ARTWORK", nil, 1)
    fill:SetColorTexture(1, 1, 1, 1)
    fill:SetAllPoints()
    fill:AddMaskTexture(mask)

    local unitName = "player"
    UpdateHealthTextureUsingPercent(unitName, fill)

    frame:SetScript("OnEvent", function(_, event, eventUnit)
        if eventUnit == unitName then
            UpdateHealthTextureUsingPercent(unitName, fill)
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

    UpdateHealthTextureUsingPercent(unitName, fill)
    return frame
end
