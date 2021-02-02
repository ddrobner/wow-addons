-- Fake Item Links by Vildiesel EU-Well of Eternity

local _, addonTable = ...

local locale = GetLocale()
addonTable.L = setmetatable({}, { __index = function(_, k)
                                             return k
                                            end})
local L = addonTable.L

if locale == "esES" then 
L["Affixes"] = "Afijos"
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
L["Dungeon"] = "Mazmorra"
L["Itemlevel"] = "Nivel de Equipo"
L["Keystone"] = "Piedra Angular"
L["or drag an Item here"] = "o arrastra un Objeto aquí"
L["Properties"] = "Propiedades"
L["Quality"] = "Calidad"
--[[Translation missing --]]
--[[ L["Stats"] = ""--]] 
--[[Translation missing --]]
--[[ L["Type an ItemID, link an Item"] = ""--]] 

elseif locale == "esMX" then 
--[[Translation missing --]]
--[[ L["Affixes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dungeon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keystone"] = ""--]] 
--[[Translation missing --]]
--[[ L["or drag an Item here"] = ""--]] 
--[[Translation missing --]]
--[[ L["Properties"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quality"] = ""--]] 
--[[Translation missing --]]
--[[ L["Stats"] = ""--]] 
--[[Translation missing --]]
--[[ L["Type an ItemID, link an Item"] = ""--]] 

elseif locale == "itIT" then 
--[[Translation missing --]]
--[[ L["Affixes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
L["Dungeon"] = "Spedizione"
L["Itemlevel"] = "Liv. oggetto"
--[[Translation missing --]]
--[[ L["Keystone"] = ""--]] 
L["or drag an Item here"] = "o trascina un oggetto qui"
L["Properties"] = "Proprietà"
L["Quality"] = "Qualità"
L["Stats"] = "Stat"
L["Type an ItemID, link an Item"] = "Digita un ItemID, linka un oggetto"

elseif locale == "ptBR" then 
--[[Translation missing --]]
--[[ L["Affixes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dungeon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keystone"] = ""--]] 
--[[Translation missing --]]
--[[ L["or drag an Item here"] = ""--]] 
--[[Translation missing --]]
--[[ L["Properties"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quality"] = ""--]] 
--[[Translation missing --]]
--[[ L["Stats"] = ""--]] 
--[[Translation missing --]]
--[[ L["Type an ItemID, link an Item"] = ""--]] 

elseif locale == "frFR" then
--[[Translation missing --]]
--[[ L["Affixes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dungeon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keystone"] = ""--]] 
--[[Translation missing --]]
--[[ L["or drag an Item here"] = ""--]] 
--[[Translation missing --]]
--[[ L["Properties"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quality"] = ""--]] 
--[[Translation missing --]]
--[[ L["Stats"] = ""--]] 
--[[Translation missing --]]
--[[ L["Type an ItemID, link an Item"] = ""--]] 

elseif locale == "deDE" then 
L["Affixes"] = "Zusätze"
L["Chat Link"] = "Chatlink"
L["Dungeon"] = "Dungeon"
L["Itemlevel"] = "Gegenstandsstufe"
L["Keystone"] = "Schlüsselstein"
L["or drag an Item here"] = "Oder ziehe einen Gegenstand hierher"
L["Properties"] = "Eigenschaften"
L["Quality"] = "Qualität"
L["Stats"] = "Werte"
L["Type an ItemID, link an Item"] = "Gib eine Gegenstands-ID ein, verlinke einen Gegenstand"

elseif locale == "ruRU" then 
--[[Translation missing --]]
--[[ L["Affixes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dungeon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keystone"] = ""--]] 
--[[Translation missing --]]
--[[ L["or drag an Item here"] = ""--]] 
--[[Translation missing --]]
--[[ L["Properties"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quality"] = ""--]] 
--[[Translation missing --]]
--[[ L["Stats"] = ""--]] 
--[[Translation missing --]]
--[[ L["Type an ItemID, link an Item"] = ""--]] 

elseif locale == "zhCN" then 
L["Affixes"] = "后缀"
L["Chat Link"] = "聊天链接"
L["Dungeon"] = "地下城"
L["Itemlevel"] = "物品等级"
L["Keystone"] = "钥石"
L["or drag an Item here"] = "或拖动物品到此处"
L["Properties"] = "属性"
L["Quality"] = "质量"
L["Stats"] = "数据"
L["Type an ItemID, link an Item"] = "输入物品 ID，链接物品"

elseif locale == "zhTW" then 
--[[Translation missing --]]
--[[ L["Affixes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dungeon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keystone"] = ""--]] 
--[[Translation missing --]]
--[[ L["or drag an Item here"] = ""--]] 
--[[Translation missing --]]
--[[ L["Properties"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quality"] = ""--]] 
--[[Translation missing --]]
--[[ L["Stats"] = ""--]] 
--[[Translation missing --]]
--[[ L["Type an ItemID, link an Item"] = ""--]] 

elseif locale == "koKR" then
--[[Translation missing --]]
--[[ L["Affixes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chat Link"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dungeon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keystone"] = ""--]] 
--[[Translation missing --]]
--[[ L["or drag an Item here"] = ""--]] 
--[[Translation missing --]]
--[[ L["Properties"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quality"] = ""--]] 
--[[Translation missing --]]
--[[ L["Stats"] = ""--]] 
--[[Translation missing --]]
--[[ L["Type an ItemID, link an Item"] = ""--]] 

end
