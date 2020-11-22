--[[
    Copyright (C) 2006-2007 Nymbia
    Copyright (C) 2010 Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local KPS = LibStub("AceAddon-3.0"):GetAddon("Profiles: Keyboard binds")

----------------------------

local getOpt, setOpt
do
   function getOpt(info)
      local key = info[#info]
      local boolean_conversion = false
      
      -- Ugly hack because lua sees false and 0 different from perl
      if KPSdb.char[key] == 0 then
         boolean_conversion = false
      elseif KPSdb.char[key] == 1 then
         boolean_conversion = true
      else
         boolean_conversion = KPSdb.char[key]
      end
      
      return boolean_conversion
   end
   
   function setOpt(info, value)
      local key = info[#info]
      local boolean_conversion = false
      
      -- Ugly hack because lua sees false and 0 different from perl
      if value == false then
         boolean_conversion = 0
      elseif value == true then
         boolean_conversion = 1
      else
         boolean_conversion = value
      end
      
      KPSdb.char[key] = boolean_conversion
      return boolean_conversion
   end
end

local options, moduleOptions = nil, {}
local function getOptions()
   if not options then
      options = {
         type = "group",
         args = {
            general = {
               type = "group",
               inline = true,
               name = "",
               args = {
                  
                  KLSaddonEnabled = {
                     type = "toggle",
                     name = "Enable",
                     desc = "Enable or disable Profiles: Keyboard binds",
                     order = 101,
                     width = "full",
                     get = getOpt,
                     set = function (info) 
                        if KPSdb.char.KLSaddonEnabled == 0 then 
                           KPSdb.char.KLSaddonEnabled = 1
                           KPS:Enable()
                        else
                           KPSdb.char.KLSaddonEnabled = 0
                           KPS:Disable()
                        end
                     end,
                  },
				  KPSLoadProfileAtStart = {
                     type = "toggle",
                     name = "Load profile at start",
                     desc = "",
                     order = 102,
                     width = "full",
                     get = getOpt,
                     set = function (info,value) 
                        local dbg = setOpt(info, value)
                     end,
                  },
					
                  KLSdebugEnabled = {
                     type = "toggle",
                     name = "Show debug window",
                     desc = "Show the debug window. Copy and paste the output into a Curseforge.com ticket.",
                     order = 103,
                     width = "full",
                     get = getOpt,
                     set = function (info,value) 
                        local dbg = setOpt(info, value)
                        KPS:DebugWindowToggle(dbg) 
                     end,
                  },
                  editProfile = {
                     type = "select",
                     name = "Profiles",
                     desc = "Edit profiles",
                     values = function (info) 
                        local t = {}
                        local pName = UnitName("player")
                        for v,k in ipairs(KPSdb:GetProfiles()) do 
                            if not string.find(k,pName) then
                                t[k] = k 
                            end 
                        end
                            return t 
                        end,
                     style = "dropdown",
                     get = function (info) return KPSdb:GetCurrentProfile() end,
                     set = function (info,value) KPS:LoadProfil(value) end,
                     order = 210,
                  },
                  
                  nllock = {
                     type = "description",
                     name = "",
                     order = 212,
                  },
                  unlock = {
                     type = "execute",
                     name = "Reset profile",
                     desc = "Reset the selected profile.",
                     func = function(info, value)
                        KPS:DeleteProfil(KPSdb:GetCurrentProfile())
                     end,
                     order = 213,
                  },
                  
                  soon = {
                     type = "group",
                     name = "",
                     desc = "The stuff you see here is on my todo list. It will be implemented soon(tm).",
                     guiInline = true,
                     order = 450,              
                     get = getOpt,
                     set = setOpt,
                     args = {
--~                          renameProfile  = {
--~                              type = "input",
--~                              name = "Rename profile",
--~                              desc = "Rename the selected profile| NOTE: This option will be comming soon",
--~                              disabled = true,
--~                              get = function (info) return end,
--~                              set = function (info,value) print(value) end,
--~                              order = 211,
--~                           },
                        KPS_trigger = {
                           type = "select",
                           name = "Profile trigger",
                           desc = "Trigger that switches profiles",
                           values = {  
									  ["KPS: Outfitter"]="Outfitter", 
									  ["KPS: Equipment manager"]="Equipment manager",
									  ["KPS: Manual Profiles"]="Manual Profiles"},
                           style = "dropdown",
                           get = function (info,value) return KPSdb.char.KLStriggerModule end,
                           set = function (info,value) return KPS:ModuleToggle(value) end,
                           order = 98,
                        },
                     },
                  },
               },
            },
         },
      }
      for k,v in pairs(moduleOptions) do
         options.args[k] = (type(v) == "function") and v() or v
      end
   end
   return options
end


function KPS:SetupOptions()
   self.optFrames = {}
   LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Profiles: Keyboard binds", getOptions)
   self.optFrames.KPS = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Profiles: Keyboard binds", "Profiles: Keyboard binds", nil, "general")
   --self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), "Profiles")
end

function KPS:RegisterModuleOptions(name, optTable, displayName)
   moduleOptions[name] = optTable
   self.optFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Profiles: Keyboard binds", displayName or name, "Profiles: Keyboard binds", name)
end
