local addonName, addon = ...

-- The reminder should only be shown when it's not inconvenient to the player. 
local function AllowReminder()
    local inCombat = addon.inCombat
    local inPvP = C_PvP.IsArena() or C_PvP.IsBattleground()
    local isBusy = UnitIsAFK("player") or UnitIsDND("player")
    return not (inCombat or inPvP or isBusy)
end

-- Show the reminder frame if it is not already shown.
local function ShowReminder()
    if addon.reminderFrame:IsShown() then
        return
    end

    PlaySound(addon.reminderSoundkitId)
    addon.reminderFrame.model:SetAnimation(16)
    addon.reminderFrame:Show()
end

-- Determine if the reminder should be hidden or shown. The reminder will only
-- be shown once the next schedule time is met, and the criteria are met to
-- allow the reminder to be shown.
local function UpdateReminder()
    if not AllowReminder() then
        addon.reminderFrame:Hide()
        return
    end

    -- If we haven't hit the timeout yet, do nothing.
    local remainder = addon.nextReminderTime - GetServerTime()
    if remainder > 0 then
        C_Timer.After(remainder, UpdateReminder)
        return
    end

    ShowReminder()
end

-- Set a new time for showing the reminder.
local function ResetReminder()
    addon.nextReminderTime = GetServerTime() + addon.reminderInterval
    UpdateReminder()
end

-- This is called for a variety of events.
function addon:CheckReminder()
    UpdateReminder()
end

-- Starts reminders being shown.
function addon:StartReminder()
    self.reminderFrame.model:SetDisplayInfo(self.reminderDisplayId)
    self.reminderFrame:SetScript("OnHide", ResetReminder)
    ResetReminder()
end