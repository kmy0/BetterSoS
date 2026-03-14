---@class ModData
---@field map ModMap
---@field enum ModEnum
---@field initialized boolean

---@class (exact) ModMap
---@field colors {good: integer, bad: integer, info: integer, blue: integer, bg: integer}
---@field actions table<string, string>

---@class (exact) ModEnum
---@field auto_start_quest QuestStartType.*
---@field monster_state MonsterState.*
---@field monster_target MonsterTarget.*
---@field auto_search_quest QuestSearchType.*

---@class (exact) QuestFilter
---@field passcode boolean
---@field manualaccept boolean
---@field time integer?
---@field time_limit integer?
---@field player integer?
---@field player_max integer?
---@field rank table<integer, boolean>?
---@field host_hr [integer, integer]?
---@field multiplay_setting table<app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING, boolean>?
---@field map table<app.FieldDef.STAGE, boolean>?
---@field monster_target table<MonsterTarget, boolean>?
---@field monster_state table<string, boolean>?
---@field monster_species table<app.EnemyDef.SPECIES, boolean>?
---@field monster table<app.EnemyDef.ID, boolean>?
---@field monster_grade table<integer, boolean>?
---@field type table<app.MissionTypeList.TYPE, boolean>?
---@field environ table<app.EnvironmentType.ENVIRONMENT, boolean>?
---@field boost boolean
---@field item_wishlist boolean
---@field item_wishlist_any boolean
---@field item_rare boolean
---@field item_judge app.ItemDef.ID?

---@class ModData
local this = {
    ---@diagnostic disable-next-line: missing-fields
    enum = {},
    map = {
        colors = {
            bad = 0xff1947ff,
            good = 0xff47ff59,
            info = 0xff27f3f5,
            blue = 0xff905c34,
            bg = 0xff1c1b1a,
        },
        actions = {
            search_start = "mod.actions.search_start",
            search_cancel = "mod.actions.search_cancel",
        },
    },
    initialized = false,
}

---@enum QuestStartType
this.enum.auto_start_quest = { ---@class QuestStartType.* : {[string]: integer}
    DISABLED = 1,
    PICK = 2,
    START_AND_DEPART = 3,
    START_AND_PREP = 4,
}
---@enum QuestSearchType
this.enum.auto_search_quest = { ---@class QuestSearchType.* : {[string]: integer}
    DISABLED = 1,
    SEARCH = 2,
}
---@enum MonsterState
this.enum.monster_state = { ---@class MonsterState.* : {[string]: integer}
    NONE = 1,
    NORMAL = 2,
    KING = 3,
    FRENZY = 4,
}
---@enum MonsterTarget
this.enum.monster_target = { ---@class MonsterTarget.* : {[string]: integer}
    SMALL = 1,
    SINGLE = 2,
    MULTI = 3,
}

---@return boolean
function this.init()
    this.initialized = true
    return true
end

return this
