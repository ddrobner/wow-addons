--
--
--
--  Profiles: Keyboard binds: Outfitter
--  by Fulgerul
--
--  This is a trigger module for Profiles: Keyboard binds that changes profiles
--  when the user changes Outfitter sets
--
--
--


KPS_Outfitter = KPS:NewModule("KPS: Outfitter", "AceConsole-3.0", "AceEvent-3.0","AceTimer-3.0")

--TODO: Enabling this module when Outfitter is not loaded at all crashes lua!
-- Wait for Outfitter to start
function KPS_Outfitter:OnEnable()
KPS:DebugMsg("KPS: Outfitter - OnEnable()")

Outfitter:RegisterOutfitEvent("OUTFITTER_INIT", KPS_Outfitter:RegisterOutfitEvents())

end

function KPS_Outfitter:RegisterOutfitEvents()
	DEFAULT_CHAT_FRAME:AddMessage("KPS: Outfitter ON")
	KPS:DebugMsg("KPS: Outfitter - RegisterOutfitEvents() - Registering events.")

	Outfitter:RegisterOutfitEvent("WEAR_OUTFIT", function (pOutfit) KPS_Outfitter:OnUpdate(pOutfit) end)
	Outfitter:RegisterOutfitEvent("DELETE_OUTFIT", function (_,pOutfit) KPS_Outfitter:OnDelete(pOutfit) end)
	Outfitter:RegisterOutfitEvent("ADD_OUTFIT", function (_,pOutfit) KPS_Outfitter:OnUpdate(pOutfitt) end)
    
    -- Init
    -- Do we have keybinds for this spec ?
	
	if Outfitter:GetCurrentOutfitInfo() ~= "" then
		 local specialization = "Outfitter - "..Outfitter:GetCurrentOutfitInfo()
	            
		 if (KPS:ExistsProfile(specialization) == nil)then
			KPS:DebugMsg("KPS: Outfitter: Enable_On_ADDON_LOADED() - No keybinds specified for spec "..specialization..". Saving keybinds...");
			 KPS:SaveProfil(specialization)
		 else
			 KPS:DebugMsg("KPS: Outfitter: Enable_On_ADDON_LOADED() -   "..specialization..". loading keybinds...");
			 KPS:LoadProfil(specialization)
		 end
	end

end

function KPS_Outfitter:OnUpdate(KPSoutfit)
KPS:DebugMsg("KPS: Outfitter - OnUpdate()")

    if not KPSoutfit then return end
    
    -- Do we have keybinds for this spec ?
    local specialization = ""
    
    if KPSoutfit == "WEAR_OUTFIT" or not KPSoutfit then
        specialization = "Outfitter - "..Outfitter:GetCurrentOutfitInfo()
    else
        specialization = "Outfitter - "..KPSoutfit
    end
           
    if (KPS:ExistsProfile(specialization) == nil)then
        KPS:DebugMsg("KPS: Outfitter: OnUpdate() - No keybinds specified for spec "..specialization..". Saving keybinds...");
        KPS:SaveProfil(specialization)
    else
        KPS:DebugMsg("KPS: Outfitter: OnUpdate() -   "..specialization..". loading keybinds...");
        KPS:LoadProfil(specialization)
    end
            
end

function KPS_Outfitter:OnDelete(KPSoutfit)
KPS:DebugMsg("KPS: Outfitter - OnDelete()")

    if not KPSoutfit then return end
    
    -- Do we have keybinds for this spec ?
    local specialization = "Outfitter - "..KPSoutfit
    KPS:DeleteProfil(specialization)
    KPS_Outfitter:OnUpdate()
end

-- Module disabled
function KPS_Outfitter:OnDisable()
KPS:DebugMsg("KPS: Outfitter - OnDisable()")
        
    if (Outfitter) then
        if not Outfitter:IsInitialized() then
            Outfitter:RegisterOutfitEvent('OUTFITTER_INIT', function () KPS_Outfitter:OnEnable() end)
        else
            KPS:DebugMsg("KPS: Outfitter - OnDisable() - Unregistering events.")
            Outfitter:UnregisterOutfitEvent('WEAR_OUTFIT')
            Outfitter:UnregisterOutfitEvent('DELETE_OUTFIT',"KPS_Outfitter:OnDelete")
            Outfitter:UnregisterOutfitEvent('ADD_OUTFIT')
            Outfitter:UnregisterOutfitEvent('OUTFITTER_INIT')
        end
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("KPS: Outfitter OFF")
end
