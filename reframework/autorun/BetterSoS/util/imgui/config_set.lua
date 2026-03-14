---@class (exact) ImguiConfigSet
---@field ref ConfigBase

local util_imgui = require("BetterSoS.util.imgui.init")

---@class ImguiConfigSet
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param config_ref ConfigBase
---@return ImguiConfigSet
function this:new(config_ref)
    return setmetatable({ ref = config_ref }, self)
end

---@param name string
---@param config_key string
---@param func fun(...): boolean, any
---@return boolean
function this:generic_config(name, config_key, func, ...)
    local changed, value
    changed, value = func(name, self.ref:get(config_key), ...)
    if changed then
        self.ref:set(config_key, value)
    end
    return changed
end

---@param name string
---@param config_key_a string
---@param config_key_b string
---@param func fun(...): boolean, any, any
---@return boolean
function this:generic_config2(name, config_key_a, config_key_b, func, ...)
    local changed, value_a, value_b =
        func(name, self.ref:get(config_key_a), self.ref:get(config_key_b), ...)
    if changed then
        self.ref:set(config_key_a, value_a)
        self.ref:set(config_key_b, value_b)
    end
    return changed
end

---@param name string
---@param config_key string
---@return boolean
function this:checkbox(name, config_key)
    return self:generic_config(name, config_key, imgui.checkbox)
end

---@param name string
---@param config_key string
---@param values  string[]
---@return boolean
function this:combo(name, config_key, values)
    return self:generic_config(name, config_key, imgui.combo, values)
end

---@param name string
---@param config_key string
---@param flags_obj integer? `ImGuiColorEditFlags`
---@return boolean
function this:color_edit(name, config_key, flags_obj)
    return self:generic_config(name, config_key, imgui.color_edit, flags_obj)
end

---@param name string
---@param config_key string
---@param v_min number
---@param v_max number
---@param display_format? string
---@return boolean
function this:slider_float(name, config_key, v_min, v_max, display_format)
    return self:generic_config(name, config_key, imgui.slider_float, v_min, v_max, display_format)
end

---@param name string
---@param config_key string
---@param v_min number
---@param v_max number
---@param display_format? string
---@return boolean
function this:slider_int(name, config_key, v_min, v_max, display_format)
    return self:generic_config(name, config_key, imgui.slider_int, v_min, v_max, display_format)
end

---@param name string
---@param config_key string
---@param enabled_obj boolean?
---@return boolean
function this:menu_item(name, config_key, enabled_obj)
    return self:generic_config(name, config_key, util_imgui.menu_item, enabled_obj)
end

---@param name string
---@param config_key string
---@param flags ImGuiInputTextFlags?
---@return boolean
function this:input_text(name, config_key, flags)
    return self:generic_config(name, config_key, imgui.input_text, flags)
end

---@param name string
---@param config_key_lo string
---@param config_key_hi string
---@param v_min integer
---@param v_max integer
---@param display_format string?
---@param display_text string?
---@param disabled boolean?
---@return boolean
function this:range_slider_int(
    name,
    config_key_lo,
    config_key_hi,
    v_min,
    v_max,
    display_format,
    display_text,
    disabled
)
    return self:generic_config2(
        name,
        config_key_lo,
        config_key_hi,
        util_imgui.range_slider_int,
        v_min,
        v_max,
        display_format,
        display_text,
        disabled
    )
end

---@param name string
---@param config_key_lo string
---@param config_key_hi string
---@param v_min number
---@param v_max number
---@param display_format string?
---@param display_text string?
---@param disabled boolean?
---@return boolean
function this:range_slider_float(
    name,
    config_key_lo,
    config_key_hi,
    v_min,
    v_max,
    display_format,
    display_text,
    disabled
)
    return self:generic_config2(
        name,
        config_key_lo,
        config_key_hi,
        util_imgui.range_slider_float,
        v_min,
        v_max,
        display_format,
        display_text,
        disabled
    )
end

---@param id string
---@param config_key string
---@param options table<integer, string>
---@param disabled_options table<integer, boolean>?
---@param disabled boolean?
---@param horizontal boolean?
---@param fallback integer?
---@return boolean
function this:radio_group(id, config_key, options, disabled_options, disabled, horizontal, fallback)
    return self:generic_config(
        id,
        config_key,
        util_imgui.radio_group,
        options,
        disabled_options,
        disabled,
        horizontal,
        fallback
    )
end

return this
