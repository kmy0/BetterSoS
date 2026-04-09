local this = {
    ace = require("BetterSoS.data.ace"),
    mod = require("BetterSoS.data.mod"),
}

local e = require("BetterSoS.util.game.enum")
local game_lang = require("BetterSoS.util.game.lang")
local m = require("BetterSoS.util.ref.methods")
local s = require("BetterSoS.util.ref.singletons")
local util_game = require("BetterSoS.util.game.init")
local util_misc = require("BetterSoS.util.misc.init")
local util_ref = require("BetterSoS.util.ref.init")
local util_table = require("BetterSoS.util.misc.table")

local ace_map = this.ace.map

---@return app.ItemDef.ID[], app.ItemDef.ID[]
local function make_items()
    ---@type app.ItemDef.ID[]
    local judge_items = {}
    ---@type app.ItemDef.ID[]
    local special_items = {}

    for _, item_id in e.iter("app.ItemDef.ID") do
        local item_data = m.getItemData(item_id)

        if not item_data or not m.isValidItem(item_id) or not item_data:get_Special() then
            goto continue
        end

        local guid = item_data:get_RawName()
        local name_english = game_lang.get_message_local(guid, 1)

        if name_english:len() == 0 then
            goto continue
        end

        table.insert(special_items, item_id)
        ::continue::
    end

    local setting = s.get("app.VariousDataManager"):get_Setting()
    local exrewards = setting:get_ExQuestRewardSetting()

    util_game.do_something(exrewards._ArtianRewardTbl, function(_, _, value)
        table.insert(judge_items, value:get_RewardItem())
    end)

    util_game.do_something(exrewards._AmuletRewardTbl, function(_, _, value)
        table.insert(judge_items, value:get_RewardItem())
    end)

    util_game.do_something(exrewards._SkillGemRewardTbl, function(_, _, value)
        table.insert(judge_items, value:get_RewardItem())
    end)

    util_game.do_something(exrewards._ExjudgeEmRewardArray, function(_, _, value)
        table.insert(judge_items, value:get_ItemID())
    end)

    return util_table.sort(judge_items), util_table.sort(special_items)
end

---@return app.FieldDef.STAGE[]
local function make_maps()
    ---@type app.FieldDef.STAGE[]
    local ret = {}
    -- 10 = Rimechain Peak, 11 = Dragontorch Shrine, 13 = Forgotten Machineworks
    local non_main_stages = { 10, 11, 13 }
    for _, stage in e.iter("app.FieldDef.STAGE") do
        if
            m.isMainStage(stage)
            or m.isArenaStage(stage)
            or util_table.contains(non_main_stages, stage)
        then
            table.insert(ret, stage)
        end
    end

    return util_table.sort(ret)
end

---@return app.EnemyDef.ID[], table<app.EnemyDef.ID, app.EnemyDef.SPECIES>
local function make_monsters()
    ---@type app.EnemyDef.ID[]
    local ret = {}
    ---@type table<app.EnemyDef.ID, app.EnemyDef.SPECIES>
    local ret2 = {}
    for _, em_id in e.iter("app.EnemyDef.ID") do
        -- 33 = High Purrformance Barrel Puncher
        if em_id ~= 33 and m.isEmValid(em_id) and m.isBossID(em_id) then
            local species_fixed = m.getEmSpecies(em_id)
            local species = e.to_enum("app.EnemyDef.SPECIES", species_fixed)

            table.insert(ret, em_id)
            ret2[em_id] = species
        end
    end

    return util_table.sort(ret), ret2
end

---@return app.EnemyDef.SPECIES[]
local function make_species()
    ---@type app.EnemyDef.SPECIES[]
    local ret = {}
    local all_species = util_table.values(ace_map.monster_to_species)
    for _, species in e.iter("app.EnemyDef.SPECIES") do
        -- 20 = ??? omega
        if species ~= 20 and util_table.contains(all_species, species) then
            table.insert(ret, species)
        end
    end

    return util_table.sort(ret)
end

---@return app.EnvironmentType.ENVIRONMENT[]
local function make_environ()
    ---@type app.EnemyDef.SPECIES[]
    local ret = {}
    for _, environ in e.iter("app.EnvironmentType.ENVIRONMENT") do
        table.insert(ret, environ)
    end

    return util_table.sort(ret)
end

---@return app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING[]
local function make_multiplay_setting()
    ---@type app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING[]
    local ret = {}
    for _, setting in e.iter("app.net_quest_session.cCreateQuestSessionInfo.MULTIPLAY_SETTING") do
        table.insert(ret, setting)
    end

    return util_table.sort(ret)
end

---@return {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}?
local function make_SmartCampPicker_data()
    if not util_misc.mod_exists("smart_camp_picker") then
        return
    end

    local SmartCampPicker_config = json.load_file("SmartCampPicker/config.json") or {}
    if not SmartCampPicker_config.enabled then
        return
    end

    ---@type {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}?
    local ret = {}
    util_misc.try(function()
        ---@cast ret {[app.FieldDef.STAGE]: {[AreaId]: {CampId: integer}}}
        for _, stage in e.iter("app.FieldDef.STAGE") do
            local stage_data = json.load_file(
                string.format("SmartCampPicker/navmesh_distances/stage_%s.json", stage)
            )

            if stage_data then
                ---@cast stage_data {areas: {[string]: {distances: {[string]: integer}}}}
                for area, values in pairs(stage_data.areas) do
                    for camp_id, dist in pairs(values.distances) do
                        util_table.set_nested_value(
                            ret,
                            { stage, tonumber(area), tonumber(camp_id) },
                            dist
                        )
                    end
                end
            end
        end
    end, function(_)
        ret = nil
    end)

    return ret
end

---@param stage app.FieldDef.STAGE
---@param areas AreaId[]
---@param camp_ids CampId[]
---@return {[CampId]: integer}?
function this.get_camp_distances(stage, areas, camp_ids)
    if not ace_map.SmartCampPicker_data then
        return
    end

    ---@type {[CampId]: integer[]}
    local distances = {}
    for _, area in pairs(areas) do
        for _, camp_id in pairs(camp_ids) do
            local dist =
                util_table.get_nested_value(ace_map.SmartCampPicker_data, { stage, area, camp_id })
            if dist then
                util_table.insert_nested_value(distances, { camp_id }, dist)
            end
        end
    end

    if util_table.empty(distances) then
        return
    end

    ---@type {[CampId]: integer}
    local ret = {}
    for camp_id, dist in pairs(distances) do
        ret[camp_id] = math.min(table.unpack(dist))
    end

    return ret
end

---@return integer[]
local function make_ranks()
    ---@type integer[]
    local ret = {}
    for _, rank in e.iter("app.QuestDef.EM_REWARD_RANK") do
        table.insert(ret, rank)
    end

    return util_table.sort(ret)
end

---@return integer[]
local function make_grades()
    local max_grade = util_ref.types.get("app.EnemyDef"):get_field("MaxRewardGrade"):get_data() --[[@as integer]]
    ---@type integer[]
    local ret = {}
    for i = 1, max_grade do
        table.insert(ret, i)
    end

    return util_table.sort(ret)
end

---@return app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE[], table<app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE, app.MissionTypeList.TYPE[]>
local function make_search_type_to_quest_type()
    local e_search = e.get("app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE")
    local e_quest = e.get("app.MissionTypeList.TYPE")

    ---@type table<app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE, app.MissionTypeList.TYPE[]>
    local ret = {
        [e_search.MISSION] = { e_quest.MAINSTORY, e_quest.SIDESTORY },
        [e_search.KEEP] = { e_quest.KEEPQUEST, e_quest.INSTANTQUEST },
        [e_search.FREE] = { e_quest.FREEQUEST },
        [e_search.EVENT] = { e_quest.STREAM_EVENTQUEST, e_quest.STREAM_CHALLENGEQUEST },
    }

    return util_table.keys(ret), ret
end

---@return integer[], integer[]
local function make_player()
    local player = {}
    local player_max = {}

    for i = 2, ace_map.max_player do
        table.insert(player_max, i)
    end

    for i = 1, ace_map.max_player - 1 do
        table.insert(player, i)
    end

    return player, player_max
end

---@return boolean
function this.init()
    if not s.get("app.VariousDataManager") then
        return false
    end

    if
        not e.wrap_init(function()
            e.new("app.GUIID.ID")
            e.new("app.cGUI050000QuestSearchWindowCtrl.SEARCH_STATE")
            e.new("app.EnemyDef.LEGENDARY_ID")
            e.new("app.NETWORK_ERROR_CODE")
            e.new("app.GUIDefApp.NOTIFY_WINDOW_TYPE")
            e.new("app.net_session_manager.SESSION_TYPE")
            e.new("ace.GUIDef.SHUTDOWN_MODE")
            e.new("app.GUIDefApp.SHUTDOWN_TYPE")
            e.new("app.MissionTypeList.TYPE")
            e.new("app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE")
            e.new("app.cStartPointInfo.START_POINT_TYPE")
            e.new("app.GUI050000.QUEST_TYPE")
            e.new("app.MissionIDList.ID")
            e.new("app.cGUIQuestOrderParam.QUEST_START_TYPE")
            e.new("ace.ACE_PAD_KEY.BITS")
            e.new("ace.ACE_MKB_KEY.INDEX")
            e.new("app.NETWORK_REQUEST_LISTTYPE")
            e.new("app.NetworkRequest.TYPE")
            e.new("app.cGUIQuestOrderParam.QUEST_ORDER_FROM")
        end)
    then
        return false
    end

    ace_map.judge_items, ace_map.special_items = make_items()
    ace_map.monsters, ace_map.monster_to_species = make_monsters()
    ace_map.monster_species = make_species()
    ace_map.environ = make_environ()
    ace_map.maps = make_maps()
    ace_map.ranks = make_ranks()
    ace_map.grades = make_grades()
    ace_map.quest_type, ace_map.quest_type_map = make_search_type_to_quest_type()
    ace_map.SmartCampPicker_data = make_SmartCampPicker_data()
    ace_map.multiplay_setting = make_multiplay_setting()
    ace_map.max_hr =
        util_ref.types.get("app.BasicParamUtil"):get_field("MAX_HUNTER_RANK"):get_data()--[[@as integer]]
    ace_map.player, ace_map.player_max = make_player()

    return true
end

return this
