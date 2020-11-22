--
--
--
--  Profiles: Keyboard binds: Talents
--  by Fulgerul
--
--  This is a trigger module for Keyboard Layout Saver that changes profiles
--  when the user changes specs
--
--
--


KPS_Talents = KPS:NewModule("KPS: Talents", "AceConsole-3.0", "AceEvent-3.0")

-- local specialization = 0
-- local KPS_player_talent_update_counter = 0

-- Module loaded
function KPS_Talents:OnEnable()
KPS:DebugMsg("KPS: Talents - OnEnable()")
    
    DEFAULT_CHAT_FRAME:AddMessage("KPS: Talents OFF - This module has been deactivated in favor of manual/minimap module!")
    KPS_Talents:Disable()
	KPS_ManualProfiles:Enable()
	KPSdb.char.KLStriggerModule = "KPS: Manual Profiles"
    -- KPS:DebugMsg("KPS: Talents - OnEnable() - Registering events.")
    
    ---------------------------------------------------
	-- Dont change profiles all the time when we enter worlds.
	---------------------------------------------------
    -- KPS_Talents:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- KPS_Talents:RegisterEvent("PLAYER_LEAVING_WORLD")
    
    -- KPS_Talents:RegisterEvent("PLAYER_TALENT_UPDATE")
end


-- Module disabled
function KPS_Talents:OnDisable()
KPS:DebugMsg("KPS: Talents - OnDisable()")
        
    DEFAULT_CHAT_FRAME:AddMessage("KPS: Talents OFF")
   
    -- KPS:DebugMsg("KPS: Talents - OnDisable() - Unregistering events.")
    -- KPS_Talents:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- KPS_Talents:UnregisterEvent("PLAYER_LEAVING_WORLD")
    -- KPS_Talents:UnregisterEvent("PLAYER_TALENT_UPDATE")
end


-----------------------------------------------------
-- Dont run change profiles when we enter/leave worlds.
-----------------------------------------------------
-- function KPS_Talents:PLAYER_ENTERING_WORLD()
	-- KPS:DebugMsg("PLAYER_ENTERING_WORLD(): Entered")
	
    -- KPS_player_talent_update_counter = 0
-- end

-- function KPS_Talents:PLAYER_LEAVING_WORLD()
	-- KPS:DebugMsg("PLAYER_LEAVING_WORLD(): Entered")
	
    -- KPS_player_talent_update_counter = 0
-- end

-- User changed specs
-- function KPS_Talents:PLAYER_TALENT_UPDATE(...)
-- KPS:DebugMsg("KPS: Talents - PLAYER_TALENT_UPDATE()")

	 -- PLAYER_TALENT_UPDATE event must not run after PLAYER_ENTERING_WORLD
    -- if KPS_player_talent_update_counter == 0 then
		-- KPS:DebugMsg("PLAYER_TALENT_UPDATE(): First time run, returning...")
		-- KPS_player_talent_update_counter = 1
		-- return
    -- end
    
    -- specialization = KPS_Talents:GetCurrentClass();
        
        -- if specialization == "NOT CHOSEN TALENTS" then
            -- KPS:DebugMsg("KPS: Talents - PLAYER_TALENT_UPDATE(): No talent spec. returning...")
            -- return
        -- end
    -- KPS:DebugMsg("KPS: Talents - PLAYER_TALENT_UPDATE(): specialization now <"..specialization..">")
   
   -- Do we have keybinds for this spec ?
        -- if (KPS:ExistsProfile(specialization) == nil)then
            -- KPS:DebugMsg("KPS: Talents - PLAYER_TALENT_UPDATE(): No keybinds specified for spec "..specialization..". Saving keybinds...");
            -- KPS:SaveProfil(specialization)
        -- else
            -- KPS:DebugMsg("KPS: Talents - PLAYER_TALENT_UPDATE(): "..specialization..". loading keybinds...");
            -- KPS:LoadProfil(specialization)
        -- end
-- end

-- Helper class, helps define the current spec
-- function KPS_Talents:GetCurrentClass()
-- KPS:DebugMsg("KPS: Talents - GetCurrentClass()")

    -- local tree = GetPrimaryTalentTree()
    -- local treename = tree and select(2, GetTalentTabInfo(tree)) -- Combat
	
    -- if treename then
		-- local tree_digit = select(5,GetTalentTabInfo(1)).."/"..select(5,GetTalentTabInfo(2)).."/"..select(5,GetTalentTabInfo(3)) -- 0/31/1
		-- treename = treename.." ("..tree_digit..")"
      -- return treename
    -- else
      -- KPS:DebugMsg("KPS: Talents - GetCurrentClass(): No talents defined!")
    -- return "NOT CHOSEN TALENTS";
   -- end
-- end
