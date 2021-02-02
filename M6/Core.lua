local api, conf, addonName, T = {}, nil, ...

local function writeArray(t, n, i, a, ...)
	if n > 0 then
		t[i] = a
		return writeArray(t, n-1, i+1, ...)
	end
end
local function nextAction(_, okey)
	local k, v = next(conf.actions, okey)
	return k, v and v.name or nil
end
local function nextGroup(_, okey)
	local k, v = next(conf.groups, okey)
	if type(k) == "number" then
		return k,v
	elseif k then
		return nextGroup(_, k)
	end
end
local safequote do
	local r = {u="\\117", ["{"]="\\123", ["}"]="\\125"}
	function safequote(s)
		return s and (("%q"):format(s):gsub("[{u}]", r)) or 'nil'
	end
end
local GetSpecialization = GetSpecialization or function() return 1 end

local EV, AB, RW, KR = T.Evie do
	-- NB: Skip's version checks need to stay as recent as these
	AB = T.ActionBook:compatible(2,18)
	RW = T.ActionBook:compatible("Rewire", 1, 5)
	KR = T.ActionBook:compatible("Kindred", 1, 11)
	assert(AB and RW and KR, "ActionBook is missing or incompatible")
	api.ext = setmetatable({}, {__index={ActionBook=T.ActionBook}})
end

local core = CreateFrame("Button", "M6Prime", nil, "SecureActionButtonTemplate,SecureHandlerBaseTemplate")
core:SetFrameRef("RW", RW:seclib())
core:Execute([=[--
	RW, macros, named, bound = self:GetFrameRef("RW"), newtable(), newtable(), newtable()
]=])
core:SetAttribute("type", "macro")
core:WrapScript(core, "OnClick", [=[--
	self:SetAttribute("macrotext", RW:RunAttribute("RunMacro", macros[button] or bound[button], true))
]=])
local coreEnv = GetManagedEnvironment(core)

local activeActionIDs, activeChar, activeSet, switchSet, newMacro, syncSet = {} do
	local satBindingButtons = {}
	local pending = false
	local function pushMacro(key, text)
		core:Execute(("macros[%s] = %s"):format(safequote(key), text and safequote(text) or "nil"))
		if text then
			local mk = "_M6+" .. key
			if not GetMacroInfo(mk) then
				CreateMacro(mk, "Temp", "#temp", not not GetMacroInfo(120))
			end
			EditMacro(mk, mk, M6:GetKeyIcon(key), ("#showtooltip\n#m6\n/click %s %s"):format(core:GetName(), key))
		end
	end
	local escapeBindConditionalChars = {[';']='SEMICOLON', ['[']='OPEN', [']']='CLOSE'}
	local function pushActiveSet()
		wipe(activeActionIDs)
		for sid, aid in pairs(activeSet.slots) do
			activeActionIDs[aid] = sid
		end
		if InCombatLockdown() then
			pending = pending or EV.RegisterEvent("PLAYER_REGEN_ENABLED", pushActiveSet) or true
			return
		end
		pending = false
		for k in rtable.pairs(coreEnv.bound) do
			KR:UnregisterBindingDriver(core, k)
		end
		core:Execute([=[wipe(macros) wipe(bound)]=])
		for k,v in pairs(activeSet.slots) do
			local ac = conf.actions[v]
			if ac and ac[1] == "macrotext" then
				pushMacro(k, ac[2])
			end
		end
		local bindSet = activeSet.bind
		for k,ac in pairs(conf.actions) do
			local bind = bindSet[k] == nil and ac.globalBind or bindSet[k]
			if bind and ac and ac[1] == "macrotext" then
				local bkey = 'b' .. k
				if not bind:match("%[.*%]") then
					bind = bind:gsub('[^-]+$', escapeBindConditionalChars)
				end
				core:Execute(('bound[%s] = %s'):format(safequote(bkey), safequote(ac[2])))
				local bb = satBindingButtons[bkey]
				if not bb then
					bb = CreateFrame("Button", "M6Bind!" .. bkey, nil, "SecureActionButtonTemplate")
					bb:SetAttribute("type", "click")
					bb:SetAttribute("clickbutton", core)
					satBindingButtons[bkey] = bb
				end
				bb:RegisterForClicks(GetCVarBool("ActionButtonUseKeyDown") and "AnyDown" or "AnyUp")
				KR:RegisterBindingDriver(bb, bkey, bind .. ";", -20)
			end
		end
		return "remove"
	end
	function newMacro(action)
		local id = 1
		while activeSet.slots[("s%02x"):format(id)] do
			id = id + 1
		end
		local k = ("s%02x"):format(id)
		activeSet.slots[k], activeActionIDs[action] = action, k;
		(InCombatLockdown() and pushActiveSet or pushMacro)(k, conf.actions[action][2])
		return "_M6+" .. k, k
	end
	function switchSet(id)
		id = id or 1
		activeSet = type(activeChar[id]) == "table" and activeChar[id] or {}
		activeChar[id] = activeSet
		if type(activeSet.slots) ~= "table" then
			activeSet.slots = {}
		end
		if type(activeSet.bind) ~= "table" then
			activeSet.bind = {}
		end
		if IsLoggedIn() then
			pushActiveSet()
		else
			EV.PLAYER_LOGIN = pushActiveSet
		end
	end
	function EV:PLAYER_SPECIALIZATION_CHANGED()
		switchSet(GetSpecialization())
	end
	-- 8.0: PSC doesn't fire on login, but specializations aren't available at load time
	function EV:PLAYER_LOGIN()
		switchSet(GetSpecialization())
	end
	syncSet = pushActiveSet
end

local namedSet, pushName = {} do
	local queue = {}
	local function procQueue()
		for k,v in pairs(queue) do
			core:Execute(v)
			queue[k] = nil
		end
		return "remove"
	end
	local function hintFunc(n, _, ...)
		local mt = coreEnv.named[n]
		if mt then
			return RW:GetMacroAction(mt, ...)
		end
	end
	function core:NamedHandlerAck(name)
		RW:SetNamedMacroHandler(name, core, hintFunc)
	end
	core:SetAttribute("RunNamedMacro", [[-- M6:RunNamedMacro
		local mt = named[...]
		return mt and RW:RunAttribute("RunMacro", mt) or nil
	]])
	function pushName(name, macro, id)
		local set = ([[--
			local name, macro = %s, %s
			named[name] = macro
			RW:SetAttribute("frameref-SetNamedMacroHandler-handlerFrame", macro and self or nil)
			RW:RunAttribute("SetNamedMacroHandler", name)
			if macro then
				self:CallMethod("NamedHandlerAck", name)
			end
		]]):format(safequote(name), macro and safequote(macro) or 'nil')
		namedSet[name] = macro and id or nil
		if InCombatLockdown() then
			if not next(queue) then
				EV.PLAYER_REGEN_ENABLED = procQueue
			end
			queue[name] = set
		else
			core:Execute(set)
		end
	end
end

function EV:ADDON_LOADED(addon)
	if addon ~= addonName then return end
	
	conf = type(M6DB) == "table" and M6DB or {}
	for k in ("actions profiles groups"):gmatch("%S+") do
		if type(conf[k]) ~= "table" then
			conf[k] = {}
		end
	end
	conf.icRangeColor = type(conf.icRangeColor) == "string" and conf.icRangeColor:match("^%x%x%x%x%x%x$") or "ffffff"
	conf.icManaColor = type(conf.icManaColor) == "string" and conf.icManaColor:match("^%x%x%x%x%x%x$") or "8080ff"
	
	local realm, name, spec = GetRealmName(), UnitName("player"), GetSpecialization()
	local rt = type(conf.profiles[realm]) == "table" and conf.profiles[realm] or {}
	M6DB, activeChar = conf, type(rt[name]) == "table" and rt[name] or {}
	conf.profiles[realm], rt[name] = rt, activeChar
	switchSet(spec)
	for k,v in pairs(conf.actions) do
		if v[1] == "macrotext" and v[2] and v.name then
			pushName(v.name, v[2], k)
		end
	end
	
	EV("M6_READY", conf)
	
	return "remove"
end
function EV:PLAYER_LOGOUT()
	for _,v in pairs(conf.profiles) do
		if v.slots and not next(v.slots) then
			v.slots = nil
		end
		if v.bind and not next(v.bind) then
			v.bind = nil
		end
		if not next(v) then
			conf.profiles[v] = nil
		end
	end
end

local function handleGroupEntryRemoval(gid)
	for _,v in pairs(conf.actions) do
		if v.group == gid then
			return
		end
	end
	local gn = conf.groups[gid]
	conf.groups[gid] = nil
	if gn and conf.groups[gn] == gid then
		conf.groups[gn] = nil
	end
end
local function swapHintIcon(ico, u, s, _ico, ...)
	return u, s, ico, ...
end

function api:NewAction(...)
	local k = #conf.actions + 1
	conf.actions[k] = {...}
	return k
end
function api:PickupAction(id)
	if conf.actions[id] then
		for k,v in pairs(activeSet.slots) do
			if v == id then
				PickupMacro("_M6+" .. k, k)
				return
			end
		end
		PickupMacro(newMacro(id))
	end
end
function api:GetAction(id)
	return unpack(conf.actions[id])
end
function api:SetAction(id, ...)
	local at, ac = conf.actions[id], select("#", ...)
	if ac > 4 then
		writeArray(conf.actions[id], ac, 1, ...)
	else
		at[1], at[2], at[3], at[4] = ...
	end
	syncSet()
	local name = conf.actions[id].name
	if name then
		pushName(name, conf.actions[id][2], id)
	end
end
function api:GetActionName(id)
	return conf.actions[id].name
end
function api:SetActionName(id, name)
	name = type(name) == "string" and name:match("^%s*%S.-%s*$") or nil
	local oid, su, base = namedSet[name], 1, name
	while oid and oid ~= id do
		name, su = base .. "-" .. su, su + 1
		oid = namedSet[name]
	end
	conf.actions[id].name = name
	if name then
		pushName(name, conf.actions[id][2], id)
	end
	return base == name
end
function api:SetActionBind(id, bind, forAll)
	local globBind, changed = conf.actions[id].globalBind, false
	bind = type(bind) == "string" and bind ~= "" and bind or nil
	if bind == globBind then
		if not forAll then
			changed, conf.actions[id].globalBind = 1, nil
		else
			bind = nil
		end
	elseif forAll then
		conf.actions[id].globalBind, changed, bind = bind or nil, 1
	end
	
	if bind then
		for k,v in pairs(activeSet.bind) do
			if v == bind then
				changed, activeSet.bind[k] = 1
			end
		end
	end
	
	if activeSet.bind[id] ~= bind then
		activeSet.bind[id], changed = bind, 1
	end
	if changed then
		syncSet()
	end
end
function api:GetActionBind(id)
	local lbind = activeSet.bind[id]
	local gbind = conf.actions[id]
	gbind = gbind and conf.actions[id].globalBind
	return lbind == nil and gbind or lbind, lbind ~= nil, gbind
end
function api:SetActionIcon(id, ico)
	conf.actions[id].icon = (type(ico) == "string" or type(ico) == "number") and ico or nil
end
function api:GetActionIcon(id)
	return conf.actions[id].icon
end
function api:SetActionGroup(id, group)
	group = type(group) == "string" and group:match("(%S.-)%s*$") or nil
	local gid, ogid = conf.groups[group], conf.actions[id].group
	if group and not gid then
		gid = #conf.groups+1
		conf.groups[gid], conf.groups[group] = group, gid
	end
	conf.actions[id].group = gid
	if ogid and ogid ~= gid then
		handleGroupEntryRemoval(ogid)
	end
end
function api:GetActionGroup(id)
	local gid = conf.actions[id].group
	return conf.groups[gid], gid
end
function api:IsActionActivated(id)
	return activeActionIDs[id] ~= nil
end
function api:DeactivateAction(id)
	for k,v in pairs(activeSet.slots) do
		if v == id then
			activeSet.slots[k] = nil
			syncSet()
			return
		end
	end
end
function api:DeleteAction(id)
	local ogid = conf.actions[id] and conf.actions[id].group
	conf.actions[id] = nil
	for _,v in pairs(conf.profiles) do
		for _,t in pairs(v) do
			local slots = t.slots
			if slots then
				for s,a in pairs(slots) do
					if a == id then
						slots[s] = nil
					end
				end
			end
			if t.bind then
				t.bind[id] = nil
			end
		end
	end
	if ogid then
		handleGroupEntryRemoval(ogid)
	end
	syncSet()
end
function api:AllActions()
	return nextAction
end
function api:AllGroups()
	return nextGroup
end
function api:GetHint(key)
	local macro = coreEnv.macros[key]
	if macro then
		local ico = conf.actions[activeSet.slots[key]]
		ico = ico and ico.icon
		if ico then
			return swapHintIcon(ico, RW:GetMacroAction(macro))
		end
		return RW:GetMacroAction(macro)
	end
end

local keyIconCache, iconKeyCache = {}, {} do
	local base = 2^30 + 42e4
	for i=0,255 do
		local iid, key = base + i, ("s%02x"):format(i)
		iconKeyCache[iid], keyIconCache[key] = key, iid
	end
end
function api:GetIconKey(icon)
	return iconKeyCache[icon]
end
function api:GetKeyIcon(key)
	return keyIconCache[key]
end

_G.M6 = api