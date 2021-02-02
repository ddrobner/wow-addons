-- AdiBags_Keystone -- M+ keystone filter for AdiBags
-- Copyright (C) 2019 Tinkspring
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local mythicKeystoneFilter = AdiBags:RegisterFilter("Keystone", 91)
mythicKeystoneFilter.uiName = "Mythic+ Keystone";
mythicKeystoneFilter.uiDesc = "Put Mythic+ keystones in their own section."

function mythicKeystoneFilter:Filter(slotData)
  local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID, _, _ = GetItemInfo(slotData.itemId)
  if (classID == 5 and subclassID == 1) then
    return "Keystone";
  end
end
