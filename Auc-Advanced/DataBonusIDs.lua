--[[
	Auctioneer
	Version: 8.2.6471 (SwimmingSeadragon)
	Revision: $Id: DataBonusIDs.lua 6471 2019-11-02 14:38:37Z none $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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

	Install BonusID data to the core AucAdvanced.Data table

	Implemented as a separate file containg raw bonusID data, for ease of maintenance
	Auctioneer modules will normally compile the raw data into a more useable format, usually during "gameactive" event

	This is not a complete set of all BonusIDs, only a subset that may be of interest to Auctioneer
--]]

if not AucAdvanced then return end
local data = AucAdvanced.Data -- add to existing data table (created in CoreManifest)
if not data then return end

-- Suffix lookup table. For each suffix, all variants are mapped to the same value
data.BonusSuffixMap = {
	["19"] = "29",
	["20"] = "29",
	["21"] = "29",
	["22"] = "29",
	["23"] = "29",
	["24"] = "29",
	["25"] = "29",
	["26"] = "29",
	["27"] = "29",
	["28"] = "29",
	["29"] = "29", -- Fireflash Crit/Haste
	["30"] = "29",
	["31"] = "29",
	["32"] = "29",
	["33"] = "29",
	["34"] = "29",
	["35"] = "29",
	["36"] = "29",
	["37"] = "29",
	["38"] = "29",
	["39"] = "29",
	["45"] = "55",
	["46"] = "55",
	["47"] = "55",
	["48"] = "55",
	["49"] = "55",
	["50"] = "55",
	["51"] = "55",
	["52"] = "55",
	["53"] = "55",
	["54"] = "55",
	["55"] = "55", -- Peerless Crit/Mastery
	["56"] = "55",
	["57"] = "55",
	["58"] = "55",
	["59"] = "55",
	["60"] = "55",
	["61"] = "55",
	["62"] = "55",
	["63"] = "55",
	["64"] = "55",
	["65"] = "55",
	["66"] = "55",
	["67"] = "55",
	["68"] = "55",
	["69"] = "55",
	["70"] = "55",
	["71"] = "55",
	["72"] = "55",
	["73"] = "55",
	["74"] = "55",
	["75"] = "55",
	["76"] = "55",
	["77"] = "55",
	["78"] = "55",
	["79"] = "55",
	["80"] = "55",
	["81"] = "55",
	["82"] = "55",
	["83"] = "55",
	["84"] = "55",
	["85"] = "55",
	["86"] = "55",
	["87"] = "97",
	["88"] = "97",
	["89"] = "97",
	["90"] = "97",
	["91"] = "97",
	["92"] = "97",
	["93"] = "97",
	["94"] = "97",
	["95"] = "97",
	["96"] = "97",
	["97"] = "97", -- Quickblade Crit/Versatility
	["98"] = "97",
	["99"] = "97",
	["100"] = "97",
	["101"] = "97",
	["102"] = "97",
	["103"] = "97",
	["104"] = "97",
	["105"] = "97",
	["106"] = "97",
	["107"] = "97",
	["108"] = "118",
	["109"] = "118",
	["110"] = "118",
	["111"] = "118",
	["112"] = "118",
	["113"] = "118",
	["114"] = "118",
	["115"] = "118",
	["116"] = "118",
	["117"] = "118",
	["118"] = "118", -- Feverflare Haste/Mastery
	["119"] = "118",
	["120"] = "118",
	["121"] = "118",
	["122"] = "118",
	["123"] = "118",
	["124"] = "118",
	["125"] = "118",
	["126"] = "118",
	["127"] = "118",
	["128"] = "118",
	["129"] = "29",
	["130"] = "29",
	["131"] = "29",
	["132"] = "29",
	["133"] = "29",
	["134"] = "29",
	["135"] = "29",
	["136"] = "29",
	["137"] = "29",
	["138"] = "29",
	["139"] = "29",
	["140"] = "29",
	["141"] = "29",
	["142"] = "29",
	["143"] = "29",
	["144"] = "29",
	["145"] = "29",
	["146"] = "29",
	["147"] = "29",
	["148"] = "29",
	["149"] = "29",
	["150"] = "160",
	["151"] = "160",
	["152"] = "160",
	["153"] = "160",
	["154"] = "160",
	["155"] = "160",
	["156"] = "160",
	["157"] = "160",
	["158"] = "160",
	["159"] = "160",
	["160"] = "160", -- Aurora Haste/Versatility
	["161"] = "160",
	["162"] = "160",
	["163"] = "160",
	["164"] = "160",
	["165"] = "160",
	["166"] = "160",
	["167"] = "160",
	["168"] = "160",
	["169"] = "160",
	["170"] = "160",
	["175"] = "118",
	["176"] = "118",
	["177"] = "118",
	["178"] = "118",
	["179"] = "118",
	["180"] = "118",
	["181"] = "118",
	["182"] = "118",
	["183"] = "118",
	["184"] = "118",
	["185"] = "118",
	["186"] = "118",
	["187"] = "118",
	["188"] = "118",
	["189"] = "118",
	["190"] = "118",
	["191"] = "118",
	["192"] = "118",
	["193"] = "118",
	["194"] = "118",
	["195"] = "118",
	["196"] = "206",
	["197"] = "206",
	["198"] = "206",
	["199"] = "206",
	["200"] = "206",
	["201"] = "206",
	["202"] = "206",
	["203"] = "206",
	["204"] = "206",
	["205"] = "206",
	["206"] = "206", -- Harmonious Mastery/Versatility
	["207"] = "206",
	["208"] = "206",
	["209"] = "206",
	["210"] = "206",
	["211"] = "206",
	["212"] = "206",
	["213"] = "206",
	["214"] = "206",
	["215"] = "206",
	["216"] = "206",
	["217"] = "160",
	["218"] = "160",
	["219"] = "160",
	["220"] = "160",
	["221"] = "160",
	["222"] = "160",
	["223"] = "160",
	["224"] = "160",
	["225"] = "160",
	["226"] = "160",
	["227"] = "160",
	["228"] = "160",
	["229"] = "160",
	["230"] = "160",
	["231"] = "160",
	["232"] = "160",
	["233"] = "160",
	["234"] = "160",
	["235"] = "160",
	["236"] = "160",
	["237"] = "160",
	["238"] = "97",
	["239"] = "97",
	["240"] = "97",
	["241"] = "97",
	["242"] = "97",
	["243"] = "97",
	["244"] = "97",
	["245"] = "97",
	["246"] = "97",
	["247"] = "97",
	["248"] = "97",
	["249"] = "97",
	["250"] = "97",
	["251"] = "97",
	["252"] = "97",
	["253"] = "97",
	["254"] = "97",
	["255"] = "97",
	["256"] = "97",
	["257"] = "97",
	["258"] = "97",
	["259"] = "160",
	["260"] = "160",
	["261"] = "160",
	["262"] = "160",
	["263"] = "160",
	["264"] = "160",
	["265"] = "160",
	["266"] = "160",
	["267"] = "160",
	["268"] = "160",
	["269"] = "160",
	["270"] = "160",
	["271"] = "160",
	["272"] = "160",
	["273"] = "160",
	["274"] = "160",
	["275"] = "160",
	["276"] = "160",
	["277"] = "160",
	["278"] = "160",
	["279"] = "160",
	["280"] = "206",
	["281"] = "206",
	["282"] = "206",
	["283"] = "206",
	["284"] = "206",
	["285"] = "206",
	["286"] = "206",
	["287"] = "206",
	["288"] = "206",
	["289"] = "206",
	["290"] = "206",
	["291"] = "206",
	["292"] = "206",
	["293"] = "206",
	["294"] = "206",
	["295"] = "206",
	["296"] = "206",
	["297"] = "206",
	["298"] = "206",
	["299"] = "206",
	["300"] = "206",
	["301"] = "97",
	["302"] = "97",
	["303"] = "97",
	["304"] = "97",
	["305"] = "97",
	["306"] = "97",
	["307"] = "97",
	["308"] = "97",
	["309"] = "97",
	["310"] = "97",
	["311"] = "97",
	["312"] = "97",
	["313"] = "97",
	["314"] = "97",
	["315"] = "97",
	["316"] = "97",
	["317"] = "97",
	["318"] = "97",
	["319"] = "97",
	["320"] = "97",
	["321"] = "97",
	["322"] = "206",
	["323"] = "206",
	["324"] = "206",
	["325"] = "206",
	["326"] = "206",
	["327"] = "206",
	["328"] = "206",
	["329"] = "206",
	["330"] = "206",
	["331"] = "206",
	["332"] = "206",
	["333"] = "206",
	["334"] = "206",
	["335"] = "206",
	["336"] = "206",
	["337"] = "206",
	["338"] = "206",
	["339"] = "206",
	["340"] = "206",
	["341"] = "206",
	["342"] = "206",
	["343"] = "97",
	["344"] = "97",
	["345"] = "97",
	["346"] = "97",
	["347"] = "97",
	["348"] = "97",
	["349"] = "97",
	["350"] = "97",
	["351"] = "97",
	["352"] = "97",
	["353"] = "97",
	["354"] = "97",
	["355"] = "97",
	["356"] = "97",
	["357"] = "97",
	["358"] = "97",
	["359"] = "97",
	["360"] = "97",
	["361"] = "97",
	["362"] = "97",
	["363"] = "97",
	["364"] = "160",
	["365"] = "160",
	["366"] = "160",
	["367"] = "160",
	["368"] = "160",
	["369"] = "160",
	["370"] = "160",
	["371"] = "160",
	["372"] = "160",
	["373"] = "160",
	["374"] = "160",
	["375"] = "160",
	["376"] = "160",
	["377"] = "160",
	["378"] = "160",
	["379"] = "160",
	["380"] = "160",
	["381"] = "160",
	["382"] = "160",
	["383"] = "160",
	["384"] = "160",
	["385"] = "206",
	["386"] = "206",
	["387"] = "206",
	["388"] = "206",
	["389"] = "206",
	["390"] = "206",
	["391"] = "206",
	["392"] = "206",
	["393"] = "206",
	["394"] = "206",
	["395"] = "206",
	["396"] = "206",
	["397"] = "206",
	["398"] = "206",
	["399"] = "206",
	["400"] = "206",
	["401"] = "206",
	["402"] = "206",
	["403"] = "206",
	["404"] = "206",
	["405"] = "206",
	["406"] = "160",
	["407"] = "160",
	["408"] = "160",
	["409"] = "160",
	["410"] = "160",
	["411"] = "160",
	["412"] = "160",
	["413"] = "160",
	["414"] = "160",
	["415"] = "160",
	["416"] = "160",
	["417"] = "160",
	["418"] = "160",
	["419"] = "160",
	["420"] = "160",
	["421"] = "160",
	["422"] = "160",
	["423"] = "160",
	["424"] = "160",
	["425"] = "160",
	["426"] = "160",
	["427"] = "206",
	["428"] = "206",
	["429"] = "206",
	["430"] = "206",
	["431"] = "206",
	["432"] = "206",
	["433"] = "206",
	["434"] = "206",
	["435"] = "206",
	["436"] = "206",
	["437"] = "206",
	["438"] = "206",
	["439"] = "206",
	["440"] = "206",
	["441"] = "206",
	["442"] = "206",
	["443"] = "206",
	["444"] = "206",
	["445"] = "206",
	["446"] = "206",
	["447"] = "206",
	["459"] = "29",
	["460"] = "55",
	["464"] = "118",
	["465"] = "160",
	["469"] = "206",
	["478"] = "97",
	["479"] = "487",
	["480"] = "488",
	["481"] = "490",
	["485"] = "486",
	["486"] = "486", -- Decimator Crit
	["487"] = "487", -- Impatient Haste
	["488"] = "488", -- Savant Mastery
	["489"] = "486",
	["490"] = "490", -- Adaptable Versatility
	["491"] = "490",
	["492"] = "490",
	["1676"] = "97",
	["1677"] = "97",
	["1678"] = "97",
	["1679"] = "97",
	["1680"] = "97",
	["1681"] = "97",
	["1682"] = "97",
	["1683"] = "55",
	["1684"] = "55",
	["1685"] = "55",
	["1686"] = "55",
	["1687"] = "55",
	["1688"] = "55",
	["1689"] = "55",
	["1690"] = "29",
	["1691"] = "29",
	["1692"] = "29",
	["1693"] = "29",
	["1694"] = "29",
	["1695"] = "29",
	["1696"] = "29",
	["1697"] = "118",
	["1698"] = "118",
	["1699"] = "118",
	["1700"] = "118",
	["1701"] = "118",
	["1702"] = "118",
	["1703"] = "118",
	["1704"] = "160",
	["1705"] = "160",
	["1706"] = "160",
	["1707"] = "160",
	["1708"] = "160",
	["1709"] = "160",
	["1710"] = "160",
	["1711"] = "206",
	["1712"] = "206",
	["1713"] = "206",
	["1714"] = "206",
	["1715"] = "206",
	["1716"] = "206",
	["1717"] = "206",
	["1718"] = "486",
	["1719"] = "490",
	["1720"] = "487",
	["1721"] = "488",
	["1742"] = "97",
	["1743"] = "97",
	["1744"] = "97",
	["1745"] = "97",
	["1746"] = "97",
	["1747"] = "97",
	["1748"] = "97",
	["1749"] = "55",
	["1750"] = "55",
	["1751"] = "55",
	["1752"] = "55",
	["1753"] = "55",
	["1754"] = "55",
	["1755"] = "55",
	["1756"] = "29",
	["1757"] = "29",
	["1758"] = "29",
	["1759"] = "29",
	["1760"] = "29",
	["1761"] = "29",
	["1762"] = "29",
	["1763"] = "118",
	["1764"] = "118",
	["1765"] = "118",
	["1766"] = "118",
	["1767"] = "118",
	["1768"] = "118",
	["1769"] = "118",
	["1770"] = "160",
	["1771"] = "160",
	["1772"] = "160",
	["1773"] = "160",
	["1774"] = "160",
	["1775"] = "160",
	["1776"] = "160",
	["1777"] = "206",
	["1778"] = "206",
	["1779"] = "206",
	["1780"] = "206",
	["1781"] = "206",
	["1782"] = "206",
	["1783"] = "206",
	["1784"] = "486",
	["1785"] = "490",
	["1786"] = "487",
	["1787"] = "488",
	["3343"] = "97",
	["3344"] = "97",
	["3345"] = "97",
	["3346"] = "55",
	["3347"] = "55",
	["3348"] = "55",
	["3349"] = "29",
	["3350"] = "29",
	["3351"] = "55",
	["3352"] = "55",
	["3353"] = "29",
	["3354"] = "55",
	["3355"] = "118",
	["3356"] = "118",
	["3357"] = "118",
	["3358"] = "206",
	["3359"] = "206",
	["3360"] = "206",
	["3361"] = "97",
	["3362"] = "97",
	["3363"] = "97",
	["3364"] = "160",
	["3365"] = "160",
	["3366"] = "160",
	["3367"] = "206",
	["3368"] = "206",
	["3369"] = "206",
	["3370"] = "29",
	["3371"] = "29",
	["3372"] = "29",
	["3373"] = "118",
	["3374"] = "118",
	["3375"] = "118",
	["3376"] = "160",
	["3377"] = "160",
	["3378"] = "160",
	["3401"] = "97",
	["3402"] = "55",
	["3403"] = "29",
	["3404"] = "118",
	["3405"] = "160",
	["3406"] = "206",
}

data.BonusPrimaryStatList = {
	517, -- +Agi
	550, -- +Str
	551, -- +Int
}

data.BonusTierList = {
	545, -- Epic upgrade
	566, -- Heroic
	567, -- Mythic
	1798, -- Heroic 705
	1799, -- Mythic 720
}

data.BonusCraftedStageList = {
	525, -- Stage 1 (basic item)
	526, -- Stage 2
	558, -- Stage 2
	527, -- Stage 3
	559, -- Stage 3
	593, -- Stage 4
	594, -- Stage 4
	617, -- Stage 5
	619, -- Stage 5
	618, -- Stage 6
	620, -- Stage 6
}

data.BonusWarforgedList = {
	560,
	561, -- Heroic
	562, -- Mythic
}

data.BonusSocketedList = {
	563,
	564, -- Heroic
	565, -- Mythic
}

data.BonusTertiaryStatList = {
	40, -- Avoidance
	41, -- Leech
	42, -- Speed
	43, -- Indestructible
}

AucAdvanced.RegisterRevision("$URL: Auc-Advanced/DataBonusIDs.lua $", "$Rev: 6471 $")
