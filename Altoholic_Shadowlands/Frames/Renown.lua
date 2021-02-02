local addonName = "Altoholic"
local addon = _G[addonName]
local ns = addon.Tabs.Shadowlands

local g_covenantID;
local g_covenantData;

-- All this code adapted from Blizzard_CovenantRenown.lua

addon:Controller("AltoholicUI.ShadowlandsRenown", {
	OnBind = function(self)    
	end,
    
	Update = function(frame)
		frame:Show()
	end,

    OnShow = function(self)
	   self:SetUpCovenantData();
	   self:GetLevels();
	   local fromOnShow = true;
	   self:Refresh(fromOnShow);
	   PlaySound(SOUNDKIT.UI_COVENANT_RENOWN_OPEN_WINDOW, nil, SOUNDKIT_ALLOW_DUPLICATES);
    end,

    OnHide = function(self)
	   PlaySound(SOUNDKIT.UI_COVENANT_RENOWN_CLOSE_WINDOW, nil, SOUNDKIT_ALLOW_DUPLICATES);
    end,

    OnEvent = function(self, event, ...)
	   if event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" then
		self:Refresh();
	   elseif event == "COVENANT_RENOWN_INTERACTION_STARTED" then
		ShowUIPanel(self);
	   elseif event == "COVENANT_RENOWN_INTERACTION_ENDED" then
		HideUIPanel(self);
	   end
    end,

    OnMouseWheel = function(self, direction)
	   local track = self.TrackFrame;
	   local centerIndex = track:GetCenterIndex();
	   centerIndex = centerIndex + (direction * -1);
	   track:SetSelection(centerIndex);
    end,

    SetUpCovenantData = function(self)
	   local covenantID = DataStore:GetCovenantID(ns:GetAltKey()) or 1
       if covenantID == 0 then covenantID = 1 end -- if player doesn't have a covenant, just show the Kyrian data
	   local covenantData = C_Covenants.GetCovenantData(covenantID);
	   if g_covenantID ~= covenantID then
		g_covenantID = covenantID;
		g_covenantData = covenantData;

        SetupTextureKitOnRegions(g_covenantData.textureKit, self, {["SelectedLevelGlow"] = "CovenantSanctum-Renown-Next-Glow-%s"}, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

		-- the track
		local levels = C_CovenantSanctumUI.GetRenownLevels(covenantID);
		self.TrackFrame:Init(#levels);
		local elements = self.TrackFrame:GetElements();
		for i in ipairs(levels) do
			elements[i]:SetInfo(levels[i]);
		end
		self.maxLevel = levels[#levels].level;
	   end
    end,

    GetLevels = function(self)
	   local renownLevel = DataStore:GetRenownLevel(ns:GetAltKey()) or 0
	   self.actualLevel = renownLevel
	   self.displayLevel = renownLevel
    end,

    Refresh = function(self, fromOnShow)
	   local displayLevel = math.min(self.displayLevel + 1, self.maxLevel);
	   self:SelectLevel(displayLevel, fromOnShow);
    end,

    SelectLevel = function(self, level, fromOnShow)
	   local selectionIndex;
	   local elements = self.TrackFrame:GetElements();
	   for i, frame in ipairs(elements) do
		if frame:GetLevel() == level then
			selectionIndex = i;
			break;
		end
	   end
	   local forceRefresh = false;
	   local skipSound = fromOnShow;
	   self.TrackFrame:SetSelection(selectionIndex, forceRefresh, skipSound);
    end,
    
    OnTrackUpdate = function(self, leftIndex, centerIndex, rightIndex, isMoving)
	   local track = self.TrackFrame;
	   local elements = track:GetElements();
	   local selectedElement = elements[centerIndex];
	   local selectedLevel = selectedElement:GetLevel();
	   if self.displayLevel ~= self.actualLevel and selectedLevel ~= self.displayLevel + 1 then
		self:Refresh();
		return;
	   end
	   local elements = track:GetElements();
	   for i = leftIndex, rightIndex do
		local selected = not self.moving and centerIndex == i;
		local frame = elements[i];
		frame:Refresh(self.actualLevel, self.displayLevel, selected);
		local alpha = track:GetDesiredAlphaForIndex(i);
		frame:ApplyAlpha(alpha);
	   end
	   if not isMoving then
		self.SelectedLevelGlow:SetPoint("CENTER", elements[centerIndex]);
		self.SelectedLevelGlow:Show();
	   else
		self.SelectedLevelGlow:Hide();
	   end
    end,
})

addon:Controller("AltoholicUI.ShadowlandsRenownTrackFrame", {
    totalWidth = 570,
	elementWidth = 55,
	elementSpacing = -2,
	fullAlphaRadius = 94,	-- distance from Center where full alpha is applied to text
	
	scrollSpeeds = {
		{ timeAfter = 0.6, speed = 2 },
		{ timeAfter = 1, speed = 3 },
		{ timeAfter = 1, speed = 4 },
	},

	elementTemplate = "AltoCovenantRenownLevelTemplate",

	scrollStartSound = SOUNDKIT.UI_COVENANT_RENOWN_SLIDE_START,
	scrollStopSound = SOUNDKIT.UI_COVENANT_RENOWN_SLIDE_STOP,
	scrollCenterChangeSound = SOUNDKIT.UI_COVENANT_RENOWN_SLIDE_START,

    OnBind = function(self)
	   self.calculationWidth = self.elementWidth + self.elementSpacing;			-- this gets used in several functions
	   self.visibleRadius = math.ceil((self.totalWidth + self.elementWidth) / 2);	-- an element is visible if its center falls within this distance from track center
	   self.numElementsPerHalf = math.ceil(self.visibleRadius / self.calculationWidth);
    end,

    OnHide = function(self)
	   if self.scrollTime then
	       self:StopScroll();
	   end
    end,

    Init = function(self, numElements)
	    if not self.headElement then
		    self.numElements = numElements;
		    self.Elements = { };
		    local lastFrame;
		    for i = 1, numElements do
			    local frame = CreateFrame("FRAME", nil, self.ClipFrame, self.elementTemplate);
			    frame.index = i;
			    tinsert(self.Elements, frame);
			    if lastFrame then
				    frame:SetPoint("LEFT", lastFrame, "RIGHT", self.elementSpacing, 0);
			    else
				    self.headElement = frame;
				    frame:SetPoint("CENTER");
			    end
			    lastFrame = frame;
		    end
	    end
    end,

    GetElements = function(self)
	    return self.Elements;
    end,

    OnUpdate = function(self, elapsed)
	   if self.stopRequested then
	       self:StopScroll();
	   end
	   if not self.scrollTime then
	       return;
	   end

	   self.scrollTime = self.scrollTime + elapsed;
	   local speed = 0;
	   local runningTime = 0;
	   for _, speedData in ipairs(self.scrollSpeeds) do
	   	runningTime = runningTime + speedData.timeAfter;
		if self.scrollTime >= runningTime then
			speed = speedData.speed;
		else
			break;
		end
	   end

	   self.moving = speed > 0;
	   if self.moving then
		local offset = self.offset + speed * self.direction * self.scrollTime;
		offset = Clamp(offset, 0, self:GetMaxOffset());
		self.offset = offset;
		self.headElement:SetPoint("CENTER", -offset, 0);
		self:RefreshView();

		if not self.loopingSoundHandle and self.scrollLoopSound then
			self.loopingSoundHandle = select(2, PlaySound(self.scrollLoopSound, nil, SOUNDKIT_ALLOW_DUPLICATES));
		end
	   end	
    end,

    SetSelection = function(self, index, forceRefresh, skipSound)
	   -- stops other sources (like parent's mousewheel) from interfering during movement
	   if self.scrollTime then
		return;
	   end
       
	   index = index or self.numElements;
	   index = Clamp(index, 1, self.numElements);
	   if self.selectedIndex ~= index and not skipSound and self.scrollStopSound then
		PlaySound(self.scrollStopSound, nil, SOUNDKIT_ALLOW_DUPLICATES);
	   end
	   self.selectedIndex = index;
	   local offset = self:GetAbsoluteOffsetForIndex(index);
	   self.headElement:SetPoint("CENTER", -offset, 0);
	   self.offset = offset;
	   if forceRefresh then
		self.centerIndex = nil;
	   end
	   self:RefreshView();
    end,

    RefreshView = function(self)
	   local centerIndex = self:GetClosestIndexToCenter();
	   if self.centerIndex ~= centerIndex then
		self.centerIndex = centerIndex;
		local leftIndex = math.max(1, centerIndex - self.numElementsPerHalf);
		local rightIndex = math.min(centerIndex + self.numElementsPerHalf, self.numElements);
		self:GetParent():OnTrackUpdate(leftIndex, centerIndex, rightIndex, self.moving);
		if self.moving and self.scrollCenterChangeSound then
			PlaySound(self.scrollCenterChangeSound, nil, SOUNDKIT_ALLOW_DUPLICATES);
		end
	   end

	   self.LeftButton:SetEnabled(self.offset > 0);
	   self.RightButton:SetEnabled(self.offset < self:GetMaxOffset());	
    end,

    GetCenterIndex = function(self)
	   return self.centerIndex;
    end,

    GetDesiredAlphaForIndex = function(self, index)
	   local alpha = 0;
	   local distance = math.abs(self:GetDistanceFromCenterForIndex(index));
	   if distance <= self.fullAlphaRadius then
		alpha = 1;
	   elseif distance <= self.visibleRadius then
		alpha = Lerp(1, 0, distance/self.visibleRadius);
	   end
	   return alpha;
    end,

    GetAbsoluteOffsetForIndex = function(self, index)
	   return (index - 1) * self.calculationWidth;
    end,

    GetMaxOffset = function(self)
	   if not self.maxOffset then
		self.maxOffset = self:GetAbsoluteOffsetForIndex(self.numElements);
	   end
	   return self.maxOffset;
    end,

    GetClosestIndexToCenter = function(self)
	   local index = self.offset / self.calculationWidth;
	   index = math.floor(index) + 1;
	   return index;
    end,

    GetDistanceFromCenterForIndex = function(self, index)
    	return (index - 1) * self.calculationWidth - self.offset;
    end,

    StartScroll = function(self, direction)
	   self.scrollTime = 0;
	   self.direction = direction;
    end,

    StopScroll = function(self, direction)
	   self.scrollTime = nil;
	   if not self.moving and self.direction then
	       	self:SetSelection(self.selectedIndex + self.direction);
	   end
	   self.moving = false;
	   self.stopRequested = false;
	   if self.loopingSoundHandle then
    		StopSound(self.loopingSoundHandle);
	       	self.loopingSoundHandle = nil;
	   end
	   -- figure out next based on offset
	   local centerIndex = self:GetClosestIndexToCenter();
	   local offset = self:GetAbsoluteOffsetForIndex(centerIndex);
	   local delta = self.offset - offset;
	   local forceRefresh = true;
	   if delta < 1 or self.direction == -1 then
		  self:SetSelection(centerIndex, forceRefresh);
	   else
		  self:SetSelection(centerIndex + 1, forceRefresh);
	   end
    end,

    RequestStop = function(self)
	   if self.scrollTime then
		  self.stopRequested = true;
	   end
    end,
})

addon:Controller("AltoholicUI.ShadowlandsRenownTrackButton", {

    OnBind = function(self)
	   if self.direction == 1 then
	    self:GetNormalTexture():SetTexCoord(1, 0, 0, 1);
		self:GetHighlightTexture():SetTexCoord(1, 0, 0, 1);
		self:GetPushedTexture():SetTexCoord(1, 0, 0, 1);
		self:GetDisabledTexture():SetTexCoord(1, 0, 0, 1);
	   end
    end,

    OnMouseDown = function(self)
	   if self:IsEnabled() then
    		local track = self:GetParent();
    		track:StartScroll(self.direction);
    		if track.scrollStartSound then
    			PlaySound(track.scrollStartSound, nil, SOUNDKIT_ALLOW_DUPLICATES);
    		end
    	end
    end,

    OnMouseUp = function(self)
	   if self:IsEnabled() then
	       	local track = self:GetParent();
		  track:StopScroll();
	   end
    end,

    OnDisable = function(self)
	   local track = self:GetParent();
	   track:RequestStop();
    end,
})

addon:Controller("AltoholicUI.ShadowlandsRenownLevel", {
    SetInfo = function(self, info)
	   self.info = info;
	   self.init = false;
    end,

    GetLevel = function(self)
	   return self.info and self.info.level or 0;
    end,

    TryInit = function(self)
	   if self.init then
		return;
	   end

	   self.init = true;
	   self.Level:SetText(self.info.level);

	   if self.info.isCapstone then
		self.Icon:AddMaskTexture(self.HexMask);
		self.HighlightTexture:SetAtlas("CovenantSanctum-Renown-Hexagon-Hover", TextureKitConstants.UseAtlasSize);
	   else
		self.Icon:RemoveMaskTexture(self.HexMask);
		self.HighlightTexture:SetAtlas("CovenantSanctum-Renown-Icon-Hover", TextureKitConstants.UseAtlasSize);
	   end

	   local maskTexture = self:GetParent().Mask;
	   for i, texture in ipairs(self.Textures) do
		texture:AddMaskTexture(maskTexture);
	   end

	   local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(g_covenantID, self:GetLevel());
	   -- use first reward for icon
	   self.rewardInfo = rewards[1];
	   self:SetIcon();
    end,

    Refresh = function(self, actualLevel, displayLevel, selected)
	   self:TryInit();

	   local level = self:GetLevel();
	   local earned = level <= displayLevel;
	   local borderAtlas;
	   if selected then
		borderAtlas = "CovenantSanctum-Renown-Next-Border-%s";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Next-Border-%s";
		elseif self.info.isMilestone then
			borderAtlas = "CovenantSanctum-Renown-Special-Next-Border-%s";
		end
	   elseif earned then
		borderAtlas = "CovenantSanctum-Renown-Icon-Border-%s";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Border-%s";
		elseif self.info.isMilestone then
			borderAtlas = "CovenantSanctum-Renown-Special-Border-%s";
		end
	   else
		borderAtlas = "CovenantSanctum-Renown-Icon-Border-Disabled";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Border-Disabled";
		elseif self.info.isMilestone then
			borderAtlas = "CovenantSanctum-Renown-Special-Disabled-Border-%s";
		end
	   end
	   self.IconBorder:SetAtlas(borderAtlas:format(g_covenantData.textureKit), TextureKitConstants.UseAtlasSize);

	   if earned then
		self.Icon:SetDesaturated(false);
		self.Level:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	   else
		self.Icon:SetDesaturated(true);
		self.Level:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	   end
	   self.Check:SetShown(level <= actualLevel);
    end,

    SetIcon = function(self)
	   if not self.rewardInfo then return end
	   self.Icon:SetTexture((CovenantUtil.GetRenownRewardInfo(self.rewardInfo, GenerateClosure(self.SetIcon, self))))
    end,

    ApplyAlpha = function(self, alpha)
	   self.Level:SetAlpha(alpha);
    end,

    OnMouseUp = function(self)
	   local track = self:GetParent():GetParent();
	   track:SetSelection(self.index);
    end,

    OnEnter = function(self)
	   GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -8, -8);
	   self:RefreshTooltip();
    end,

    RefreshTooltip = function(self)
	   if not GameTooltip:GetOwner() == self then
		return;
	   end

	   local onItemUpdateCallback = GenerateClosure(self.RefreshTooltip, self);
	   local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(g_covenantID, self:GetLevel());
	   local addRewards = true;
	   if self.isCapstone then
		GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddHighlightLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC2);
	   else
		if #rewards == 1 then
			local icon, name, description = CovenantUtil.GetRenownRewardInfo(rewards[1], onItemUpdateCallback);
			GameTooltip_SetTitle(GameTooltip, name);
			GameTooltip_AddNormalLine(GameTooltip, description);
			addRewards = false;
		else
			GameTooltip_SetTitle(GameTooltip, string.format(RENOWN_REWARD_MILESTONE_TOOLTIP_TITLE, self.info.level));
		end
	   end
	   if addRewards then
		for i, rewardInfo in ipairs(rewards) do
			local _, name = CovenantUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback);
			if name then
				GameTooltip_AddNormalLine(GameTooltip, string.format(RENOWN_REWARD_TOOLTIP_REWARD_LINE, name));
			end
		end
	   end
	   GameTooltip:Show();
    end,
})