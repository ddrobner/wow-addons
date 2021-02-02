local addonName = "Altoholic"
local addon = _G[addonName]
local ns = addon.Tabs.Shadowlands

--=============================================================================================

local function GetCurrentTier(talents)
	local currentTier = 0;
	for i, talentInfo in ipairs(talents) do
		if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave then
			currentTier = currentTier + 1;
		end
	end
	return currentTier;
end

local timeFormatter = CreateFromMixins(SecondsFormatterMixin);
timeFormatter:Init(SECONDS_PER_MIN, SecondsFormatter.Abbreviation.Truncate, false);

--=============================================================================================

local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Background-%s",
}
local listTextureKitRegions = {
	["BackgroundTile"] = "UI-Frame-%s-BackgroundTile",
};
local featureBorderTextureKitRegions = {
	["Border"] = "CovenantSanctum-Icon-Border-%s",
	["Glow"] = "CovenantSanctum-Icon-Glow-%s",
}
local reservoirTextureKitRegions = {
	["Glow"] = "CovenantSanctum-Resevoir-Glow-%s",
	["StaticGlow"] = "CovenantSanctum-Resevoir-Glow-%s",
	["Background"] = "CovenantSanctum-Resevoir-Empty-%s",
	["FillBackground"] = "CovenantSanctum-Resevoir-Full-%s",
	["Spark"] = "CovenantSanctum-Reservoir-Spark-%s",
	["SparkGlow"] = "CovenantSanctum-Reservoir-Spark-Glow-%s",
}
local upgradeTextureKitRegions = {
	["Border"] = "CovenantSanctum-Upgrade-Border-%s",
	["IconBorder"] = "CovenantSanctum-Upgrade-Icon-Border-%s",
}
local bagsGlowTextureKitRegions = {
	["Glow"] = "CovenantSanctum-Bag-Glow-%s",
}

local function SetupTextureKit(frame, regions)
	SetupTextureKitOnRegions(AltoholicTabShadowlands.ReservoirPanel:GetCovenantData().textureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

local EFFECT_MISSILE = 1;
local EFFECT_IMPACT = 2;
local EFFECT_ANIMA_FULL = 3;
local EFFECT_RESEARCH = 4;

local covenantSanctumEffectList = {
	[Enum.CovenantType.Venthyr] = { 103, 107, 111, 115 },
	[Enum.CovenantType.Kyrian] = { 104, 108, 112, 116 },
	[Enum.CovenantType.NightFae] = { 105, 109, 113, 117 },
	[Enum.CovenantType.Necrolord] = { 106, 110, 114, 118 },
}

local function GetEffectID(index)
	local effectList = covenantSanctumEffectList[AltoholicTabShadowlands.ReservoirPanel:GetCovenantID()];
	return effectList and effectList[index];
end

local covenantSanctumFeatureDescription = {
	[Enum.GarrTalentFeatureType.AnimaDiversion] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_FEATURE_ANIMACONDUCTOR_NECROLORD,
	},
	[Enum.GarrTalentFeatureType.TravelPortals] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_FEATURE_TRAVELNETWORK_NECROLORD,
	},
	[Enum.GarrTalentFeatureType.Adventures] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_FEATURE_ADVENTURES_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_FEATURE_ADVENTURES_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_FEATURE_ADVENTURES_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_FEATURE_ADVENTURES_NECROLORD,
	},
	[Enum.GarrTalentFeatureType.SanctumUnique] = {
		[Enum.CovenantType.Venthyr] = COVENANT_SANCTUM_UNIQUE_VENTHYR,
		[Enum.CovenantType.Kyrian] = COVENANT_SANCTUM_UNIQUE_KYRIAN,
		[Enum.CovenantType.NightFae] = COVENANT_SANCTUM_UNIQUE_NIGHTFAE,
		[Enum.CovenantType.Necrolord] = COVENANT_SANCTUM_UNIQUE_NECROLORD,
	},
};

--=============================================================================================

addon:Controller("AltoholicUI.ShadowlandsReservoirPanel", {
    OnBind = function(self)
    	self.researchModelScenePool = CreateFramePool("MODELSCENE", self, "ScriptAnimatedModelSceneTemplate");
    end,

    Update = function(self)
        if not DataStore:GetCovenantFeatures(ns:GetAltKey()) or (#DataStore:GetCovenantFeatures(ns:GetAltKey()) == 0) then
            self:Hide()
            return
        end
            
        self:SetCovenantInfo()
        self:SetUpCurrencies();
        self:Show()
    end,

    SetCovenantInfo = function(self)
    	local covenantID = DataStore:GetCovenantID(ns:GetAltKey())
    	if covenantID ~= self.covenantID then
    		self.covenantID = covenantID;
    		self.covenantData = C_Covenants.GetCovenantData(covenantID);
    	end
    end,
    
    GetCovenantID = function(self)
    	return self.covenantID;
    end,
    
    GetCovenantData = function(self)
    	return self.covenantData;
    end,

    OnShow = function(self)
    	self:SetUpTextureKits();
    	self:SetUpUpgrades();
    
    	if self:GetSelectedTree() then
    		self:Refresh();
    	else
    		self:SetSelectedTree(self.TravelUpgrade.treeID);
    	end
    
    	self:UpdateCurrencies();
    end,
    
    OnHide = function(self)
    	self.selectedTreeID = nil;
    	if self.animaGainEffect then
    		self.animaGainEffect:CancelEffect();
    	end
    	for i, frame in ipairs(self.Upgrades) do
    		if frame.researchEffect then
    			frame.researchEffect:CancelEffect();
    			frame.GlowAnim:Stop();
    			frame.Glow:SetAlpha(0);
    		end
    	end
    end,
    
    Refresh = function(self)
    	for i, frame in ipairs(self.Upgrades) do
    		frame:Refresh();
    	end
    	self.TalentsList:Refresh();
    end,
    
    HasAnyTalents = function(self)
    	for i, frame in ipairs(self.Upgrades) do
    		if frame:GetTier() > 0 then
    			return true;
    		end
    	end
    	return false;
    end,
    
    SetSelectedTree = function(self, treeID)
    	if self.selectedTreeID ~= treeID then
    		self.selectedTreeID = treeID;
    		self:Refresh();
    	end
    end,
    
    GetSelectedTree = function(self)
    	return self.selectedTreeID;
    end,
    
    GetSelectedTreeDescriptionText = function(self)
    	for i, frame in ipairs(self.Upgrades) do
    		if frame.treeID == self.selectedTreeID then
    			return frame:GetDescriptionText();
    		end
    	end
    	return nil;
    end,
    
    SetUpCurrencies = function(self)
    	local tooltipAnchor = "ANCHOR_RIGHT";
    
    	local initFunction = function(currencyFrame)
    		currencyFrame:SetWidth(50);
    	end
    	local currencies = CopyTable(DataStore:GetSoulCurrencies(ns:GetAltKey()))
    	-- sort them by ID - just happens to be in the order desired
    	table.sort(currencies);
    	-- add Anima to the front
    	local animaCurrencyID, maxDisplayableValue = C_CovenantSanctumUI.GetAnimaInfo()
    	tinsert(currencies, 1, animaCurrencyID);
    
    	local stride = #currencies;
    	local paddingX = 7;
    	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopRightToBottomLeft, stride, paddingX);
    	local initAnchor = nil;
    	local abbreviateCost = true;
    	local reverseOrder = true;
    	self.CurrencyDisplayGroup:SetCurrencies(currencies, initFunction, initAnchor, layout, tooltipAnchor, abbreviateCost, reverseOrder);
    
    	self.currencyOrder = currencies;
    end,
    
    SetUpUpgrades = function(self)
    	local features = DataStore:GetCovenantFeatures(ns:GetAltKey())
    	for i, featureInfo in ipairs(features) do
    		if featureInfo.featureType == Enum.GarrTalentFeatureType.AnimaDiversion then
    			self.DiversionUpgrade.treeID = featureInfo.garrTalentTreeID;
    			self.DiversionUpgrade.featureType = featureInfo.featureType;
    		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.TravelPortals then
    			self.TravelUpgrade.treeID = featureInfo.garrTalentTreeID;
    			self.TravelUpgrade.featureType = featureInfo.featureType;
    		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.Adventures then
    			self.AdventureUpgrade.treeID = featureInfo.garrTalentTreeID;
    			self.AdventureUpgrade.featureType = featureInfo.featureType;
    		elseif featureInfo.featureType == Enum.GarrTalentFeatureType.SanctumUnique then
    			self.UniqueUpgrade.treeID = featureInfo.garrTalentTreeID;
    			self.UniqueUpgrade.featureType = featureInfo.featureType;
    		end
    	end
    end,
    
    SetUpTextureKits = function(self)
    	SetupTextureKit(self.TalentsList, listTextureKitRegions);
    
    	for i, frame in ipairs(self.Upgrades) do
    		frame:SetUpTextureKit();
    	end
    end,
    
    UpdateCurrencies = function(self)
    	self.CurrencyDisplayGroup:Refresh();
    end,
    
    GetSortedResearchCurrencyCosts = function(self, currencyCosts)
    	local outputTable = { };
    	for i, orderValue in ipairs(self.currencyOrder) do
    		for j, cost in ipairs(currencyCosts) do
    			if cost.currencyType == orderValue then
    				tinsert(outputTable, cost)
    				break;
    			end
    		end
    	end
    	return outputTable;
    end,
    
    HasAnySoulCurrencies = function(self)
    	local currencies = DataStore:GetSoulCurrencies(ns:GetAltKey())
    	for i, currencyID in ipairs(currencies) do
    		local quantity = DataStore:GetSoulCurrenciesQuantity(ns:GetAltKey(), currencyID)
    		if quantity > 0 then
    			return true;
    		end
    	end
    	return false;
    end,
})
    
--=============================================================================================
local function SortTalents(talentA, talentB)
    return talentA.tier < talentB.tier;
end

addon:Controller("AltoholicUI.ShadowlandsReservoirTalentsList", {
    OnBind = function(self)
    	self.talentPool = CreateFramePool("FRAME", self, "AltoCovenantSanctumUpgradeTalentTemplate");
    end,
    
    Refresh = function(self)
    	self.talentPool:ReleaseAll();
    
    	local treeID = self:GetParent():GetSelectedTree();
    	local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
        treeInfo.talents = DataStore:GetGarrisonTalentTreeTalents(ns:GetAltKey(), treeID)
    	table.sort(treeInfo.talents, SortTalents);
    
    	self.upgradeTalentID = nil;
    
    	local lastTalentFrame = nil;
    	for i, talentInfo in ipairs(treeInfo.talents) do
    		if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
    			self.upgradeTalentID = talentInfo.id;
    		end
    
    		local talentFrame = self.talentPool:Acquire();
    		talentInfo.researchCurrencyCosts = self:GetParent():GetSortedResearchCurrencyCosts(talentInfo.researchCurrencyCosts);
    		talentFrame:Set(talentInfo);
    
    		if lastTalentFrame then
    			talentFrame:SetPoint("TOP", lastTalentFrame, "BOTTOM", 0, -1);
    		else
    			talentFrame:SetPoint("TOP", -4, 0);
    		end
    
    		talentFrame:Show();
    		lastTalentFrame = talentFrame;
    	end
    
    	self.Title:SetText(treeInfo.title);
    	local currentTier = GetCurrentTier(treeInfo.talents);
    	if currentTier == 0 then
    		self.Tier:SetText(COVENANT_SANCTUM_TIER_INACTIVE);
    	else
    		self.Tier:SetFormattedText(COVENANT_SANCTUM_TIER, currentTier);
    	end
    end,
    
    FindTalentButton = function(self, talentID)
    	for talentFrame in self.talentPool:EnumerateActive() do
    		if talentFrame.talentID == talentID then
    			return talentFrame;
    		end
    	end
    	return nil;
    end,
})
    
--=============================================================================================
local TalentUnavailableReasons = {};
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableAnotherIsResearching] = ORDER_HALL_TALENT_UNAVAILABLE_ANOTHER_IS_RESEARCHING;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableNotEnoughResources] = COVENANT_SANCTUM_NOT_ENOUGH_RESOURCES;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableNotEnoughGold] = ORDER_HALL_TALENT_UNAVAILABLE_NOT_ENOUGH_GOLD;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableTierUnavailable] = ORDER_HALL_TALENT_UNAVAILABLE_TIER_UNAVAILABLE;
TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent] = COVENANT_SANCTUM_TALENT_REQUIRES_PREVIOUS_TIER;

addon:Controller("AltoholicUI.ShadowlandsReservoirUpgradeTalent", {
    OnBind = function(self)
    	self.Name:SetFontObjectsToTry("SystemFont_Shadow_Med2", "GameFontHighlight");
    end,
    
    Set = function(self, talentInfo)
    	self.Name:SetText(talentInfo.name);
    	self.Icon:SetTexture(talentInfo.icon);
    
    	self.talentID = talentInfo.id;
    	local disabled = false;
    	local abbreviateCost = true;
    	local showingCost = false;
    
    	local nameColor = HIGHLIGHT_FONT_COLOR;
    	local textColor = HIGHLIGHT_FONT_COLOR;
    	local tierColor = nil;
    	if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave then
    		self.InfoText:SetText(COVENANT_SANCTUM_UPGRADE_ACTIVE);
    		textColor = NORMAL_FONT_COLOR;
    		tierColor = NORMAL_FONT_COLOR;
    	elseif talentInfo.isBeingResearched then
    		self.InfoText:SetText(COVENANT_SANCTUM_UPGRADE_ACTIVATING);
    		textColor = RED_FONT_COLOR;
    	elseif talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
    		local costString = GetGarrisonTalentCostString(talentInfo, abbreviateCost);
    		self.InfoText:SetText(costString or "");
    		showingCost = not not costString;
    		nameColor = GREEN_FONT_COLOR;
    		tierColor = GREEN_FONT_COLOR;
    	else
    		disabled = true;
    		local isMet, failureString = C_Garrison.IsTalentConditionMet(talentInfo.id);
    		if isMet then
    			local costString = GetGarrisonTalentCostString(talentInfo, abbreviateCost);
    			self.InfoText:SetText(costString);
    			showingCost = not not costString;
    		else
    			self.InfoText:SetText(failureString or "");
    		end
    		nameColor = DISABLED_FONT_COLOR;
    		tierColor = DISABLED_FONT_COLOR;
    	end
    	self.Name:SetTextColor(nameColor:GetRGB());
    	self.InfoText:SetTextColor(textColor:GetRGB());
    	if tierColor then
    		self.TierBorder:Show();
    		self.Tier:SetText(talentInfo.tier + 1);
    		self.Tier:SetTextColor(tierColor:GetRGB());
    	else
    		self.TierBorder:Hide();
    		self.Tier:SetText(nil);
    	end
    
    	local spaceOutLines = false;
    	if showingCost then
    		if self.Name:GetNumLines() > 1 and self.Name:GetFontObject() == SystemFont_Shadow_Med2 then
    			spaceOutLines = true;
    		end
    	end
    	if spaceOutLines then
    		self.Name:SetPoint("TOPLEFT", 58, -5);
    		self.InfoText:SetPoint("LEFT", self, "BOTTOMLEFT", 58, 13);
    	else
    		self.Name:SetPoint("TOPLEFT", 58, -6);
    		self.InfoText:SetPoint("LEFT", self, "BOTTOMLEFT", 58, 14);
    	end
    
    	self.Icon:SetDesaturated(disabled);
    	if disabled then
    		self.IconBorder:SetAtlas("CovenantSanctum-Upgrade-Icon-Border-Disabled", TextureKitConstants.UseAtlasSize);
    	else
    		local atlas = GetFinalNameFromTextureKit(upgradeTextureKitRegions.IconBorder, self:GetParent():GetParent():GetCovenantData().textureKit);
    		self.IconBorder:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
    	end
    
    	if talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
    		self.Border:SetAtlas("CovenantSanctum-Upgrade-Border-Available");
    	else
    		local atlas = GetFinalNameFromTextureKit(upgradeTextureKitRegions.Border, self:GetParent():GetParent():GetCovenantData().textureKit);
    		self.Border:SetAtlas(atlas);
    	end
    
    	if talentInfo.isBeingResearched and not talentInfo.hasInstantResearch then
    		self.Cooldown:SetCooldownUNIX(talentInfo.startTime, talentInfo.researchDuration);
    		self.Cooldown:Show();
    		self.Icon:SetVertexColor(0.25, 0.25, 0.25)
    	else
    		self.Cooldown:Hide();
    		self.Icon:SetVertexColor(1, 1, 1);
    	end
    end,
    
    OnEnter = function(self)
    	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    	self:RefreshTooltip();
    end,
    
    RefreshTooltip = function(self)
    	local talent			= C_Garrison.GetTalentInfo(self.talentID);
    	local garrTalentTreeID	= DataStore:CovenantSanctum_GetCurrentTalentTreeID(ns:GetAltKey())
    	local talentTreeType	= C_Garrison.GetGarrisonTalentTreeType(garrTalentTreeID);
    
    	GameTooltip:ClearLines();
    	self.UpdateTooltip = nil;
    
    	-- Multi-Rank Talents
    	if talent.talentMaxRank > 1 then
    		local talentRank = math.max(0, talent.talentRank);
    
    		GameTooltip:AddLine(talent.name, 1, 1, 1);
    		GameTooltip_AddColoredLine(GameTooltip, TOOLTIP_TALENT_RANK:format(talentRank, talent.talentMaxRank), HIGHLIGHT_FONT_COLOR);
    		GameTooltip:AddLine(talent.description, nil, nil, nil, true);
    
    		-- Next Rank (show research description)
    		if talent.talentRank > 0 and talent.talentRank < talent.talentMaxRank then
    			GameTooltip:AddLine(" ");
    			GameTooltip_AddColoredLine(GameTooltip, TOOLTIP_TALENT_NEXT_RANK, HIGHLIGHT_FONT_COLOR);
    			GameTooltip:AddLine(talent.researchDescription, nil, nil, nil, true);
    		end
    	else
    		GameTooltip:AddLine(talent.name, 1, 1, 1);
    		GameTooltip:AddLine(talent.description, nil, nil, nil, true);
    	end
    
    	if talent.isBeingResearched and not talent.hasInstantResearch then
    		GameTooltip:AddLine(" ");
    		GameTooltip:AddLine(NORMAL_FONT_COLOR_CODE..TIME_REMAINING..FONT_COLOR_CODE_CLOSE.." "..timeFormatter:Format(talent.timeRemaining), 1, 1, 1);
    		self.UpdateTooltip = self.RefreshTooltip;
    	elseif (talentTreeType == Enum.GarrTalentTreeType.Tiers and not talent.selected) or (talentTreeType == Enum.GarrTalentTreeType.Classic and not talent.researched) then
    		GameTooltip:AddLine(" ");
    
    		if (talent.researchDuration and talent.researchDuration > 0) then
    			GameTooltip:AddLine(RESEARCH_TIME_LABEL.." "..HIGHLIGHT_FONT_COLOR_CODE..timeFormatter:Format(talent.researchDuration)..FONT_COLOR_CODE_CLOSE);
    			self.UpdateTooltip = self.RefreshTooltip;
    		end
    
    		local costString = GetGarrisonTalentCostString(talent);
    		if costString then
    			GameTooltip:AddLine(costString, 1, 1, 1);
    		end
    
    		if talent.talentAvailability == Enum.GarrisonTalentAvailability.Available or (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAnotherIsResearching) then
    			GameTooltip_AddInstructionLine(GameTooltip, COVENANT_SANCTUM_TALENT_RESEARCH);
    		else
    			if (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailablePlayerCondition and talent.playerConditionReason) then
    				GameTooltip:AddLine(talent.playerConditionReason, 1, 0, 0);
    			elseif (talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent) then
    				local prereqTalentButton = self:GetParent():FindTalentButton(talent.prerequisiteTalentID);
    				local preReqTalent = prereqTalentButton and prereqTalentButton.talent;
    				if (preReqTalent) then
    					GameTooltip:AddLine(TOOLTIP_TALENT_PREREQ:format(preReqTalent.talentMaxRank, preReqTalent.name), 1, 0, 0);
    				else
    					GameTooltip:AddLine(TalentUnavailableReasons[Enum.GarrisonTalentAvailability.UnavailableRequiresPrerequisiteTalent], 1, 0, 0);
    				end
    			elseif (TalentUnavailableReasons[talent.talentAvailability]) then
    				GameTooltip:AddLine(TalentUnavailableReasons[talent.talentAvailability], 1, 0, 0);
    			end
    		end
    	end
    	GameTooltip:Show();
    end,
})

--=============================================================================================
addon:Controller("AltoholicUI.ShadowlandsReservoirUpgradeTree", {
    Refresh = function(self)
    	local treeInfo = C_Garrison.GetTalentTreeInfo(self.treeID);
    	if treeInfo then
            treeInfo.talents = DataStore:GetGarrisonTalentTreeTalents(ns:GetAltKey(), self.treeID)
    		self.tier = GetCurrentTier(treeInfo.talents);
    		if self.tier == 0 then
    			self.Tier:SetText(nil);
    			self.TierBorder:Hide();
    		else
    			self.Tier:SetText(self.tier);
    			self.TierBorder:Show();
    		end
    		self.Icon:SetTexture(treeInfo.talents[1].icon);
    		self.SelectedTexture:SetShown(self:IsSelected());
    		-- check for cooldown or available talent
    		local startTime, researchDuration, researchTalentID;
    		local readyToResearch = false;
    		for i, talentInfo in ipairs(treeInfo.talents) do
    			if talentInfo.isBeingResearched and not talentInfo.hasInstantResearch then
    				startTime = talentInfo.startTime;
    				researchDuration = talentInfo.researchDuration;
    				researchTalentID = talentInfo.id;
    				break;
    			elseif talentInfo.talentAvailability == Enum.GarrisonTalentAvailability.Available then
    				readyToResearch = true;
    				break;
    			end
    		end
    		if startTime and researchDuration then
    			self.Cooldown:SetCooldownUNIX(startTime, researchDuration);
    			self.Cooldown:Show();
    			self.Icon:SetVertexColor(0.25, 0.25, 0.25);
    		else
    			self.Cooldown:Hide();
    			self.Icon:SetVertexColor(1, 1, 1);
    		end
    		self.researchTalentID = researchTalentID;
    		self.UpgradeArrow:SetShown(readyToResearch);
    	end
    end,
    
    GetTier = function(self)
    	return self.tier or 0;
    end,
    
    GetDescriptionText = function(self)
    	local covenantID = AltoholicTabShadowlands.ReservoirPanel:GetCovenantID()
    	if self.featureType and covenantSanctumFeatureDescription[self.featureType] and covenantSanctumFeatureDescription[self.featureType][covenantID] then
    		return covenantSanctumFeatureDescription[self.featureType][covenantID];
    	end
    	return "";
    end,
    
    OnMouseDown = function(self)
    	local parent = self:GetParent();
    	if parent:GetSelectedTree() ~= self.treeID then
    		parent:SetSelectedTree(self.treeID);
    	end
    end,
    
    OnEnter = function(self)
    	self.HighlightTexture:Show();
    	self:RefreshTooltip();
    end,
    
    RefreshTooltip = function(self)
    	local treeInfo = C_Garrison.GetTalentTreeInfo(self.treeID);
    	if treeInfo then
            treeInfo.talents = DataStore:GetGarrisonTalentTreeTalents(ns:GetAltKey(), self.treeID)
    		local timeRemaining;
    		for i, talentInfo in ipairs(treeInfo.talents) do
    			if talentInfo.isBeingResearched and not talentInfo.hasInstantResearch then
    				timeRemaining = talentInfo.timeRemaining;
    				break;
    			end
    		end
    		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    		GameTooltip_SetTitle(GameTooltip, treeInfo.title);
    		GameTooltip_AddNormalLine(GameTooltip, self:GetDescriptionText());
    		if timeRemaining and timeRemaining > 0 then
    			self.UpdateTooltip = self.RefreshTooltip;
    			GameTooltip_AddBlankLineToTooltip(GameTooltip);
    			local text = string.format(COVENANT_SANCTUM_TIME_REMAINING, timeFormatter:Format(timeRemaining));
    			GameTooltip_AddHighlightLine(GameTooltip, text);
    		else
    			self.UpdateTooltip = nil;
    		end
    		GameTooltip:Show();
    	end
    end,
    
    OnLeave = function(self)
    	self.HighlightTexture:Hide();
    	GameTooltip:Hide();
    end,
    
    IsSelected = function(self)
    	return self:GetParent():GetSelectedTree() == self.treeID;
    end,
    
    SetUpTextureKit = function(self)
    	SetupTextureKit(self, featureBorderTextureKitRegions);
    end,
})