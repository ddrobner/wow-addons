if not WeakAuras.IsCorrectVersion() then return end

if not(GetLocale() == "zhCN") then
  return
end

local L = WeakAuras.L

-- WeakAuras/Templates
	--[[Translation missing --]]
	L[" Debuff"] = " Debuff"
	L["<70% Mana"] = "<70%法力值"
	L[">70% Mana"] = ">70%法力值"
	L["Abilities"] = "技能"
	--[[Translation missing --]]
	L["Ability"] = "Ability"
	L["Add Triggers"] = "添加触发器"
	L["Always Active"] = "总是激活"
	L["Always Show"] = "总是显示"
	L["Always show the aura, highlight it if debuffed."] = "总是显示光环，存在减益时高亮。"
	L["Always show the aura, turns grey if on cooldown."] = "总是显示光环，冷却中时变灰。"
	L["Always show the aura, turns grey if the debuff not active."] = "总是显示光环，无减益时变灰。"
	L["Always shows highlights if enchant missing."] = "如果附魔缺失，总是显示发光"
	L["Always shows the aura, grey if buff not active."] = "总是显示光环，无增益时变灰。"
	L["Always shows the aura, highlight it if buffed."] = "总是显示光环，有增益时高亮。"
	L["Always shows the aura, highlight when active, turns blue on insufficient resources."] = "总是显示光环，激活时高亮，资源不足时变蓝。"
	L["Always shows the aura, highlight while proc is active, blue on insufficient resources."] = "总是显示光环，激活时高亮，资源不足时变蓝。"
	L["Always shows the aura, highlight while proc is active, blue when not usable."] = "总是显示光环，激活时高亮，不可用时变蓝。"
	L["Always shows the aura, highlight while proc is active, turns red when out of range, blue on insufficient resources."] = "总是显示光环，激活时高亮，超出距离时变红，资源不足时变蓝。"
	L["Always shows the aura, turns blue on insufficient resources."] = "总是显示光环，资源不足时变蓝。"
	L["Always shows the aura, turns blue when not usable."] = "总是显示光环，不可用时变蓝。"
	L["Always shows the aura, turns grey if on cooldown."] = "总是显示光环，冷却中时变灰。"
	L["Always shows the aura, turns grey if the ability is not usable and red when out of range."] = "总是显示光环，不可用时变灰，超出距离时变红。"
	L["Always shows the aura, turns grey if the ability is not usable."] = "总是显示光环，不可用时变灰。"
	L["Always shows the aura, turns red when out of range, blue on insufficient resources."] = "总是显示光环，超出距离时变红，资源不足时变蓝。"
	L["Always shows the aura, turns red when out of range."] = "总是显示光环，超出距离时变红。"
	L["Back"] = "返回"
	L["Basic Show On Cooldown"] = "仅在冷却中显示"
	L["Basic Show On Ready"] = "仅在可用时显示"
	L["Bloodlust/Heroism"] = "嗜血/英勇"
	--[[Translation missing --]]
	L["Bonded Buff"] = "Bonded Buff"
	--[[Translation missing --]]
	L["Buff"] = "Buff"
	L["buff"] = "增益效果"
	L["Buff on Other"] = "其他单位的增益效果"
	L["Buffs"] = "增益"
	--[[Translation missing --]]
	L["Build Up"] = "Build Up"
	L["Cancel"] = "取消"
	L["Cast"] = "施放"
	L["Charge and Buff Tracking"] = "可用次数充能和增益效果追踪"
	L["Charge and Debuff Tracking"] = "可用次数充能和减益效果追踪"
	L["Charge and Duration Tracking"] = "充能和持续时间追踪"
	L["Charge Tracking"] = "可用次数充能追踪"
	--[[Translation missing --]]
	L["Combustion Ready"] = "Combustion Ready"
	--[[Translation missing --]]
	L["Conduits"] = "Conduits"
	--[[Translation missing --]]
	L["Cooldown"] = "Cooldown"
	L["cooldown"] = "冷却"
	L["Cooldown Tracking"] = "冷却追踪"
	L["Create Auras"] = "创建光环"
	--[[Translation missing --]]
	L["Debuff"] = "Debuff"
	L["debuff"] = "减益效果"
	L["Debuffs"] = "减益"
	--[[Translation missing --]]
	L["Empowered Buff"] = "Empowered Buff"
	--[[Translation missing --]]
	L["Fire"] = "Fire"
	--[[Translation missing --]]
	L["Frost"] = "Frost"
	L["General"] = "一般"
	L["Health"] = "生命值"
	L["Highlight while active, red when out of range."] = "激活时高亮，超出距离是变红"
	L["Highlight while active."] = "激活时高亮"
	L["Highlight while buffed, red when out of range."] = "获得增益效果时高亮，超出范围变红显示"
	L["Highlight while buffed."] = "获得增益效果时高亮"
	L["Highlight while debuffed, red when out of range."] = "获得减益效果时高亮，超出范围变红显示"
	L["Highlight while debuffed."] = "获得减益效果时高亮"
	L["Highlight while spell is active."] = "当法术激活时高亮"
	L["Hold CTRL to create multiple auras at once"] = "按住 CTRL 键来一次性创建多个光环"
	L["Keeps existing triggers intact"] = "保持现存触发器完整"
	--[[Translation missing --]]
	L["Legendaries"] = "Legendaries"
	--[[Translation missing --]]
	L["Meteor Ready"] = "Meteor Ready"
	--[[Translation missing --]]
	L["Nature"] = "Nature"
	L["Next"] = "下一个"
	L["Only show the aura if the target has the debuff."] = "只有在目标拥有减益效果时才显示此光环"
	L["Only show the aura when the item is on cooldown."] = "只有当物品在冷却中时才显示此光环"
	L["Only shows if the weapon is enchanted."] = "只有当武器被附魔时才显示"
	L["Only shows if the weapon is not enchanted."] = "只有当武器没有被附魔时才显示"
	L["Only shows the aura if the target has the buff."] = "只有当目标拥有增益效果是才显示此光环"
	L["Only shows the aura when the ability is on cooldown."] = "只有当技能在冷却中时才显示此光环"
	L["Only shows the aura when the ability is ready to use."] = "只有当技能可用时才显示此光环"
	L["Pet alive"] = "宠物存活"
	L["Pet Behavior"] = "宠物行为"
	L["PvP Talents"] = "PvP 天赋"
	L["Replace all existing triggers"] = "替换所有现存的触发器"
	L["Replace Triggers"] = "替换触发器"
	L["Resources"] = "资源"
	L["Resources and Shapeshift Form"] = "资源和变形形态"
	L["Runes"] = "符文编号"
	L["Shapeshift Form"] = "变形形态"
	L["Show Always, Glow on Missing"] = "总是显示，缺失时发光"
	L["Show Charges and Check Usable"] = "显示可用次数充能并检查可用性"
	L["Show Charges with Proc Tracking"] = "显示可用次数充能和触发追踪"
	L["Show Charges with Range Tracking"] = "显示可用次数充能和距离追踪"
	L["Show Charges with Usable Check"] = "显示可用次数充能和可用性检测结果"
	L["Show Cooldown and Buff"] = "显示冷却和增益效果"
	L["Show Cooldown and Buff and Check for Target"] = "显示冷却和增益效果并检查是否有选中的目标"
	L["Show Cooldown and Buff and Check Usable"] = "显示冷却和增益效果并检查可用性"
	L["Show Cooldown and Check for Target"] = "显示冷却并检查是否有选中的目标"
	L["Show Cooldown and Check for Target & Proc Tracking"] = "显示冷却并检查是否有选中的目标并追踪触发"
	L["Show Cooldown and Check Usable"] = "显示冷却并检查可用性"
	L["Show Cooldown and Check Usable & Target"] = "显示冷却并检查可用性和是否有选中的目标"
	L["Show Cooldown and Check Usable, Proc Tracking"] = "显示冷却并检查可用性和追踪触发"
	L["Show Cooldown and Check Usable, Target & Proc Tracking"] = "显示冷却并检查可用性，是否有选中的目标和追踪触发"
	L["Show Cooldown and Debuff"] = "显示冷却和减益效果"
	L["Show Cooldown and Debuff and Check for Target"] = "显示冷却和减益效果并检查是否有选中的目标"
	L["Show Cooldown and Duration"] = "显示冷却和持续时间"
	L["Show Cooldown and Duration and Check for Target"] = "显示冷却和持续时间并检查是否有选中的目标"
	L["Show Cooldown and Duration and Check Usable"] = "显示冷却和持续时间并检查可用性"
	L["Show Cooldown and Proc Tracking"] = "显示冷却并追踪触发"
	L["Show Cooldown and Totem Information"] = "显示冷却和图腾信息"
	L["Show if Enchant Missing"] = "当附魔缺失时显示"
	L["Show on Ready"] = "仅在可用时显示"
	L["Show Only if Buffed"] = "仅在获得增益效果时显示"
	L["Show Only if Debuffed"] = "仅在获得减益效果时显示"
	L["Show Only if Enchanted"] = "仅在已附魔时显示"
	L["Show Only if on Cooldown"] = "仅在冷却中显示"
	L["Show Totem and Charge Information"] = "显示图腾和可用次数充能信息"
	--[[Translation missing --]]
	L["Slow"] = "Slow"
	L["slow debuff"] = "减速"
	L["Stance"] = "姿态"
	L["stun debuff"] = "眩晕"
	--[[Translation missing --]]
	L["Stun Debuff"] = "Stun Debuff"
	--[[Translation missing --]]
	L["Totem"] = "Totem"
	L["Track the charge and proc, highlight while proc is active, turns red when out of range, blue on insufficient resources."] = "追踪可用次数充能和触发，当触发时高亮显示，超出距离时变红显示，资源不足时变蓝显示"
	L["Tracks the charge and the buff, highlight while the buff is active, blue on insufficient resources."] = "追踪可用次数和增益效果，当增益效果激活时高亮，当没有足够资源是变蓝显示"
	L["Tracks the charge and the debuff, highlight while the debuff is active, blue on insufficient resources."] = "追踪可用次数和减益效果，当减益效果激活时高亮，当没有足够资源是变蓝显示"
	L["Tracks the charge and the duration of spell, highlight while the spell is active, blue on insufficient resources."] = "追踪法术的充能和持续时间，当法术激活时高亮，没有足够的能量时变蓝。"
	L["Unknown Item"] = "未知物品"
	L["Unknown Spell"] = "未知法术"

