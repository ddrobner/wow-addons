local addonName = "Altoholic"
local addon = _G[addonName]
local ns = addon.Tabs.Shadowlands

addon:Controller("AltoholicUI.ShadowlandsSoulbindPanel", {
	OnBind = function(self)	
	end,
	Update = function(self)    	
    	local character = ns:GetAltKey()
    	if not character then return end
        
        local covenantID = DataStore:GetCovenantID(ns:GetAltKey())
        if not covenantID or covenantID == 0 then
            self:Hide()
            self.Tree1:Hide()
            self.Tree2:Hide()
            self.Tree3:Hide()
            return
        end
        
        self:Show()
        self.Tree1:Show()
        self.Tree2:Show()
        self.Tree3:Show()
	end,
})

local SoulbindTreeLinkDirections = 
{
	Vertical = 1,
	Converge = 2,
	Diverge = 3,
};

addon:Controller("AltoholicUI.ShadowlandsSoulbindTreeNodeLink", {
    Init = function(self, direction, angle)
    	if direction == SoulbindTreeLinkDirections.Vertical then
    		self.Background:SetAtlas("Soulbinds_Tree_Connector_Vertical", true);
    		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Vertical_Mask", true);
    	elseif direction == SoulbindTreeLinkDirections.Converge then
    		self.Background:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Close", true);
    		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Close_Mask", true);
    	elseif direction == SoulbindTreeLinkDirections.Diverge then
    		self.Background:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Far", true);
    		self.FillMask:SetAtlas("Soulbinds_Tree_Connector_Diagonal_Far_Mask", true);
    	end
    
    	self:RotateTextures(angle);
    end,

    OnHide = function(self)
    	self.FlowAnim1:Stop();
    	self.FlowAnim2:Stop();
    	self.FlowAnim3:Stop();
    	self.FlowAnim4:Stop();
    	self.FlowAnim5:Stop();
    	self.FlowAnim6:Stop();
    end,

    Reset = function(self)
    	self:SetState(Enum.SoulbindNodeState.Unselected);
    end,

    SetState = function(self, state)
    	self.state = state;
    
    	if state == Enum.SoulbindNodeState.Unselected or state == Enum.SoulbindNodeState.Unavailable then
    		self:DesaturateHierarchy(1);
    		for _, foreground in ipairs(self.foregrounds) do
    			foreground:SetShown(false);
    		end
    		self.FlowAnim1:Stop();
    		self.FlowAnim2:Stop();
    		self.FlowAnim3:Stop();
    		self.FlowAnim4:Stop();
    		self.FlowAnim5:Stop();
    		self.FlowAnim6:Stop();
    	elseif state == Enum.SoulbindNodeState.Selectable then
    		self:DesaturateHierarchy(0);
    		for _, foreground in ipairs(self.foregrounds) do
    			foreground:SetShown(true);
    			foreground:SetVertexColor(.3, .3, .3);
    		end
    	elseif state == Enum.SoulbindNodeState.Selected then
    		self:DesaturateHierarchy(0);
    		for _, foreground in ipairs(self.foregrounds) do
    			foreground:SetShown(true);
    			foreground:SetVertexColor(.192, .686, .941);
    		end
    	end
    end,

    GetState = function(self)
    	return self.state;
    end,
})

local SoulbindConduitMixin = CreateFromMixins(SpellMixin)

function SoulbindConduitMixin:Init(conduitID)
	self.conduitID = conduitID;
	if self:IsValid() then
		self:SetSpellID(C_Soulbinds.GetConduitSpellID(conduitID, self:GetConduitRank()));
	end
end

function SoulbindConduitMixin:IsValid()
	return self.conduitID > 0;
end

function SoulbindConduitMixin:GetConduitID()
	return self.conduitID;
end

function SoulbindConduitMixin:GetConduitRank()
	local rank = DataStore:GetConduitRankFromCollection(ns:GetAltKey(), self:GetConduitID());
	return self:IsValid() and math.max(rank, 1) or 1;
end

function SoulbindConduitMixin:Matches(conduit)
	return conduit and self:GetConduitID() == conduit:GetConduitID();
end

function SoulbindConduitMixin:GetHyperlink()
	return C_Soulbinds.GetConduitHyperlink(self:GetConduitID(), self:GetConduitRank());
end

local Soulbinds = {};

local SOULBINDS_COVENANT_KYRIAN = 1;
local SOULBINDS_COVENANT_VENTHYR = 2;
local SOULBINDS_COVENANT_NIGHT_FAE = 3;
local SOULBINDS_COVENANT_NECROLORD = 4;
local soulbindDefaultIDs = {
	[SOULBINDS_COVENANT_KYRIAN] = 7,
	[SOULBINDS_COVENANT_VENTHYR] = 8,
	[SOULBINDS_COVENANT_NIGHT_FAE] = 1,
	[SOULBINDS_COVENANT_NECROLORD] = 4,
};

function Soulbinds.GetDefaultSoulbindID(covenantID)
	return soulbindDefaultIDs[covenantID];
end

function Soulbinds.GetConduitName(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return CONDUIT_POTENCY;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return CONDUIT_ENDURANCE;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return CONDUIT_FINESSE;
	end
end

function Soulbinds.GetConduitEmblemAtlas(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return "Soulbinds_Tree_Conduit_Icon_Attack";
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return "Soulbinds_Tree_Conduit_Icon_Protect";
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return "Soulbinds_Tree_Conduit_Icon_Utility";
	end
end

local SoulbindTreeNodeMixin = CreateFromMixins(CallbackRegistryMixin);

function SoulbindTreeNodeMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self.linkFrames = {};
end

function SoulbindTreeNodeMixin:OnEnter()
	self:LoadTooltip();
	self.MouseOverlay:Show();
end

function SoulbindTreeNodeMixin:OnLeave()
	GameTooltip:Hide();
	self.MouseOverlay:Hide();
end

function SoulbindTreeNodeMixin:SetAnimDuration(seconds)
	self.RingOverlay.Anim.FadeIn:SetDuration(seconds);
	self.RingOverlay.Anim.FadeOut:SetDuration(seconds);
end

function SoulbindTreeNodeMixin:Init(node)
	self:SetNode(node);
	self:UpdateVisuals();
end

function SoulbindTreeNodeMixin:PlaySelectionEffect()
	local modelScene = self:GetFxModelScene();
	local NODE_SELECTION_FX_1 = 42;
	local NODE_SELECTION_FX_2 = 48;
	modelScene:AddEffect(NODE_SELECTION_FX_1, self);
	modelScene:AddEffect(NODE_SELECTION_FX_2, self);
end

function SoulbindTreeNodeMixin:OnStateTransition(oldState, newState)
	if newState == Enum.SoulbindNodeState.Selected and oldState == Enum.SoulbindNodeState.Selectable then
		self:PlaySelectionEffect();
		local LEARN_SHAKE_DELAY = 0;
		C_Timer.After(LEARN_SHAKE_DELAY, GenerateClosure(self.Shake, self));
	end
end

function SoulbindTreeNodeMixin:Shake()
	if self:IsShown() then
		local SHAKE = { { x = 0, y = -5}, { x = 0, y = 5}, { x = 0, y = -5}, { x = 0, y = 5}, { x = -3, y = -2}, { x = 2, y = 2}, { x = -1, y = -2}, { x = 3, y = 2}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, };
		local SHAKE_DURATION = 0.1;
		local SHAKE_FREQUENCY = 0.001;
		ScriptAnimationUtil.ShakeFrame(UIParent, SHAKE, SHAKE_DURATION, SHAKE_FREQUENCY)
	end
end

function SoulbindTreeNodeMixin:GetFxModelScene()
	return self.FxModelScene;
end

function SoulbindTreeNodeMixin:Reset()
	self.node = nil;
	self.linkFrames = {};
	self.RingOverlay:Hide();
	self.RingOverlay.Anim:Stop();
	self:GetFxModelScene():ClearEffects();
end

function SoulbindTreeNodeMixin:UpdateVisuals()
	if self:IsUnavailable() then
		self.Icon:SetDesaturated(true);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	elseif self:IsUnselected() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(true);
		self.MouseOverlay:SetDesaturated(true);
	elseif self:IsSelectable() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Hide();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	elseif self:IsSelected() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Hide();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	end
end

function SoulbindTreeNodeMixin:IsSelected()
	return self:GetState() == Enum.SoulbindNodeState.Selected;
end

function SoulbindTreeNodeMixin:IsSelectable()
	return self:GetState() == Enum.SoulbindNodeState.Selectable;
end

function SoulbindTreeNodeMixin:IsUnselected()
	return self:GetState() == Enum.SoulbindNodeState.Unselected;
end

function SoulbindTreeNodeMixin:IsUnavailable()
	return self:GetState() == Enum.SoulbindNodeState.Unavailable;
end

function SoulbindTreeNodeMixin:GetState()
	return self.node and self.node.state or nil;
end

function SoulbindTreeNodeMixin:GetNode()
	return self.node;
end

function SoulbindTreeNodeMixin:SetNode(node)
	local oldState = self:GetState();
	self.node = node;
	local newState = self:GetState();
	if oldState and oldState ~= newState then
		self:OnStateTransition(oldState, newState);
	end
end

function SoulbindTreeNodeMixin:AddLink(linkFrame)
	table.insert(self.linkFrames, linkFrame);
end

function SoulbindTreeNodeMixin:GetLinks()
	return self.linkFrames;
end

function SoulbindTreeNodeMixin:GetID()
	return self.node.ID;
end

function SoulbindTreeNodeMixin:GetRow()
	return self.node.row;
end

function SoulbindTreeNodeMixin:GetColumn()
	return self.node.column;
end

function SoulbindTreeNodeMixin:GetIcon()
	return self.node.icon;
end

function SoulbindTreeNodeMixin:GetSpellID()
	return self.node.spellID;
end

function SoulbindTreeNodeMixin:GetParentNodeIDs()
	return self.node.parentNodeIDs;
end

function SoulbindTreeNodeMixin:IsConduit()
	return self.node.conduitType ~= nil;
end

function SoulbindTreeNodeMixin:GetConduitID()
	return self.node and self.node.conduitID or nil;
end

function SoulbindTreeNodeMixin:GetConduitRank()
	return self.node.conduitRank;
end

function SoulbindTreeNodeMixin:GetUnavailableReason()
	if self.node.failureRenownRequirement then
		local renownLevel = DataStore:GetRenownLevel(ns:GetAltKey())
		local renownRequirement = self.node.failureRenownRequirement;

		return SOULBIND_NODE_RENOWN_ERROR_FORMAT:format(renownRequirement, renownLevel);
		
	elseif self.node.playerConditionReason then
		return self.node.playerConditionReason;
	end
end

function SoulbindTreeNodeMixin:SetSelectableAnimShown(shown, editable, canSelectMultiple)
	self.RingOverlay:SetShown(shown);
	
	local animated = shown and editable;
	if animated then
		self.RingOverlay.Anim:SetPlaying(shown);
	end

	local showArrow = animated and canSelectMultiple;
	self.Arrow:SetShown(showArrow);
	self.Arrow2:SetShown(showArrow);
end

function SoulbindTreeNodeMixin:StopAnimations()
	self.RingOverlay:Hide();
	self.RingOverlay.Anim:Stop();
	self.Arrow:Hide();
	self.Arrow2:Hide();
end

addon:Controller("AltoholicUI.ShadowlandsSoulbindTreeNode", {
    OnBind = function(self)
        Mixin(self, SoulbindTreeNodeMixin)
    end,
})

local SoulbindTraitNodeMixin = CreateFromMixins(SoulbindTreeNodeMixin);

function SoulbindTraitNodeMixin:OnLoad()
	SoulbindTreeNodeMixin.OnLoad(self);
end

function SoulbindTraitNodeMixin:Init(node)
	SoulbindTreeNodeMixin.Init(self, node);
	
	if not self.spell then
		self.spell = Spell:CreateFromSpellID(self:GetSpellID());
	end

	self.Icon:SetTexture(self:GetIcon());
end

function SoulbindTraitNodeMixin:LoadTooltip()
	local onSpellLoad = function()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.spell:GetSpellID());
		GameTooltip:Show();
	end;
	self.spell:ContinueOnSpellLoad(onSpellLoad);
end

function SoulbindTraitNodeMixin:Reset()
	SoulbindTreeNodeMixin.Reset(self);

	self.spell = nil;
end

function SoulbindTraitNodeMixin:UpdateVisuals()
	SoulbindTreeNodeMixin.UpdateVisuals(self);

	if self:IsUnavailable() then
		self.Ring:SetAtlas("Soulbinds_Tree_Ring_Disabled", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Ring_Disabled", false);
	else
		self.Ring:SetAtlas("Soulbinds_Tree_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Ring", false);
	end
end

addon:Controller("AltoholicUI.ShadowlandsTraitNode", {
    OnBind = function(self)
        Mixin(self, SoulbindTraitNodeMixin)
    end,
})

local SoulbindConduitNodeMixin = CreateFromMixins(SoulbindTreeNodeMixin);

function SoulbindConduitNodeMixin:OnLoad()
	SoulbindTreeNodeMixin.OnLoad(self);
	self.animTextures =
	{
		self.PickupOverlay,
		self.PickupOverlay2,
		self.PickupArrowsOverlay,
		self.UnsocketedWarning,
		self.UnsocketedWarning2,
	};
end

function SoulbindConduitNodeMixin:OnEnter()
	SoulbindTreeNodeMixin.OnEnter(self);

	self:TrySetConduitListConduitsPulsePlaying();
end

function SoulbindConduitNodeMixin:OnLeave()
	SoulbindTreeNodeMixin.OnLeave(self);
end

function SoulbindConduitNodeMixin:TrySetConduitListConduitsPulsePlaying()
end

function SoulbindConduitNodeMixin:EvaluateSetConduitListConduitsPulsePlaying()
end

function SoulbindConduitNodeMixin:Reset()
	SoulbindTreeNodeMixin.Reset(self);
	self.conduit = nil;
	self.Icon:Hide();
	for _, texture in ipairs(self.SocketAnimTextures) do
		texture.Anim:Stop();
	end
end

function SoulbindConduitNodeMixin:SetConduit(conduitID, initializing)
	self.conduit = CreateAndInitFromMixin(SoulbindConduitMixin, conduitID)
	self:DisplayConduit();
end

function SoulbindConduitNodeMixin:GetConduit()
	return self.conduit;
end

function SoulbindConduitNodeMixin:Init(node)
	SoulbindTreeNodeMixin.Init(self, node);
	
	local atlas = Soulbinds.GetConduitEmblemAtlas(self:GetConduitType());
	self.Emblem:SetAtlas(atlas);
	self.EmblemBg:SetAtlas(atlas)
	self.EmblemBg:SetVertexColor(0, 0, 0);

	local conduitID = DataStore:GetInstalledConduitID(ns:GetAltKey(), self:GetID())
	local initializing = true;
	self:SetConduit(conduitID, initializing);

	self:DisplayConduit();
end

function SoulbindConduitNodeMixin:PlaySocketAnimation()
	for _, texture in ipairs(self.SocketAnimTextures) do
		texture.Anim:Play();
	end

	local CONDUIT_INSTALL_FX_1 = 48;
	local CONDUIT_INSTALL_FX_2 = 44;
	self:GetFxModelScene():AddEffect(CONDUIT_INSTALL_FX_1, self);
	self:GetFxModelScene():AddEffect(CONDUIT_INSTALL_FX_2, self);
end

function SoulbindConduitNodeMixin:UpdateVisuals()
	SoulbindTreeNodeMixin.UpdateVisuals(self);
	
	if self:IsUnavailable() then
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring_Disabled", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring_Disabled", false);
		self.Emblem:SetDesaturated(true);
		self.Emblem:SetAlpha(.75);
	elseif self:IsUnselected() then
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.Emblem:SetDesaturated(true);
		self.Emblem:SetAlpha(.75);
	else
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.Emblem:SetDesaturated(false);
		self.Emblem:SetAlpha(1.0);
	end
end

function SoulbindConduitNodeMixin:GetConduitType()
	return self.node.conduitType;
end

function SoulbindConduitNodeMixin:IsConduitType(type)
	return self:GetConduitType() == type;
end

function SoulbindConduitNodeMixin:SetUsingStaticAnimOverride(useAnimOverride)
	if useAnimOverride then
		self.PickupArrowsOverlay:SetAtlas(nil);
		self.PickupArrowsStatic:Show();
	else
		self.PickupArrowsOverlay:SetAtlas("Soulbinds_Tree_Conduit_Arrows", false);
		self.PickupArrowsStatic:Hide();
	end
end

function SoulbindConduitNodeMixin:SetUnsocketedWarningAnimShown(shown)
	for _, texture in ipairs(self.UnsocketedWarningTextures) do
		texture:SetShown(shown);
		texture.Anim:SetPlaying(shown);
	end
end

function SoulbindConduitNodeMixin:StopAnimations()
	SoulbindTreeNodeMixin.StopAnimations(self);

	for _, texture in ipairs(self.animTextures) do
		texture.Anim:Stop();
		texture:Hide();
	end
end

function SoulbindConduitNodeMixin:DisplayConduit()
	local conduit = self.conduit;
	if conduit:IsValid() then
		if not conduit.Matches(self:GetConduit()) then
			local onConduitSpellLoad = function()
				local spellID = conduit:GetSpellID();
				self.Icon:SetTexture(GetSpellTexture(spellID));
				self.Icon:Show();
			end
			conduit:ContinueOnSpellLoad(onConduitSpellLoad);
		end
	else
		self.Icon:Hide();
	end
end

function SoulbindTreeNodeMixin:AddNotInProximityLine()
	if self:IsConduit() then
		GameTooltip_AddErrorLine(GameTooltip, SOULBIND_CONDUIT_ACTIVATE_UNAVAIL);
	else
		GameTooltip_AddErrorLine(GameTooltip, SOULBIND_NODE_ACTIVATE_UNAVAIL);
	end
end

local function GetUninstalledConduitStrings(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return CONDUIT_SLOT_POTENCY, CONDUIT_TYPE_DESC_POTENCY;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return CONDUIT_SLOT_ENDURANCE, CONDUIT_TYPE_DESC_ENDURANCE;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return CONDUIT_SLOT_FINESSE, CONDUIT_TYPE_DESC_FINESSE;
	end
end

function SoulbindConduitNodeMixin:LoadTooltip()
	local conduit = self:GetConduit();
	if conduit:IsValid() then
		local onConduitLoad = function()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetConduit(conduit:GetConduitID(), conduit:GetConduitRank()); 
			GameTooltip:Show();
		end;
		conduit:ContinueOnSpellLoad(onConduitLoad);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local title, description = GetUninstalledConduitStrings(self:GetConduitType());
		GameTooltip_SetTitle(GameTooltip, title);
		GameTooltip_AddNormalLine(GameTooltip, description);
		GameTooltip:Show();
	end
end

addon:Controller("AltoholicUI.ShadowlandsSoulbindConduitNode", {
    OnBind = function(self)
        Mixin(self, SoulbindConduitNodeMixin)
    end,
})

local CONDUIT_TEMPLATE = "AltoSoulbindConduitNodeTemplate";
local TRAIT_TEMPLATE = "AltoSoulbindTraitNodeTemplate";
local LINK_TEMPLATE = "AltoSoulbindTreeNodeLinkTemplate";
local SELECT_ANIM_TEMPLATE = "PowerSwirlTemplate";

addon:Controller("AltoholicUI.ShadowlandsSoulbindTree", {
    OnBind = function(self)
    	local resetterCb = function(pool, frame)
    		frame:Reset();
    		FramePool_HideAndClearAnchors(pool, frame);
    	end;
    	
    	self.pools = CreateFramePoolCollection();
    	self.pools:CreatePool("BUTTON", self.NodeContainer, TRAIT_TEMPLATE, resetterCb);
    	self.pools:CreatePool("BUTTON", self.NodeContainer, CONDUIT_TEMPLATE, resetterCb);
    	self.pools:CreatePool("FRAME", self.LinkContainer, LINK_TEMPLATE, resetterCb);
    	self.pools:CreatePool("FRAME", self.Fx, SELECT_ANIM_TEMPLATE);
    end,
    
    OnShow = function(self)
    	local covenantID = DataStore:GetCovenantID(ns:GetAltKey())
    	if covenantID == 0 then
    		self:Hide()
            return
    	end
    
    	local soulbindIndex = self:GetID()
        local covenantData = C_Covenants.GetCovenantData(covenantID)
        
        local soulbindID = covenantData.soulbindIDs[soulbindIndex]
    	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
    
        self.soulbindID = soulbindID
    	self.soulbindData = soulbindData;
    	self.covenantData = covenantData;
    
    	self:Init(soulbindData);
    end,
    
    Reset = function(self)
    	self.pools:ReleaseAll();
    	self.soulbindID = nil;
    	self.nodeFrames = nil;
    	self.linkToFrames = nil;
    	if self.mouseOverTimer then
    		self.mouseOverTimer:Cancel();
    	end
    end,

    OnHide = function(self)
    	self:Reset();
    end,

    GetNodes = function(self)
    	return self.nodeFrames;
    end,

    OnSelectAnimFinished = function(self, frame, anim)
    	local pool = self.pools:GetPool(SELECT_ANIM_TEMPLATE);
    	pool:Release(frame);
    end,

    StopNodeAnimationsIf = function(self, predicate)
    	for _, nodeFrame in pairs(self.nodeFrames) do
    		if predicate(nodeFrame) then
    			nodeFrame:StopAnimations();
    		end
    	end
    end,

    StopNodeAnimations = function(self)
    	for _, nodeFrame in pairs(self.nodeFrames) do
    		nodeFrame:StopAnimations();
    	end
    end,

    GetSelectableCount = function(self)
    	return AccumulateIf(self.nodeFrames, 
    		function(nodeFrame)
    			return nodeFrame:IsSelectable();
    		end
    	);
    end,

    Init = function(self, soulbindData)
    	self.soulbindID = soulbindData.ID;
    
    	local cellVerticalDist = 38;
    	local cellHorizontalDist = 70;
    	local tree = soulbindData.tree;
    	local nodes = tree.nodes;
        
  		if not self.constructed then
  			self.constructed = true;
  		end
  		
  		self.pools:ReleaseAll();
  		self.nodeFrames = {};
  		self.linkToFrames = {};
  
  		for _, node in ipairs(nodes) do
  			local template = node.conduitType and CONDUIT_TEMPLATE or TRAIT_TEMPLATE;
  			local nodeFrame = self.pools:Acquire(template);
  			nodeFrame:Init(node);
  
  			local row = nodeFrame:GetRow();
  			local column = nodeFrame:GetColumn();
  			local x = column * cellHorizontalDist;
  			local y = row * cellVerticalDist;
  
  			local coord = {x = x, y = -y};
  			nodeFrame:SetPoint("TOPLEFT", nodeFrame:GetParent(), "TOPLEFT", coord.x, coord.y);
  			nodeFrame.coord = coord;
  
  			local nodeID = nodeFrame:GetID();
  			self.nodeFrames[nodeID] = nodeFrame;
  			nodeFrame:Show();
  		end
  	
  		local diagonalDistSq = Square(cellHorizontalDist) + Square(cellVerticalDist);
  		
  		for _, linkFromFrame in pairs(self.nodeFrames) do
  			if linkFromFrame:GetRow() > 0 then
  				for _, parentID in ipairs(linkFromFrame:GetParentNodeIDs()) do
  					local linkToFrame = self.nodeFrames[parentID];
  					local linkFrame = self.pools:Acquire(LINK_TEMPLATE);
  
  					local toColumn = linkToFrame:GetColumn();
  					local fromColumn = linkFromFrame:GetColumn();
  					local offset = toColumn - fromColumn;
  					
  					if offset < 0 then
  						linkFrame:SetPoint("BOTTOMRIGHT", linkFromFrame, "TOPLEFT");
  						linkFrame:SetPoint("TOPLEFT", linkToFrame, "BOTTOMRIGHT");
  					elseif offset > 0 then
  						linkFrame:SetPoint("BOTTOMLEFT", linkFromFrame, "TOPRIGHT");
  						linkFrame:SetPoint("TOPRIGHT", linkToFrame, "BOTTOMLEFT");
  					else
  						linkFrame:SetPoint("BOTTOM", linkFromFrame, "TOP");
  						linkFrame:SetPoint("TOP", linkToFrame, "BOTTOM");
  					end
  
  					local direction;
  					local diagonal = toColumn ~= fromColumn;
  					if diagonal then
  						local distSq = RegionUtil.CalculateDistanceSqBetween(linkFromFrame, linkToFrame);
  						direction = distSq < diagonalDistSq and SoulbindTreeLinkDirections.Converge or SoulbindTreeLinkDirections.Diverge;
  					else
  						direction = SoulbindTreeLinkDirections.Vertical;
  					end
  
  					local quarter = (math.pi / 2);
  					local angle = RegionUtil.CalculateAngleBetween(linkToFrame, linkFromFrame) - quarter;
  
  					self.linkToFrames[linkFrame] = linkToFrame;
  
  					linkFrame:Init(direction, angle);
  					linkFrame:Show();
  
  					linkFromFrame:AddLink(linkFrame);
  				end
  			end
  		end
    
    	for _, nodeFrame in pairs(self.nodeFrames) do
    		local state = nodeFrame:GetState();
    		for _, linkFrame in ipairs(nodeFrame:GetLinks()) do
    			local linkToFrame = self.linkToFrames[linkFrame];
    			linkFrame:SetState(linkToFrame:IsSelected() and state or Enum.SoulbindNodeState.Unselected);
    		end
    	end
    end,
})