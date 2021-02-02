local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local conduitsFilter = AdiBags:RegisterFilter("Conduits", 94)
conduitsFilter.uiName = "|cff00ffffConduits|r";
conduitsFilter.uiDesc = "Puts Conduits Items in their own section."

function conduitsFilter:Filter(slotData)
	local itemLink = GetContainerItemLink(slotData.bag, slotData.slot)
	if (itemLink) then
		local isConduit = C_Soulbinds.IsItemConduitByItemInfo(itemLink);
		if (isConduit) then 
			return "|cff00ffffConduits|r";
		end
	end
	return
end