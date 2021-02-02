local addonName = "Altoholic"
local addon = _G[addonName]
local ns = addon.Tabs.Shadowlands

-- from Blizzard_WeeklyRewards.lua

local NUM_COLUMNS = 3;

local UNLOCKED_EFFECT_INFO = { effectID = 102, offsetX = -30, offsetY = -20};

addon:Controller("AltoholicUI.ShadowlandsWeekliesPanel", {
    OnBind = function(self)
    	self:SetUpActivity(RAIDS, "weeklyrewards-background-raid", Enum.WeeklyRewardChestThresholdType.Raid, 1);
    	self:SetUpActivity(MYTHIC_DUNGEONS, "weeklyrewards-background-mythic", Enum.WeeklyRewardChestThresholdType.MythicPlus, 2);
    	self:SetUpActivity(PVP, "weeklyrewards-background-pvp", Enum.WeeklyRewardChestThresholdType.RankedPvP, 3);
    end,
    
    Update = function(self)
        if not DataStore_Keystones then
            self:Hide()
            return
        end
        self:Show()
    end,

    OnShow = function(self)
    	self:Refresh()
    end,

    SetUpActivity = function(self, name, atlas, activityType, rowID)
    	local prevFrame;
    	for i = 1, NUM_COLUMNS do
    		local frame = CreateFrame("FRAME", nil, self, "AltoWeeklyRewardActivityTemplate");
    		if prevFrame then
    			frame:SetPoint("LEFT", prevFrame, "RIGHT", 9, 0);
    		else
    			frame:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 190, (-100*(rowID-1)) - 100);
    		end
    
    		frame.type = activityType;
    		frame.index = i;
    		prevFrame = frame;
    	end
    end,

    GetActivityFrame = function(self, activityType, index)
    	for i, frame in ipairs(self.Activities) do
    		if frame.type == activityType and frame.index == index then
    			return frame;
    		end
    	end
    end,

    Refresh = function(self)
    	local activities = DataStore:WeeklyRewards_GetActivities(ns:GetAltKey())
        if not activities then
            self:Hide()
            return
        end
        
    	for i, activityInfo in ipairs(activities) do
    		local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
    		frame:Refresh(activityInfo);
    	end
    end,
})

addon:Controller("AltoholicUI.ShadowlandsWeekliesActivity", {
    Refresh = function(self, activityInfo)
    	local thresholdString;
    	if activityInfo.type == Enum.WeeklyRewardChestThresholdType.Raid then
    		thresholdString = WEEKLY_REWARDS_THRESHOLD_RAID;
    	elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
    		thresholdString = WEEKLY_REWARDS_THRESHOLD_MYTHIC;
    	elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
    		thresholdString = WEEKLY_REWARDS_THRESHOLD_PVP;
    	end
    	self.Threshold:SetFormattedText(thresholdString, activityInfo.threshold);
    
    	self.unlocked = activityInfo.progress >= activityInfo.threshold;
    	self.info = activityInfo;
    
    	self:SetProgressText();
    
    	local useAtlasSize = true;
    
    	if self.unlocked then
    		self.Border:SetAtlas("weeklyrewards-frame-reward-unlocked", useAtlasSize);
    		self.Threshold:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
    		self.Progress:SetTextColor(GREEN_FONT_COLOR:GetRGB());
    		self.LockIcon:Show();
    		self.LockIcon:SetAtlas("weeklyrewards-icon-unlocked", useAtlasSize);
    		self.Orb:SetAtlas("weeklyrewards-orb-unlocked");
    	else
    		self.Orb:SetAtlas("weeklyrewards-orb-locked");
    		self.Border:SetAtlas("weeklyrewards-frame-reward-locked", useAtlasSize);
    		self.Threshold:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
    		self.Progress:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
    		self.LockIcon:Hide();
    	end
    end,
    
    SetProgressText = function(self, text)
    	local activityInfo = self.info;
    	if text then
    		self.Progress:SetText(text);	
    	elseif self.unlocked then
    		if activityInfo.type == Enum.WeeklyRewardChestThresholdType.Raid then
    			local name = DifficultyUtil.GetDifficultyName(activityInfo.level);
    			self.Progress:SetText(name);
    		elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
    			self.Progress:SetFormattedText(WEEKLY_REWARDS_MYTHIC, activityInfo.level);
    		elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
    			self.Progress:SetText(PVPUtil.GetTierName(activityInfo.level));
    		end
    	else
    		self.Progress:SetFormattedText(GENERIC_FRACTION_STRING, activityInfo.progress, activityInfo.threshold);
    	end
    end,
    
    OnEnter = function(self)
    	if self.unlocked then
    		self:ShowPreviewItemTooltip();		
    	end
    end,
    
    ShowPreviewItemTooltip = function(self)
    	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);
    	GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_CURRENT_REWARD);
    	local itemLink, upgradeItemLink = DataStore:WeeklyRewards_GetExampleRewardItemHyperlinks(ns:GetAltKey(), self.info.id);
    	local itemLevel, upgradeItemLevel;
    	if itemLink then
    		itemLevel = GetDetailedItemLevelInfo(itemLink);
    	end
    	if upgradeItemLink then
    		upgradeItemLevel = GetDetailedItemLevelInfo(upgradeItemLink);
    	end
    	if not itemLevel then
    		GameTooltip_AddErrorLine(GameTooltip, RETRIEVING_ITEM_INFO);
    		self.UpdateTooltip = self.ShowPreviewItemTooltip;
    	else
    		self.UpdateTooltip = nil;
    		if self.info.type == Enum.WeeklyRewardChestThresholdType.Raid then
    			self:HandlePreviewRaidRewardTooltip(itemLevel, upgradeItemLevel);
    		elseif self.info.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
    			self:HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel);
    		elseif self.info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
    			self:HandlePreviewPvPRewardTooltip(itemLevel, upgradeItemLevel);
    		end
    		if not upgradeItemLevel then
    			GameTooltip_AddColoredLine(GameTooltip, WEEKLY_REWARDS_MAXED_REWARD, GREEN_FONT_COLOR);
    		end
    	end
    	GameTooltip:Show();
    end,
    
    HandlePreviewRaidRewardTooltip = function(self, itemLevel, upgradeItemLevel)
    	local currentDifficultyID = self.info.level;
    	local currentDifficultyName = DifficultyUtil.GetDifficultyName(currentDifficultyID);
    	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName));
    	GameTooltip_AddBlankLineToTooltip(GameTooltip);
    	if upgradeItemLevel then
    		local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(currentDifficultyID);
    		if nextDifficultyID then
    			local difficultyName = DifficultyUtil.GetDifficultyName(nextDifficultyID);
    			GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
    			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName));
    		end
    	end
    end,
    
    HandlePreviewMythicRewardTooltip = function(self, itemLevel, upgradeItemLevel)
    	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, itemLevel, self.info.level));
    	GameTooltip_AddBlankLineToTooltip(GameTooltip);
    	if upgradeItemLevel then
    		GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
    		if self.info.threshold == 1 then
    			GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_COMPLETE_MYTHIC_SHORT);
    		else
    			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC, self.info.level + 1, self.info.threshold));
    			local runHistory = DataStore:GetKeystoneRunHistory(ns:GetAltKey())
    			if #runHistory > 0 then
    				GameTooltip_AddBlankLineToTooltip(GameTooltip);
    				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, self.info.threshold));			
    				local comparison = function(entry1, entry2)
    					if ( entry1.level == entry2.level ) then
    						return entry1.mapChallengeModeID < entry2.mapChallengeModeID;
    					else
    						return entry1.level > entry2.level;
    					end
    				end
    				table.sort(runHistory, comparison);
    				for i = 1, self.info.threshold do
    					local runInfo = runHistory[i];
                        if runInfo then
    					   local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID);
    					   GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name));
                        end
    				end
    			end
    		end
    	end
    end,
    
    HandlePreviewPvPRewardTooltip = function(self, itemLevel, upgradeItemLevel)
    	local tierName = PVPUtil.GetTierName(self.info.level);
    	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_PVP, itemLevel, tierName));
    	GameTooltip_AddBlankLineToTooltip(GameTooltip);
    	if upgradeItemLevel then
    		-- All brackets have the same breakpoints, use the first one
    		local tierID = C_PvP.GetPvpTierID(self.info.level, CONQUEST_BRACKET_INDEXES[1]);
    		local tierInfo = C_PvP.GetPvpTierInfo(tierID);
    		local ascendTierInfo = C_PvP.GetPvpTierInfo(tierInfo.ascendTier);
    		if ascendTierInfo then
    			GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
    			local ascendTierName = PVPUtil.GetTierName(ascendTierInfo.pvpTierEnum);
    			if ascendTierInfo.ascendRating == 0 then
    				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_PVP_MAX, ascendTierName, tierInfo.ascendRating));
    			else
    				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_PVP, ascendTierName, tierInfo.ascendRating, ascendTierInfo.ascendRating - 1));
    			end
    		end
    	end
    end,
    
    OnLeave = function(self)
    	self.UpdateTooltip = nil;
    	GameTooltip:Hide();
    end,
})
