--[[	*** LibGatheringNodes ***
Author: Teelo
11 October 2020

This library contains a database of gathering nodes with the associated item ID of the main item gathered from it.
--]]

local LIB_VERSION_MAJOR, LIB_VERSION_MINOR = "LibGatheringNodes-1.0", 6
local lib = LibStub:NewLibrary(LIB_VERSION_MAJOR, LIB_VERSION_MINOR)

if not lib then return end -- No upgrade needed

local GAME_LOCALE = GetLocale()

--	*** API ***

-- get the item ID of the resulting ore when given the gathering node name
-- you should extract the gather node name from the tooltip when the player mouses over an object
-- returns: item ID if it matches a known gathering node
-- or nil if no translation is known or if it isn't a gathering node
-- **
-- Update, version 6 onwards, 18/December/2020:
-- In ENGLISH only
-- Now returns ALL item IDs as a list of return values
-- Eg: returns itemID1, itemID2, itemID3, ...
function lib.getItemID(nodeName)
    local result = lib[GAME_LOCALE][nodeName]
    if type(result) == "table" then
        return unpack(result)
    else 
        return result
    end 
end