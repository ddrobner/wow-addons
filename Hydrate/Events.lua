local addonName, addon = ...

local events = CreateFrame("Frame", addonName .. "Events", UIParent)
addon.events = events

function events:OnEvent(event, ...)
    if self[event] then
        self[event](self, event, ...)
    end
end

events:SetScript("OnEvent", events.OnEvent)
events:RegisterEvent("ADDON_LOADED")

-- Dispatch events.
function events:ADDON_LOADED(_, name)
    if name ~= addonName then
        return
    end

    self:UnregisterAllEvents()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_FLAGS_CHANGED")
    self:RegisterEvent("ZONE_CHANGED")
end

-- Start reminders once the player is in the game.
function events:PLAYER_ENTERING_WORLD(...)
    addon:StartReminder()
end

-- This is fired when the player enters combat. Reminders should not be shown in
-- combat to avoid distracting the player.
function events:PLAYER_REGEN_DISABLED(...)
    addon.inCombat = true
    addon:CheckReminder()
end

-- This is fired when the player leaves combat. Remindes can be shown again.
function events:PLAYER_REGEN_ENABLED(...)
    addon.inCombat = false
    addon:CheckReminder()
end

-- This is fired when the player AFK or DND flags change state. Reminders should
-- not be shown while the player is AFK or DND as the player is unlikely to
-- respond to them.
function events:PLAYER_FLAGS_CHANGED(...)
    addon:CheckReminder()
end

-- This is fired when the player changes zones. Reminders should not be shown
-- while the player is in an Arean or Battleground.
function events:ZONE_CHANGED(...)
    addon:CheckReminder()
end