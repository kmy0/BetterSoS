---@class (exact) AceData
---@field map AceMap

---@class (exact) AceMap
---@field guid_searching string
---@field guid_no_quests string
---@field guid_close string
---@field guid_join_quest string
---@field guid_any string
---@field maps app.FieldDef.STAGE[]
---@field judge_items app.ItemDef.ID[]
---@field special_items app.ItemDef.ID[]
---@field monsters app.EnemyDef.ID[]
---@field ranks integer[]
---@field grades integer[]
---@field monster_to_species table<app.EnemyDef.ID, app.EnemyDef.SPECIES>
---@field monster_species app.EnemyDef.SPECIES[]
---@field environ app.EnvironmentType.ENVIRONMENT[]
---@field multiplay_setting app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING[]
---@field search_type_to_guid table<string, string>
---@field start_type_to_guid table<string, string>
---@field quest_type app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE[]
---@field quest_type_map table<app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE, app.MissionTypeList.TYPE[]>
---@field SmartCampPicker_data {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}?
---@field max_hr integer
---@field max_time integer
---@field max_player integer

---@alias AreaId integer
---@alias CampId integer

---@class AceData
local this = {
    map = {
        guid_searching = "dea7a74a-8dca-4761-bfb5-872013a020d6",
        guid_no_quests = "5861a854-56ed-4ebc-8650-2f6d0170c47d",
        guid_close = "a1b5007e-66b6-4c36-b8be-9434dae0386a",
        guid_join_quest = "85b834d2-6bcf-473c-9c2e-8ec117ad6de7",
        guid_any = "8fee14a2-10f0-41a2-8c40-72a029623bbc",
        maps = {},
        judge_items = {},
        special_items = {},
        monsters = {},
        quest_type = {},
        quest_type_map = {},
        monster_to_species = {},
        search_type_to_guid = {
            MISSION = "e284bb17-5832-4884-9e97-b27935d895cd",
            FREE = "2092b44c-6ca1-4739-8c15-de9ff059bf1f",
            KEEP = "6a5c2dbb-e2ac-4c14-8dce-9f2cc7845e9e",
            EVENT = "85173188-e304-4770-bf5f-a31f44001ee3",
        },
        start_type_to_guid = {
            START_AND_DEPART = "977e49d1-da76-487a-a830-96ac3e409483",
            START_AND_PREP = "b83ede97-c238-4f41-b555-a64b9ed87a22",
        },
        monster_species = {},
        environ = {},
        multiplay_setting = {},
        ranks = {},
        grades = {},
        max_hr = 0,
        max_time = 50,
        max_player = 4,
    },
}
return this
