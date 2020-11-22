--
--
--
--  Profiles: Keyboard binds: Equipment manager
--  by Fulgerul
--
--  This is a trigger module for Profiles: Keyboard binds that changes profiles
--  when the user changes Equipment manager sets
--
--
--


KPS_EQM = KPS:NewModule("KPS: Equipment manager", "AceConsole-3.0", "AceEvent-3.0","AceTimer-3.0")

-- Wait for Equipment manager to start
function KPS_EQM:OnEnable()
KPS:DebugMsg("KPS: Equipment manager - OnEnable()")

if not CanUseEquipmentSets() then
	print("EQM Disabled!")
else
	print("KPS: Equipment manager ON")
	KPS_EQM:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
end



end

function KPS_EQM:EQUIPMENT_SWAP_FINISHED(_,_,KPS_EQM_SET) 
KPS:DebugMsg("KPS: Equipment manager - EQUIPMENT_SWAP_FINISHED()")

     if (KPS:ExistsProfile(KPS_EQM_SET) == nil)then
         KPS:DebugMsg("KPS: Equipment manager: OnUpdate() - No keybinds specified for spec "..KPS_EQM_SET..". Saving keybinds...");
         KPS:SaveProfil(KPS_EQM_SET)
     else
         KPS:DebugMsg("KPS: Equipment manager: OnUpdate() -   "..KPS_EQM_SET..". loading keybinds...");
         KPS:LoadProfil(KPS_EQM_SET)
     end
end

-- Module disabled
function KPS_EQM:OnDisable()
KPS:DebugMsg("KPS: Equipment manager - OnDisable()")
        
    KPS_EQM:UnregisterEvent("EQUIPMENT_SWAP_FINISHED")  
    
    DEFAULT_CHAT_FRAME:AddMessage("KPS: Equipment manager OFF")
end

-- 
-- 
-- function KPS_EQM:OnDelete(KPSoutfit)
-- KPS:DebugMsg("KPS: Equipment manager - OnDelete()")
-- 
    -- if not KPSoutfit then return end
    -- 
    -- -- Do we have keybinds for this spec ?
    -- local specialization = "Equipment manager - "..KPSoutfit
    -- KPS:DeleteProfil(specialization)
    -- KPS_EQM:OnUpdate()
-- end
-- 
