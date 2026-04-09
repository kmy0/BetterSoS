---@class Gui
---@field window GuiWindow

---@class (exact) GuiWindow
---@field flags integer
---@field condition integer

local combo_chips = require("BetterSoS.util.imgui.combo_chips")
local config = require("BetterSoS.config.init")
local data = require("BetterSoS.data.init")
local menu_bar = require("BetterSoS.gui.menu_bar")
local set = require("BetterSoS.util.imgui.config_set"):new(config)
local state = require("BetterSoS.gui.state")
local util_gui = require("BetterSoS.gui.util")
local util_imgui = require("BetterSoS.util.imgui.init")
local util_table = require("BetterSoS.util.misc.table")

local ace_map = data.ace.map
local mod_map = data.mod.map
local mod_enum = data.mod.enum

---@class Gui
local this = {
    window = {
        flags = 1024,
        condition = 2,
    },
}

---@param key "map" | "monster" | "type" | "monster_species" | "monster_state" | "monster_target" | "environ" | "multiplay_setting" | "rank" | "monster_grade" | "player" | "player_max"
local function draw_chips(key)
    local config_mod = config.current.mod
    local combo = state.combo[key] --[[@as Combo]]
    local map = config_mod[key] --[[@as table<string, integer>]]
    local combo_index_key = "mod.combo_ignore_" .. key --[[@as string]]

    set:checkbox("##box_ignore_" .. key, "mod.ignore_" .. key)
    imgui.begin_disabled(not config:get("mod.ignore_" .. key))
    imgui.same_line()
    set:combo_chips(
        "##combo_ignore_" .. key,
        combo_index_key,
        map,
        combo,
        util_gui.tr("mod.button_ignore", key),
        {
            {
                label = config.lang:tr("mod.button_clear"),
                action = combo_chips.clear_selection,
            },
            {
                label = config.lang:tr("mod.button_ignore_all"),
                is_draw = function(_, _, combo, _)
                    return not util_table.empty(combo.map)
                        and #combo.values + #combo.disabled > config.min_ignore_all
                end,
                action = combo_chips.select_all,
            },
        }
    )
    imgui.end_disabled()

    if not util_table.empty(map) then
        imgui.separator()
    end
end

---@param id string
---@param min_val integer
---@param max_val integer
---@param display_text string?
local function draw_ignore_slider(id, min_val, max_val, display_text)
    local config_mod = config.current.mod

    set:checkbox("##box_ignore_" .. id, "mod.ignore_" .. id)
    imgui.begin_disabled(not config_mod["ignore_" .. id])
    imgui.same_line()
    set:slider_int("##slider_" .. id, "mod.slider_" .. id, min_val, max_val, display_text)
    imgui.end_disabled()
end

---@param id string
---@param id_a string
---@param id_b string
---@param min_val integer
---@param max_val integer
---@param display_text string?
local function draw_ignore_slider_range(id, id_a, id_b, min_val, max_val, display_text)
    local config_mod = config.current.mod

    set:checkbox("##box_ignore_" .. id, "mod.ignore_" .. id)
    local disabled = not config_mod["ignore_" .. id]
    imgui.begin_disabled(disabled)
    imgui.same_line()

    set:range_slider_int(
        "##slider_" .. id,
        string.format("mod.slider_%s_%s", id, id_a),
        string.format("mod.slider_%s_%s", id, id_b),
        min_val,
        max_val,
        nil,
        display_text,
        disabled
    )
    imgui.end_disabled()
end

local function draw_quest_attr()
    local config_mod = config.current.mod

    util_imgui.separator_text(
        config.lang:tr("mod.category_ignore_attr"),
        nil,
        nil,
        mod_map.colors.blue
    )
    set:checkbox(util_gui.tr("mod.box_ignore_passcode"), "mod.ignore_passcode")
    set:checkbox(util_gui.tr("mod.box_ignore_manualaccept"), "mod.ignore_manualaccept")

    draw_ignore_slider(
        "time",
        1,
        ace_map.max_time,
        string.format(
            config.lang:tr("mod.slider_text_time"),
            config_mod.slider_time,
            config_mod.slider_time == 1 and config.lang:tr("misc.text_minute")
                or config.lang:tr("misc.text_minute_plural")
        )
    )
    draw_ignore_slider(
        "time_limit",
        1,
        ace_map.max_time,
        string.format(
            config.lang:tr("mod.slider_text_time_limit"),
            config_mod.slider_time_limit,
            config_mod.slider_time_limit == 1 and config.lang:tr("misc.text_minute")
                or config.lang:tr("misc.text_minute_plural")
        )
    )
    draw_ignore_slider_range(
        "host_hr",
        "lower",
        "upper",
        1,
        ace_map.max_hr,
        string.format(
            config.lang:tr("mod.slider_text_host_hr"),
            config_mod.slider_host_hr_lower,
            config_mod.slider_host_hr_upper
        )
    )
    draw_chips("player")
    draw_chips("player_max")
    draw_chips("rank")
    draw_chips("type")
    draw_chips("multiplay_setting")

    imgui.spacing()
end

local function draw_monster()
    util_imgui.separator_text(
        config.lang:tr("mod.category_ignore_monster"),
        nil,
        nil,
        mod_map.colors.blue
    )

    draw_chips("monster_grade")
    draw_chips("monster")
    draw_chips("monster_species")
    draw_chips("monster_state")
    draw_chips("monster_target")

    imgui.spacing()
end

local function draw_map()
    util_imgui.separator_text(
        config.lang:tr("mod.category_ignore_map"),
        nil,
        nil,
        mod_map.colors.blue
    )
    draw_chips("map")
    draw_chips("environ")

    imgui.spacing()
end

local function draw_item()
    local config_mod = config.current.mod

    util_imgui.separator_text(config.lang:tr("mod.category_require"), nil, nil, mod_map.colors.blue)
    set:checkbox(
        util_gui.tr("mod.box_require_item_wishlist", "any"),
        "mod.require_item_wishlist_any"
    )
    util_imgui.tooltip(config.lang:tr("mod.tooltip_item_wishlist_any"), true)
    util_imgui.tooltip_text(config.lang:tr("mod.tooltip_investigations_only"))
    set:checkbox(util_gui.tr("mod.box_require_boost"), "mod.require_boost")
    set:checkbox(util_gui.tr("mod.box_require_item_wishlist"), "mod.require_item_wishlist")
    util_imgui.tooltip(config.lang:tr("mod.tooltip_item_wishlist"), true)
    set:checkbox(util_gui.tr("mod.box_require_item_rare"), "mod.require_item_rare")
    util_imgui.tooltip(config.lang:tr("mod.tooltip_item_rare"), true)
    set:checkbox("##require_judge_item", "mod.require_item_judge")
    imgui.same_line()
    imgui.begin_disabled(not config_mod.require_item_judge)
    set:combo("##combo_item_judge", "mod.combo_item_judge", state.combo.item.values)
    imgui.end_disabled()

    imgui.spacing()
end

local function draw_auto()
    local config_mod = config.current.mod

    util_imgui.separator_text(config.lang:tr("mod.category_auto"), nil, nil, mod_map.colors.blue)

    local auto_start_ok = config_mod.ignore_manualaccept and config_mod.ignore_passcode
    set:radio_group(
        "auto_start_quest_radio",
        "mod.auto_start_quest",
        util_table.map_table(mod_enum.auto_start_quest, function(o)
            return mod_enum.auto_start_quest[o]
        end, function(o)
            local key = util_table.reverse_lookup(mod_enum.auto_start_quest, o)
            return config.lang:tr("mod.radio_start_quest." .. key)
        end),
        {
            [mod_enum.auto_start_quest.START_AND_DEPART] = not auto_start_ok,
            [mod_enum.auto_start_quest.START_AND_PREP] = not auto_start_ok,
        },
        false,
        true,
        mod_enum.auto_start_quest.DISABLED
    )
    util_imgui.tooltip(config.lang:tr("mod.tooltip_auto_start_quest"), true)

    local auto_search_ok = config_mod.auto_start_quest ~= mod_enum.auto_start_quest.DISABLED
    set:radio_group(
        "auto_search_quest_radio",
        "mod.auto_search",
        util_table.map_table(mod_enum.auto_search_quest, function(o)
            return mod_enum.auto_search_quest[o]
        end, function(o)
            local key = util_table.reverse_lookup(mod_enum.auto_search_quest, o)
            return config.lang:tr("mod.radio_search_quest." .. key)
        end),
        {
            [mod_enum.auto_search_quest.SEARCH] = not auto_search_ok,
        },
        false,
        true,
        mod_enum.auto_search_quest.DISABLED
    )
    util_imgui.tooltip(config.lang:tr("mod.tooltip_auto_search"), true)
end

function this.draw()
    local gui_main = config.gui.current.gui.main
    local config_mod = config.current.mod

    imgui.set_next_window_pos(Vector2f.new(gui_main.pos_x, gui_main.pos_y), this.window.condition)
    imgui.set_next_window_size(
        Vector2f.new(gui_main.size_x, gui_main.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_main.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.commit),
        gui_main.is_opened,
        this.window.flags
    )

    util_imgui.set_win_state(gui_main)

    if not gui_main.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        config.save_global()
        imgui.end_window()
        return
    end

    if imgui.begin_menu_bar() then
        menu_bar.draw()
        imgui.end_menu_bar()
    end

    imgui.spacing()
    imgui.indent(3)

    imgui.begin_disabled(not config_mod.enabled)
    draw_auto()
    draw_quest_attr()
    draw_monster()
    draw_map()
    draw_item()
    imgui.end_disabled()

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.unindent(3)
    imgui.spacing()
    imgui.end_window()
end

---@return boolean
function this.init()
    state.init()
    return true
end

return this
