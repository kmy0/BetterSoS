local util_misc = require("BetterSoS.util.misc.init")
local util_table = require("BetterSoS.util.misc.table")

local this = {}

local COL_FRAME_BG = 0xFF3F3535
local COL_FRAME_BG_HOVERED = 0xFF4F4E4D
local COL_FRAME_BG_ACTIVE = 0xFF8D8C8C
local COL_GRAB = 0xFFE0853D
local COL_GRAB_ACT = 0xFFFA9642
local COL_TEXT = 0xFFFFFFFF
local COL_TEXT_DIM = 0xFF808080
local COL_TEXT_HOVERED = util_misc.mul_alpha(COL_TEXT, 0.8)

local DISABLED_ALPHA = 0.6
local RADIO_RADIUS = 6.0
local RADIO_DOT_R = 3.0
local RADIO_SPACING = 8.0
local RADIO_ROW_H = 20.0
local RADIO_SEGS = 24

---@param id string
---@param current integer
---@param options table<integer, string>
---@param disabled_options table<integer, boolean>?
---@param disabled boolean?
---@param horizontal boolean?
---@param fallback integer?
---@return boolean, integer
function this.radio_group(id, current, options, disabled_options, disabled, horizontal, fallback)
    local changed = false
    local new_val = current

    if
        (disabled or disabled_options and disabled_options[current])
        and fallback
        and current ~= fallback
    then
        new_val = fallback
        changed = true
    end

    local dl = imgui.get_window_draw_list()
    local keys = util_table.sort(util_table.keys(options))

    for i = 1, #keys do
        local label = options[i]
        local is_selected = (new_val == i)
        local text_size = imgui.calc_text_size(label)
        local btn_w = RADIO_RADIUS * 2 + RADIO_SPACING + text_size.x

        local p = imgui.get_cursor_screen_pos()
        local clicked = imgui.invisible_button(id .. "_" .. i, Vector2f.new(btn_w, RADIO_ROW_H))
        local after_btn = imgui.get_cursor_screen_pos()
        local is_option_disabled = disabled_options and disabled_options[i]
        local hovered = imgui.is_item_hovered() and not disabled and not is_option_disabled
        local is_active = imgui.is_item_active() and not disabled and not is_option_disabled

        if clicked and not is_selected and not disabled and not is_option_disabled then
            new_val = i
            changed = true
        end

        local cx = p.x + RADIO_RADIUS
        local cy = p.y + RADIO_ROW_H * 0.5

        local col_fill = is_active and COL_FRAME_BG_ACTIVE
            or hovered and COL_FRAME_BG_HOVERED
            or COL_FRAME_BG
        local col_ring = is_selected and COL_GRAB or COL_FRAME_BG_ACTIVE
        local col_dot = is_selected and (hovered and COL_GRAB_ACT or COL_GRAB) or COL_GRAB
        local col_text = is_selected and COL_TEXT or hovered and COL_TEXT_HOVERED or COL_TEXT_DIM

        if is_option_disabled then
            col_fill = util_misc.mul_alpha(col_fill, DISABLED_ALPHA)
            col_ring = util_misc.mul_alpha(col_ring, DISABLED_ALPHA)
            col_dot = util_misc.mul_alpha(col_dot, DISABLED_ALPHA)
            col_text = util_misc.mul_alpha(col_text, DISABLED_ALPHA)
        end

        if disabled then
            col_fill = util_misc.mul_alpha(col_fill, DISABLED_ALPHA)
            col_ring = util_misc.mul_alpha(col_ring, DISABLED_ALPHA)
            col_dot = util_misc.mul_alpha(col_dot, DISABLED_ALPHA)
            col_text = util_misc.mul_alpha(col_text, DISABLED_ALPHA)
        end

        dl:add_circle_filled(Vector2f.new(cx, cy), RADIO_RADIUS, col_fill, RADIO_SEGS)
        dl:add_circle(Vector2f.new(cx, cy), RADIO_RADIUS, col_ring, RADIO_SEGS, 1.5)

        if is_selected then
            dl:add_circle_filled(Vector2f.new(cx, cy), RADIO_DOT_R, col_dot, RADIO_SEGS)
        end

        imgui.set_cursor_screen_pos(
            Vector2f.new(p.x + RADIO_RADIUS * 2 + RADIO_SPACING, cy - text_size.y * 0.5)
        )
        imgui.text_colored(label, col_text)

        if horizontal and i < #keys then
            imgui.set_cursor_screen_pos(Vector2f.new(p.x + btn_w + RADIO_SPACING, p.y))
        else
            imgui.set_cursor_screen_pos(Vector2f.new(after_btn.x, after_btn.y))
        end
    end

    return changed, new_val
end

return this
