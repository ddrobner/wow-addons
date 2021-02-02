LoadAddOn("Blizzard_WeeklyRewards")
-- Addon based on Ace3 addons like Bugsack, CoolGlow, SimulationCraft and many others

local _, GreatVault = ...
GreatVault = LibStub("AceAddon-3.0"):NewAddon(GreatVault, "GreatVault", "AceConsole-3.0", "AceEvent-3.0")

---Minimap Broker inspired by countless ace3 addons like bugsack, simulationcraft, coolglow and others
GreatVaultLDB = LibStub("LibDataBroker-1.1"):NewDataObject("GreatVault", { 
	type = "data source", 
	text = "The Great Vault", 
	icon = "Interface\\Addons\\GreatVault\\media\\icon.blp", 
	OnClick = function(_, button) 
		WeeklyRewardsFrame:SetShown(not WeeklyRewardsFrame:IsShown()) 
	end,

	OnTooltipShow = function(tt)    
	tt:AddLine("Great Vault")    
	tt:AddLine(" ")    
	tt:AddLine("Click to toggle The Great Vault.") 
	tt:AddLine(" ") 
	tt:AddLine("Toggle minimap button by typing |c33c9fcff/greatvault minimap|r")
 end})
tinsert(UISpecialFrames, "WeeklyRewardsFrame");LibDBIcon = LibStub("LibDBIcon-1.0")


-- db implemention copied from simulationcraft
function GreatVault:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("GreatVaultDB", {
    profile = {
      minimap = {
        hide = false,
      },
      frame = {
        point = "CENTER",
        relativeFrame = nil,
        relativePoint = "CENTER",
        ofsx = 0,
        ofsy = 0,
        width = 750,
        height = 400,
      },
    },
  });
  LibDBIcon:Register("GreatVault", GreatVaultLDB, self.db.profile.minimap)
  GreatVault:UpdateMinimapButton()
	
  GreatVault:RegisterChatCommand('greatvault', 'HandleChatCommand')
end

-- functions copied from simulationcraft
function GreatVault:OnEnable()

end

function GreatVault:OnDisable()

end

function GreatVault:UpdateMinimapButton()
  if (self.db.profile.minimap.hide) then
    LibDBIcon:Hide("GreatVault")
  else
    LibDBIcon:Show("GreatVault")
  end
end

local function getLinks(input)
  local separatedLinks = {}
  for link in input:gmatch("|c.-|h|r") do
     separatedLinks[#separatedLinks + 1] = link
  end
  return separatedLinks
end

--- handle chat copied from simulationcraft, credits to them 
function GreatVault:HandleChatCommand(input)
  local args = {strsplit(' ', input)}
  local links = getLinks(input)
  for _, arg in ipairs(args) do
    if arg == 'minimap' then
      self.db.profile.minimap.hide = not self.db.profile.minimap.hide
      DEFAULT_CHAT_FRAME:AddMessage("Great Vault Minimap Icon is now " .. (self.db.profile.minimap.hide and "hidden" or "shown"))
      GreatVault:UpdateMinimapButton()
      return 
    end
  end
end