local combatEvent = "PLAYER_REGEN_DISABLED"
local outOfCombatEvent = "PLAYER_REGEN_ENABLED"
local reloadEvent = "PLAYER_ENTERING_WORLD"
local mStartEvent = "CHALLENGE_MODE_START"
local mEndEvent = "CHALLENGE_MODE_COMPLETED"
local buffCheckEvents = {
    UNIT_AURA = true,
    UPDATE_SHAPESHIFT_FORM = true,
    PLAYER_ALIVE = true,
}

local function CreateBuffReminder(parent, classBuffType, reminderIndex)
    local reminder = CreateFrame("Frame", classBuffType, parent)
    local ySize = 30
    reminder:SetSize(150, ySize)
    reminder:SetPoint("CENTER", parent, "CENTER", 0, reminderIndex * ySize)
    reminder.text = reminder:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    reminder.text:SetPoint("CENTER")
    reminder.text:SetText("Missing buff: " .. classBuffType)
    reminder:Hide()
    return reminder
end

local function ShowBuffReminder(frame, isMissing)
    if isMissing then
        frame:Show()
    else
        frame:Hide()
    end
end

local function HideReminderFrame(frame)
    for eventName, _ in pairs(buffCheckEvents) do
        frame:Hide()
        frame:UnregisterEvent(eventName)
    end
end

local function ShowReminderFrame(frame)
    for eventName, _ in pairs(buffCheckEvents) do
        frame:RegisterEvent(eventName)
    end
end

function AptoUI.Reminders.CreateBuffReminders()
    local class, _ = AptoUI.Utils.GetClassAndSpec()
    local classBuffs = AptoUI.Utils.ClassBuffLookup[class] or {}

    local buffReminderFrame = AptoUI.Utils.CreateHUDFrame(class)

    local reminders = {}
    local reminderIndex = 0
    for classBuffType, _ in pairs(classBuffs) do
        local reminderFrame = CreateBuffReminder(buffReminderFrame, classBuffType, reminderIndex)
        reminders[classBuffType] = reminderFrame
        reminderFrame:RegisterEvent(reloadEvent)
        reminderFrame:RegisterEvent(combatEvent)
        reminderFrame:RegisterEvent(outOfCombatEvent)
        reminderFrame:RegisterEvent(mStartEvent)
        reminderFrame:RegisterEvent(mEndEvent)
        reminderFrame:RegisterEvent(reloadEvent)

        for eventName, _ in pairs(buffCheckEvents) do
            reminderFrame:RegisterEvent(eventName)
        end
        -- we are registering/unregistering events based on combat
        -- because in combat the unit auras are secret,
        -- which means it doesn't work & throws a load of errors
        -- so we might as well just hide the frames in this case
        -- same goes for when m+ is active
        reminderFrame:SetScript("OnEvent", function(self, event, unit)
            local active = C_ChallengeMode.IsChallengeModeActive()
            local inInstance, instanceType = IsInInstance()
            if (
                event == combatEvent
                or event == mStartEvent
                or (event == reloadEvent and active and inInstance)
            ) then
                HideReminderFrame(reminderFrame)
            elseif (
                event == outOfCombatEvent
                or event == mEndEvent
                or (event == reloadEvent and (not active or not inInstance))
            ) then
                ShowReminderFrame(reminderFrame)
            end
            if AptoUI.Utils.isUpdateEvent(buffCheckEvents, event) or event == outOfCombatEvent then
                local isMissing = AptoUI.Utils.HasMissingClassBuff(class)[classBuffType] or false
                ShowBuffReminder(reminderFrame, isMissing)
            end
        end)
        reminderIndex = reminderIndex + 1
    end
    return reminders
end
