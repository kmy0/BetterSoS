---@class GuiState
---@field combo GuiCombo
---@field listener NewBindListener?

---@class (exact) GuiCombo
---@field monster Combo
---@field map Combo
---@field item Combo
---@field type Combo
---@field monster_species Combo
---@field monster_target Combo
---@field monster_state Combo
---@field environ Combo
---@field action Combo
---@field multiplay_setting Combo
---@field rank Combo
---@field monster_grade Combo
---@field player Combo
---@field player_max Combo
---@field quest_target Combo
---@field weapon_host Combo
---@field weapon_member Combo
---@field weapon_more Combo

---@class (exact) NewBindListener
---@field opt string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local combo = require("BetterSoS.util.imgui.combo")
local config = require("BetterSoS.config.init")
local data = require("BetterSoS.data.init")
local e = require("BetterSoS.util.game.enum")
local game_lang = require("BetterSoS.util.game.lang")
local m = require("BetterSoS.util.ref.methods")
local util_game = require("BetterSoS.util.game.init")
local util_ref = require("BetterSoS.util.ref.init")
local util_table = require("BetterSoS.util.misc.table")

local ace_map = data.ace.map
local mod = data.mod

---@param weapon_type string, app.WeaponDef.TYPE
---@return string
local function translate_weapon(weapon_type)
    local w_type = tonumber(weapon_type) --[[@as number]]
    local custom_type = util_table.reverse_lookup(mod.enum.weapon_type, w_type)

    if custom_type then
        return config.lang:tr("mod.combo_weapon." .. custom_type)
    end

    local guid = m.getWeaponName(w_type)
    return game_lang.get_message_local2(guid)
end

---@class GuiState
local this = {
    combo = {
        monster = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local guid = m.getEnemyNameGuid(tonumber(key) --[[@as app.EnemyDef.ID]])
                return game_lang.get_message_local2(guid)
            end
        ),
        map = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local guid = util_ref.value_type("System.Guid")
                m.getStageNameGuid(tonumber(key) --[[@as app.FieldDef.STAGE]], guid:address())
                return game_lang.get_message_local2(guid)
            end
        ),
        item = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local item_id = tonumber(key)
                if item_id < 0 then
                    return config.lang:tr(
                        "mod.combo_item_judge."
                            .. util_table.reverse_lookup(mod.enum.judge_group, item_id)
                    )
                end

                local guid = m.getItemNameGuid(item_id --[[@as app.ItemDef.ID]])
                return game_lang.get_message_local2(guid)
            end
        ),
        type = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local search_type = tonumber(key) --[[@as app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE]]
                local search_name = e.get(
                    "app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE"
                )[search_type]
                local guid = util_game.parse_guid(ace_map.search_type_to_guid[search_name])
                return game_lang.get_message_local2(guid)
            end
        ),
        monster_species = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local species_data = m.getSpeciesData(tonumber(key) --[[@as app.EnemyDef.SPECIES]])
                local guid = species_data:get_EmSpeciesName()
                return game_lang.get_message_local2(guid)
            end
        ),
        monster_target = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local name = util_table.reverse_lookup(mod.enum.monster_target, tonumber(key))
                return config.lang:tr("mod.combo_ignore_monster_target." .. name)
            end
        ),
        monster_state = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local name = util_table.reverse_lookup(mod.enum.monster_state, tonumber(key))
                return config.lang:tr("mod.combo_ignore_monster_state." .. name)
            end
        ),
        environ = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local environ = tonumber(key) --[[@as app.EnvironmentType.ENVIRONMENT]]
                local name = e.get("app.EnvironmentType.ENVIRONMENT")[environ]
                return config.lang:tr("mod.combo_ignore_environ." .. name)
            end
        ),
        action = combo:new(
            mod.map.actions,
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr(mod.map.actions[key])
            end
        ),
        multiplay_setting = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local setting = tonumber(key) --[[@as app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING]]
                local name = e.get(
                    "app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING"
                )[setting]
                return config.lang:tr("mod.combo_ignore_multiplay_setting." .. name)
            end
        ),
        rank = combo:new(
            nil,
            function(a, b)
                return tonumber(a.key) < tonumber(b.key)
            end,
            nil,
            function(key)
                return key .. config.lang:tr("misc.text_star")
            end
        ),
        monster_grade = combo:new(
            nil,
            function(a, b)
                return tonumber(a.key) < tonumber(b.key)
            end,
            nil,
            function(key)
                return key .. config.lang:tr("misc.text_diamond")
            end
        ),
        player = combo:new(
            nil,
            function(a, b)
                return tonumber(a.key) < tonumber(b.key)
            end,
            nil,
            function(key)
                local val = tonumber(key)
                return string.format(
                    config.lang:tr("mod.combo_ignore_player_text"),
                    val,
                    config.lang:tr("misc.text_player"),
                    val == 1 and config.lang:tr("misc.text_slot")
                        or config.lang:tr("misc.text_slot_plural")
                )
            end
        ),
        player_max = combo:new(
            nil,
            function(a, b)
                return tonumber(a.key) < tonumber(b.key)
            end,
            nil,
            function(key)
                local val = tonumber(key)
                return string.format(
                    config.lang:tr("mod.combo_ignore_player_max_text"),
                    val,
                    config.lang:tr("misc.text_player"),
                    val == 1 and config.lang:tr("misc.text_slot")
                        or config.lang:tr("misc.text_slot_plural")
                )
            end
        ),
        quest_target = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local val = tonumber(key) --[[@as app.QuestDef.QUEST_TARGET]]
                local name = e.get("app.QuestDef.QUEST_TARGET")[val]
                return config.lang:tr("mod.combo_ignore_quest_target." .. name)
            end
        ),
        weapon_host = combo:new(nil, function(a, b)
            return a.value < b.value
        end, nil, translate_weapon),
        weapon_member = combo:new(nil, function(a, b)
            return a.value < b.value
        end, nil, translate_weapon),
        weapon_more = combo:new(nil, function(a, b)
            return a.value < b.value
        end, nil, translate_weapon),
    },
}

function this.translate_combo()
    for _, c in
        pairs(this.combo --[[@as table<string, Combo>]])
    do
        c:translate()
    end
end

function this.clear_disabled_items()
    for _, c in
        pairs(this.combo --[[@as table<string, Combo>]])
    do
        c:enable_all_items()
    end
end

function this.init()
    local config_mod = config.current.mod

    this.combo.monster:swap(
        util_table.map_array(ace_map.monsters),
        nil,
        util_table.keys(config_mod.monster)
    )
    this.combo.map:swap(util_table.map_array(ace_map.maps), nil, util_table.keys(config_mod.map))
    this.combo.item:swap(
        util_table.map_array(
            util_table.array_merge(util_table.values(mod.enum.judge_group), ace_map.judge_items)
        )
    )
    this.combo.type:swap(
        util_table.map_array(ace_map.quest_type),
        nil,
        util_table.keys(config_mod.type)
    )
    this.combo.monster_species:swap(
        util_table.map_array(ace_map.monster_species),
        nil,
        util_table.keys(config_mod.monster_species)
    )
    this.combo.monster_target:swap(
        util_table.map_array(mod.enum.monster_target),
        nil,
        util_table.keys(config_mod.monster_target)
    )
    this.combo.monster_state:swap(
        util_table.map_array(mod.enum.monster_state),
        nil,
        util_table.keys(config_mod.monster_state)
    )
    this.combo.environ:swap(
        util_table.map_array(ace_map.environ),
        nil,
        util_table.keys(config_mod.environ)
    )
    this.combo.multiplay_setting:swap(
        util_table.map_array(ace_map.multiplay_setting),
        nil,
        util_table.keys(config_mod.multiplay_setting)
    )
    this.combo.rank:swap(util_table.map_array(ace_map.ranks), nil, util_table.keys(config_mod.rank))
    this.combo.monster_grade:swap(
        util_table.map_array(ace_map.grades),
        nil,
        util_table.keys(config_mod.monster_grade)
    )
    this.combo.player:swap(
        util_table.map_array(ace_map.player),
        nil,
        util_table.keys(config_mod.player)
    )
    this.combo.player_max:swap(
        util_table.map_array(ace_map.player_max),
        nil,
        util_table.keys(config_mod.player_max)
    )
    this.combo.quest_target:swap(
        util_table.map_array(ace_map.quest_target),
        nil,
        util_table.keys(config_mod.quest_target)
    )
    this.combo.weapon_host:swap(
        util_table.map_array(ace_map.weapon_type),
        nil,
        util_table.keys(config_mod.weapon_host)
    )
    this.combo.weapon_member:swap(
        util_table.map_array(ace_map.weapon_type),
        nil,
        util_table.keys(config_mod.weapon_member)
    )
    this.combo.weapon_more:swap(
        util_table.map_array(ace_map.weapon_type),
        nil,
        util_table.keys(config_mod.weapon_more)
    )

    this.translate_combo()
end

return this
