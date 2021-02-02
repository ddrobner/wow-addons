local addonName = "Altoholic"
local addon = _G[addonName]
local ns = addon.Tabs.Shadowlands

-- From Blizzard_AnimaDiversionUtil.lua

local function IsNodeActive(nodeState)
	return (nodeState == Enum.AnimaDiversionNodeState.SelectedTemporary) or (nodeState == Enum.AnimaDiversionNodeState.SelectedPermanent);
end

-- From Blizzard_AnimaDiersionUI\AnimaDiversionDataProvider.lua

local animaPinTextureKitRegions = {
	[Enum.AnimaDiversionNodeState.Unavailable] = "AnimaChannel-Icon-%s-Normal",
	[Enum.AnimaDiversionNodeState.Available] = "AnimaChannel-Icon-%s-Select",
	[Enum.AnimaDiversionNodeState.SelectedTemporary] = "AnimaChannel-Icon-%s-Ready",
	[Enum.AnimaDiversionNodeState.SelectedPermanent] = "AnimaChannel-Icon-%s-Ready",
	[Enum.AnimaDiversionNodeState.Cooldown] = "AnimaChannel-Icon-%s-Normal",
};

local reinforceNodeTextureKitAnimationEffectId = {
	["Kyrian"] = 22,
	["NightFae"] = 28,
	["Venthyr"] = 25,
	["Necrolord"] = 31, 
}; 

local animaConnectionShowBlackLink = { 
	["Venthyr"] = true,
	["Necrolord"] = true, 
}; 

local ANIMA_DIVERSION_ORIGIN_PIN_BORDER = "AnimaChannel-Icon-Device-%s-Border";
local ANIMA_DIVERSION_LINK_TEXTURE = "animachannel-link-anima-%s";
local ANIMA_DIVERSION_LINE_TEXTURE = "_AnimaChannel-Channel-Line-horizontal-%s";
local ANIMA_SELECTION_MODEL_EFFECT_ID = 35;

local AnimaDiversionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AnimaDiversionDataProviderMixin:OnShow()
end 

function AnimaDiversionDataProviderMixin:OnHide()
	self:ResetModelScene();
end 

function AnimaDiversionDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData(); 
end 

function AnimaDiversionDataProviderMixin:SetupConnectionOnPin(pin)
	local connection = self.connectionPool:Acquire();
	connection:Setup(self.textureKit, self.origin, pin);
	connection:Show();

	self.origin.IconBorder:Show();
end

function AnimaDiversionDataProviderMixin:ResetModelScene()
	if self.modelScenePin then
		self.modelScenePin.ModelScene:ClearEffects();
		self.modelScenePin = nil;
	end

	self.pinEffects = {};
end

function AnimaDiversionDataProviderMixin:AddEffectOnPin(effectID, pin, permanent)
	if self.modelScenePin then
		if not self.pinEffects[pin] then
			self.pinEffects[pin] = {};
		end

		if not self.pinEffects[pin][effectID] then
			local pinEffect = self.modelScenePin.ModelScene:AddEffect(effectID, pin, pin);
			self.pinEffects[pin][effectID] = {effect = pinEffect, temporary =  not permanent};
		end
	end
end

function AnimaDiversionDataProviderMixin:ClearEffectOnPin(effectID, pin, onlyTemporaryEffects)
	if self.modelScenePin then
		if self.pinEffects[pin] and self.pinEffects[pin][effectID] then
			if not onlyTemporaryEffects or self.pinEffects[pin][effectID].temporary then
				self.pinEffects[pin][effectID].effect:CancelEffect();
				self.pinEffects[pin][effectID] = nil;
			end
		end
	end
end

function AnimaDiversionDataProviderMixin:ClearEffectOnAllPins(effectID, onlyTemporaryEffects, exemptPin)
	if self.modelScenePin then
		for pin, _ in pairs(self.pinEffects) do
			if pin ~= exemptPin then
				self:ClearEffectOnPin(effectID, pin, onlyTemporaryEffects);
			end
		end
	end
end

function AnimaDiversionDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("AltoAnimaDiversionPinTemplate");

	self:ResetModelScene();
	self:GetMap():RemoveAllPinsByTemplate("AltoAnimaDiversionModelScenePinTemplate");
end

function AnimaDiversionDataProviderMixin:CanReinforceNode() 
	return self.bolsterProgress >= 10;
end 

function AnimaDiversionDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	self.bolsterProgress = DataStore:GetReinforceProgress(ns:GetAltKey())

	if not self.connectionPool then
		self.connectionPool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "AltoAnimaDiversionConnectionTemplate");
	else
		self.connectionPool:ReleaseAll(); 
	end

	self.textureKit = C_Covenants.GetCovenantData(DataStore:GetCovenantID(ns:GetAltKey())).textureKit -- hopefully these always use the same strings
    if not self.textureKit then return end

	self:AddModelScene();

	local originPosition = DataStore:GetAnimaDiversionOriginPosition(ns:GetAltKey())
	if not originPosition then
		return;
	end

	local animaNodes = DataStore:GetAnimaDiversionNodes(ns:GetAltKey()) 
	if not animaNodes then 
		return;
	end 

	self:AddOrigin(originPosition);

	for _, nodeData in ipairs(animaNodes) do
		self:AddNode(nodeData)
	end
end

function AnimaDiversionDataProviderMixin:AddNode(nodeData)
	local pin = self:GetMap():AcquirePin("AltoAnimaDiversionPinTemplate");

	pin:SetPosition(nodeData.normalizedPosition.x, nodeData.normalizedPosition.y);
	pin.nodeData = nodeData;
	pin.owner = self;
	pin.textureKit = self.textureKit;
	pin:SetSize(150,175);
	pin:SetupNode();

	if pin:IsConnected() then
		self:SetupConnectionOnPin(pin);
		return true;
	end
end

function AnimaDiversionDataProviderMixin:AddOrigin(position)
	local pin = self:GetMap():AcquirePin("AltoAnimaDiversionPinTemplate");

	pin:SetPosition(position.x, position.y);
	pin.nodeData = nil;
	pin.owner = self; 
	pin.textureKit = self.textureKit;
	pin:SetSize(175,175); 
	pin:SetupOrigin();

	self.origin = pin; 
end 

function AnimaDiversionDataProviderMixin:AddModelScene()
	local pin = self:GetMap():AcquirePin("AltoAnimaDiversionModelScenePinTemplate");
	pin:SetPosition(0.5, 0.5);
	self.modelScenePin = pin; 
	local width = self:GetMap():DenormalizeHorizontalSize(1.0); 
	local height = self:GetMap():DenormalizeVerticalSize(1.0);
	pin:SetSize(width, height);
	pin.ModelScene:SetSize(width, height);
	pin.ModelScene:SetFrameLevel(1000);
	pin.ModelScene:RefreshModelScene();
end 

local AnimaDiversionModelScenePinMixin = CreateFromMixins(MapCanvasPinMixin); 
function AnimaDiversionModelScenePinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ANIMA_DIVERSION_MODELSCENE_PIN");
end
addon:Controller("AltoholicUI.ShadowlandsAnimaDiversionModelScenePinTemplate", {
    OnBind = function(self)
        Mixin(self, AnimaDiversionModelScenePinMixin)
    end,
}) 

local AnimaDiversionPinMixin = CreateFromMixins(MapCanvasPinMixin); 
function AnimaDiversionPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ANIMA_DIVERSION_PIN");
end

function AnimaDiversionPinMixin:SetupOrigin()
	self.visualState = nil;
	self.Icon:SetAtlas("AnimaChannel-Icon-Device", TextureKitConstants.UseAtlasSize);
	self.Icon:SetDesaturated(false);
	SetupTextureKitOnFrame(self.textureKit, self.IconBorder, ANIMA_DIVERSION_ORIGIN_PIN_BORDER, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	self.IconBorder:Hide();
	self.IconDisabledOverlay:Hide();
	self:Show();
end 

function AnimaDiversionPinMixin:IsConnected() 
	return IsNodeActive(self.nodeData.state);
end 

function AnimaDiversionPinMixin:SetupNode()
	local useState = self.nodeData.state;
	
	if self.nodeData.state == Enum.AnimaDiversionNodeState.SelectedPermanent then
		local permanent = true;
		self:SetReinforceState(true, permanent);
	elseif self.owner:CanReinforceNode() then
		if self.nodeData.state ~= Enum.AnimaDiversionNodeState.Unavailable then
			useState = Enum.AnimaDiversionNodeState.Available;
			self:SetReinforceState(true);
		end
	elseif self.nodeData.state == Enum.AnimaDiversionNodeState.Available then
		self:SetSelectedState(true, true);
	end

	local worldQuestID = DataStore:GetTalentUnlockWorldQuest(ns:GetAltKey(), self.nodeData.talentID)
	if worldQuestID then
		-- prime the data;
		HaveQuestRewardData(worldQuestID) -- not sure if this will work on other characters?
	end

	self:SetVisualState(useState);
	self.IconBorder:Hide();

	self:Show();
end 

function AnimaDiversionPinMixin:SetVisualState(state)
	self.visualState = state;
	SetupTextureKitOnFrame(self.textureKit, self.Icon, animaPinTextureKitRegions[state], TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnFrame(self.textureKit, self.IconDisabledOverlay, animaPinTextureKitRegions[state], TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	if state == Enum.AnimaDiversionNodeState.Unavailable then
		self.IconDisabledOverlay:SetVertexColor(0, 0, 0, 0.4);
		self.IconDisabledOverlay:Show();
		self.Icon:SetDesaturated(true);
	else
		self.IconDisabledOverlay:Hide();
		self.Icon:SetDesaturated(false);
	end
end

function AnimaDiversionPinMixin:SetReinforceState(reinforce, permanent) 
	if reinforce then
		self.owner:AddEffectOnPin(reinforceNodeTextureKitAnimationEffectId[self.textureKit], self, permanent);
	else
		self.owner:ClearEffectOnPin(reinforceNodeTextureKitAnimationEffectId[self.textureKit], self);
	end
end 

function AnimaDiversionPinMixin:SetSelectedState(selected, leaveOtherSelections)
	if selected then
		local onlyTemporaryEffects = true;
		self.owner:ClearEffectOnAllPins(reinforceNodeTextureKitAnimationEffectId[self.textureKit], onlyTemporaryEffects, self);

		if not leaveOtherSelections then
			self.owner:ClearEffectOnAllPins(ANIMA_SELECTION_MODEL_EFFECT_ID, onlyTemporaryEffects, self);
		end

		self.owner:AddEffectOnPin(ANIMA_SELECTION_MODEL_EFFECT_ID, self);
	else
		self.owner:ClearEffectOnPin(ANIMA_SELECTION_MODEL_EFFECT_ID, self);
	end
end 

function AnimaDiversionPinMixin:OnMouseEnter() 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:RefreshTooltip();
end

function AnimaDiversionPinMixin:RefreshTooltip()
	GameTooltip:ClearLines();
	self.UpdateTooltip = nil;

	if not self.nodeData then -- If we are the origin pin we want to show a special tooltip. 
		GameTooltip_AddHighlightLine(GameTooltip, ANIMA_DIVERSION_ORIGIN_TOOLTIP);
	else
		GameTooltip_AddNormalLine(GameTooltip, self.nodeData.name);
		GameTooltip_AddHighlightLine(GameTooltip, self.nodeData.description);
		if self.nodeData.state == Enum.AnimaDiversionNodeState.Unavailable then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddErrorLine(GameTooltip, ANIMA_DIVERSION_NODE_UNAVAILABLE);
		elseif self.nodeData.state == Enum.AnimaDiversionNodeState.Cooldown and not self.owner:CanReinforceNode() then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddErrorLine(GameTooltip, ANIMA_DIVERSION_NODE_COOLDOWN);
		elseif self.nodeData.state == Enum.AnimaDiversionNodeState.SelectedPermanent then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, ANIMA_DIVERSION_POI_REINFORCED, GREEN_FONT_COLOR);
		elseif self.nodeData.state == Enum.AnimaDiversionNodeState.Available then 
			local talentInfo = C_Garrison.GetTalentInfo(self.nodeData.talentID) -- don't need to move this to DataStore
			if talentInfo then
				local costString = GetGarrisonTalentCostString(talentInfo);
				if costString then
					GameTooltip_AddBlankLineToTooltip(GameTooltip);
					GameTooltip_AddHighlightLine(GameTooltip, costString);
				end
			end
			GameTooltip_AddColoredLine(GameTooltip, ANIMA_DIVERSION_CLICK_CHANNEL, GREEN_FONT_COLOR);
		end
		local worldQuestID = DataStore:GetTalentUnlockWorldQuest(ns:GetAltKey(), self.nodeData.talentID)
		if worldQuestID then
			GameTooltip_AddQuestRewardsToTooltip(GameTooltip, worldQuestID);
			GameTooltip.recalculatePadding = true;
			if not HaveQuestRewardData(worldQuestID) then
				self.UpdateTooltip = self.RefreshTooltip;
			end
		end
	end 

	GameTooltip:Show(); 
end

function AnimaDiversionPinMixin:OnMouseLeave() 
	GameTooltip:Hide();
end

addon:Controller("AltoholicUI.ShadowlandsAnimaDiversionPinTemplate", {
    OnBind = function(self)
        Mixin(self, AnimaDiversionPinMixin)
    end,
})

addon:Controller("AltoholicUI.ShadowlandsAnimaDiversionConnectionTemplate", {
    Setup = function(self, textureKit, origin, pin)
    		-- Anchor straight up from the origin
    	self:SetPoint("BOTTOM", origin, "CENTER");
    
    	-- Then adjust the height to be the length from origin to pin
    	local length = RegionUtil.CalculateDistanceBetween(origin, pin) * origin:GetEffectiveScale();
    	self:SetHeight(length);
    
    	-- And finally rotate all the textures around the origin so they line up
    	local quarter = (math.pi / 2);
    	local angle = RegionUtil.CalculateAngleBetween(origin, pin) - quarter;
    	self:RotateTextures(angle, 0.5, 0);
    
    	self.Line:SetStartPoint("CENTER", origin);
    	self.Line:SetEndPoint("CENTER", pin);
    
    	local lineThickness = (pin.nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary) and 20 or 40;
    	self.Line:SetThickness(lineThickness);
    
    	SetupTextureKitOnFrame(textureKit, self.Line, ANIMA_DIVERSION_LINE_TEXTURE, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
    	SetupTextureKitOnFrame(textureKit, self.AnimaLink1, ANIMA_DIVERSION_LINK_TEXTURE, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
    	SetupTextureKitOnFrame(textureKit, self.AnimaLink2, ANIMA_DIVERSION_LINK_TEXTURE, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
    	self.AnimaLinkBlack:SetShown(animaConnectionShowBlackLink[textureKit]);
    
    	self.Mask:SetShown(pin.nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary);
    
    	for _, animationGroup in ipairs(self.animationGroups) do
    		animationGroup:Play();
    	end
    end,
})

-- All this code adapted from Blizzard_AnimaDiversionUI.lua

local ANIMA_GEM_TEXTURE_INFO = "AnimaChannel-Bar-%s-Gem"; 
local MAX_ANIMA_GEM_COUNT = 10;  

local fullGemsTextureKitAnimationEffectId = {
	["Kyrian"] = 24,
	["Venthyr"] = 27,
	["NightFae"] = 30,
	["Necrolord"] = 33, 
};

local newGemTextureKitAnimationEffectId = {
	["Kyrian"] = 23,
	["Venthyr"] = 26,
	["NightFae"] = 29,
	["Necrolord"] = 32, 
};

addon:Controller("AltoholicUI.ShadowlandsAnimaDiversionPanel", {
	OnBind = function(self)
      	MapCanvasMixin.OnLoad(self);	
      	self:SetShouldZoomInOnClick(false);
      	self:SetMouseWheelZoomMode(MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE);
      	self:SetShouldPanOnClick(false);
      	self:AddStandardDataProviders();
      	self.bolsterProgressGemPool = CreateFramePool("FRAME", self.ReinforceProgressFrame, "AltoAnimaDiversionBolsterProgressGemTemplate");
        AltoholicFrame:HookScript("OnSizeChanged", function() self.ScrollContainer:OnCanvasSizeChanged() end)
	end,
    
	Update = function(self)
        local covenantID = DataStore:GetCovenantID(ns:GetAltKey())
        if not covenantID or covenantID == 0 then
            -- hide everything instead; character doesn't have a covenant
            self:Hide()
            return
        end
        
    	self.covenantData = C_Covenants.GetCovenantData(covenantID)
        self.uiTextureKit = self.covenantData.textureKit
    	local mapIDs = {["NightFae"] = 1739, ["Venthyr"] = 1738, ["Kyrian"] = 1813, ["Necrolord"] = 1814} -- TODO: ge the right names/numbers for other covenants
        self.mapID = mapIDs[self.uiTextureKit] 
    	self:SetupBolsterProgressBar();
    	self:SetupCurrencyFrame(); 
    	ShowUIPanel(self);
	end,

    OnShow = function(self)
	   self:SetMapID(self.mapID);
	   MapCanvasMixin.OnShow(self);

	   self:ResetZoom();
    end,

    OnHide = function(self)
	   MapCanvasMixin.OnHide(self);
	   self.ReinforceInfoFrame:Hide();
    end,
    
    OnEvent = function(self, event, ...)
    	MapCanvasMixin.OnEvent(self, event, ...);
    end,

    SetExclusiveSelectionNode = function(self, node)
    	for pin in self:EnumeratePinsByTemplate("AltoAltoAnimaDiversionPinTemplate") do
    		if pin ~= node and pin.visualState == Enum.AnimaDiversionNodeState.Available then
    			if pin.nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary then
    				pin:SetVisualState(Enum.AnimaDiversionNodeState.SelectedTemporary);
    			else
    				pin:SetVisualState(Enum.AnimaDiversionNodeState.Cooldown);
    			end
    		end
    	end
    	self.disallowSelection = true;
    end,

    ClearExclusiveSelectionNode = function(self)
    	self:RefreshAllDataProviders();
    	self.disallowSelection = false;
    end,

    CanReinforceNode = function(self) 
    	return self.bolsterProgress >= 10;
    end,

    AddBolsterEffectToGem = function(self, gem, effectID, overlay)
    	local modelScene = overlay and self.ReinforceProgressFrame.OverlayModelScene or self.ReinforceProgressFrame.ModelScene;
    	modelScene:AddEffect(effectID, gem, gem);
    end,

    SetupBolsterProgressBar = function(self)
    	self.bolsterProgressGemPool:ReleaseAll(); 
    	self.ReinforceProgressFrame.ModelScene:ClearEffects();
    	self.ReinforceProgressFrame.OverlayModelScene:ClearEffects();
    
    	local gemsFullEffectID = fullGemsTextureKitAnimationEffectId[self.uiTextureKit];
    	local newGemEffectID = newGemTextureKitAnimationEffectId[self.uiTextureKit];
    	
    	local newBolsterProgress =  math.min(MAX_ANIMA_GEM_COUNT, DataStore:GetReinforceProgress(ns:GetAltKey()))
    	local numNewGems =  0;
    	if self.bolsterProgress and newBolsterProgress > self.bolsterProgress then
    		numNewGems = newBolsterProgress - self.bolsterProgress;
    	end
    	self.bolsterProgress = newBolsterProgress; 
    
    	local isReinforceReady = self:CanReinforceNode();
    
    	local firstNewGem = (newBolsterProgress - numNewGems) + 1;
    
    	for i=1, newBolsterProgress do
    		local isNewGem = i >= firstNewGem;
    
    		self.lastGem = self:SetupBolsterGem(i, isNewGem);
    
    		if isNewGem then
    			self:AddBolsterEffectToGem(self.lastGem, newGemEffectID, true);
    		end
    
    		if isReinforceReady then
    			if numNewGems > 0 then
    				C_Timer.After(0.5, GenerateClosure(self.AddBolsterEffectToGem, self, self.lastGem, gemsFullEffectID));
    			else
    				self:AddBolsterEffectToGem(self.lastGem, gemsFullEffectID);
    			end
    		end 
    	end
    
    	self.ReinforceInfoFrame:Init(); 
    	self.ReinforceInfoFrame:SetShown(isReinforceReady);
    end, 

    SetupBolsterGem = function(self, index, isNew)
    	local gem = self.bolsterProgressGemPool:Acquire(); 
    	if(index == 1) then 
    		gem:SetPoint("LEFT", self.ReinforceProgressFrame, 27, -5);
    	elseif(index > 5) then
    		gem:SetPoint("LEFT", self.lastGem, "RIGHT", -3, 0);
    	else 
    		gem:SetPoint("LEFT", self.lastGem, "RIGHT", -2, 0);	
    	end
    	local atlas = GetFinalNameFromTextureKit(ANIMA_GEM_TEXTURE_INFO, self.uiTextureKit);
    	gem.Gem:SetAtlas(atlas, true);
    
    	if isNew then
    		C_Timer.After(0.25, GenerateClosure(gem.Show, gem));
    	else
    		gem:Show();
    	end
    
    	return gem;
    end,

    AddStandardDataProviders = function(self)
    	self:AddDataProvider(CreateFromMixins(AnimaDiversionDataProviderMixin));	
    	local pinFrameLevelsManager = self:GetPinFrameLevelsManager(); 
    	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
    	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ANIMA_DIVERSION_MODELSCENE_PIN");
    	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ANIMA_DIVERSION_PIN");
    end, 

    SetupTextureKits =  function(self, frame, regions)
	    SetupTextureKitOnRegions(self.uiTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
    end,  

    SetupCurrencyFrame = function(self)
        local info = DataStore:GetAnimaCurrencyInfo(ns:GetAltKey())
        if not info then return end 
    	local count, icon = info.count, info.icon
    	if(count) then 
    		self.AnimaDiversionCurrencyFrame.CurrencyFrame.Quantity:SetText(ANIMA_DIVERSION_CURRENCY_DISPLAY:format(count, icon));
    	end 
    end,
})
 
addon:Controller("AltoholicUI.ShadowlandsAnimaDiversionCurrencyFrame", {
	OnBind = function(self)
    end,

    OnEnter = function(self)
    	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    	GameTooltip_AddNormalLine(GameTooltip, ANIMA_DIVERSION_CURRENCY_TOOLTIP_TITLE, true);
    	GameTooltip_AddHighlightLine(GameTooltip, ANIMA_DIVERSION_CURRENCY_TOOLTIP_DESCRIPTION, true);
    	GameTooltip:Show(); 
    end, 

    OnLeave = function(self)
	    GameTooltip:Hide(); 
    end, 
})

addon:Controller("AltoholicUI.ShadowlandsAnimaDiversionReinforceProgressFrame", {
	OnBind = function(self)
    end,

    OnEnter = function(self)
    	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    	GameTooltip_AddNormalLine(GameTooltip, ANIMA_DIVERSION_REINFORCE_STREAM_TOOLTIP_TITLE, true);
    	GameTooltip_AddHighlightLine(GameTooltip,ANIMA_DIVERSION_REINFORCE_STREAM_TOOLTIP_DESCRIPTION, true);
    	GameTooltip:Show(); 
    end, 

    OnLeave = function(self)
    	GameTooltip:Hide(); 
    end,
}) 

addon:Controller("AltoholicUI.ShadowlandsAnimaDiversionReinforceInfoFrame", {
	OnBind = function(self)
    end,
    
    OnHide = function(self)
	   self.selectedNode = nil; 
    end,

    CanReinforceAnything = function(self)
    	local animaNodes = DataStore:GetAnimaDiversionNodes(ns:GetAltKey()) 
    	if (not animaNodes) then 
    		return false;
    	end 
    
    	for _, nodeData in ipairs(animaNodes) do
    		if (nodeData.state == Enum.AnimaDiversionNodeState.Available or nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary) then 
    			return true; 
    		end
    	end  
    	return false; 
    end, 

    Init = function(self)
    	self.canReinforce = self:CanReinforceAnything() 
    end, 

    GetSelectedNode = function(self)
    	return self.selectedNode;
    end,

    ClearSelectedNode = function(self)
    	if self.selectedNode then
    		self:Init();
    	end
    
    	self.selectedNode = nil;
    end, 
}) 
