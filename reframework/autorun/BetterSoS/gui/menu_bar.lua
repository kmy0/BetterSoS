local bind_manager = require("BetterSoS.bind.init")
local config = require("BetterSoS.config.init")
local data = require("BetterSoS.data.init")
local routine_search = require("BetterSoS.better_sos.routine_search")
local set = require("BetterSoS.util.imgui.config_set"):new(config)
local state = require("BetterSoS.gui.state")
local util_bind = require("BetterSoS.util.game.bind.init")
local util_gui = require("BetterSoS.gui.util")
local util_imgui = require("BetterSoS.util.imgui.init")
local util_mod = require("BetterSoS.util.mod.init")
local util_table = require("BetterSoS.util.misc.table")

local mod_map = data.mod.map

local this = {}

---@param label string
---@param draw_func fun()
---@param enabled_obj boolean?
---@param text_color integer?
---@return boolean
local function draw_menu(label, draw_func, enabled_obj, text_color)
    enabled_obj = enabled_obj == nil and true or enabled_obj

    if text_color then
        imgui.push_style_color(0, text_color)
    end

    local menu = imgui.begin_menu(label, enabled_obj)

    if text_color then
        imgui.pop_style_color(1)
    end

    if menu then
        draw_func()
        imgui.end_menu()
    end

    return menu
end

local function draw_mod_menu()
    imgui.push_style_var(14, Vector2f.new(0, 2))

    if
        set:menu_item(util_gui.tr("menu.config.enabled"), "mod.enabled")
        and routine_search.has_instance()
        and routine_search.can_cancel()
        and not config.current.mod.enabled
    then
        routine_search.abort()
    end

    imgui.separator()

    if util_imgui.menu_item(util_gui.tr("menu.config.reset"), nil, nil, true) then
        state.clear_disabled_items()
        config:restore()
    end

    imgui.pop_style_var(1)
end

local function draw_lang_menu()
    local config_lang = config.current.mod.lang
    imgui.push_style_var(14, Vector2f.new(0, 2))

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if
            util_imgui.menu_item(menu_item, config_lang.file == menu_item)
            and config_lang.file ~= menu_item
        then
            config_lang.file = menu_item
            config.lang:change()
            config:save()
            state.translate_combo()
        end
    end

    imgui.separator()

    set:menu_item(util_gui.tr("menu.language.fallback"), "mod.lang.fallback")
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

    imgui.indent(2)
    draw_menu(util_gui.tr("menu.language.font_size.name"), function()
        imgui.spacing()

        if set:slider_int("##font_size_slider", "mod.lang.font_size", 8, 48) then
            config_lang.font_size = math.min(math.max(config_lang.font_size, 8), 48)
        end

        imgui.same_line()

        if imgui.button(util_gui.tr("menu.language.font_size.button_apply")) then
            config.lang:change(nil, config_lang.font_size)
        end

        imgui.spacing()
    end)
    imgui.unindent(2)

    imgui.pop_style_var(1)
end

local function draw_help_menu()
    imgui.push_style_var(14, Vector2f.new(0, 2))

    if util_imgui.menu_item(util_gui.tr("menu.help.unstuck_me"), nil, nil, true) then
        util_mod.close_all_menu()
    end
    util_imgui.tooltip(config.lang:tr("menu.help.tooltip_unstuck_me"))

    imgui.pop_style_var(1)
end

local function draw_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    if
        set:slider_int(
            util_gui.tr("menu.bind.slider_buffer"),
            "mod.bind.buffer",
            1,
            11,
            config_mod.bind.buffer - 1 == 0 and config.lang:tr("misc.text_disabled")
                or config_mod.bind.buffer - 1 == 1 and string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame")
                )
                or string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame_plural")
                )
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.buffer)
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.tooltip_buffer"))

    imgui.separator()
    imgui.begin_disabled(state.listener ~= nil)

    local manager = bind_manager.action
    local config_key = "mod.bind.action"
    set:combo("##bind_action_combo", "mod.bind.combo_action", state.combo.action.values)

    imgui.same_line()

    if imgui.button(util_gui.tr("menu.bind.button_add")) then
        state.listener = {
            opt = state.combo.action:get_key(config_mod.bind.combo_action),
            listener = util_bind.listener:new(),
            opt_name = state.combo.action:get_value(config_mod.bind.combo_action),
        }
    end

    imgui.end_disabled()

    if state.listener then
        bind_manager.monitor:pause()

        imgui.separator()

        local bind = state.listener.listener:listen() --[[@as ModBind]]
        ---@type string[]
        local bind_name

        if bind.name_display ~= "" then
            bind_name = { bind.name_display, "..." }
        else
            bind_name = { config.lang:tr("menu.bind.text_default") }
        end

        imgui.begin_table("keybind_listener", 1, 1 << 9)
        imgui.table_next_row()

        util_imgui.adjust_pos(0, 3)

        imgui.table_set_column_index(0)

        if manager:is_valid(bind) then
            bind.bound_value = state.listener.opt

            local is_col, col = manager:is_collision(bind)
            if is_col and col then
                state.listener.collision = string.format(
                    "%s %s",
                    config.lang:tr("menu.bind.tooltip_bound"),
                    config.lang:tr(mod_map.actions[col.bound_value])
                )
            else
                state.listener.collision = nil
            end
        else
            state.listener.collision = nil
        end

        imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

        local save_button = imgui.button(util_gui.tr("menu.bind.button_save"))

        if save_button then
            manager:register(bind)
            config:set(config_key, manager:get_base_binds())

            config:save()
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_disabled()
        imgui.same_line()

        if imgui.button(util_gui.tr("menu.bind.button_clear")) then
            state.listener.listener:clear()
        end

        imgui.same_line()

        if imgui.button(util_gui.tr("menu.bind.button_cancel")) then
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_table()
        imgui.separator()

        if state.listener and state.listener.collision then
            imgui.text_colored(state.listener.collision, mod_map.colors.bad)
            imgui.separator()
        end

        imgui.text(table.concat(bind_name, " + "))
        imgui.separator()
    end

    if
        not util_table.empty(config:get(config_key))
        and imgui.begin_table("keybind_state", 3, 1 << 9)
    then
        imgui.separator()

        ---@type ModBind[]
        local remove = {}
        local binds = config:get(config_key) --[=[@as ModBind[]]=]
        for i = 1, #binds do
            local bind = binds[i]
            imgui.table_next_row()
            imgui.table_set_column_index(0)

            if
                imgui.button(util_gui.tr("menu.bind.button_remove", bind.name, bind.bound_value))
            then
                table.insert(remove, bind)
            end

            imgui.table_set_column_index(1)
            imgui.text(config.lang:tr(mod_map.actions[bind.bound_value]))
            imgui.table_set_column_index(2)
            imgui.text(bind.name_display)
        end

        if not util_table.empty(remove) then
            for _, bind in pairs(remove) do
                manager:unregister(bind)
            end

            config:set(config_key, manager:get_base_binds())
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    draw_menu(util_gui.tr("menu.config.name"), draw_mod_menu)
    draw_menu(util_gui.tr("menu.language.name"), draw_lang_menu)
    draw_menu(util_gui.tr("menu.bind.name"), draw_bind_menu)
    draw_menu(util_gui.tr("menu.help.name"), draw_help_menu)
end

return this
