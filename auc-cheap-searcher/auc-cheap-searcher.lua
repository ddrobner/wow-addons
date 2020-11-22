--[[
	Cheapo searcher module for Auctioneer Search UI - (URL: http://auctioneeraddon.com/ )
-- 20190916 version for both WoW Battle of Azeroth and WoW Classic - this will determine version dynamically at runtime.
-- based on the Vendor Searcher - SearcherVendor.lua

	This is a plugin module for the SearchUI that assists in searching by refined parameters

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
-- Create a new instance of our lib with our parent
if not AucSearchUI then return end
local lib, parent, private = AucSearchUI.NewSearcher("Cheapo")
if not lib then return end
--local aucPrint,decode,_,_,replicate,_,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
--local aucPrint,_,_,_,_,_,_,_,_,_,_,_ = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
--local GetItemInfo = GetItemInfo

local isCanIMogItUsable = false
local UsableMogsOnly = false
local CompletionistMode = false
local SetsComponentsOnly = false
local CurrentCharOnly = true

local wowgameversion = tonumber(select(4, GetBuildInfo()))
if wowgameversion == nil then
wowgameversion = 1
end

lib.tabname = "Cheapo"

-- Set our defaults
default("Cheapo.vendorcap.pct", 20)
default("Cheapo.maxprice", 5000000)

default("Cheapo.allow.bid", false)
default("Cheapo.allow.buy", true)
default("Cheapo.timeleft", 0)

if wowgameversion < 80000 then
default("Cheapo.transmog.mode", false)
else
default("Cheapo.transmog.mode", true)
end

default("Cheapo.transmog.completionist", false)
default("Cheapo.transmog.usableonly", false)
default("Cheapo.transmog.CurrentCharOnly", true)
default("Cheapo.transmog.SetsComponentsOnly", false)



-- timeleft code by pagep
-- https://gitlab.com/norganna-wow/auctioneer/auc-util-searchui/commit/fa34dbf1e0663974
-- -- strings for the vendor search UI panel
function private.getTimeLeftStrings()
    if AucAdvanced.Classic then
        return {
                {0, "Any"},
                {1, "less than 30 min"},
                {2, "2 hours"},
                {3, "8 hours"},
                {4, "24 hours"},
            }
    else
        return {
                {0, "Any"},
                {1, "less than 30 min"},
                {2, "2 hours"},
                {3, "12 hours"},
                {4, "48 hours"},
            }
    end
end


-- note: no strings, just comparing values 0-4
function private.CheckTimeLeft(iTleft)
	local timeLeftLimit = get("Cheapo.timeleft")
	if timeLeftLimit == 0 then
		return true
	elseif timeLeftLimit == iTleft then
-- maybe use >= instead of == here to avoid running multiple searches?
		return true
	else
		private.debug = "Time left wrong"
		return false
	end
end



-- Do not bother about pet links when looking for transmog items:
-- if it's a caged pet then this code will not even be called
-- because caged pets don't have a sell-to-vendor price,
-- and vendor price is used as the primary search criteria.
-- before calling this function

local function PlayerNeedsTransmogMissingAppearance(itemLink)

if wowgameversion < 80000 then
-- safety check
return false
end

	local needsItem = false
	local _, canBeSource = false, false

	local itemID = tonumber(itemLink:match("item:(%d+)"));

	if itemID then
		_, _, canBeSource, _ = C_Transmog.GetItemInfo(itemID)
	end
	
if canBeSource then
	if not isCanIMogItUsable then
		needsItem = not C_TransmogCollection.PlayerHasTransmog(itemID)

		if needsItem then
			local sourceID = select(2, C_TransmogCollection.GetItemInfo(itemID))
			
			if sourceID then
				local weHaveInfo, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID);
				if weHaveInfo then
					if canCollect then
						needsItem = not C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID)
						else
						needsItem = false;
					end
				else
					needsItem = false;
				end
			else
				needsItem = false;
			end
		end
		
	else
		if not ( CanIMogIt:IsTransmogable(itemLink) ) then
				return false
						-- item is not transmoggable		
		end			


	needsItem = not CanIMogIt:PlayerKnowsTransmogFromItem(itemLink)
	
	
		if needsItem and not CompletionistMode then
		local checkthis = CanIMogIt:PlayerKnowsTransmog(itemLink)
			if checkthis ~= nil then
					needsItem = not checkthis
			end
		end
		
		
		if needsItem and CurrentCharOnly then
			needsItem = CanIMogIt:CharacterCanLearnTransmog(itemLink)
		end
		
		if needsItem and CurrentCharOnly then
			local checkthis = CanIMogIt:IsValidAppearanceForCharacter(itemLink)
			if checkthis == nil then 
				needsItem = false
			else
				needsItem = checkthis
			end
--				aucPrint("4-"..tostring(needsItem))
		end
		
		
		if needsItem and SetsComponentsOnly then
			    local sourceID = CanIMogIt:GetSourceID(itemLink)
		    if sourceID ~= nil then
			local checkthis = CanIMogIt:SetsDBGetSetFromSourceID(sourceID)
				if checkthis == nil then
					needsItem = false
				end
-- else -- don't touch needsItem state
			end
		end	
		
		
		if needsItem and UsableMogsOnly then
			local checkthis = CanIMogIt:CharacterIsTooLowLevelForItem(itemLink)
			if checkthis ~= nil then
				needsItem = not checkthis
--				aucPrint("2-"..tostring(needsItem))
			end
		end

	end
end
		
return needsItem
end

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	lib.MakeGuiConfig = nil

	--force refresh tab name
	lib.tabname = "Cheapo"
	
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")

	gui:AddSearcher("Cheapo", "Search for cheap items which are listed under, at or above sell-to-vendor price.", 100)

	gui:AddControl(id, "Header",     0,      "Near vendor price search")

	local last = gui:GetLast(id)
	gui:AddControl(id, "Slider", 0, 1, "Cheapo.vendorcap.pct", 0, 2000, 1, "extra factor: %s%%")
	
-----------	gui:AddControl(id, "Note",       0, 1, 100, 14, "TimeLeft:")
	gui:AddControl(id, "Selectbox",  0, 1, private.getTimeLeftStrings(), "Cheapo.timeleft", "time left")
	
	gui:AddControl(id, "Label", 0, 1, nil, "Maximum Price")
	gui:AddControl(id, "MoneyFramePinned",  0, 1, "Cheapo.maxprice", 1, Const.MAXBIDPRICE, "")

	gui:AddControl(id, "Label",        0, 1, nil, "  I recommend sorting on the profit or\npercent columns.\n\n  Percentages of 100 and above indicate\nthat the price is at or above the vendor\nprice.\n\n")

	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "Cheapo.allow.bid", "Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.52, 1, "Cheapo.allow.buy", "Buyouts")

if wowgameversion >= 80000 then

	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.66, 1, "Cheapo.transmog.mode", "Transmog mode")
	gui:AddTip(id, "Tries to filter out unusable and already known items. \n Reference price is still sell-to-vendor though, not market.")
	
	
	if (IsAddOnLoaded("CanIMogIt")) then	
		isCanIMogItUsable = true
	
	last = gui:GetLast(id)
	gui:AddControl(id, "Label", 0.365, 1, nil, "mog\nfor:")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "Cheapo.transmog.CurrentCharOnly", "class")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.52, 1, "Cheapo.transmog.usableonly", "level")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.61, 1, "Cheapo.transmog.SetsComponentsOnly", "sets")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.70, 1, "Cheapo.transmog.completionist", "completionist\nmode")


	
	gui:AddControl(id, "Label",        0.42, 1, nil, "   Notes:\n  -a) items listed at below-vendor prices will always be shown even if they are not transmog pieces.\n  -b) transmog searches for other classes rely on the \"Can I Mog It?\" database to be correctly updated.\n  -c) searching for item set pieces will also multiply internally the maximum price limit by 100 so that we can locate more items.\n  -d) the extra factor slider for percentage cap is used only when the transmog search mode is disabled.\n")
	
		gui:AddControl(id, "Label",        0.42, 1, nil, "\"Can I Mog It?\" addon presence detected, will use improved transmog detection functions provided by this addon's API.")
	else
	
	
	gui:AddControl(id, "Label",        0.42, 1, nil, "   Notes:\n  -Items listed at below-vendor prices will always be shown even if they are not transmog pieces.\n  -the extra factor slider for percentage cap is used only when the transmog search mode is disabled.\n")

		gui:AddControl(id, "Label",        0.45, 1, nil, "\n\n\"Can I Mog It?\" addon is NOT detected.\nThe search will use only basic transmog detection functions. You should expect to see weird results.")
	end	
-- ending wowgameversion UI build-up test	
end

--sanity checks: 
	if wowgameversion < 80000 then
	  set("Cheapo.transmog.mode", false)
	else
	  set("Cheapo.transmog.mode", true)
	end	

end

function lib.Search(item)
--force refresh tab name
lib.tabname = "Cheapo"

	local cheapmogs = get("Cheapo.transmog.mode")

	if wowgameversion < 80000 then
-- safety check, this makes sure to disable any possible transmog checks for classic WoW
	cheapmogs = false
	end
	
	CheapoMaxPercent = get("Cheapo.vendorcap.pct")

	CheapoMaxPprice = get("Cheapo.maxprice")

-- sanity checks and limits enforcement for slider values
	
	if CheapoMaxPercent == nil or type(CheapoMaxPercent) ~= "number" then
			CheapoMaxPercent = 20
			set("Cheapo.vendorcap.pct", 20)
		aucPrint("WARNING: Maximum Percentage is not a valid number, resetting to 20%")
	end

	if CheapoMaxPprice == nil or type(CheapoMaxPprice) ~= "number" then
			CheapoMaxPprice = 5000000
			set("Cheapo.maxprice", 5000000)
		aucPrint("WARNING: Maximum Price is not a valid number, resetting to 500g")
	end

	if CheapoMaxPercent > 2000 then
		CheapoMaxPercent = 2000
		set("Cheapo.vendorcap.pct", 2000)
	elseif CheapoMaxPercent < 0 then
		CheapoMaxPercent = 0
		set("Cheapo.vendorcap.pct", 0)
	end

local CheapoMaxActivePprice = CheapoMaxPprice

if isCanIMogItUsable then
	UsableMogsOnly = get("Cheapo.transmog.usableonly")
	CurrentCharOnly = get("Cheapo.transmog.CurrentCharOnly")
	CompletionistMode = get("Cheapo.transmog.completionist")
	SetsComponentsOnly = get("Cheapo.transmog.SetsComponentsOnly")
	if cheapmogs and SetsComponentsOnly then
		CheapoMaxActivePprice = CheapoMaxPprice * 100
	end
end

	
	local bidprice, buyprice = item[Const.PRICE], item[Const.BUYOUT]
	
	if buyprice <= 0 or not get("Cheapo.allow.buy") then
		buyprice = nil
	end
	if not get("Cheapo.allow.bid") then
		bidprice = nil
	end
	if not (bidprice or buyprice) then
		return false, "Does not meet bid/buy requirements"
	end

	if not private.CheckTimeLeft( item[Const.TLEFT] ) then
		return false, "Does not meet timeleft requirements"
	end

	-- local _,_,_,_,_,_,_,_,_,_,market = GetItemInfo(item[Const.LINK])
	local market = AucAdvanced.GetItemInfoCache(item[Const.LINK], 11)
	-- If there's no price, then we obviously can't sell it, ignore!
	if not market or market == 0 then
		return false, "No vendor price"
	end

	market = market * item[Const.COUNT]
local value = market	



if ( wowgameversion < 80000 ) or ( not cheapmogs ) then
	value = market * ((CheapoMaxPercent / 100)+1)	
else
-- do not limit percentage in transmog search mode for modern WoW.
	value = 99999999999
end



	if buyprice and buyprice <= value and buyprice <= CheapoMaxActivePprice then

		if buyprice < market then
		     return "buy", market, nil, "Vendor"
		  else
			if cheapmogs then
				if PlayerNeedsTransmogMissingAppearance(item[Const.LINK]) then
--					aucPrint("candidate found "..item[Const.LINK])
					return "buy", market, nil, "Cheapo random transmog"
				else
					return false, "item not needed for transmog"
				end
			else
				return "buy", market
			end
		  end
	elseif bidprice and bidprice <= value and bidprice <= CheapoMaxActivePprice then

	      if bidprice < market then
		     return "bid", market, nil, "Vendor"
		  else
  			if cheapmogs then
				if PlayerNeedsTransmogMissingAppearance(item[Const.LINK]) then
--					aucPrint("candidate found "..item[Const.LINK])
					return "bid", market, nil, "Cheapo random transmog"
				else
					return false, "item not needed for transmog"
				end
			else
				return "bid", market
			end
		end
	end
	return false, "Not a match for active criteria."
end

