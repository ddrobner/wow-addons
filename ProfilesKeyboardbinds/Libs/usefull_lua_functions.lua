--[[ DataDumper.lua
Copyright (c) 2007 Olivetti-Engineering SA

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Example:
dump(Profiles_master_flag)
return {
	master_action = "save"
	master_profile_name = "testprofile"
	name="Keyboard binds"
},
---
]]

local dumplua_closure = [[
local closures = {}
local function closure(t) 
  closures[#closures+1] = t
  t[1] = assert(loadstring(t[1]))
  return t[1]
end

for _,t in pairs(closures) do
  for i = 2,#t do 
    debug.setupvalue(t[1], i-1, t[i]) 
  end 
end
]]

local lua_reserved_keywords = {
   'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 
   'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 
'return', 'then', 'true', 'until', 'while' }

local function keys(t)
   local res = {}
   local oktypes = { stringstring = true, numbernumber = true }
   local function cmpfct(a,b)
      if oktypes[type(a)..type(b)] then
         return a < b
      else
         return type(a) < type(b)
      end
   end
   for k in pairs(t) do
      res[#res+1] = k
   end
   table.sort(res, cmpfct)
   return res
end

local c_functions = {}
for _,lib in pairs{'_G', 'string', 'table', 'math', 
'io', 'os', 'coroutine', 'package', 'debug'} do
   local t = _G[lib] or {}
   lib = lib .. "."
   if lib == "_G." then lib = "" end
   for k,v in pairs(t) do
      if type(v) == 'function' and not pcall(string.dump, v) then
         c_functions[v] = lib..k
      end
   end
end

function DataDumper(value, varname, fastmode, ident)
   local defined, dumplua = {}
   -- Local variables for speed optimization
   local string_format, type, string_dump, string_rep = 
   string.format, type, string.dump, string.rep
   local tostring, pairs, table_concat = 
   tostring, pairs, table.concat
   local keycache, strvalcache, out, closure_cnt = {}, {}, {}, 0
   setmetatable(strvalcache, {__index = function(t,value)
            local res = string_format('%q', value)
            t[value] = res
            return res
   end})
   local fcts = {
      string = function(value) return strvalcache[value] end,
      number = function(value) return value end,
      boolean = function(value) return tostring(value) end,
      ['nil'] = function(value) return 'nil' end,
      ['function'] = function(value) 
         return string_format("loadstring(%q)", string_dump(value)) 
      end,
      userdata = function() error("Cannot dump userdata") end,
      thread = function() error("Cannot dump threads") end,
   }
   local function test_defined(value, path)
      if defined[value] then
         if path:match("^getmetatable.*%)$") then
            out[#out+1] = string_format("s%s, %s)\n", path:sub(2,-2), defined[value])
         else
            out[#out+1] = path .. " = " .. defined[value] .. "\n"
         end
         return true
      end
      defined[value] = path
   end
   local function make_key(t, key)
      local s
      if type(key) == 'string' and key:match('^[_%a][_%w]*$') then
         s = key .. "="
      else
         s = "[" .. dumplua(key, 0) .. "]="
      end
      t[key] = s
      return s
   end
   for _,k in ipairs(lua_reserved_keywords) do
      keycache[k] = '["'..k..'"] = '
   end
   if fastmode then 
      fcts.table = function (value)
         -- Table value
         local numidx = 1
         out[#out+1] = "{"
         for key,val in pairs(value) do
            if key == numidx then
               numidx = numidx + 1
            else
               out[#out+1] = keycache[key]
            end
            local str = dumplua(val)
            out[#out+1] = str..","
         end
         if string.sub(out[#out], -1) == "," then
            out[#out] = string.sub(out[#out], 1, -2);
         end
         out[#out+1] = "}"
         return "" 
      end
   else 
      fcts.table = function (value, ident, path)
         if test_defined(value, path) then return "nil" end
         -- Table value
         local sep, str, numidx, totallen = " ", {}, 1, 0
         local meta, metastr = (debug or getfenv()).getmetatable(value)
         if meta then
            ident = ident + 1
            metastr = dumplua(meta, ident, "getmetatable("..path..")")
            totallen = totallen + #metastr + 16
         end
         for _,key in pairs(keys(value)) do
            local val = value[key]
            local s = ""
            local subpath = path
            if key == numidx then
               subpath = subpath .. "[" .. numidx .. "]"
               numidx = numidx + 1
            else
               s = keycache[key]
               if not s:match "^%[" then subpath = subpath .. "." end
               subpath = subpath .. s:gsub("%s*=%s*$","")
            end
            s = s .. dumplua(val, ident+1, subpath)
            str[#str+1] = s
            totallen = totallen + #s + 2
         end
         if totallen > 80 then
            sep = "\n" .. string_rep("  ", ident+1)
         end
         str = "{"..sep..table_concat(str, ","..sep).." "..sep:sub(1,-3).."}" 
         if meta then
            sep = sep:sub(1,-3)
            return "setmetatable("..sep..str..","..sep..metastr..sep:sub(1,-3)..")"
         end
         return str
      end
      fcts['function'] = function (value, ident, path)
         if test_defined(value, path) then return "nil" end
         if c_functions[value] then
            return c_functions[value]
         elseif debug == nil or debug.getupvalue(value, 1) == nil then
            return string_format("loadstring(%q)", string_dump(value))
         end
         closure_cnt = closure_cnt + 1
         local res = {string.dump(value)}
         for i = 1,math.huge do
            local name, v = debug.getupvalue(value,i)
            if name == nil then break end
            res[i+1] = v
         end
         return "closure " .. dumplua(res, ident, "closures["..closure_cnt.."]")
      end
   end
   function dumplua(value, ident, path)
      return fcts[type(value)](value, ident, path)
   end
   if varname == nil then
      varname = "return "
   elseif varname:match("^[%a_][%w_]*$") then
      varname = varname .. " = "
   end
   if fastmode then
      setmetatable(keycache, {__index = make_key })
      out[1] = varname
      table.insert(out,dumplua(value, 0))
      return table.concat(out)
   else
      setmetatable(keycache, {__index = make_key })
      local items = {}
      for i=1,10 do items[i] = '' end
      items[3] = dumplua(value, ident or 0, "t")
      if closure_cnt > 0 then
         items[1], items[6] = dumplua_closure:match("(.*\n)\n(.*)")
         out[#out+1] = ""
      end
      if #out > 0 then
         items[2], items[4] = "local t = ", "\n"
         items[5] = table.concat(out)
         items[7] = varname .. "t"
      else
         items[2] = varname
      end
      return table.concat(items)
   end
end
function dump(...)
   print(DataDumper(...), "\n---")
end

--[[

http://lua-users.org/wiki/SortedIteration

Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:

t = {
   ['1'] = nil,
   ['2'] = nil,
   ['3'] = 'xxx',
   ['4'] = 'xxx',
   ['5'] = 'xxx',
}

print("Ordered iterating")
for key, val in orderedPairs(t) do
   print(key.." : "..val)
end

Output:
Ordered iterating
3: xxx
4: xxx
5: xxx
]]

function cmp_multitype(op1, op2)
    local type1, type2 = type(op1), type(op2)
    if type1 ~= type2 then --cmp by type
        return type1 < type2
    elseif type1 == "number" and type2 == "number"
        or type1 == "string" and type2 == "string" then
        return op1 < op2 --comp by default
    elseif type1 == "boolean" and type2 == "boolean" then
        return op1 == true
    else
        return tostring(op1) < tostring(op2) --cmp by address
    end
end

function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex, cmp_multitype ) --### CANGE ###
    
	return orderedIndex
end

function orderedNext(t, state)
   -- Equivalent of the next function, but returns the keys in the alphabetic
   -- order. We use a temporary ordered key table that is stored in the
   -- table being iterated.
   
   --print("orderedNext: state = "..tostring(state) )
   if state == nil then
      -- the first time, generate the index
      t.__orderedIndex = __genOrderedIndex( t )
      key = t.__orderedIndex[1]
      
	  if key ~= "__orderedIndex" then
		return key, t[key]
	  end
   end
   -- fetch the next value
   key = nil
   for i = 1,table.getn(t.__orderedIndex) do
      if t.__orderedIndex[i] == state then
         key = t.__orderedIndex[i+1]
      end
   end
   
   if key and key ~= "__orderedIndex "then
   
    
	return key, t[key]
	
   end
   
   -- no more value to return, cleanup
   t.__orderedIndex = nil
   return
end

function orderedPairs(t)
   -- Equivalent of the pairs() function on tables. Allows to iterate
   -- in order
   return orderedNext, t, nil
end


-- Copy Table
-- Usage: table_copy = copyTable(original_table)

function copyTable(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--Regexp routine
-- nocase("Hi there!")) >>> 
-- [hH][iI] [tT][hH][eE][rR][eE]!
function nocase (s)
   s = string.gsub(s, "%a", function (c)
         return string.format("[%s%s]", string.lower(c),
            string.upper(c))
   end)
   return s
end

inspect ={
  _VERSION = 'inspect.lua 3.0.0',
  _URL     = 'http://github.com/kikito/inspect.lua',
  _DESCRIPTION = 'human-readable representations of tables',
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique Garc�a Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

inspect.KEY       = setmetatable({}, {__tostring = function() return 'inspect.KEY' end})
inspect.METATABLE = setmetatable({}, {__tostring = function() return 'inspect.METATABLE' end})

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
  if str:match('"') and not str:match("'") then
    return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local controlCharsTranslation = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}

local function escapeChar(c) return controlCharsTranslation[c] end

local function escape(str)
  local result = str:gsub("\\", "\\\\"):gsub("(%c)", escapeChar)
  return result
end

local function isIdentifier(str)
  return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function isSequenceKey(k, length)
  return type(k) == 'number'
     and 1 <= k
     and k <= length
     and math.floor(k) == k
end

local defaultTypeOrders = {
  ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
  ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sortKeys(a, b)
  local ta, tb = type(a), type(b)

  -- strings and numbers are sorted numerically/alphabetically
  if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

  local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
  -- Two default types are compared according to the defaultTypeOrders table
  if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
  elseif dta     then return true  -- default types before custom ones
  elseif dtb     then return false -- custom types after default ones
  end

  -- custom types are sorted out alphabetically
  return ta < tb
end

local function getNonSequentialKeys(t)
  local keys, length = {}, #t
  for k,_ in pairs(t) do
    if not isSequenceKey(k, length) then table.insert(keys, k) end
  end
  table.sort(keys, sortKeys)
  return keys
end

local function getToStringResultSafely(t, mt)
  local __tostring = type(mt) == 'table' and rawget(mt, '__tostring')
  local str, ok
  if type(__tostring) == 'function' then
    ok, str = pcall(__tostring, t)
    str = ok and str or 'error: ' .. tostring(str)
  end
  if type(str) == 'string' and #str > 0 then return str end
end

local maxIdsMetaTable = {
  __index = function(self, typeName)
    rawset(self, typeName, 0)
    return 0
  end
}

local idsMetaTable = {
  __index = function (self, typeName)
    local col = setmetatable({}, {__mode = "kv"})
    rawset(self, typeName, col)
    return col
  end
}

local function countTableAppearances(t, tableAppearances)
  tableAppearances = tableAppearances or setmetatable({}, {__mode = "k"})

  if type(t) == 'table' then
    if not tableAppearances[t] then
      tableAppearances[t] = 1
      for k,v in pairs(t) do
        countTableAppearances(k, tableAppearances)
        countTableAppearances(v, tableAppearances)
      end
      countTableAppearances(getmetatable(t), tableAppearances)
    else
      tableAppearances[t] = tableAppearances[t] + 1
    end
  end

  return tableAppearances
end

local copySequence = function(s)
  local copy, len = {}, #s
  for i=1, len do copy[i] = s[i] end
  return copy, len
end

local function makePath(path, ...)
  local keys = {...}
  local newPath, len = copySequence(path)
  for i=1, #keys do
    newPath[len + i] = keys[i]
  end
  return newPath
end

local function processRecursive(process, item, path)
  if item == nil then return nil end

  local processed = process(item, path)
  if type(processed) == 'table' then
    local processedCopy = {}
    local processedKey

    for k,v in pairs(processed) do
      processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY))
      if processedKey ~= nil then
        processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey))
      end
    end

    local mt  = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE))
    setmetatable(processedCopy, mt)
    processed = processedCopy
  end
  return processed
end


-------------------------------------------------------------------

local Inspector = {}
local Inspector_mt = {__index = Inspector}

function Inspector:puts(...)
  local args   = {...}
  local buffer = self.buffer
  local len    = #buffer
  for i=1, #args do
    len = len + 1
    buffer[len] = tostring(args[i])
  end
end

function Inspector:down(f)
  self.level = self.level + 1
  f()
  self.level = self.level - 1
end

function Inspector:tabify()
  self:puts(self.newline, string.rep(self.indent, self.level))
end

function Inspector:alreadyVisited(v)
  return self.ids[type(v)][v] ~= nil
end

function Inspector:getId(v)
  local tv = type(v)
  local id = self.ids[tv][v]
  if not id then
    id              = self.maxIds[tv] + 1
    self.maxIds[tv] = id
    self.ids[tv][v] = id
  end
  return id
end

function Inspector:putKey(k)
  if isIdentifier(k) then return self:puts(k) end
  self:puts("[")
  self:putValue(k)
  self:puts("]")
end

function Inspector:putTable(t)
  if t == inspect.KEY or t == inspect.METATABLE then
    self:puts(tostring(t))
  elseif self:alreadyVisited(t) then
    self:puts('<table ', self:getId(t), '>')
  elseif self.level >= self.depth then
    self:puts('{...}')
  else
    if self.tableAppearances[t] > 1 then self:puts('<', self:getId(t), '>') end

    local nonSequentialKeys = getNonSequentialKeys(t)
    local length            = #t
    local mt                = getmetatable(t)
    local toStringResult    = getToStringResultSafely(t, mt)

    self:puts('{')
    self:down(function()
      if toStringResult then
        self:puts(' -- ', escape(toStringResult))
        if length >= 1 then self:tabify() end
      end

      local count = 0
      for i=1, length do
        if count > 0 then self:puts(',') end
        self:puts(' ')
        self:putValue(t[i])
        count = count + 1
      end

      for _,k in ipairs(nonSequentialKeys) do
        if count > 0 then self:puts(',') end
        self:tabify()
        self:putKey(k)
        self:puts(' = ')
        self:putValue(t[k])
        count = count + 1
      end

      if mt then
        if count > 0 then self:puts(',') end
        self:tabify()
        self:puts('<metatable> = ')
        self:putValue(mt)
      end
    end)

    if #nonSequentialKeys > 0 or mt then -- result is multi-lined. Justify closing }
      self:tabify()
    elseif length > 0 then -- array tables have one extra space before closing }
      self:puts(' ')
    end

    self:puts('}')
  end
end

function Inspector:putValue(v)
  local tv = type(v)

  if tv == 'string' then
    self:puts(smartQuote(escape(v)))
  elseif tv == 'number' or tv == 'boolean' or tv == 'nil' then
    self:puts(tostring(v))
  elseif tv == 'table' then
    self:putTable(v)
  else
    self:puts('<',tv,' ',self:getId(v),'>')
  end
end

-------------------------------------------------------------------

function inspect.inspect(root, options)
  options       = options or {}

  local depth   = options.depth   or math.huge
  local newline = options.newline or '\n'
  local indent  = options.indent  or '  '
  local process = options.process

  if process then
    root = processRecursive(process, root, {})
  end

  local inspector = setmetatable({
    depth            = depth,
    buffer           = {},
    level            = 0,
    ids              = setmetatable({}, idsMetaTable),
    maxIds           = setmetatable({}, maxIdsMetaTable),
    newline          = newline,
    indent           = indent,
    tableAppearances = countTableAppearances(root)
  }, Inspector_mt)

  inspector:putValue(root)

  return table.concat(inspector.buffer)
end

setmetatable(inspect, { __call = function(_, ...) return inspect.inspect(...) end })

return inspect
