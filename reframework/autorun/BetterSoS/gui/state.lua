---@class GuiState
---@field combo GuiCombo
---@field listener NewBindListener?

---@class (exact) GuiCombo
---@field monster Combo
---@field map Combo
---@field item Combo
---@field type Combo
---@field quest_start Combo
---@field monster_species Combo
---@field monster_target Combo
---@field monster_state Combo
---@field environ Combo
---@field action Combo
---@field multiplay_setting Combo

---@class (exact) NewBindListener
---@field opt string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local combo = require("BetterSoS.gui.combo")
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
                local guid = m.getItemNameGuid(tonumber(key) --[[@as app.ItemDef.ID]])
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
        quest_start = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                local name = util_table.reverse_lookup(mod.enum.quest_start, tonumber(key))
                return config.lang:tr("mod.combo_quest_start." .. name)
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
    },
}

function this.translate_combo()
    for _, c in
        pairs(this.combo --[[@as table<string, Combo>]])
    do
        c:translate()
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
    this.combo.item:swap(util_table.map_array(ace_map.judge_items))
    this.combo.type:swap(
        util_table.map_array(ace_map.quest_type),
        nil,
        util_table.keys(config_mod.type)
    )
    this.combo.quest_start:swap(util_table.map_array(mod.enum.quest_start))
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

    this.translate_combo()
end

return this
