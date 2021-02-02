local addonName = "Altoholic"
local addon = _G[addonName]

local ns = addon.Tabs.Shadowlands

addon:Controller("AltoholicUI.ShadowlandsOverview", {
	OnBind = function(frame)
        frame:Show()
        frame:Update()
	end,
	Update = function(frame)
        local covenantID = DataStore:GetCovenantID(ns:GetAltKey()) or 0 
        local covenantData = C_Covenants.GetCovenantData(covenantID)

        if covenantID > 0 and covenantData and covenantData.name then
            frame.RenownButton:Show()
            frame.SoulbindButton:Show()
            frame.Callings:Show()	
            frame.Title:SetText(covenantData.name)
            frame.ArdenwealdGardeningPanel:Update()
            frame.NoCovenantError:Hide()
        else
            frame.RenownButton:Hide()
            frame.SoulbindButton:Hide()
            frame.Callings:Hide()
            frame.Title:SetText("")
            frame.ArdenwealdGardeningPanel:Hide()
            frame.NoCovenantError:Show()
        end
        
        frame:Show()
	end,
})

addon:Controller("AltoholicUI.ShadowlandsRenownButton", {
	OnBind = function(self)
        self:SetPoint("TOPLEFT", self:GetParent().Title, "BOTTOMLEFT", 10, 0)
	end,

    Update = function(self)
	   self:UpdateRenownLevel()
	   self:UpdateButtonTextures()
    end,

    Button_OnClick = function(self, button)
        -- open the renown tab
    end,

    UpdateRenownLevel = function(self)
        self.Renown:SetText(DataStore:GetRenownLevel(ns:GetAltKey()))
    end,

    UpdateButtonTextures = function(self) 
	    local covenantData = C_Covenants.GetCovenantData(DataStore:GetCovenantID(ns:GetAltKey()) or 0)
        if not covenantData then return end
	    self:SetNormalAtlas(("shadowlands-landingpage-renownbutton-%s"):format(covenantData.textureKit));
	    self:SetPushedAtlas(("shadowlands-landingpage-renownbutton-%s"):format(covenantData.textureKit));
	    self.PushedImage:SetAtlas(("shadowlands-landingpage-renownbutton-%s-down"):format(covenantData.textureKit));
    end,

    OnMouseDown = function(self)
	    self.PushedImage:Show();
    end,

    OnMouseUp = function(self)
	    self.PushedImage:Hide();
    end,
})

addon:Controller("AltoholicUI.ShadowlandsSoulbindButton", {
	OnBind = function(self)
        self:SetPoint("TOPLEFT", self:GetParent().RenownButton, "BOTTOMLEFT")
	end,

    Update = function(self)
	   self:UpdateSoulbindName()
    end,

    Button_OnClick = function(self, button)
        -- open the renown tab
    end,

    UpdateSoulbindName = function(self)
	   local soulbindID = DataStore:GetActiveSoulbindID(ns:GetAltKey())
	   if soulbindID and soulbindID > 0 then
    		self:SetSoulbind(C_Soulbinds.GetSoulbindData(soulbindID))
	   end
    end,
    
    OnEnter = function(self)
	   self.Highlight:Show();
    end,

    OnLeave = function(self)
	   self.Highlight:Hide();
    end,

    OnMouseDown = function(self)
	   self.Press:Show();
    end,

    OnMouseUp = function(self)
	   self.Press:Hide();
    end,
    
    SetSoulbind = function(self, soulbindData)
	   local portraitAtlas = ("shadowlands-landingpage-soulbindsbutton-%s"):format(soulbindData.textureKit);
	   self.Portrait:SetAtlas(portraitAtlas, true);
	   self.Label:SetText(soulbindData.name);
    end,
})

addon:Controller("AltoholicUI.ShadowlandsCallingsPane", {
    OnBind = function(self)
       self:SetPoint("TOPLEFT", self:GetParent().SoulbindButton, "BOTTOMLEFT")
    end,
})

-- Adapted from Blizzard_CovenantCallings\CovenantCallings.lua
addon:Controller("AltoholicUI.ShadowlandsCallingQuest", {
    OnBind = function(self)
       self:SetPoint("TOPLEFT", 80*(self:GetID()-1) + 20, -50)
    end,
    
    Update = function(self)
	   self:UpdateIcon();
	   self:UpdateBang();
    end,
    
    UpdateIcon = function(self)
        local id = self:GetID()
        local callings = DataStore:GetCallingQuests(ns:GetAltKey())
        local covenantData = C_Covenants.GetCovenantData(DataStore:GetCovenantID(ns:GetAltKey()) or 0)
        if not covenantData then return end
        
        local icon = 0
        for _, callingData in pairs(callings) do
            if id == 1 then
                icon = callingData.icon
            end
            id = id - 1
        end
        
        if icon == 0 then
		    icon = ("Interface/Pictures/Callings-%s-Head-Disable"):format(covenantData.textureKit);
	    end
        self.Icon:SetTexture(icon)
		self.Highlight:SetTexture(icon)
    end,
    
    UpdateBang = function(self)
    	local id = self:GetID()
        local callings = DataStore:GetCallingQuests(ns:GetAltKey())
        
        local bang = nil 
        for questID in pairs(callings) do
            if id == 1 and questID ~= 0 then
                bang = "Callings-Available"
            end
            id = id - 1
        end
        
    	self.Bang:SetShown(bang ~= nil);
    	if bang then
    		self.Bang:SetAtlas(bang, true);
    	end
    
    	self.Glow:SetShown(bang ~= nil);
    end,
    
    OnEnter = function(self)
	    self:UpdateTooltip();
	    self.Highlight:Show();
    end,

    OnLeave = function(self)
	    if self.usedTaskPOI then
		    TaskPOI_OnLeave(self);
		    self.usedTaskPOI = nil;
	    else
		    GameTooltip:Hide();
	    end

	    self.Highlight:Hide();
    end,
    
    UpdateTooltip = function(self)
	    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

    	local id = self:GetID()
        local callings = DataStore:GetCallingQuests(ns:GetAltKey())
        
        local questComplete = true 
        for questID in pairs(callings) do
            if id == 1 and questID ~= 0 then
                questComplete = false
            end
            id = id - 1
        end

	    if questComplete then
            -- this horrible code cludge is from CovenantCalling.lua, CovenantCallingMixin:GetDaysUntilNextString()
		    GameTooltip:SetText(_G["BOUNTY_BOARD_NO_CALLINGS_DAYS_" .. Constants.Callings.MaxCallings - self:GetID() + 1] or BOUNTY_BOARD_NO_CALLINGS_DAYS_1, HIGHLIGHT_FONT_COLOR:GetRGB());
	    else
            self:UpdateTooltipQuestActive()
        end

	    GameTooltip:Show();
	    GameTooltip.recalculatePadding = true
    end,
    
    UpdateTooltipQuestActive = function(self)
        local questID = nil
        local id = self:GetID()
        local callings = DataStore:GetCallingQuests(ns:GetAltKey()) 
        for qid in pairs(callings) do
            if id == 1 and qid ~= 0 then
                questID = qid
            end
            id = id - 1
        end
        
        if not questID then return end
    
    	-- Add the quest title
    	local title = QuestUtils_GetQuestName(questID)
    	GameTooltip_SetTitle(GameTooltip, title)
    
        local covenantData = C_Covenants.GetCovenantData(DataStore:GetCovenantID(ns:GetAltKey()) or 0)
    
    	if covenantData then
    		GameTooltip_AddNormalLine(GameTooltip, covenantData.name)
    	end
    
    	-- Add the remaining time
    	WorldMap_AddQuestTimeToTooltip(questID);
    
    	-- Add the rewards
    	GameTooltip_AddBlankLineToTooltip(GameTooltip)
    	GameTooltip_AddNormalLine(GameTooltip, CALLING_QUEST_TOOLTIP_DESCRIPTION, true)
    	GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, TOOLTIP_QUEST_REWARDS_STYLE_CALLING_REWARD)
    end
})

addon:Controller("AltoholicUI.ShadowlandsArdenwealdPanel", {
    OnBind = function(self)
    end,
    
    Update = function(self)
        if DataStore:IsArdenwealdGardenAccessible(ns:GetAltKey()) then
            self:Show()
        else
            self:Hide()
        end
    end,
})

-- From Blizzard_ArdenwealdGardening.lua
local ArdenwealdGardeningSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
ArdenwealdGardeningSecondsFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.None, true, true);

function ArdenwealdGardeningSecondsFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

function ArdenwealdGardeningSecondsFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

addon:Controller("AltoholicUI.ShadowlandsArdenwealdButton", {
    OnBind = function(self)
    end,

    OnEnter = function(self)
    	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
    	GameTooltip_SetTitle(GameTooltip, GARDENWEALD_STATUS_HEADER);
    
    	local data = DataStore:GetArdenwealdGardenData(ns:GetAltKey());
    	local hasActive = data.active > 0;
    	if hasActive then
    		local time = ArdenwealdGardeningSecondsFormatter:Format(data.remainingSeconds);
    		GameTooltip_AddNormalLine(GameTooltip, GARDENWEALD_STATUS_ACTIVE_COUNT:format(data.active, time));
    	end
    
    	if data.ready > 0 then
    		if hasActive then
    			GameTooltip_AddBlankLineToTooltip(GameTooltip);
    		end
    		GameTooltip_AddNormalLine(GameTooltip, GARDENWEALD_STATUS_READY_COUNT:format(data.ready));
    	elseif not hasActive then
    		GameTooltip_AddNormalLine(GameTooltip, GARDENWEALD_STATUS_DORMANT);
    	end
    
    	GameTooltip:Show();
    
    	self.Highlight:Show();
    	self.Icon2:Show();
    end,

    OnLeave = function(self)
    	GameTooltip_Hide();
    
    	self.Highlight:Hide();
    	self.Icon2:Hide();
    end,
})
