local addonName = "Altoholic"
local addon = _G[addonName]

local ns = addon.Tabs.Shadowlands

addon:Controller("AltoholicUI.ShadowlandsSanctumFeatures", {
	OnBind = function(frame)
		frame:Update()
	end,
	Update = function(self)
        local covenantID = DataStore:GetCovenantID(ns:GetAltKey()) or 0 
        local covenantData = C_Covenants.GetCovenantData(covenantID)

        if covenantID > 0 and covenantData and covenantData.name then
            self.ArdenwealdGardeningPanel:Update()
        end
        
        self:Show()
	end,
})
