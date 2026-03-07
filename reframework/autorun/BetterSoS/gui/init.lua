---@class Gui
---@field window GuiWindow

---@class (exact) GuiWindow
---@field flags integer
---@field condition integer

local config = require("BetterSoS.config.init")
local data = require("BetterSoS.data.init")
local menu_bar = require("BetterSoS.gui.menu_bar")
local set = require("BetterSoS.util.imgui.config_set"):new(config)
local state = require("BetterSoS.gui.state")
local util_gui = require("BetterSoS.gui.util")
local util_imgui = require("BetterSoS.util.imgui.init")
local util_mod = require("BetterSoS.util.mod.init")
local util_table = require("BetterSoS.util.misc.table")

local ace_map = data.ace.map
local mod_map = data.mod.map

---@class Gui
local this = {
    window = {
        flags = 1024,
        condition = 2,
    },
}

---@param key "map" | "monster" | "type" | "monster_species" | "monster_state" | "monster_target" | "environ"
local function draw_chips(key)
    local config_mod = config.current.mod
    local combo = state.combo[key] --[[@as Combo]]
    local map = config_mod[key] --[[@as table<string, integer>]]
    local combo_index_key = "mod.combo_ignore_" .. key --[[@as string]]

    set:checkbox("##box_ignore_" .. key, "mod.ignore_" .. key)
    imgui.begin_disabled(not config:get("mod.ignore_" .. key))
    imgui.same_line()
    imgui.begin_disabled(util_table.empty(combo.values))
    set:combo("##combo_ignore_" .. key, combo_index_key, combo.values)
    imgui.same_line()

    if imgui.button(util_gui.tr("mod.button_ignore", key)) then
        local index = combo:get_key(config:get(combo_index_key))
        if not map[index] then
            map[index] = util_table.empty(map) and 1
                or math.max(table.unpack(util_table.values(map))) + 1
            config:set(combo_index_key, combo:disable_item(index))
        end
    end
    imgui.end_disabled()

    if not util_table.empty(map) then
        local sorted = util_table.sort(util_table.keys(map), function(a, b)
            return map[a] < map[b]
        end)

        imgui.same_line()
        local max_x = imgui.get_cursor_pos().x
        local spacing = 8
        local frame_padding = 4
        local some_x = 3
        imgui.new_line()

        imgui.push_style_color(5, mod_map.colors.blue)
        imgui.push_style_var(13, 2)
        imgui.push_style_color(21, mod_map.colors.bg)

        for i = 1, #sorted do
            local val = sorted[i]
            local text = combo:get_disabled(val).value

            if
                imgui.get_cursor_pos().x
                    + imgui.calc_text_size(text).x
                    + spacing
                    + frame_padding
                    + some_x
                >= max_x
            then
                imgui.new_line()
            end

            if imgui.button(string.format("%s##%s_%s", text, key, i)) then
                map[val] = nil
                config:set(combo_index_key, combo:enable_item(val))
            end

            imgui.same_line()
        end

        imgui.new_line()
        imgui.pop_style_color(2)
        imgui.pop_style_var(1)

        imgui.separator()
    end

    imgui.end_disabled()
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
        config.max_time,
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
        config.max_time,
        string.format(
            config.lang:tr("mod.slider_text_time_limit"),
            config_mod.slider_time_limit,
            config_mod.slider_time_limit == 1 and config.lang:tr("misc.text_minute")
                or config.lang:tr("misc.text_minute_plural")
        )
    )
    draw_ignore_slider(
        "player",
        2,
        config.max_player - 1,
        string.format(
            config.lang:tr("mod.slider_text_player"),
            config_mod.slider_player,
            config.lang:tr("misc.text_player"),
            config_mod.slider_player == 1 and config.lang:tr("misc.text_slot")
                or config.lang:tr("misc.text_slot_plural")
        )
    )
    draw_ignore_slider(
        "player_max",
        2,
        config.max_player,
        string.format(
            config.lang:tr("mod.slider_text_player_max"),
            config_mod.slider_player_max,
            config.lang:tr("misc.text_player"),
            config_mod.slider_player_max == 1 and config.lang:tr("misc.text_slot")
                or config.lang:tr("misc.text_slot_plural")
        )
    )
    draw_ignore_slider(
        "rank_lower",
        1,
        ace_map.max_quest_rank,
        string.format(
            config.lang:tr("mod.slider_text_rank_lower"),
            config_mod.slider_rank_lower,
            config.lang:tr("misc.text_star")
        )
    )
    draw_ignore_slider(
        "rank_upper",
        1,
        ace_map.max_quest_rank,
        string.format(
            config.lang:tr("mod.slider_text_rank_upper"),
            config_mod.slider_rank_upper,
            config.lang:tr("misc.text_star")
        )
    )
    draw_chips("type")

    imgui.spacing()
end

local function draw_monster()
    util_imgui.separator_text(
        config.lang:tr("mod.category_ignore_monster"),
        nil,
        nil,
        mod_map.colors.blue
    )
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
    local is_auto_start = util_mod.is_auto_start_quest()

    util_imgui.separator_text(config.lang:tr("mod.category_auto"), nil, nil, mod_map.colors.blue)
    imgui.begin_disabled(is_auto_start and config_mod.auto_start_quest)
    set:checkbox(util_gui.tr("mod.box_auto_pick_quest"), "mod.auto_pick_quest")
    imgui.end_disabled()

    imgui.begin_disabled(
        not config_mod.ignore_manualaccept
            or not config_mod.ignore_passcode
            or config_mod.auto_pick_quest
    )
    set:checkbox(util_gui.tr("mod.box_auto_start_quest"), "mod.auto_start_quest")
    imgui.end_disabled()
    util_imgui.tooltip(config.lang:tr("mod.tooltip_auto_start_quest"), true)

    imgui.begin_disabled(not is_auto_start or config_mod.auto_pick_quest)
    imgui.same_line()
    set:combo("##combo_quest_accept", "mod.combo_quest_start", state.combo.quest_start.values)
    imgui.end_disabled()

    imgui.begin_disabled(not is_auto_start and not config_mod.auto_pick_quest)
    set:checkbox(util_gui.tr("mod.box_auto_search"), "mod.auto_search")
    imgui.end_disabled()
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
    draw_quest_attr()
    draw_monster()
    draw_map()
    draw_item()
    draw_auto()
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
