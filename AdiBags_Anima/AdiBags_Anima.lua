local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local animaFilter = AdiBags:RegisterFilter("Anima", 94)
animaFilter.uiName = "|cff00ffffAnima|r";
animaFilter.uiDesc = "Puts Anima Items in their own section."

function animaFilter:Filter(slotData)
	local itemLink = GetContainerItemLink(slotData.bag, slotData.slot)
	if (itemLink) then
		local isAnima = C_Item.IsAnimaItemByID(itemLink);
		if (isAnima) then 
			return "|cff00ffffAnima|r";
		end
	end
	return
end