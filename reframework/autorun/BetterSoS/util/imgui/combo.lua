---@class (exact) Combo
---@field values string[]
---@field map ComboMap[]
---@field sort (fun(a: ComboMap, b: ComboMap): boolean)?
---@field mapper (fun(value: any): string)?
---@field _translate (fun(key: any): string)?
---@field disabled ComboMap[]

---@alias ComboMap {key: any, value: string}

local util_table = require("BetterSoS.util.misc.table")

---@class Combo
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param key_to_value table?
---@param sort (fun(a: ComboMap, b: ComboMap): boolean)?
---@param mapper (fun(value: any): string)?
---@param translate (fun(key: any): string)?
---@param disabled_keys any[]?
---@return Combo
function this:new(key_to_value, sort, mapper, translate, disabled_keys)
    local o = {
        sort = sort,
        mapper = mapper,
        _translate = translate,
        disabled = {},
    }

    if key_to_value then
        this._map(o, key_to_value)
    end

    setmetatable(o, self)
    ---@cast o Combo

    for _, key in pairs(disabled_keys or {}) do
        o:disable_item(key)
    end
    return o
end

---@overload fun(key_to_value: table, current_index: integer): integer
---@overload fun(key_to_value: table)
---@param key_to_value table
---@param current_index integer?
---@param disabled_keys any[]?
---@return integer?
function this:swap(key_to_value, current_index, disabled_keys)
    self.disabled = {}

    if current_index then
        local current_key = self.map[current_index].key
        self:_map(key_to_value)
        return util_table.index(self.map, function(o)
            return o.key == current_key
        end) or 1
    end
    self:_map(key_to_value)

    for _, key in pairs(disabled_keys or {}) do
        self:disable_item(key)
    end
end

---@param current_index integer?
function this:translate(current_index)
    if not self._translate then
        return
    end

    self.values = {}
    local current_item = self.map[current_index or 1] or {}
    local current_key = current_item.key

    for _, v in pairs(self.map) do
        v.value = self._translate(v.key)
    end

    for _, v in pairs(self.disabled) do
        v.value = self._translate(v.key)
    end

    if self.sort then
        table.sort(self.map, self.sort)
    end

    for i = 1, #self.map do
        local m = self.map[i]
        table.insert(self.values, m.value)
    end

    return util_table.index(self.map, function(o)
        return o.key == current_key
    end) or 1
end

---@param index integer
---@return any
function this:get_key(index)
    return self.map[index].key
end

---@param index integer
---@return string
function this:get_value(index)
    return self.map[index].value
end

---@param key any?
---@param value string?
---@return ComboMap
function this:get_disabled(key, value)
    return util_table.value(self.disabled, function(_, item)
        return key == item.key or value == item.value
    end) --[[@as ComboMap]]
end

---@param key any?
---@param value string?
---@return integer
function this:disable_item(key, value)
    local index = self:get_index(key, value)
    if index then
        local item = table.remove(self.map, index)
        table.insert(self.disabled, item)
        table.remove(self.values, index)

        if index <= #self.values then
            return index
        else
            return math.max(index - 1, 1)
        end
    end

    return 1
end

---@param key any?
---@param value string?
---@return integer
function this:enable_item(key, value)
    ---@type integer
    local index

    if key then
        index = util_table.index(self.disabled, function(o)
            return o.key == key
        end) --[[@as integer]]
    elseif value then
        index = util_table.index(self.disabled, function(o)
            return o.value == value
        end) --[[@as integer]]
    end

    local item = table.remove(self.disabled, index)
    table.insert(self.map, item)

    if self.sort then
        table.sort(self.map, self.sort)
    end

    self.values = {}
    for i = 1, #self.map do
        local m = self.map[i]
        table.insert(self.values, m.value)
    end

    return self:get_index(key, value) --[[@as integer]]
end

function this:enable_all_items()
    for _, v in pairs(util_table.values(self.disabled)) do
        self:enable_item(v.key)
    end
end

function this:disable_all_items()
    for _, v in pairs(util_table.values(self.map)) do
        self:disable_item(v.key)
    end
end

---@param key any?
---@param value string?
---@return integer?
function this:get_index(key, value)
    if key then
        return util_table.index(self.map, function(o)
            return o.key == key
        end)
    end

    if value then
        return util_table.index(self.map, function(o)
            return o.value == value
        end)
    end
end

function this:size()
    return #self.values
end

function this:empty()
    return util_table.empty(self.values)
end

---@protected
---@param key_to_value table
function this:_map(key_to_value)
    self.values = {}
    self.map = {}

    local t = key_to_value
    if self.mapper then
        t = util_table.map_table(t, nil, self.mapper)
    end

    for k, v in pairs(t) do
        table.insert(self.map, { key = k, value = v })
    end

    if self.sort then
        table.sort(self.map, self.sort)
    end

    for i = 1, #self.map do
        local m = self.map[i]
        table.insert(self.values, m.value)
    end
end

return this
