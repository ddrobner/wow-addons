--
--
--
-- Manual profiles
--  by Fulgerul
--
--  This is a trigger module for Profiles: * that reverts addon_object
--	to the old way of saving and loading profiles, through manual /commands
--	
-- Enabling this trigger will cause all other triggers to disable
-- Disabling the trigger does NOT actually disable as we want CMD line iface

----------- [ Config ] --------

-- Main addon object containing AceEvent
local addon_obj = KPS
-- Where do we find save,load and delete ?

local save_profile_ref 	= "PreSaveBindsProfile"
local load_profile_ref 	= "PreLoadBindsProfile"
local del_profile_ref 	= "PreDeleteProfile"
local export_profile_ref 	= "ExportCharProfile"
local import_profile_ref 	= "ImportGlobalProfile"

-- SLASH specific code
SLASH_KPS1 = "/KPS"
-------------------------------

-- local addon_obj_mod = addon_obj:NewModule("Manual Profiles", "AceConsole-3.0", "AceEvent-3.0")


-- Module loaded
-- Disable all other triggers
-- function addon_obj_mod:OnEnable()
-----------------------------
--
--	Change SlashCmdList!
--
-----------------------------

	SlashCmdList["KPS"] = 
	function(msg)
	   local cmd, arg = string.split(" ", msg, 2)
	   cmd = string.lower(cmd or "")
	   arg = arg or ""
	   
		if (cmd == "version") then
			addon_obj:Echo("Profiles: Macros v."..MPS_Version)
		elseif (cmd=="list")then
			addon_obj:ListProfiles()
		elseif (cmd=="" or arg=="")then
			addon_obj:Echo(SLASH_KPS1.." delete <name>")
			addon_obj:Echo(SLASH_KPS1.." save <name>")
			addon_obj:Echo(SLASH_KPS1.." load <name>")
			addon_obj:Echo(SLASH_KPS1.." import")
			addon_obj:Echo(SLASH_KPS1.." export")
			addon_obj:Echo(SLASH_KPS1.." list")
			addon_obj:Echo(SLASH_KPS1.." version")
			addon_obj:Echo(SLASH_KPS1.." debug [on|off]")
		elseif (cmd=="save")then
			addon_obj[save_profile_ref](addon_obj, arg)
		elseif (cmd=="load" and arg~="")then
			addon_obj[load_profile_ref](addon_obj, arg)
		elseif (cmd=="delete" and arg~="")then
			addon_obj[del_profile_ref](addon_obj, arg) -- Thanks Adirelle :)
		elseif (cmd=="export")then
			addon_obj[export_profile_ref](addon_obj, arg)
		else    
			addon_obj:Echo("wrong entry")
	   end
	end
	
	KPS_ManualProfiles = KPS:NewModule("KPS: Manual Profiles", "AceConsole-3.0", "AceEvent-3.0")

	-- Module loaded
	function KPS_ManualProfiles:OnEnable()
	KPS:DebugMsg("KPS: Manual Profiles - OnEnable()")
		
		DEFAULT_CHAT_FRAME:AddMessage("KPS: Manual Profiles ON")
		DEFAULT_CHAT_FRAME:AddMessage("KPS: Use /slashcommands for operations")
		
		-- Disable core events evolving around UPDATE_BINDINGS
		KPS:UnregisterEvent("PLAYER_REGEN_DISABLED")
		KPS:UnregisterEvent("PLAYER_REGEN_ENABLED")
		KPS:UnregisterEvent("UPDATE_BINDINGS")
	end


	-- Module disabled
	function KPS_ManualProfiles:OnDisable()
	KPS:DebugMsg("KPS: Manual Profiles - OnDisable()")
		
		-- Core events evolving around UPDATE_BINDINGS are registered by CORE!
		DEFAULT_CHAT_FRAME:AddMessage("KPS: Manual Profiles OFF")
	   
	end
-- end
