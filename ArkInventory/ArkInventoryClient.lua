-- blizzzard functions that no longer exist, or have been replaced across clients

ArkInventory.CrossClient = { }

function ArkInventory.CrossClient.GetProfessionInfo( ... )
	
	if GetProfessionInfo then
		
		return GetProfessionInfo( ... )
		
	else
		
		local index = ...
		local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType = GetSkillLineInfo( index )
		
		for k, v in pairs( ArkInventory.Const.Tradeskill.Data ) do
			if v.text == skillName then
				--ArkInventory.Output( "skill [", index, "] found [", skillName, "]=[", k, "]" )
				return skillName, "", 0, 0, 0, 0, k
			end
		end
		
		--ArkInventory.Output( "skill [", index, "] not found [", skillName, "]" )
		
	end
	
end

function ArkInventory.CrossClient.GetProfessions( ... )
	
	if GetProfessions then
		
		return GetProfessions( ... )
		
	else
		
		local skills = { }
		local skillnum = 0
		local header1 = string.lower( ArkInventory.Localise["TRADESKILLS"] )
		local header2 = string.lower( ArkInventory.Localise["SECONDARY_SKILLS"] )
		
		for k = 1, GetNumSkillLines( ) do
			local name, header = GetSkillLineInfo( k )
			--ArkInventory.Output( name, " / ", header )
			if header ~= nil then
				
				name = string.lower( name )
				
				if string.match( header1, name ) or string.match( header2, name ) then
					
					--ArkInventory.Output( "valid header = ", name )
					
					good = true
					
					if string.match( header2, name ) and skillnum < 2 then
						skillnum = 2
					end
					
				else
					
					good = false
					
				end
				
			else
				
				if good then
					skillnum = skillnum + 1
					--ArkInventory.Output( "skills[", skillnum, "] = ", k, " [", name, "]" )
					skills[skillnum] = k
				end
				
			end
		end
		
		
		return skills[1], skills[2], skills[3], skills[4], skills[5]
		
	end
	
end

function ArkInventory.CrossClient.SetSortBagsRightToLeft( ... )
	if SetSortBagsRightToLeft then
		return SetSortBagsRightToLeft( ... )
	end
end

function ArkInventory.CrossClient.GetContainerItemQuestInfo( ... )
	local b, s, i = ...
	if GetContainerItemQuestInfo then
		return GetContainerItemQuestInfo( b, s )
	else
		if ArkInventory.PT_ItemInSets( i.h, "ArkInventory.System.Quest.Start" ) then
			return true
		end
	end
end

function ArkInventory.CrossClient.IsArtifactPowerItem( ... )
	if IsArtifactPowerItem then
		return IsArtifactPowerItem( ... )
	end
end

function ArkInventory.CrossClient.IsReagentBankUnlocked( ... )
	if IsReagentBankUnlocked then
		return IsReagentBankUnlocked( ... )
	end
end

function ArkInventory.CrossClient.IsCorruptedItem( ... )
	if IsCorruptedItem then
		return IsCorruptedItem( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyInfo( ... )
	
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
		
		return C_CurrencyInfo.GetCurrencyInfo( ... )
		
	elseif GetCurrencyInfo then
		
		local info = { }
		local name, quantity, iconFileID, quantityEarnedThisWeek, maxWeeklyQuantity, maxQuantity, discovered, quality = GetCurrencyInfo( ... )
		
		info.name = name
--		{ Name = "isHeader", Type = "bool", Nilable = false },
--		{ Name = "isHeaderExpanded", Type = "bool", Nilable = false },
--		{ Name = "isTypeUnused", Type = "bool", Nilable = false },
--		{ Name = "isShowInBackpack", Type = "bool", Nilable = false },
		info.quantity = quantity
		info.iconFileID = iconFileID
		info.quantityEarnedThisWeek = quantityEarnedThisWeek
		info.maxQuantity = maxQuantity
--		{ Name = "canEarnPerWeek", Type = "bool", Nilable = false },
--		{ Name = "isTradeable", Type = "bool", Nilable = false },
		info.quality = quality
		info.maxWeeklyQuantity = maxWeeklyQuantity
		info.discovered = discovered
		
		return info
		
	end
	
end

function ArkInventory.CrossClient.GetCurrencyLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyLink then
		return C_CurrencyInfo.GetCurrencyLink( ... )
	elseif GetCurrencyLink then
		return GetCurrencyLink( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyListSize( ... )
	if GetCurrencyListSize then
		return GetCurrencyListSize( ... )
	elseif C_CurrencyInfo then
		return C_CurrencyInfo.GetCurrencyListSize( ... )
	end
end

function ArkInventory.CrossClient.GetCurrencyListInfo( ... )
	
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListInfo then
		
		return C_CurrencyInfo.GetCurrencyListInfo( ... )
		
	elseif GetCurrencyListInfo then
		
		local info = { }
		local name, isHeader, isHeaderExpanded, isTypeUnused, isShowInBackpack, quantity, iconFileID, maxQuantity, canEarnPerWeek, quantityEarnedThisWeek, unknown, itemID = GetCurrencyListInfo( ... )
		
		info.name = name
		info.isHeader = isHeader
		info.isHeaderExpanded = isHeaderExpanded
		info.isTypeUnused = isTypeUnused
		info.isShowInBackpack = isShowInBackpack
		info.quantity = quantity
		info.iconFileID = iconFileID
		info.maxQuantity = maxQuantity
		info.canEarnPerWeek = canEarnPerWeek
		info.quantityEarnedThisWeek = quantityEarnedThisWeek
--		{ Name = "isTradeable", Type = "bool", Nilable = false },
--		{ Name = "quality", Type = "ItemQuality", Nilable = false },
--		{ Name = "maxWeeklyQuantity", Type = "number", Nilable = false },
--		{ Name = "discovered", Type = "bool", Nilable = false },
		
		return info
		
	end
	
end

function ArkInventory.CrossClient.GetBackpackCurrencyInfo( ... )
	
	if C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo then
		
		return C_CurrencyInfo.GetBackpackCurrencyInfo( ... )
		
	elseif GetBackpackCurrencyInfo then
		
		info = { }
		local name, quantity, iconFileID, currencyTypesID = GetBackpackCurrencyInfo( ... )
		
		info.name = name
		info.quantity = quantity
		info.iconFileID = iconFileID
		info.currencyTypesID = currencyTypesID
		
		return info
		
	end
	
end

function ArkInventory.CrossClient.GetCurrencyListLink( ... )
	if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListLink then
		return C_CurrencyInfo.GetCurrencyListLink( ... )
	elseif GetCurrencyListLink then
		return GetCurrencyListLink( ... )
	end
end

function ArkInventory.CrossClient.SetCurrencyUnused( ... )
	if SetCurrencyUnused then
		return SetCurrencyUnused( ... )
	elseif C_CurrencyInfo then
		return C_CurrencyInfo.SetCurrencyUnused( ... )
	end
end

function ArkInventory.CrossClient.ExpandCurrencyList( ... )
	if ExpandCurrencyList then
		return ExpandCurrencyList( ... )
	elseif C_CurrencyInfo then
		return C_CurrencyInfo.ExpandCurrencyList( ... )
	end
end

function ArkInventory.CrossClient.GetFriendshipReputation( ... )
	if GetFriendshipReputation then
		return GetFriendshipReputation( ... )
	end
end

function ArkInventory.CrossClient.IsFactionParagon( ... )
	if C_Reputation then
		if C_Reputation.IsFactionParagon then
			return C_Reputation.IsFactionParagon( ... )
		end
	end
end

function ArkInventory.CrossClient.SetCVar( ... )
	if C_CVar then
		return C_CVar.SetCVar( ... )
	else
		return SetCVar( ... )
	end
end

function ArkInventory.CrossClient.GetCVar( ... )
	if C_CVar then
		return C_CVar.GetCVar( ... )
	else
		return GetCVar( ... )
	end
end

function ArkInventory.CrossClient.GetCVarBool( ... )
	if C_CVar then
		return C_CVar.GetCVarBool( ... )
	else
		return GetCVarBool( ... )
	end
end



local a = string.lower( ArkInventory.CrossClient.GetCVar( "agentuid" ) )
local p = string.lower( ArkInventory.CrossClient.GetCVar( "portal" ) )
if WOW_PROJECT_ID == 2 then
	if a == "classic_ptr" or p == "test" then
		ArkInventory.Const.Blizzard.Client.id = ArkInventory.Const.Blizzard.Client.CLASSIC_PTR
		ArkInventory.Const.Blizzard.Client.name = EXPANSION_NAME0 .. ": PTR"
	else -- a == "wow_classic"
		ArkInventory.Const.Blizzard.Client.id = ArkInventory.Const.Blizzard.Client.CLASSIC
		ArkInventory.Const.Blizzard.Client.name = EXPANSION_NAME0
	end
else
	if a == "wow_beta" then
		ArkInventory.Const.Blizzard.Client.id = ArkInventory.Const.Blizzard.Client.RETAIL_BETA
		ArkInventory.Const.Blizzard.Client.name = EXPANSION_NAME8 .. ": Beta"
	elseif a == "wow_ptr" or p == "test" then
		ArkInventory.Const.Blizzard.Client.id = ArkInventory.Const.Blizzard.Client.RETAIL_PTR
		ArkInventory.Const.Blizzard.Client.name = EXPANSION_NAME7 .. ": PTR"
	else
		ArkInventory.Const.Blizzard.Client.id = ArkInventory.Const.Blizzard.Client.RETAIL
		ArkInventory.Const.Blizzard.Client.name = EXPANSION_NAME7
	end
end

--ArkInventory.Output( ArkInventory.Const.Blizzard.Client.id )
--ArkInventory.Output( ArkInventory.Const.Blizzard.Client.name )

function ArkInventory.ClientCheck( id, toc_min, toc_max )
	
--	ArkInventory.Output2( "----- ----- ------" )
--	ArkInventory.Output2( "check = ", id, " - ", type( id ) )
	
	if type( id ) == "boolean" then return id end
	if type( id ) ~= "string" then return true end
	if string.len( id ) < 6 then return true end
	
--	ArkInventory.Output2( "id = ", ArkInventory.Const.Blizzard.Client.id )
	
	if id == string.sub( ArkInventory.Const.Blizzard.Client.id, 1, string.len( id ) ) then
--		ArkInventory.Output2( "ok: ", id, " == ", string.sub( ArkInventory.Const.Blizzard.Client.id, 1, string.len( id ) ) )
		
		if ( not toc_min or ArkInventory.Const.Blizzard.TOC >= toc_min ) and ( not toc_max or ArkInventory.Const.Blizzard.TOC <= toc_max ) then
			--ArkInventory.Output2( "Client is correct and TOC is ok ", toc_min, " > ", ArkInventory.Const.Blizzard.TOC, " < ", toc_max  )
			return true
		else
			--ArkInventory.Output2( "Client is correct but TOC is out of bounds ", toc_min, " > ", ArkInventory.Const.Blizzard.TOC, " < ", toc_max  )
			return false
		end
		
	end
	
--	ArkInventory.Output2( "Client is incorrect, meant for ", id )
	
	return false
	
end

