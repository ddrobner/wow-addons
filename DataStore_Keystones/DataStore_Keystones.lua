if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    print("DataStore_Keystones does not support Classic WoW")
    return
end

--[[	*** DataStore_Keystones ***
Written by : Teelo, US-Jubei'thos
https://www.patreon.com/teelojubeithos
--]]

if not DataStore then return end
local addonName = "DataStore_Keystones"
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local addon = _G[addonName]

local AddonDB_Defaults = {
	global = {
		Options = {
			NextResetTimestamp = 0,
		},
		Characters = {
			['*'] = {				-- ["Account.Realm.Name"] 
				lastUpdate = nil,
				currentKeystone = {},
				highestKeystoneThisWeek = {},
                
                WeeklyActivities = {
                    ['*'] = { -- id from C_WeeklyRewards.GetActivities
                        progress = 0,
                        level = 0,
                        exampleRewards = {}, -- from C_WeeklyRewards.GetExampleRewardItemHyperlinks
                    }
                },
                
                RunHistory = { -- from C_MythicPlus.GetRunHistory(true, false), so includes previous weeks but not incomplete runs
                    ['*'] = { -- array index, arbitrary
                        mapChallengeModeID = 0,
                        level = 0,
                        thisWeek = false,
                        completed = false, -- should always be false! Will not store incomplete runs.
                    }
                },
			}
		},
	}
}

-- *** Utility functions ***
local function GetOption(option)
	return addon.db.global.Options[option]
end

local function SetOption(option, value)
	addon.db.global.Options[option] = value
end

-- *** Scanning functions ***
local function ScanCurrentKeystoneInfo()
    local char = addon.ThisCharacter
    
    if not C_MythicPlus.GetOwnedKeystoneChallengeMapID() then 
        wipe(char.currentKeystone)
        return 
    end
    
    local name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(C_MythicPlus.GetOwnedKeystoneChallengeMapID())
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    
    if char.currentKeystone.name ~= name then
        -- Keystone has changed since last scan
        char.currentKeystone.name = name
        char.currentKeystone.texture = texture
        char.currentKeystone.keystoneLevel = keyStoneLevel
    end        
    
    char.lastUpdate = time()
end

local function ScanHighestKeystone()
    local char = addon.ThisCharacter
    wipe(char.highestKeystoneThisWeek)
    local maps = C_ChallengeMode.GetMapTable()
    if not maps then return end
    
    local bestTime, bestLevel
    for i = 1, #maps do
		local durationSec, weeklyLevel = C_MythicPlus.GetWeeklyBestForMap(maps[i])
        if weeklyLevel then
            if (not bestTime) or (weeklyLevel > bestLevel) or ((weeklyLevel == bestLevel) and (durationSec < bestTime)) then
                local name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(maps[i])
                char.highestKeystoneThisWeek.name = name
                char.highestKeystoneThisWeek.completionMilliseconds = durationSec * 1000
                char.highestKeystoneThisWeek.level = weeklyLevel
                char.highestKeystoneThisWeek.texture = texture
                char.highestKeystoneThisWeek.backgroundTexture = backgroundTexture
                
                char.lastUpdate = time()
                
                bestTime = durationSec * 1000
                bestLevel = weeklyLevel
            end
        end
    end
    
    char.lastUpdate = time()
end

local function ScanRunHistory()
    addon.ThisCharacter.RunHistory = C_MythicPlus.GetRunHistory(true)
end

local function ScanWeeklyRewards()
    local activities = C_WeeklyRewards.GetActivities()
    
    -- Only save some of the data, and indexed on the id
    local data = {}
    for _, activity in pairs(activities) do
        data[activity.id] = {
            progress = activity.progress,
            level = activity.level,
            exampleRewards = {C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)},
        }
    end
    
    addon.ThisCharacter.WeeklyActivities = data 
end

-- *** Event Handlers ***
local function OnPlayerAlive()
	ScanCurrentKeystoneInfo()
    ScanRunHistory()
    ScanWeeklyRewards()
end

local function OnAffixUpdate()
    ScanHighestKeystone()
    ScanRunHistory()
end

local function OnItemReceived(event, bag)
    if (bag < 0) or (bag >= 5) then
		return
	end
    ScanCurrentKeystoneInfo()
end

local function OnWeeklyRewardsUpdate()
	ScanCurrentKeystoneInfo()
    ScanHighestKeystone()
    ScanRunHistory()
    ScanWeeklyRewards()
end

-- ** MIXINS **

-- *** Keystone Info ***
local function _GetCurrentKeystone(character)
    local keystone = character.currentKeystone
    if not keystone then return nil, nil, nil end    
    return keystone.name, keystone.texture, keystone.keystoneLevel
end

local function _GetHighestKeystone(character)
    local keystone = character.highestKeystoneThisWeek
    if not keystone then return nil, nil, nil, nil, nil end
    return keystone.name, keystone.completionMilliseconds, keystone.level, keystone.texture, keystone.backgroundTexture
end

local function _GetKeystoneRunHistory(character, includePreviousWeeks)
    local history = character.RunHistory
    local result = {}
    
    if includePreviousWeeks then return history end
    
    -- make new array filtering out previous weeks
    local j = 1
    for i, info in pairs(history) do
        if info.thisWeek then
            result[j] = info
            j = j + 1
        end
    end
    
    return result
end

-- Weekly rewards
local function _WeeklyRewards_GetActivities(character)
    local activities = C_WeeklyRewards.GetActivities() -- start with the data provided by the API then replace the character-specific data
    local storedActivities = character.WeeklyActivities
    for i, activityInfo in ipairs(activities) do
        activities[i].progress = storedActivities[activityInfo.id].progress
        activities[i].level = storedActivities[activityInfo.id].level
    end
    return activities
end

local function _WeeklyRewards_GetExampleRewardItemHyperlinks(character, id)
    return unpack(character.WeeklyActivities[id].exampleRewards)
end


-- ** HELPERS **

local function ClearExpiredKeystones()
	if time() > GetOption("NextResetTimestamp") then
    	for key, character in pairs(addon.db.global.Characters) do
            -- wipe current keystone data
    		wipe(character.currentKeystone)
            wipe(character.highestKeystoneThisWeek)
            
            -- set all runs in the M+ run history to not be "this week" anymore
            for i in ipairs(character.RunHistory) do
                character.RunHistory[i].completed = false
            end
            
            -- wipe weekly rewards data
            wipe(character.WeeklyActivities)
    	end
	end
    
    SetOption("NextResetTimestamp", time() + C_DateAndTime.GetSecondsUntilWeeklyReset())
end

local PublicMethods = {
    GetCurrentKeystone = _GetCurrentKeystone,
    GetHighestKeystone = _GetHighestKeystone,
    GetKeystoneRunHistory = _GetKeystoneRunHistory,
    WeeklyRewards_GetActivities = _WeeklyRewards_GetActivities,
    WeeklyRewards_GetExampleRewardItemHyperlinks = _WeeklyRewards_GetExampleRewardItemHyperlinks,
}

function addon:OnInitialize()
	addon.db = LibStub("AceDB-3.0"):New(addonName .. "DB", AddonDB_Defaults)

	DataStore:RegisterModule(addonName, addon, PublicMethods)

	DataStore:SetCharacterBasedMethod("GetCurrentKeystone")
	DataStore:SetCharacterBasedMethod("GetHighestKeystone")
    DataStore:SetCharacterBasedMethod("GetKeystoneRunHistory")
    DataStore:SetCharacterBasedMethod("WeeklyRewards_GetActivities")
    DataStore:SetCharacterBasedMethod("WeeklyRewards_GetExampleRewardItemHyperlinks")
end

function addon:OnEnable()
	addon:RegisterEvent("PLAYER_ALIVE", OnPlayerAlive)
	addon:RegisterEvent("BAG_UPDATE", OnItemReceived)
    addon:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", OnAffixUpdate)
    
	addon:RegisterEvent("WEEKLY_REWARDS_UPDATE", OnWeeklyRewardsUpdate) -- fires when the week ticks over

    ClearExpiredKeystones()
end

function addon:OnDisable()
	addon:UnregisterEvent("PLAYER_ALIVE")
	addon:UnregisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
	addon:UnregisterEvent("BAG_UPDATE")
    addon:UnregisterEvent("WEEKLY_REWARDS_UPDATE")
end
