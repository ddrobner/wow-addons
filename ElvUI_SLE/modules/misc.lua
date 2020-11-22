local SLE, T, E, L, V, P, G = unpack(select(2, ...))
local M = SLE:NewModule('Misc', 'AceHook-3.0', 'AceEvent-3.0')

local _G = _G

--Viewports
function M:SetAllPoints(...)
	M:SetViewport()
end

--[[function M:ClearAllPoints(force)
	print("ClearAllPoints", force)
	if force then
		WorldFrame:ORClear()
	end
end]]

function M:SetViewport()
	if SLE._Compatibility['SunnArt'] then return end --Other viewport addon is enabled
	local scale = E.global.general.UIScale

	_G.WorldFrame:ClearAllPoints()
	_G.WorldFrame:SetPoint('TOPLEFT', (M.db.viewport.left * scale), -(M.db.viewport.top * scale))
	_G.WorldFrame:SetPoint('BOTTOMRIGHT', -(M.db.viewport.right * scale), (M.db.viewport.bottom * scale))
end

--Raid utility
function M:RaidUtility_SetMouseoverAlpha()
	local a = E.db.sle.blizzard.rumouseover and 0 or 1
	_G.RaidUtility_ShowButton:SetAlpha(a)
end

function M:RaidUtility_OnDragStop()
	local point, anchor, point2, x, y = self:GetPoint()
	local frame = _G.RaidUtility_ShowButton
	frame:ClearAllPoints()
	if strfind(point, 'BOTTOM') then
		frame:SetPoint(point, anchor, point2, x, y)
	else
		frame:SetPoint(point, anchor, point2, x, y)
	end
end

function M:RaidUtility_OnEnter()
	if not E.db.sle.blizzard.rumouseover then return end
	self:SetAlpha(1)
end

function M:RaidUtility_OnLeave()
	if not E.db.sle.blizzard.rumouseover then return end
	self:SetAlpha(0)
end

function M:RaidUtility_Hook()
	--Creating mover for the button
	local frame = _G.RaidUtility_ShowButton
	if not frame then return end --Just in case
	E:CreateMover(frame, 'RaidUtility_Mover', RAID_CONTROL, nil, nil, nil, 'ALL,S&L,S&L MISC')
	local mover = _G.RaidUtility_Mover

	--Setting default point and stuff
	if E.db.movers == nil then E.db.movers = {} end

	--Making frame actually following mover around
	mover:HookScript('OnDragStart', function(self)
		frame:ClearAllPoints()
		frame:SetPoint('CENTER', self)
	end)
	mover:HookScript('OnDragStop', M.RaidUtility_OnDragStop)

	if E.db.movers.RaidUtility_Mover == nil then
		frame:ClearAllPoints()
		frame:SetPoint('TOP', E.UIParent, 'TOP', -400, E.Border)
	else
		M.RaidUtility_OnDragStop(mover)
	end

	frame:RegisterForDrag('') --No buttons for drag
	frame:HookScript('OnEnter', M.RaidUtility_OnEnter)
	frame:HookScript('OnLeave', M.RaidUtility_OnLeave)
	M.RaidUtility_OnLeave(frame)
end

function M:Initialize()
	if not SLE.initialized then return end
	M.db = E.db.sle.misc
	E:CreateMover(_G.UIErrorsFrame, 'UIErrorsFrameMover', L["Error Frame"], nil, nil, nil, 'ALL,S&L,S&L MISC')

	--GhostFrame Mover
	E:CreateMover(_G.GhostFrame, 'SLEGhostFrameMover', L["Ghost Frame"], nil, nil, nil, 'ALL,S&L,S&L MISC')
	_G.GhostFrame.mover:SetSize(_G.GhostFrameContentsFrame:GetSize())

	--Raid Utility
	if _G.RaidUtility_ShowButton then M:RaidUtility_Hook() end

	--Viewport
	function CinematicFrame_CancelCinematic()
		if ( CinematicFrame.isRealCinematic ) then
			StopCinematic();
		elseif ( CanCancelScene() ) then
			CancelScene();
		else
			VehicleExit();
		end
	end

	--Some high level bullshit
	-- WorldFrame.ORClear = WorldFrame.ClearAllPoints
	-- WorldFrame.ClearAllPoints = M.ClearAllPoints
	WorldFrame.ORSetAll = WorldFrame.SetAllPoints
	WorldFrame.SetAllPoints = M.SetAllPoints

	M:SetViewport()
	hooksecurefunc(E, 'PixelScaleChanged', M.SetViewport)

	function M:ForUpdateAll()
		M.db = E.db.sle.misc
		M:SetViewport()
	end
end

SLE:RegisterModule(M:GetName())
