local _, T = ...
local EV = T.Evie
local NINE = select(4, GetBuildInfo()) > 9e4

do -- T.After0
	local OVERTIME_LIMIT = 1000
	local f, q, nq, lqc, lq = CreateFrame("Frame"), {}, 0, 0
	function T.After0(func)
		if lq == GetTime() and lqc < OVERTIME_LIMIT then
			lqc = lqc + 1
			securecall(func)
		else
			nq = nq + 1
			q[nq] = func
		end
	end
	f:SetScript("OnUpdate", function()
		lq, lqc = GetTime(), 0
		if nq ~= 0 then
			local i, f = 1, q[1]
			while f do
				securecall(f)
				i, q[i] = i + 1
				f = q[i]
			end
			nq = 0
		end
	end)
end

local ShowOverlayGlow, HideOverlayGlow do
	local baseName = "_M6ActivationAlert"
	local assigned, spares, count = {}, {}, 0

	local function OnFinished(self)
		local glow = self:GetParent()
		local owner = glow:GetParent()
		spares[glow], assigned[owner] = glow
		glow:Hide()
	end
	local function OnHide(self)
		if self.animOut:IsPlaying() then
			self.animOut:Stop()
			OnFinished(self.animOut)
		end
	end
	local function GetOverlayGlow()
		local s = next(spares)
		if s then
			spares[s] = nil
			return s
		end
		count, s = count + 1, CreateFrame("Frame", baseName .. count, nil, "ActionBarButtonSpellActivationAlert")
		s:SetScript("OnHide", OnHide)
		s.animOut:SetScript("OnFinished", OnFinished)
		return s
	end

	local clear, emptyClear, OnFinishIn = {}, true do
		local e = GetOverlayGlow()
		spares[e], OnFinishIn = 1, e.animIn:GetScript("OnFinished")
		e:Hide()
	end
	function ShowOverlayGlow(frame)
		local s = assigned[frame]
		if s then
			if s.animOut:IsPlaying() then
				s.animOut:Stop()
				s.animIn:Play()
			end
		else
			local s, w, h = GetOverlayGlow(), frame:GetSize()
			s:SetParent(frame)
			s:SetSize(w * 1.4, h * 1.4)
			s:ClearAllPoints()
			s:SetPoint("TOPLEFT", -w * 0.2, h * 0.2)
			s:SetPoint("BOTTOMRIGHT", w * 0.2, -h * 0.2)
			s:Show()
			s.animIn:Play()
			assigned[frame] = s
		end
		clear[frame] = nil
	end
	function HideOverlayGlow(frame)
		local s = assigned[frame]
		if not s then return end
		if s.animIn:IsPlaying() then
			s.animIn:Stop()
			OnFinishIn(s.animIn)
		end
		if frame:IsVisible() then
			s.animOut:Play()
		else
			OnFinished(s.animOut)
		end
	end

	local function checkClear()
		emptyClear = true
		for k in pairs(clear) do
			HideOverlayGlow(k)
			clear[k] = nil
		end
	end
	hooksecurefunc("ActionButton_HideOverlayGlow", function(self)
		clear[self] = 1
		if emptyClear then
			T.After0(checkClear)
			emptyClear = false
		end
	end)
end

local skipNonIconUpdates = setmetatable({}, {__index=function(s, f)
	local n, r = f and f.GetName and f:GetName(), false
	if n and n:match("^MacroButton%d+$") then
		r = true
	end
	if f ~= nil then
		s[f] = r
	end
	return r
end})

local managed, skipToken = {}, {}, newproxy()

local queueSingle, queueAll, mayHaveExternalListeners do
	local manaR, manaG, manaB, rangeR, rangeG, rangeB = 0.5, 0.5, 1, 1,1,1 do
		local function fromHexColor(c)
			local r,g,b = c:match("(%x%x)(%x%x)(%x%x)")
			return tonumber(r,16)/255, tonumber(g,16)/255, tonumber(b,16)/255
		end
		function EV:M6_READY(conf)
			manaR, manaG, manaB = fromHexColor(conf.icManaColor)
			rangeR, rangeG, rangeB = fromHexColor(conf.icRangeColor)
		end
	end
	local function updateOne(wp, wi, usable, state, icon, _, count, cd, cd2, tf, ta, ext)
		if state == nil then
			usable, state, icon, _, count, cd, cd2, tf, ta, ext = true, 0, "Interface\\Icons\\INV_Misc_QuestionMark", "", 0, 0, 0
		end
		wi:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark", skipToken)
		if skipNonIconUpdates[wp] or (wi and wi.IsShown and not wi:IsShown()) then
			return
		end
		local active, overlay, usableCharge = state % 2 > 0, state % 4 > 1, usable or (state % 128 >= 64)
		local rUsable = state % 2048 < 1024
		if wp.cooldown then
			local cdCountingDown = state % 4096 < 2048
			local start = cd2 > 0 and GetTime()+cd-cd2 or 0
			wp.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
			wp.cooldown:SetSwipeColor(0, 0, 0)
			wp.cooldown:SetHideCountdownNumbers(usableCharge and rUsable)
			wp.cooldown:SetDrawSwipe(not rUsable or not usableCharge)
			CooldownFrame_Set(wp.cooldown, start, cd2 == 60 and 59.95 or cd2, cdCountingDown or 0, true)
		end
		if wp.Name then
			wp.Name:SetText("")
		end
		if wp.SetChecked then
			wp:SetChecked(active)
		end
		if not GameTooltip:IsForbidden() and GameTooltip:IsOwned(wp) then
			if tf and ta then
				GameTooltip:ClearLines()
				tf(GameTooltip, ta)
				GameTooltip:Show()
			else
				GameTooltip:ClearLines()
				GameTooltip:Show()
			end
		end
		local ic, nt = wp.icon, wp.NormalTexture
		if ic and nt then
			local nomana, norange, hasrange = state % 16 > 7, state % 32 > 15, state % 1024 > 511
			if nomana then
				ic:SetVertexColor(manaR, manaG, manaB)
				nt:SetVertexColor(0.5, 0.5, 1.0)
			elseif (cd2 ~= 0.001) and (usable or cd2 > 0 or norange) and rUsable then
				if norange then
					ic:SetVertexColor(rangeR, rangeG, rangeB)
				else
					ic:SetVertexColor(1.0, 1.0, 1.0)
				end
				nt:SetVertexColor(1.0, 1.0, 1.0)
			else
				ic:SetVertexColor(0.4, 0.4, 0.4)
				nt:SetVertexColor(1.0, 1.0, 1.0)
			end
			local cn = wp.HotKey
			if cn and wp.rangeTimer then
				wp.rangeTimer = 2+TOOLTIP_UPDATE_TIME
				if cn:GetText() == RANGE_INDICATOR then
					if norange then
						cn:Show()
						cn:SetVertexColor(1, 0.1, 0.1)
					elseif usable and hasrange then
						cn:Show()
						cn:SetVertexColor(0.6, 0.6, 0.6)
					else
						cn:Hide()
					end
				elseif norange then
					cn:SetVertexColor(1, 0.1, 0.1)
				else
					cn:SetVertexColor(0.6, 0.6, 0.6)
				end
			end
		end
		local cnt = wp.Count
		if cnt then
			if count < 1 then
				cnt:SetText("")
			else
				cnt:SetText(count > (wp.maxDisplayCount or 9999) and "*" or count)
			end
		end
		if wp.action then
			(overlay and ShowOverlayGlow or HideOverlayGlow)(wp)
		end
		local border = wp.Border
		if border then
			if state % 512 > 255 then
				border:SetVertexColor(0, 1.0, 0, 0.35)
				border:Show()
			else
				border:Hide()
			end
		end
		if mayHaveExternalListeners then
			EV("M6_BUTTON_UPDATE", wp, wi, usable, state, icon, nil, count, cd, cd2, tf, ta, ext)
		end
	end
	local update, hasQueue, hasAll = {}

	local function handleQueue()
		if hasAll then
			for k,v in pairs(managed) do
				if k:IsVisible() then
					securecall(updateOne, k, v[2], M6:GetHint(v[1]))
				end
			end
			wipe(update)
		else
			for k in pairs(update) do
				local v = managed[k]
				update[k] = nil, v and k:IsVisible() and securecall(updateOne, k, v[2], M6:GetHint(v[1]))
			end
		end
		hasQueue, hasAll = nil
	end
	function queueSingle(owner)
		if not hasAll and managed[owner] then
			update[owner] = 1
			if not hasQueue then
				hasQueue = true
				T.After0(handleQueue)
			end
		end
	end
	function queueAll()
		hasAll = true
		if not hasQueue then
			hasQueue = true
			T.After0(handleQueue)
		end
	end
end

hooksecurefunc(getmetatable(PlayerPortrait).__index, "SetTexture", function(self, tex, skip)
	if skip == skipToken or self:IsForbidden() then return end
	local key = M6:GetIconKey(tex)
	local p = self:GetParent()
	local pp = p and p:GetParent()
	if pp and pp.__MSQ_BaseFrame == p then
		p = pp
	end
	if key then
		self:SetTexture("Interface/Icons/Temp", skipToken)
		local t = managed[p] or {}
		managed[p], t[1], t[2] = t, key, self
		queueSingle(p)
	elseif p and managed[p] and managed[p][2] == self then
		managed[p] = nil
		EV("M6_BUTTON_RELEASE", p)
		if p.cooldown then
			p.cooldown:SetDrawSwipe(true)
		end
	end
end)

local core, delay = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate"), 0
core:SetScript("OnUpdate", function(_, elapsed)
	if delay > elapsed then
		delay = delay - elapsed
		return
	end
	delay = 0.15
	queueAll()
end)
core:WrapScript(core, "OnAttributeChanged", [=[--
	if name == "state-up" and value == "" then
		self:SetAttribute("state-up", nil)
		self:RunScript("Update")
	end
]=])
core.Update, EV.SPELL_UPDATE_USABLE = queueAll, queueAll
EV.UPDATE_MACROS = queueAll
EV.MODIFIER_STATE_CHANGED = queueAll
EV.CURRENT_SPELL_CAST_CHANGED = queueAll
hooksecurefunc("ActionButton_UpdateCooldown", queueSingle)
local function queueFromOnUpdate(self, el)
	if self.flashtime >= (ATTACK_BUTTON_FLASH_TIME - el)
	   or (self.rangeTimer or 3) == TOOLTIP_UPDATE_TIME then
		queueSingle(self)
	end
end
hooksecurefunc(NINE and ActionBarActionButtonMixin or _G, NINE and "OnUpdate" or "ActionButton_OnUpdate", queueFromOnUpdate)
hooksecurefunc("CooldownFrame_Set", function(s)
	return not s:IsForbidden() and queueSingle(s:GetParent())
end)
hooksecurefunc(NINE and ActionBarActionButtonMixin or _G, NINE and "UpdateState" or "ActionButton_UpdateState", queueSingle)
hooksecurefunc(NINE and ActionBarActionButtonMixin or _G, NINE and "UpdateUsable" or "ActionButton_UpdateUsable", queueSingle)
hooksecurefunc(GameTooltip, "SetOwner", function(_, o)
	return queueSingle(o)
end)
if NINE then
	local type, rg = type, rawget
	local p = EnumerateFrames()
	local q = EnumerateFrames(p)
	while p and p ~= q do
		local us = rg(p, "UpdateState")
		if us and type(us) == "function" then
			us = rg(p, "OnUpdate")
			if us and type(us) == "function" then
				us = rg(p, "UpdateUsable")
				if us and type(us) == "function" then
					if rg(p, "icon") then
						hooksecurefunc(p, "UpdateState", queueSingle)
						hooksecurefunc(p, "UpdateUsable", queueSingle)
						p:HookScript("OnUpdate", queueFromOnUpdate)
					end
				end
			end
		end
		p = EnumerateFrames(p)
		q = q and EnumerateFrames(q)
		q = q and EnumerateFrames(q)
	end
end


do -- Cursor Icons
	local oldMacro, oldIcon
	local function releaseOld()
		if oldMacro and GetMacroInfo(oldMacro) then
			EditMacro(oldMacro, oldMacro, oldIcon)
		end
		oldMacro = nil
	end
	local function pickupNew(k, ik)
		releaseOld()
		oldMacro, oldIcon = k, M6:GetKeyIcon(ik)
		local ico, _, _, tex = "Temp", M6:GetHint(ik)
		ico = type(tex) == "number" and tex or 134400
		ClearCursor()
		EditMacro(k, k, ico)
		PickupMacro(k)
	end
	function EV:UPDATE_MACROS()
		local m, t = GetCursorInfo()
		local k = m == "macro" and GetMacroInfo(t)
		if k == oldMacro and not InCombatLockdown() then
			ClearCursor()
			PickupMacro(k)
		end
	end
	local function actualCursorUpdate(e)
		local m, t = GetCursorInfo()
		if InCombatLockdown() then
			return
		elseif m == "macro" and e ~= "PLAYER_REGEN_DISABLED" then
			local k, ico = GetMacroInfo(t)
			local ik = k and ico and M6:GetIconKey(ico)
			if ik then
				pickupNew(k, ik)
			end
		elseif oldMacro then
			releaseOld()
		end
	end
	function EV:CURSOR_UPDATE()
		T.After0(actualCursorUpdate)
	end
end

M6.PainterEvents = newproxy(true) do
	local meta = getmetatable(M6.PainterEvents)
	function meta:__newindex(k, v)
		if k == "RawActionBookUpdates" and type(v) == "function" then
			mayHaveExternalListeners, EV.M6_BUTTON_UPDATE, EV.M6_BUTTON_RELEASE = true, v, v
		else
			assert(false)
		end
	end
end