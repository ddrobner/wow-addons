local addonName, addon = ...

-- This is the top-level frame for the reminder popup.
addon.reminderFrame = HydrateReminderFrame

-- This is the interval at which reminders are issued, in seconds. The actual
-- time between reminders may be longer if the player is in combat or in some
-- other state inappropriate for reminders.
addon.reminderInterval = 10 * 60

-- This is the next time at which a reminder should be shown.
addon.nextReminderTime = nil

-- This is the soundkit ID of the sound to be played when the popup is shown.
-- This defaults to the raid warning sound.
addon.reminderSoundkitId = 8959

-- This is the display ID of the model to be shown in the popup. This defaults
-- to a water elemental battle pet.
addon.reminderDisplayId = 88619