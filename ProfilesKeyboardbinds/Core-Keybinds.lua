KPS = LibStub("AceAddon-3.0"):NewAddon("Profiles: Keyboard binds", "AceConsole-3.0", "AceEvent-3.0","AceTimer-3.0")
KPS:SetDefaultModuleState(false)

AceGUI = LibStub("AceGUI-3.0")


-- Globals within this addon
local KPSversion = "v1.9.3.71"
local WoWversion = 70100
local KPSdebugframe = 0
local KPSdebugbuffer = {}
local KLSdebugEnabled = 0
local run_counter = {}      -- Global for routines to not run more than once, modified by event_throttle() ONLY!
local update_bindings_counter = 0 -- UPDATE_BINDINGS event must not run first time

function KPS:Echo(text)
	if PROFILES_TYST then return end
	
   DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Profiles: Keyboard Binds - "..text)
end


function KPS:OnInitialize()
   
    KPSdb = LibStub("AceDB-3.0"):New("ProfilesKeyboardbinds",nil,"Default")
    KPSglobaldb = LibStub("AceDB-3.0"):New("ProfilesKeyboardbindsG",nil,"Default")
	KPS:SetupOptions()
	
        -- Check if we have are supposed to load the modile
    if KPSdb.char.KLSaddonEnabled == 0 then 
        KPS:Disable()
    else
        KPS:Enable()
    end
	
	if KPSdb.char.KPSLoadProfileAtStart == 1 then
		KPS:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
	
end

function KPS:PLAYER_ENTERING_WORLD(event, addonname)
	
	if select(4, GetBuildInfo()) == WoWversion then
		
		KPS:UnregisterEvent("PLAYER_ENTERING_WORLD")

		-- Save a restore point if empty db
		if not KPS:ExistsProfile("Restore [LOCKED]") and not KPSSAVERESTORE then 
			KPSSAVERESTORE=1 
			KPS:SaveProfil("Restore [LOCKED]") 
			KPSSAVERESTORE=nil
		end
		
		if KPSdb.char.Active_profile and KPSdb.char.Active_profile ~= "Restore [LOCKED]" then
			KPS:LoadProfil(KPSdb.char.Active_profile)
		end
	end
	
	if select(4, GetBuildInfo()) ~= WoWversion then
		KPS:UnregisterEvent("PLAYER_ENTERING_WORLD")
		KPS:Echo("This addon is not compatible with this version of WoW. Please update it from curse.com")
	end
end

-- Addon loaded
function KPS:OnEnable()
KPS:DebugMsg("Core: OnEnable()")
    
    KLSdebugEnabled = KPSdb.char.KLSdebugEnabled or 0
    KPS:DebugWindowToggle(KLSdebugEnabled)
    
    DEFAULT_CHAT_FRAME:AddMessage("Profiles: Keyboard binds v"..KPSversion.." ON")
    
    if KPSdb.char.KLSaddonEnabled == nil then
        KPSdb.char.KLSaddonEnabled = 1
    end
    
    KPSdb.char.KLStriggerModule = KPSdb.char.KLStriggerModule or "KPS: Manual Profiles"
    KPS:DebugMsg("Core: OnEnable() - Loading trigger module -"..KPSdb.char.KLStriggerModule.."-") 
    
    KPS:EnableModule(KPSdb.char.KLStriggerModule)   
end


-- Toggle a named module.
-- If no module is passed to this routine, it shuts off all modules 
-- and sets KPS: Talents as default
function KPS:ModuleToggle(KPSmodule)
KPS:DebugMsg("ModuleToggle()")

    -- Empty named var, setting default
    if not KPSmodule then
        KPS:DebugMsg("ModuleToggle(): No module passed on. Setting default..")
        
        -- Disable all but default
        for name, module in KPS:IterateModules() do
        
        
            if name ~= "KPS: Manual Profiles" then
                KPS:DebugMsg("ModuleToggle(): Disabling -"..name.."-")
                KPS:DisableModule(name)
            end
        end
        
        KPSdb.char.KLStriggerModule = "KPS: Manual Profiles"
        KPS:EnableModule("KPS: Manual Profiles")
        
        return
    end
    
    -- This module is enabled, disable it now
    if KPSdb.char.KLStriggerModule == KPSmodule then
    KPS:DebugMsg("ModuleToggle(): This is already enabled. Now disabling -"..KPSmodule)
    
        -- Disable all but default
        for name, module in KPS:IterateModules() do
            if name ~= "KPS: Manual Profiles" then
                KPS:DebugMsg("ModuleToggle(): Disabling -"..name.."-")
                KPS:DisableModule(name)
            end
        end
        
        KPSdb.char.KLStriggerModule = "KPS: Manual Profiles"
        KPS:EnableModule("KPS: Manual Profiles")
        
        return
    end
    
    -- This module is disabled, try to enable it!
    
    -- Disable all but this module
    for name, module in KPS:IterateModules() do   
            if name ~= KPSmodule then
                KPS:DebugMsg("ModuleToggle(): Disabling -"..name.."-")
                KPS:DisableModule(name)
            else
                KPS:DebugMsg("ModuleToggle(): Enabling -"..KPSmodule.."-")
                
            end
    end
    
    KPS:DebugMsg("ModuleToggle(): This is disabled. Now enabling -"..KPSmodule)
    
    KPSdb.char.KLStriggerModule = KPSmodule
    
    if not KPS:EnableModule(KPSdb.char.KLStriggerModule) then
        KPS:DebugMsg("ModuleToggle(): Loading module '"..KPSdb.char.KLStriggerModule.."' failed. Reverting to 'KPS: Talents' module.")
        DEFAULT_CHAT_FRAME:AddMessage(KPSdb.char.KLStriggerModule.." failed to load. Setting default -KPS: Talents-")
        
        KPSdb.char.KLStriggerModule = "KPS: Manual Profiles"
        KPS:EnableModule("KPS: Manual Profiles")

        return
    else
        KPS:DebugMsg("ModuleToggle(): Module '"..KPSdb.char.KLStriggerModule.."' loaded.")
    end
end

function KPS:OnDisable()
KPS:DebugMsg("OnDisable()")
        
    DEFAULT_CHAT_FRAME:AddMessage("Profiles: Keyboard binds v"..KPSversion.." OFF")
   
    KPS:DebugMsg("OnDisable(): Unregistering modules")
    KPS:DisableModule(KPSdb.char.KLStriggerModule)
    
    KPSdb.char.KLSaddonEnabled = 0
    KPS:Disable()
end

-- ProfilesHub: Send message to all slaves that we are now exporting profile
function KPS:PreExport(name)
	KPS:SendAceMsg("export",name) -- ProfilesHub
end

-- This is an alias for ProfilesHub
function KPS:Export(...)
	KPS:ExportCharProfile(...)
end


-- Export char profile to global
function KPS:ExportCharProfile(name)
KPS:DebugMsg("Export("..name..")")

	if name == nil then
		name = KPSdb.char.Active_profile
	end

	if KPS:ExistsProfile(name) then
		local orig_profile = KPSdb:GetCurrentProfile()
		
		KPSglobaldb:SetProfile("General: "..name)
		KPSdb:SetProfile(name)
		
		
		-- KPSglobaldb.profile = KPSdb.profile
		for index, value in orderedPairs(KPSdb.profile) do
		  KPSglobaldb.profile[index] = value
		  
		  --KPS:DebugMsg("Export(): "..name)
		  
		  --KPS:DebugMsg("Export(): Writing.."..index.." "..value.." to global " ..KPSglobaldb.profile[index].." "..value)
		  
		  --dump(value)
		  
		end
	
		KPSdb:SetProfile(orig_profile)
		
		KPS:Echo("Profile exported "..name)
		return 1
	else
		KPS:Echo("No such profile exists: "..name)
		return nil
	end
end

function KPS:ExistsProfile(name)

	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then 
		DB = KPSglobaldb 
		else 
		DB = KPSdb 
	end
	
	for i, key in ipairs(DB:GetProfiles()) do
      if key == name then
         return (key)
      end
    end
   
    return nil
end


-- ProfilesHub: Send message to all slaves that we are now saving profile
function KPS:PreSaveBindsProfile(name)
	KPS:SendAceMsg("save",name) -- ProfilesHub
end

-- This function should NOT BE CALLED DIRECTLY.
-- Should only be called by slave event!

function KPS:SaveProfil(name)

	if name == nil then
		name = KPSdb.char.Active_profile
	end

	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then 
		DB = KPSglobaldb 
	else 
		DB = KPSdb 
	end
	
	-- Save a restore point if empty db
	if not KPS:ExistsProfile("Restore [LOCKED]") and not KPSSAVERESTORE then 
		KPSSAVERESTORE=1 
		KPS:SaveProfil("Restore [LOCKED]") 
		KPSSAVERESTORE=nil
	end
	
	-- User trying to overwrite restore point!
	if name == "Restore [LOCKED]" and not KPSSAVERESTORE then 
		KPS:Echo("This profile is locked at the first run and can only be loaded!")
		return
	end
	
	
	KPS:DebugMsg("SaveProfil("..name..")")
	
	KPS:Echo("Saving keybinds to profile "..name.."!")

	DB:SetProfile(name)
	
	-- Solving /kps save tank X 2
	if KPS:ExistsProfile(name) then KPSdb:ResetProfile(name) end
	
	
        
    -- Go through the actionbars  and save _defined_ keybinds// Thank you Adirelle
	for index = 1, GetNumBindings() do
	  local command, key1 = GetBinding(index)
	  
	  if key1 then
		-- This creates a table like { cmd = key1, key2, key3 }
		DB.profile[command] = { key1, select(3, GetBinding(index)) }
	  else
		-- Remove previous bindings
		DB.profile[command] = nil
	  end
	end  
	
	KPS:SendMessage("KPS_Profiles_save",name) -- ProfilesHub
	return name
end

-- This is an alias for ProfilesHub
function KPS:Save(...)
	KPS:SaveProfil(...)
end

-- ProfilesHub: Send message to all slaves that we are now saving profile
function KPS:PreLoadBindsProfile(name)
	KPS:SendAceMsg("load",name) -- ProfilesHub
end

-- This function should NOT BE CALLED DIRECTLY.
-- Should only be called by slave event!

function KPS:LoadProfil(name)
KPS:DebugMsg("LoadProfil("..name..")")

	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then 
		DB = KPSglobaldb 
	else 
		DB = KPSdb 
	end
	
	-- Save a restore point if empty db
	if not KPS:ExistsProfile("Restore [LOCKED]") and not KPSSAVERESTORE then 
		KPSSAVERESTORE=1 
		KPS:SaveProfil("Restore [LOCKED]") 
		KPSSAVERESTORE=nil
	end

	if InCombatLockdown() then -- if (player is in fight)
		KPS:Echo("You can t change your keyboardlayout in fight.")
		return nil
	elseif (KPS:ExistsProfile(name)==nil)then
		KPS:Echo("-"..name.."- doesn t exist.")
		return nil
	else
		KPS:DebugMsg("LoadProfil(): Setting profile "..name)
        DB:SetProfile(name)
		KPSdb.char.Active_profile = name
		KPSdb.char.Version = KPSversion
        
		
		-- Remove all keybinding before we load
		for index = 1, GetNumBindings() do
			local command, key1 = GetBinding(index)
	  
			KPS:UnbindCommand(command)
		end
		
        -- To restore
		for command, keys in pairs(DB.profile) do
            
            
            if command ~= "Reset" then 		
					local current_keys = {GetBindingKey(command)}       -- Current bindings -> UP/W
					local saved_keys = {}                               -- Saved bindings
					local binding_modified = 0                          -- Modified flag
					local current_keys_table = {}

					-- Transform to hash tables
					for i,v in pairs(DB.profile[command]) do saved_keys[v]="1" end			 -- table[1]:W -> saved_keys[W]
					for i=1, #current_keys do  current_keys_table[current_keys[i]] = "1"  end    -- @table     -> current_keys_table[Q]

					-- Check saved <=> current hash
					for i,v in pairs (saved_keys) do
					   if not current_keys_table[i] then
						  binding_modified = 1
						  KPS:DebugMsg("LoadProfil(): .Key "..i.." was changed in saved profile.")
					   end
					end

					-- Check current <=> saved hash
					if (binding_modified == 0) then
					   for i,v in pairs (current_keys_table) do
						  if not saved_keys[i] then
							 binding_modified = 1    
							  KPS:DebugMsg("LoadProfil(): -Key "..i.." was changed in saved profile.")
						  end
					   end
					end
					
					-- Modified flag active!
					if binding_modified == 1 then
					KPS:DebugMsg("LoadProfil(): "..command.." was found changed. Now restoring..")
						-- Remove all current binds for this action (eg. MOVEFORWARD)
						for i,v in pairs (current_keys_table) do
						   --KPS:DebugMsg("LoadProfil(): +Key "..i.." was changed in saved profile.")
						   
						   -- Code for addons
						   -- If active, do not touch its keybinds
						   if command == "TARGETNEARESTENEMYPLAYER" and SmartTargeting then
							KPS:DebugMsg("LoadProfil(): "..command.." was not changed because SmartTargeting addon is active!")
						   elseif command == "TARGETNEARESTENEMY" and SmartTargeting then
							KPS:DebugMsg("LoadProfil(): "..command.." was not changed because SmartTargeting addon is active!")
						   elseif command == "UIRELOAD" and SimpleReloadUI then
							print("LoadProfil(): "..command.." was not changed because SimpleReloadUI addon is active!")
						   else
								SetBinding(i)
						   end
						end
						
						-- Add all saved keys to this action
						for i,v in pairs (saved_keys) do
						
							-- Code for addon SmartTargeting
							-- If active, do not touch its keybinds
							if command == "TARGETNEARESTENEMYPLAYER" and SmartTargeting then
								KPS:DebugMsg("LoadProfil(): "..command.." was not changed because SmartTargeting addon is active!")
							elseif command == "TARGETNEARESTENEMY" and SmartTargeting then
								KPS:DebugMsg("LoadProfil(): "..command.." was not changed because SmartTargeting addon is active!")
							elseif command == "UIRELOAD" and  SimpleReloadUI then
								print("LoadProfil(): "..command.." was not changed because SimpleReloadUI addon is active!")
							else
								SetBinding(i,command)
							end
							--KPS:DebugMsg("LoadProfil(): >Key "..i.." was changed in saved profile.")
						end
						binding_modified = 0
				   end
			 end
		end         
		
	end



    KPS:Echo("-"..name.."- loaded")
    SaveBindings(2)
    
	KPS:SendMessage("KPS_Profiles_save",name) -- ProfilesHub

	return name
end


function KPS:UnbindCommand(command)
	-- Unbind all keys for this command
	local current_keys = {GetBindingKey(command)}  	-- Get keys for this command
	local current_keys_table = {}
	for i=1, #current_keys do  current_keys_table[current_keys[i]] = "1"  end
	for i,v in pairs (current_keys_table) do
	   SetBinding(i) 								-- Unbind!
	end
end

-- This is an alias for ProfilesHub
function KPS:Load(...)
	KPS:LoadProfil(...)
end

-- ProfilesHub: Send message to all slaves that we are now deleting profile
function KPS:PreDeleteProfile(name)
	KPS:SendAceMsg("delete",name) -- ProfilesHub
end

function KPS:DeleteProfil(name)
	
	-- Global DB Code
	local DB = {}
    if string.find(name,"General:") then 
		DB = KPSglobaldb 
	else 
		DB = KPSdb 
	end
	
	-- User trying to overwrite restore point!
	if name == "Restore [LOCKED]" and not KPSSAVERESTORE then 
		KPS:Echo("This profile is locked at the first run and can only be loaded!")
		return nil
	end
	
	
	if (KPS:ExistsProfile(name)==nil)then
		KPS:Echo(name.." doesnt exist.")
		KPS:ListProfiles()
		
		return nil
	else
		if name == DB:GetCurrentProfile() then
			DB:SetProfile('Default')
		end
		DB:DeleteProfile(name)
		KPS:Echo(name.." deleted.")
		
		return name
	end
end

-- This is an alias for ProfilesHub
function KPS:Delete(...)
	KPS:DeleteProfil(...)
end

function KPS:ListProfiles(silent, globaldb)
KPS:DebugMsg("ListProfiles()")

	-- Global DB Code
	local DB = {}
    if globaldb then 
		DB = KPSglobaldb 
	else 
		DB = KPSdb 
	end
    
	local KPS_Profiles = {}
	
	for i,k in ipairs(DB:GetProfiles()) do
		if not silent then
			KPS:Echo("Available Profiles: ");
			KPS:Echo(' - ' .. k)
		end
		
		KPS_Profiles[k] = 0
	end
	
	return MP_profiles
end

function KPS:DebugWindowToggle(visible)
   if visible == 1 then
      KLSdebugEnabled = 1
      KPSdb.char.KLSdebugEnabled=1
      
      KPSdebugframe = AceGUI:Create("Frame")
      KPSdebugframe:SetTitle("Profiles: Keyboard binds Debug")
      KPSdebugframe:SetStatusText("To turn this window off: /kps debug off")
      KPSdebugframe:SetCallback("OnClose", function(widget) AceGUI:Release(widget) KLSdebugEnabled = 0 KPSdb.char.KLSdebugEnabled=0 KPS:DebugWindowToggle() end)
      KPSdebugframe:SetLayout("Fill")
      KPSdebugframe:SetWidth("400")
      KPSdebugframe:SetHeight("400")
      KPS:DebugMsg("DebugWindowToggle(1)")
   else
   KPS:DebugMsg("DebugWindowToggle(0)")
      if KLSdebugEnabled == 1 then
          KLSdebugEnabled = 0
          KPSdb.char.KLSdebugEnabled=0
          KPSdebugframe:Release()
      end
   end
   
end

function KPS:DebugMsg(debugMessage)
   if KPSdebugbuffer == 0 then
      debugMessage = date("%H:%M:%S").." - DEBUGGER Loaded"
      table.insert(KPSdebugbuffer,debugMessage)
      
   else
      debugMessage = date("%H:%M:%S").." - "..debugMessage
      table.insert(KPSdebugbuffer,debugMessage)
   end
  
    if KLSdebugEnabled ~= 1 then 
        KPSdebugbuffer = circular_list(KPSdebugbuffer,200) -- Save 20 debug messages by default, even with debug turned off.
        return
    end
    
   KPSdebugframe:ReleaseChildren() -- Refresh textbox
   
   local editbox = AceGUI:Create("MultiLineEditBox")
   editbox:SetNumLines(10)
   local KPSdebugbuffervariable = "\n"
   for _,value in ipairs(KPSdebugbuffer) do 
        KPSdebugbuffervariable =  KPSdebugbuffervariable..value.."\n" 
   end
   editbox:SetText(KPSdebugbuffervariable)
   editbox:DisableButton(1)
   KPSdebugframe:AddChild(editbox)
end

-- Give this function a list_objec = {} and max amount of entries in that table
-- and it will remove them for you
function circular_list(list_object,list_max)

   if (#list_object > list_max)then
      while #list_object > list_max do 
         table.remove(list_object,1)
      end
   end
   
   return list_object
   
end

-- WoW Events are quite crazy, firing all over the place.
-- Give this function a the event and how many times per second
-- it is allowed to fire and it will return "IGNORE" if that event has gone haywire.
-- NOTE: global event_throttle_list will be needed for this function
-- NOTE 2: Should be called from the event itself
function event_throttle (event,localtime,seconds_threshold)

	-- Register the event
	--if 	run_counter[event] then
	--run_counter[times_run]++
	--run_counter[event] = { localtime = localtime, times_run = 0 }

end
