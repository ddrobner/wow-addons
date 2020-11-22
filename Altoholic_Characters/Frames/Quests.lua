local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local currentCategoryID

local function SetStatus(character, category, numQuests)
	local allCategories = (category == 0)
	
	local text = ""
	
	if allCategories then
		text = format("%s / %s", QUEST_LOG, ALL)
	else
		local headers = DataStore:GetQuestHeaders(character)
		text = format("%s / %s", QUEST_LOG, headers[category])
	end

	local status = format("%s|r / %s (%s%d|r)", DataStore:GetColoredCharacterName(character), text, colors.green, numQuests)

	if AltoholicFrameQuests:IsVisible() then
        AltoholicTabCharacters.Status:SetText(status)
    end
end

local function GetQuestList(character, category)
	local list = {}
	
	DataStore:IterateQuests(character, category, function(questIndex) 
		table.insert(list, questIndex)
	end)
	
	return list
end

addon:Controller("AltoholicUI.QuestLog", {
	SetCategory = function(frame, categoryID) currentCategoryID = categoryID end,
	GetCategory = function(frame) return currentCategoryID end,
	OnBind = function(frame)
        AltoholicFrame:RegisterResizeEvent("AltoholicFrameQuests", 8, AltoholicFrameQuests)
	end,
	Update = function(frame)
        frame = frame or AltoholicFrameQuests
		local character = addon.Tabs.Characters:GetAltKey()
        if not currentCategoryID then
            for rowIndex = 1, 18 do
                frame.ScrollFrame:GetRow(rowIndex):Hide()
            end
            return
        end
		local questList = GetQuestList(character, currentCategoryID)
		
		SetStatus(character, currentCategoryID, #questList)

		local scrollFrame = frame.ScrollFrame
		local numRows = scrollFrame.numRows
		local offset = scrollFrame:GetOffset()
		
		for rowIndex = 1, numRows do
			local rowFrame = scrollFrame:GetRow(rowIndex)
			local line = rowIndex + offset
			
			rowFrame:Hide()
			
			if line <= #questList then	-- if the line is visible
				rowFrame:SetID(questList[line])
				
				local questName, questID, link, groupName, level, groupSize, tagID, 
						isComplete, isDaily, isTask, isBounty, isStory, isHidden, isSolo = DataStore:GetQuestLogInfo(character, questList[line])
				local money = DataStore:GetQuestLogMoney(character, questList[line])
				
				rowFrame:SetName(questName, level)
				rowFrame:SetType(tagID)
				rowFrame:SetRewards()
				rowFrame:SetInfo(isComplete, isDaily, groupSize, money)
                rowFrame:Show()
			end
		end
        
        for rowIndex = numRows, 18 do
            scrollFrame:GetRow(rowIndex):Hide()
        end

		scrollFrame:Update(#questList)
	end,
})
