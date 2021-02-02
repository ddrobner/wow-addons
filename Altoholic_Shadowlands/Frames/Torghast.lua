local addonName = "Altoholic"
local addon = _G[addonName]
local ns = addon.Tabs.Shadowlands

addon:Controller("AltoholicUI.ShadowlandsTorghastPanel", {
    OnBind = function(self)
    end,
    
    Update = function(self)
        self.Row1:Update()
        self.Row2:Update()
        self:Show()
    end,
})

addon:Controller("AltoholicUI.ShadowlandsTorghastLevelRow", {
    OnBind = function(self)
    end,
    
    GetTextureKit = function(self)
        return self.textureKit
    end,
    
    Update = function(self)
        local data = DataStore:GetTorghastData(ns:GetAltKey())
        if not data then self:Hide() return end
        
        -- get the ID'th texture kit that isn't expired
        local name
        local id = self:GetID()
        for textureKit, contents in pairs(data) do
            if contents.name and contents.nextReset and (contents.nextReset > time()) then
                if id > 1 then
                    id = id - 1
                else
                    name = contents.name
                    self.textureKit = textureKit
                    break
                end
            end
        end

        if not name then
            self:Hide()
            return
        end 
        self.Name:SetText(name)
        for i = 1, 8 do
            self["Level"..i]:Update()
        end
        self:Show()
    end,
})

addon:Controller("AltoholicUI.ShadowlandsTorghastLevelPicker", {
    OnBind = function(self)
    end,
    
    Update = function(self)
        local level = self:GetID()
        local data = DataStore:GetTorghastData(ns:GetAltKey())[self:GetParent():GetTextureKit()]
        local status = data.levels[level].status
        
        self.rewards = data.rewards
        
    	self:SetupBase(self:GetParent():GetTextureKit(), self:GetID(), {["Background"] = "jailerstower-wayfinder-tierbackground-%s"})
    	self:SetState(status); 
    	self:SetDifficultyTexture();
    	self:Show(); 
    end,
    
    OnClick = function(self) end,
    
    SetupBase = function(self, textureKit, index, buttonTextureKitRegions)
    	self.Title:SetText(self:GetID())
    	self.Title:Show(); 
    	self.index = index; 
    	if (textureKit and buttonTextureKitRegions) then
    		SetupTextureKitOnRegions(textureKit, self, buttonTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
    	end
    end,

    SetDifficultyTexture = function(self)
    	if(not self.index) then 
    		return; 
    	end 
    	if(self.index == 1) then 
    		self.Icon:SetAtlas("jailerstower-skull-1",true);
    	elseif (self.index == 2) then
    		self.Icon:SetAtlas("jailerstower-skull-2",true);
    	else 
    		self.Icon:SetAtlas("jailerstower-skull-3",true);
    	end 
    end, 

    SetState = function(self, status)
    	local lockedState = status == Enum.GossipOptionStatus.Locked;
    	local completeState = status == Enum.GossipOptionStatus.AlreadyComplete; 
    	self.RewardBanner.BannerDisabled:SetShown(lockedState);
    	self.RewardBanner.Banner:SetShown(not lockedState);
    	self.RewardBanner.Reward.completeState = completeState; 
    	self.RewardBanner.Reward.lockedState = lockedState; 
    	self.RewardBanner.Reward:Init()
    	self.Background:SetDesaturated(lockedState);
    	self.Icon:SetDesaturated(lockedState);  
     
    	local fontColor = HIGHLIGHT_FONT_COLOR; 
    	if(lockedState) then
    		fontColor = LIGHTGRAY_FONT_COLOR;
    	end 
    	self.Title:SetTextColor(fontColor:GetRGB());
    end,
})


local function TorghastLevelPickerRewardSortFunction(firstValue, secondValue)
	return firstValue > secondValue;
end

addon:Controller("AltoholicUI.ShadowlandsTorghastLevelPickerRewardCircle", {
    SetSortedRewards = function(self)
    	local continuableContainer = ContinuableContainer:Create();
    	self.itemRewards = { };
    	self.currencyRewards = { };
    
    	for _, reward in ipairs(self.rewards) do 
    		if	(reward.rewardType == Enum.GossipOptionRewardType.Item) then 
    			local item = Item:CreateFromItemID(reward.id);
    			continuableContainer:AddContinuable(item);
    		else
    			local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(reward.id, reward.quantity); 
    			if (isCurrencyContainer) then 
    				local name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, quantity);
    				table.insert(self.currencyRewards, {id = reward.id, texture = texture, quantity = quantity, quality = quality, name = name, isCurrencyContainer = true, });
    			else 
    				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.id);
    				table.insert(self.currencyRewards, {id = reward.id, texture = currencyInfo.iconFileID, quantity = reward.quantity, quality = currencyInfo.quality, name = currencyInfo.name, isCurrencyContainer = false, });
    			end 
    		end
    	end 
    
    	continuableContainer:ContinueOnLoad(function()
    		for  _, reward in ipairs(self.rewards) do
    			if	(reward.rewardType == Enum.GossipOptionRewardType.Item) then 
    				local name, _, quality, _, _, _, _, _, _, itemIcon = GetItemInfo(reward.id);
    				table.insert(self.itemRewards, {id = reward.id, quality = quality, quantity = reward.quantity, texture = itemIcon, name = name});
    			end
    		end
    		if (self.itemRewards and #self.itemRewards > 1) then
    			table.sort(self.itemRewards, function(a, b) 
    				return TorghastLevelPickerRewardSortFunction(a.quality, b.quality); 
    			end);
    		end 
    		self:RefreshTooltip();
    	end);
    
    	if (self.currencyRewards and #self.currencyRewards > 1) then
    		table.sort(self.currencyRewards, function(a, b) 
    			return TorghastLevelPickerRewardSortFunction(a.quality, b.quality); 
    		end);
    	end 
    end, 

    AddCurrencyToTooltip = function(self, currency, tooltip)
    	if (tooltip) then
    		if currency.isCurrencyContainer then
    			local text = JAILERS_TOWER_CURRENCY_REWARD_CONTAINER:format(currency.texture, currency.name);
    			local color = ITEM_QUALITY_COLORS[currency.quality];
    			tooltip:AddLine(text, color.r, color.g, color.b);
    		else
    			local text = JAILERS_TOWER_CURRENCY_REWARD_FORMAT:format(currency.texture, currency.quantity, currency.name);
    			tooltip:AddLine(text, HIGHLIGHT_FONT_COLOR:GetRGB());
    		end
    	end
    end,

    SetRewardIcon = function(self)
    	if (self.itemRewards and self.itemRewards[1]) then 
    		local texture = select(5, GetItemInfoInstant(self.itemRewards[1].id));
    		self.Icon:SetTexture(texture);
    		return; 
    	end 
    
    	if(self.currencyRewards and self.currencyRewards[1]) then 
    		self.Icon:SetTexture(self.currencyRewards[1].texture);
    	end 
    end, 
    
    Init = function(self)
    	self.rewards = self:GetParent():GetParent().rewards;
    	self.currencyRewards = { };
    	self.itemRewards = { }; 
    
    	local shouldShow = self.completeState or self.lockedState or (not self.lockedState and (self.rewards and #self.rewards > 0)); 
    	local shouldShowRewards = not self.completeState and not self.lockedState; 
    
    	self:SetShown(shouldShow);
    	if (not shouldShow) then 
    		return; 
    	end 
    	
    	self.index = self:GetParent():GetParent().index;
    
    	self.RewardBorder:SetShown(shouldShowRewards);
    	self.Icon:SetShown(shouldShowRewards);
    	self.QuestComplete:SetShown(self.completeState);
    	self.LockedIcon:SetShown(self.lockedState); 
    
    	if(shouldShowRewards) then 
    		self:SetSortedRewards(); 
    		self:SetRewardIcon(); 
    	end 
    
    end, 
    
    OnEnter = function(self)
    	self:RefreshTooltip(); 
    end, 
    
    RefreshTooltip = function(self)
    	if (not self:IsMouseOver()) then 
    		return;
    	end 
    
    	if (self.lockedState) then
    		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
    		local timeLockedError = IsJailersTowerLayerTimeLocked(self.index) -- Don't see a reason to move this to DataStore when it'll be constant across characters
    		if (timeLockedError) then
    			GameTooltip_AddErrorLine(EmbeddedItemTooltip, timeLockedError, true);
    		elseif (UnitInParty("player")) then 
    			GameTooltip_AddErrorLine(EmbeddedItemTooltip, JAILERS_TOWER_LEVEL_PICKER_PARTY_LOCK, true);
    		else 
    			GameTooltip_AddErrorLine(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_LOCKED, true);
    		end 
    		EmbeddedItemTooltip:Show(); 
    		return; 
    	end 
    
    	if(self.completeState) then 
    		EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
    		GameTooltip_AddNormalLine(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_RECIEVED, true)
    		EmbeddedItemTooltip:Show(); 
    		return; 
    	end 
    
    	if (not self.currencyRewards and not self.itemRewards) then 
    		return; 
    	end 
    
    	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");
    	GameTooltip_SetTitle(EmbeddedItemTooltip, JAILERS_TOWER_REWARDS_TITLE, HIGHLIGHT_FONT_COLOR, true);
    
    	for _, currencyReward in ipairs(self.currencyRewards) do 
    		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
    		self:AddCurrencyToTooltip(currencyReward, EmbeddedItemTooltip);
    	end 
    
    	for i, itemReward in ipairs(self.itemRewards) do 
    		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
    		if(i == 1) then 
    			EmbeddedItemTooltip_SetItemByID(EmbeddedItemTooltip.ItemTooltip, itemReward.id)
    		else 
    			local text;
    			if itemReward.quantity > 1 then
    				text = string.format(JAILERS_TOWER_ITEM_REWARD_TOOLTIP_WITH_COUNT_FORMAT, itemReward.texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(itemReward.quantity), itemReward.name);
    			else
    				text = string.format(JAILERS_TOWER_ITEM_REWARD_TOOLTIP_FORMAT, itemReward.texture, itemReward.name);
    			end
    			if text then
    				local color = ITEM_QUALITY_COLORS[itemReward.quality];
    				EmbeddedItemTooltip:AddLine(text, color.r, color.g, color.b);
    			end
    		end
    	end 
    
    	if(self.index and self.index > 1) then 
    		GameTooltip_SetBottomText(EmbeddedItemTooltip, JAILERS_TOWER_REWARD_HIGH_DIFFICULTY, NORMAL_FONT_COLOR);
    	end 
    
    	EmbeddedItemTooltip:Show(); 
    end, 
    
    OnLeave = function(self)
    	EmbeddedItemTooltip:Hide();
    end,
})