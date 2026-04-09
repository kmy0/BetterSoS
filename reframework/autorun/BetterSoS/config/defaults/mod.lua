---@class (exact) MainSettings : SettingsBase
---@field version string
---@field mod ModSettings

---@class (exact) ModLanguage
---@field file string
---@field fallback boolean

---@class (exact) ModSettings
---@field enabled boolean
---@field lang ModLanguage
---@field ignore_passcode boolean
---@field ignore_manualaccept boolean
---@field ignore_time boolean
---@field ignore_time_limit boolean
---@field ignore_player boolean
---@field ignore_player_max boolean
---@field ignore_rank boolean
---@field ignore_monster boolean
---@field ignore_monster_species boolean
---@field ignore_monster_state boolean
---@field ignore_monster_target boolean
---@field ignore_monster_grade boolean
---@field ignore_map boolean
---@field ignore_type boolean
---@field ignore_environ boolean
---@field ignore_multiplay_setting boolean
---@field ignore_host_hr boolean
---@field require_item_wishlist boolean
---@field require_item_judge boolean
---@field require_item_rare boolean
---@field require_item_wishlist_any boolean
---@field require_boost boolean
---@field auto_start_quest integer -- QuestStartType
---@field auto_search integer -- QuestSearchType
---@field slider_time integer
---@field slider_time_limit integer
---@field slider_host_hr_lower integer
---@field slider_host_hr_upper integer
---@field combo_ignore_rank integer
---@field combo_ignore_monster_grade integer
---@field combo_ignore_monster integer
---@field combo_ignore_map integer
---@field combo_item_judge integer
---@field combo_ignore_type integer
---@field combo_ignore_monster_species integer
---@field combo_ignore_monster_target integer
---@field combo_ignore_monster_state integer
---@field combo_ignore_environ integer
---@field combo_ignore_multiplay_setting integer
---@field combo_ignore_player integer
---@field combo_ignore_player_max integer
---@field monster table<string, integer>
---@field monster_species table<string, integer>
---@field monster_target table<string, integer>
---@field monster_state table<string, integer>
---@field map table<string, integer>
---@field type table<string, integer>
---@field environ table<string, integer>
---@field rank table<string, integer>
---@field player table<string, integer>
---@field player_max table<string, integer>
---@field monster_grade table<string, integer>
---@field multiplay_setting table<string, integer>
---@field bind {
---     action: BindBase[],
---     buffer: integer,
---     combo_action: integer,
--- }

local version = require("BetterSoS.config.version")

---@type MainSettings
return {
    version = version.version,
    mod = {
        lang = {
            file = "en-us",
            fallback = true,
        },
        enabled = true,
        ignore_passcode = true,
        ignore_manualaccept = true,
        ignore_time = false,
        ignore_time_limit = false,
        ignore_player = false,
        ignore_rank = false,
        ignore_map = false,
        ignore_monster = false,
        ignore_player_max = false,
        ignore_monster_state = false,
        ignore_monster_target = false,
        ignore_monster_species = false,
        ignore_monster_grade = false,
        ignore_type = false,
        ignore_environ = false,
        ignore_multiplay_setting = false,
        ignore_host_hr = false,
        require_item_wishlist = false,
        require_item_wishlist_any = false,
        require_item_judge = false,
        require_item_rare = false,
        require_boost = false,
        auto_start_quest = 1,
        auto_search = 1,
        slider_time = 1,
        slider_time_limit = 1,
        slider_host_hr_lower = 1,
        slider_host_hr_upper = 999,
        combo_ignore_monster = 1,
        combo_ignore_map = 1,
        combo_item_judge = 1,
        combo_ignore_type = 1,
        combo_ignore_monster_species = 1,
        combo_ignore_monster_state = 1,
        combo_ignore_monster_target = 1,
        combo_ignore_environ = 1,
        combo_ignore_multiplay_setting = 1,
        combo_ignore_monster_grade = 1,
        combo_ignore_rank = 1,
        combo_ignore_player = 1,
        combo_ignore_player_max = 1,
        monster = {},
        map = {},
        type = {},
        monster_species = {},
        monster_target = {},
        monster_state = {},
        environ = {},
        multiplay_setting = {},
        rank = {},
        monster_grade = {},
        player = {},
        player_max = {},
        bind = {
            action = {
                {
                    bound_value = "search_cancel",
                    device = "KEYBOARD",
                    keys = {
                        79,
                    },
                    name = "ESCAPE",
                    name_display = "ESCAPE",
                },
                {
                    bound_value = "search_cancel",
                    device = "PAD",
                    keys = {
                        128,
                    },

                    name = "R_RIGHT",
                    name_display = "R_RIGHT",
                },
            },
            buffer = 2,
            combo_action = 1,
        },
    },
}
