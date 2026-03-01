AptoUI.CastBar.Config = {
    -- do not reduce width past 225 if using default textures,
    -- this is the min size of the textures Blizzard uses
    -- use the scale option instead and increase the height proportionally
    -- if you want a less-wide cast bar
    width  = 350,
    height = 40,
    alpha  = 0.5,
    textInside = true,
    scale = 0.5
}

local function CustomiseSpark(originalBarHeight, config)
    local spark = PlayerCastingBarFrame.Spark
    local barScaleFactor = config.height / originalBarHeight
    local originalSparkHeight = spark:GetHeight()
    local sparkHeightNew = originalSparkHeight * barScaleFactor * config.scale
    spark:SetHeight(sparkHeightNew)
end

local function CustomiseCastBarSize(bar, barOverlay, config)
    bar:SetWidth(config.width)
    bar:SetHeight(config.height)
    bar:SetAlpha(config.alpha)
    bar:SetScale(config.scale)
    barOverlay:SetWidth(config.width)
    barOverlay:SetHeight(config.height)
    barOverlay:SetAlpha(config.alpha)
    barOverlay:SetScale(config.scale)

    local text = bar.Text or bar.TextLabel or bar.TextString
    if text then
        text:ClearAllPoints()

        if config.textInside then
            text:SetPoint("CENTER", bar, "CENTER", 0, 0)
            text:SetJustifyH("CENTER")
            text:SetJustifyV("MIDDLE")
        else
            text:SetPoint("TOP", bar, "BOTTOM", 0, -2)
        end
        text:SetScale(1 / config.scale)
    end
end

local function CustomiseCarBarBackground(bar, config)
    -- disable background "shadow"
    -- https://github.com/Gethe/wow-ui-source/blob/5e5a1811b2215107dc59172f00394a4aad07f9bf/Interface/AddOns/Blizzard_UIPanels_Game/Mainline/CastingBarFrame.xml#L205
    -- line 205: CastingBarFrameBaseTemplate contains the layers a cast bar is made up of
    -- 2 = background
    for i, region in ipairs({ PlayerCastingBarFrame:GetRegions() }) do
        if i == 2 then
            local tex = region.GetTexture and region:GetTexture()
            if tex then
                region:SetTexture(nil)
                region:Hide()
            end
        end
    end
end

local function CustomiseCastBar()
    local config = AptoUI.CastBar.Config
    local bar = PlayerCastingBarFrame
    local barOverlay = OverlayPlayerCastingBarFrame
    if not bar then return end

    local originalBarHeight = bar:GetHeight()
    CustomiseCastBarSize(bar, barOverlay, config)
    CustomiseCarBarBackground(bar, config)
    CustomiseSpark(originalBarHeight, config)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CVAR_UPDATE")

frame:SetScript("OnEvent", function(self, event, cvar)
    if event == "PLAYER_LOGIN" then
        CustomiseCastBar()

        -- this is to make sure the text gets moved back into the cast bar after edit mode
        hooksecurefunc(PlayerCastingBarFrame, "ApplySystemAnchor", function()
            CustomiseCastBar()
        end)
    -- make sure edits get re-applied after edit mode deactivated
    elseif event == "CVAR_UPDATE" and cvar == "editMode" then
        -- Edit Mode toggled on/off
        C_Timer.After(0.1, function()
            CustomiseCastBar()
        end)
    end
end)
