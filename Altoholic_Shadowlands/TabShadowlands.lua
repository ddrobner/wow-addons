local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors

addon.Tabs.Shadowlands = {}

local ns = addon.Tabs.Shadowlands

local THIS_ACCOUNT = "Default"
local currentAccount = THIS_ACCOUNT
local currentRealm = GetRealmName()
local currentAlt = UnitName("player")
local currentPanel

-- ** Utility **
local DDM_AddTitle = addon.Helpers.DDM_AddTitle
local DDM_AddCloseMenu = addon.Helpers.DDM_AddCloseMenu
local classArray = {"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "HUNTER", "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}

local function GetCharacterLoginText(character)
	local last = DataStore:GetLastLogout(character)
	local _, realm, name = strsplit(".", character)
	
	if last then
		if (realm == GetRealmName()) and (name == UnitName("player")) then
			last = colors.green..GUILD_ONLINE_LABEL
		else
			last = format("%s: %s", LASTONLINE, colors.yellow..date("%m/%d/%Y %H:%M", last))
		end
	else
		last = ""
	end
	return format("%s %s(%s%s)", (DataStore:GetColoredCharacterName(character) or ""), colors.white, last, colors.white)
end

-- ** DB / Get **
function ns:GetAccount()
	return currentAccount
end

function ns:GetRealm()
	return currentRealm, currentAccount
end


function ns:GetAlt()
	return currentAlt, currentRealm, currentAccount
end

function ns:GetAltKey()
	if currentAlt and currentRealm and currentAccount then
		return format("%s.%s.%s", currentAccount, currentRealm, currentAlt)
	end
end

-- ** DB / Set **
function ns:SetAlt(alt, realm, account)
	currentAlt = alt
	currentRealm = realm
	currentAccount = account
end

function ns:SetAltKey(key)
	local account, realm, char = strsplit(".", key)
	ns:SetAlt(char, realm, account)
end

-- ** Icon events **
local function OnCharacterChange(self)
	ns:SetAltKey(self.value)
	
	CloseDropDownMenus()
	AltoholicTabShadowlands:Refresh()
    
    if not currentPanel then currentPanel = AltoholicTabShadowlands.OverviewPanel end
    
    currentPanel:Hide()
    currentPanel:Update()
end

local currentIcon
local function CharactersIcon_Initialize(self, level)
	local currentCharacterKey = ns:GetAltKey()
    local currentAccount, currentRealm, currentName = strsplit(".", currentCharacterKey)
    
	if level == 1 then
		for account in pairs(DataStore:GetAccounts()) do
			for realm in pairs(DataStore:GetRealms(account)) do

				local info = UIDropDownMenu_CreateInfo()

				info.text = realm
				info.hasArrow = 1
				info.checked = (currentRealm == realm)
				info.value = format("%s.%s", account, realm)
				info.func = nil
				UIDropDownMenu_AddButton(info, level)
			end
		end

		DDM_AddCloseMenu()

	elseif level == 2 then
		local menuAccount, menuRealm = strsplit(".", UIDROPDOWNMENU_MENU_VALUE)
		
		local nameList = {}		-- we want to list characters alphabetically
		for _, character in pairs(DataStore:GetCharacters(menuRealm, menuAccount)) do
            if select(2, DataStore:GetCharacterClass(character)) == classArray[currentIcon] then
			     table.insert(nameList, character)	-- we can add the key instead of just the name, since they will all be like account.realm.name, where account & realm are identical
            end
		end
		table.sort(nameList)
		

		for _, character in ipairs(nameList) do
			
			local info = UIDropDownMenu_CreateInfo()
			
			info.text		= GetCharacterLoginText(character)
			info.value		= character
			info.func		= OnCharacterChange
			info.icon		= nil
			info.checked	= (currentCharacterKey == character)
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

addon:Controller("AltoholicUI.TabShadowlandsCharacterIcon", {
    Icon_OnEnter = function(self, icon)
        currentIcon = self:GetID()
	    addon:DDM_Initialize(AltoholicTabShadowlands.ContextualMenu, CharactersIcon_Initialize)
	    CloseDropDownMenus()
	    ToggleDropDownMenu(1, nil, AltoholicTabShadowlands.ContextualMenu, icon, 0, -5)
    end,
    
    OnShow = function(self)
        local faction = "Alliance"
        if ((self:GetID() % 2) == 1) then faction = "Horde" end
        self:SetClass(classArray[self:GetID()], faction)
    end,
})

addon:Controller("AltoholicUI.TabShadowlands", {
	OnBind = function(frame)
        frame.ClassIcons:Update("THIS_ACCOUNT")
        
		-- Localise menu names
        frame.MenuItem1:SetText(OVERVIEW)
        frame.MenuItem2:SetText(COVENANT_SANCTUM_TAB_UPGRADES)
		frame.MenuItem3:SetText(COVENANT_SANCTUM_TAB_RENOWN)
        frame.MenuItem4:SetText(COVENANT_PREVIEW_SOULBINDS)
        frame.MenuItem5:SetText(COVENANT_PREVIEW_SANCTUM_FEATURE)
        frame.MenuItem6:SetText(ANIMA_DIVERSION_ORIGIN_TOOLTIP)
        frame.MenuItem7:SetText(C_Map.GetAreaInfo(10472))
        frame.MenuItem8:SetText(GREAT_VAULT_REWARDS)
		
        -- Set section 1 as default
        frame:MenuItem_Highlight(1)
        
        frame:Refresh()
	end,
	HideAll = function(frame)
		frame.OverviewPanel:Hide()
		frame.RenownPanel:Hide()
        frame.SoulbindsPanel:Hide()
        frame.SanctumFeaturesPanel:Hide()
        frame.AnimaDiversionPanel:Hide()
        frame.TorghastPanel:Hide()
        frame.WeeklyRewardsPanel:Hide()
        frame.ReservoirPanel:Hide()
	end,
	Refresh = function(frame)
        local key = ns:GetAltKey()
        local covenantData = C_Covenants.GetCovenantData(DataStore:GetCovenantID(key) or 0)
        
        if covenantData and covenantData.textureKit then
			AltoholicTabShadowlands.Background:SetAtlas(("ShadowlandsMissionsLandingPage-Background-%s"):format(covenantData.textureKit));
        else
        	AltoholicTabShadowlands.Background:SetAtlas(nil);
        end
	end,
	MenuItem_Highlight = function(frame, id)
		-- highlight the current menu item
		for i = 1, 8 do 
			frame["MenuItem"..i]:UnlockHighlight()
		end
		frame["MenuItem"..id]:LockHighlight()
	end,
	MenuItem_OnClick = function(frame, id, panel)
		frame:HideAll()
		frame:MenuItem_Highlight(id)
		
		if panel then
			frame[panel]:Update()
            currentPanel = frame[panel]
		end
	end,
})
