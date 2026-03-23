local function GetCastProgress(unitName, channelBool)
    local castingFunc = UnitCastingInfo
    if channelBool then
        castingFunc = UnitChannelInfo
    end

    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = castingFunc(unitName)
    if not startTime or not endTime then
        return nil
    end
    if startTime then
        return true
    else
        return nil
    end
end

local function StopUpdating(textureFrame)
    textureFrame:SetScript("OnUpdate", nil)
    textureFrame.fill:SetVertexColor(1, 1, 1, 0)
end

local function UpdateCastingTexture(unitName, textureFrame, channelBool)
    textureFrame:SetScript("OnUpdate", function(self)
        local progress = GetCastProgress(unitName, channelBool)
        if not progress then
            StopUpdating(self)
            return
        end
        self.fill:SetVertexColor(1, 1, 1, 1)
    end)
end

function AptoUI.HUD.CreateHexSegmentCasting(parent, unitName)
    if not UnitExists(unitName) then
        return nil
    end

    local frame = CreateFrame("Frame", nil, parent)
    local xSize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
    local ySize = AptoUI.HUD.Size.Main * AptoUI.HUD.Scale.Main
    frame:SetSize(xSize, ySize)
    frame:SetPoint("CENTER", parent, "CENTER", AptoUI.HUD.Offset.X, AptoUI.HUD.Offset.Y)
    frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.NoCombat)

    AptoUI.HUD.CreateBorder(frame, AptoUI.HUD.Textures.HexTopBorder)

    local mask = frame:CreateMaskTexture()
    mask:SetTexture(AptoUI.HUD.Textures.HexTop, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints()

    local fill = frame:CreateTexture(nil, "ARTWORK", nil, 1)
    fill:SetColorTexture(1, 1, 1, 1)
    fill:SetVertexColor(1, 1, 1, 0)
    fill:SetAllPoints()
    fill:AddMaskTexture(mask)
    frame.fill = fill

    frame:SetScript("OnEvent", function(_, event, eventUnit)
        if eventUnit == unitName and AptoUI.HUD.CastingStartEvents[event] then
            local channelBool = false
            if event == UNIT_SPELLCAST_CHANNEL_START then
                channelBool = true
            end
            UpdateCastingTexture(unitName, frame, channelBool)
            return
        end
        if AptoUI.HUD.CastingStopEvents[event] then
            if eventUnit == nil or eventUnit == unitName then
                StopUpdating(frame)
                return
            end
        end

        if eventUnit == unitName then
            if event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
                print(1)
                frame.fill:SetColorTexture(0, 1, 0, 1)
            elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
                print(2)
                frame.fill:SetColorTexture(1, 0, 0, 1)
            end
        end

        if event == "PLAYER_REGEN_DISABLED" then
            frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.Combat)
        elseif event == "PLAYER_REGEN_ENABLED" then
            frame:SetAlpha(AptoUI.HUD.HUDAlpha.Main.NoCombat)
        end
    end)

    for eventName, _ in pairs(AptoUI.HUD.CastingStartEvents) do
        frame:RegisterEvent(eventName)
    end
    for eventName, _ in pairs(AptoUI.HUD.CastingStopEvents) do
        frame:RegisterEvent(eventName)
    end
    for _, eventName in ipairs(AptoUI.HUD.PlayerCombatEvents) do
        frame:RegisterEvent(eventName)
    end
    frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

end
