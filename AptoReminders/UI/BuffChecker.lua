local combatEvent = "PLAYER_REGEN_DISABLED"
local outOfCombatEvent = "PLAYER_REGEN_ENABLED"
local buffCheckEvents = {
    UNIT_AURA = true,
    UPDATE_SHAPESHIFT_FORM = true,
    PLAYER_ALIVE = true,
    PLAYER_ENTERING_WORLD = true,
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

function AptoUI.Reminders.CreateBuffReminders()
    local class, _ = AptoUI.Utils.GetClassAndSpec()
    local classBuffs = AptoUI.Utils.ClassBuffLookup[class] or {}

    local buffReminderFrame = AptoUI.Utils.CreateHUDFrame(class)

    local reminders = {}
    local reminderIndex = 0
    for classBuffType, _ in pairs(classBuffs) do
        local reminderFrame = CreateBuffReminder(buffReminderFrame, classBuffType, reminderIndex)
        reminders[classBuffType] = reminderFrame
        reminderFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        reminderFrame:RegisterEvent(combatEvent)
        reminderFrame:RegisterEvent(outOfCombatEvent)
        for eventName, _ in pairs(buffCheckEvents) do
            reminderFrame:RegisterEvent(eventName)
        end
        -- we are registering/unregistering events based on combat
        -- because in combat the unit auras are secret,
        -- which means it doesn't work & throws a load of errors
        -- so we might as well just hide the frames in this case
        reminderFrame:SetScript("OnEvent", function(self, event, unit)
            if event == combatEvent then
                for eventName, _ in pairs(buffCheckEvents) do
                    reminderFrame:Hide()
                    reminderFrame:UnregisterEvent(eventName)
                end
            elseif event == outOfCombatEvent then
                for eventName, _ in pairs(buffCheckEvents) do
                    reminderFrame:RegisterEvent(eventName)
                end
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
