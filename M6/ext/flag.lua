local _, T = ...
local RW = assert(T.ActionBook:compatible("Rewire", 1,5), "Incompatible ActionBook/Rewire")
local KR = assert(T.ActionBook:compatible("Kindred", 1,9), "Incompatible ActionBook/Kindred")

local core, cenv = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")
core:SetFrameRef("KR", KR:seclib())
core:Execute("flags, cargcache, KR = newtable(), newtable(), self:GetFrameRef('KR')")
cenv = GetManagedEnvironment(core)
core:SetAttribute("RunSlashCmd", [=[-- M6:flag-RunSlashCmd
	local slash, clause, target = ...
	if (clause or "") == "" then
	elseif slash == "/setflag" then
		local name, eq, v = clause:match("^%s*([^=<%s]+)%s*(=?)%s*(.-)%s*$")
		if not name then
			return
		end
		name, v = name:lower(), eq == "" or (v ~= "" and v:lower()) or nil
		if flags[name] ~= v then
			flags[name] = v
			KR:RunAttribute("PokeConditional", "flag")
		end
	elseif slash == "/cycleflag" then
		local name, eq, top, step = clause:match("^%s*([^=<%s]+)%s*(=?)%s*(%d*)%+?(%-?%d*)%s*$")
		if name and (top == "") == (eq == "")then
			name, top, step = name:lower(), top ~= "" and 0+top or 2, step ~= "" and 0+step or 1
			local nv = ((tonumber(flags[name]) or 0) + step) % top
			flags[name] = nv > 0 and nv .. "" or nil
			KR:RunAttribute("PokeConditional", "flag")
		end
	elseif slash == "/randflag" then
		local name, top = clause:match("^%s*([^=<%s]+)%s*<%s*(%d*)%s*$")
		if name then
			name, top = name:lower(), top ~= "" and 0+top or 2
			local nv = top > 1 and math.random(top)-1 or 0
			flags[name] = nv > 0 and nv .. "" or nil
			KR:RunAttribute("PokeConditional", "flag")
		end
	end
]=])
core:SetAttribute("EvaluateMacroConditional", [=[-- M6:flag-EvaluateMacroConditional
	local name, cv, target, b = ...
	if name ~= "flag" or not cv then return end
	local ca, ni = cargcache[cv]
	if not ca then
		ca, ni = newtable(), 1
		for s in cv:gmatch("[^/]*") do
			local name, eq, v = s:match("^%s*([^=%s]+)%s*(=?)%s*(.-)%s*$")
			if name then
				name, v = name:lower(), v:lower()
				if eq == "=" then
					ca[ni], ca[ni+1], ni = name, v, ni + 2
				else
					ca[ni], ca[ni+1], ni = name, false, ni + 2
				end
			end
		end
		cargcache[cv] = ca
	end
	for i=1,#ca, 2 do
		local cv, dv = flags[ca[i]], ca[i+1]
		if cv == dv or (dv == false and cv) then
			return true
		end
	end
	return false
]=])

RW:RegisterCommand("/setflag", true, true, core)
RW:RegisterCommand("/cycleflag", true, true, core)
RW:RegisterCommand("/randflag", true, true, core)
local hint = loadstring(("local cargcache, flags, newtable = ... return function(...) %s end"):format(core:GetAttribute("EvaluateMacroConditional")))({}, cenv.flags, function() return {} end)
KR:SetSecureExternalConditional("flag", core, hint)