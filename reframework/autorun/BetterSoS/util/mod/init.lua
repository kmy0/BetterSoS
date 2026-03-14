local config = require("BetterSoS.config.init")
local data = require("BetterSoS.data.init")
local e = require("BetterSoS.util.game.enum")
local m = require("BetterSoS.util.ref.methods")
local s = require("BetterSoS.util.ref.singletons")
local state = require("BetterSoS.gui.state")
local util_game = require("BetterSoS.util.game.init")
local util_ref = require("BetterSoS.util.ref.init")
local util_table = require("BetterSoS.util.misc.table")

local ace_map = data.ace.map
local mod_enum = data.mod.enum

local this = {}

---@return QuestFilter
function this.make_quest_filter()
    local config_mod = config.current.mod
    ---@type table<app.MissionTypeList.TYPE, boolean>?
    local quest_type

    if config_mod.ignore_type then
        quest_type = {}
        for e_string, _ in pairs(config_mod.type) do
            local e_enum = tonumber(e_string) --[[@as app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE]]
            for _, mission_type in pairs(ace_map.quest_type_map[e_enum]) do
                quest_type[mission_type] = true
            end
        end
    end

    ---@type QuestFilter
    return {
        passcode = config_mod.ignore_passcode,
        manualaccept = config_mod.ignore_manualaccept,
        time = config_mod.ignore_time and config_mod.slider_time or nil,
        time_limit = config_mod.ignore_time_limit and config_mod.slider_time_limit or nil,
        player = config_mod.ignore_player and config_mod.slider_player or nil,
        player_max = config_mod.ignore_player_max and config_mod.slider_player_max or nil,
        rank = config_mod.ignore_rank and util_table.map_table(config_mod.rank, function(o)
            return tonumber(o)
        end) or nil,
        host_hr = config_mod.ignore_host_hr
                and { config_mod.slider_host_hr_lower, config_mod.slider_host_hr_upper }
            or nil,
        map = config_mod.ignore_map and util_table.map_table(config_mod.map, function(o)
            return tonumber(o)
        end) or nil,
        environ = config_mod.ignore_environ
                and util_table.map_table(config_mod.environ, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_target = config_mod.ignore_monster_target
                and util_table.map_table(config_mod.monster_target, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_state = config_mod.ignore_monster_state
                and util_table.map_table(config_mod.monster_state, function(o)
                    return util_table.reverse_lookup(mod_enum.monster_state, tonumber(o))
                end)
            or nil,
        monster = config_mod.ignore_monster
                and util_table.map_table(config_mod.monster, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_species = config_mod.ignore_monster_species
                and util_table.map_table(config_mod.monster_species, function(o)
                    return tonumber(o)
                end)
            or nil,
        monster_grade = config_mod.ignore_monster_grade
                and util_table.map_table(config_mod.monster_grade, function(o)
                    return tonumber(o)
                end)
            or nil,
        boost = config_mod.require_boost,
        item_wishlist = config_mod.require_item_wishlist,
        item_wishlist_any = config_mod.require_item_wishlist_any,
        item_rare = config_mod.require_item_rare,
        item_judge = config_mod.require_item_judge and tonumber(
            state.combo.item:get_key(config_mod.combo_item_judge)
        ) or nil,
        type = quest_type,
        multiplay_setting = config_mod.ignore_multiplay_setting
                and util_table.map_table(config_mod.multiplay_setting, function(o)
                    return tonumber(o)
                end)
            or nil,
    }
end

---@param quest app.net_session_manager.SessionManager.cSearchResultQuest
---@param quest_filter QuestFilter
---@return boolean
function this.predicate_quest(quest, quest_filter)
    if
        (quest_filter.passcode and quest.isLocked)
        or (quest_filter.manualaccept and not quest.isAutoAccept)
    then
        return false
    end

    if
        quest_filter.multiplay_setting and quest_filter.multiplay_setting[quest.multiplaySetting]
    then
        return false
    end

    if quest_filter.time then
        if quest.startedAt > 0 and (os.time() - quest.startedAt) / 60 > quest_filter.time then
            return false
        elseif (os.time() - quest.acceptedAt) / 60 > quest_filter.time then
            return false
        end
    end

    if quest_filter.time_limit and quest_filter.time_limit > quest.questTimeLimit then
        return false
    end

    if
        (quest_filter.player and quest.maxMemberNum - quest.memberNum < quest_filter.player)
        or (quest_filter.player_max and quest.maxMemberNum < quest_filter.player_max)
    then
        return false
    end

    if quest_filter.rank and quest_filter.rank[quest.questLevel] then
        return false
    end

    if quest_filter.host_hr then
        local host = quest:getHostHunterInfo()
        local hr = host.hr

        if hr < quest_filter.host_hr[1] or hr > quest_filter.host_hr[2] then
            return false
        end
    end

    if
        (quest_filter.map and quest_filter.map[quest.fieldId])
        or (quest_filter.environ and quest_filter.environ[quest.envType])
    then
        return false
    end

    if quest_filter.monster_target then
        local len = quest.targetMonster:get_Length()
        if
            (quest_filter.monster_target[mod_enum.monster_target.SMALL] and len == 0)
            or (quest_filter.monster_target[mod_enum.monster_target.SINGLE] and len == 1)
            or (quest_filter.monster_target[mod_enum.monster_target.MULTI] and len > 1)
        then
            return false
        end
    end

    if
        quest_filter.monster
        or quest_filter.monster_state
        or quest_filter.monster_species
        or quest_filter.monster_grade
    then
        ---@type boolean?
        local match
        util_game.do_something_limited(quest.targetMonster, function(_, _, value)
            if
                (quest_filter.monster_grade and quest_filter.monster_grade[value.Grade])
                or (quest_filter.monster and quest_filter.monster[value.Id])
                or (
                    quest_filter.monster_species
                    and quest_filter.monster_species[ace_map.monster_to_species[value.Id]]
                )
            then
                match = true
                return false
            end

            if quest_filter.monster_state then
                local legendary = e.get("app.EnemyDef.LEGENDARY_ID")[value.LegendaryId]
                local role = e.get("app.EnemyDef.ROLE_ID")[value.RoleId]

                if
                    quest_filter.monster_state[legendary]
                    or (role ~= "NORMAL" and quest_filter.monster_state[role])
                then
                    match = true
                    return false
                end
            end
        end)

        if match then
            return false
        end
    end

    local quest_type = s.get("app.MissionManager"):getMissionTypeFromID(quest.questId)
    if quest_filter.type and quest_filter.type[quest_type] then
        return false
    end

    local has_wishlisted_items = this.any_wishlisted()
    local is_investigation = this.is_investigation(quest_type)
    if quest_filter.item_wishlist_any and has_wishlisted_items then
        local any_wishlist = false

        util_game.do_something_limited(quest.targetMonster, function(_, _, value)
            if is_investigation then
                any_wishlist = m.isExQuestRequiredForWishlist(
                    quest.exRewards._Array,
                    value.Id,
                    value.RoleId,
                    value.LegendaryId,
                    quest.questRank,
                    quest.questLevel,
                    true
                )
            else
                any_wishlist = m.isQuestRequiredForWishlist(quest.questId, quest.questRank)
                    or any_wishlist
                any_wishlist = m.isEnemyRequiredForWishlist(value.Id, quest.questRank)
                    or any_wishlist
            end

            if any_wishlist then
                return false
            end
        end)

        if not any_wishlist then
            return false
        end
    end

    if is_investigation then
        if quest_filter.boost and not quest.isBoost then
            return false
        end

        if
            (quest_filter.item_wishlist and has_wishlisted_items)
            or quest_filter.item_rare
            or quest_filter.item_judge
        then
            local any_wishlisted = false
            local any_judge = false
            local any_rare = false

            util_game.do_something_limited(quest.exRewards, function(_, _, value)
                local item = value:get_ItemId()

                if quest_filter.item_judge and not any_judge then
                    any_judge = quest_filter.item_judge == item
                end

                if (quest_filter.item_wishlist and has_wishlisted_items) and not any_wishlisted then
                    any_wishlisted = m.isItemWishlisted(item)
                end

                if quest_filter.item_rare and not any_rare then
                    any_rare = util_table.contains(ace_map.special_items, item)
                end
            end)

            if
                (quest_filter.item_wishlist and has_wishlisted_items and not any_wishlisted)
                or (quest_filter.item_rare and not any_rare)
                or (quest_filter.item_judge and not any_judge)
            then
                return false
            end
        end
    end

    return true
end

---@param quest_type app.MissionTypeList.TYPE
---@return boolean
function this.is_investigation(quest_type)
    local keep_types = ace_map.quest_type_map[e.get(
        "app.net_quest_session.cSearchQuestSessionInfo.SEARCH_QUEST_TYPE"
    ).KEEP]

    return util_table.contains(keep_types, quest_type)
end

function this.close_all_menu()
    s.get("app.GUIManager"):shutdownGUIWithType(
        e.get("app.GUIDefApp.SHUTDOWN_TYPE").CLOSE_ALL_MENU,
        e.get("ace.GUIDef.SHUTDOWN_MODE").FORCE_CLOSE
    )
end

---@generic T
---@param type `T` app.GUIXXXXXX
---@return T
function this.get_gui_cls(type)
    return s.get("app.GUIManager"):getGUI(e.get("app.GUIID.ID")[string.sub(type, 6)])
end

---@return app.net_quest_session.cSearchQuestSessionInfo
function this.get_search_info()
    local GUI050000 = this.get_gui_cls("app.GUI050000")
    local ret = util_ref.ctor("app.net_quest_session.cSearchQuestSessionInfo")
    ret:add_ref()

    ---@type app.GUI050000PartsBase.cRescueSearchSettingParamHolder | app.savedata.cQuestRecruteSearchSetting
    local params
    if GUI050000 then
        params = GUI050000:getRescueSearchSettingHolder()
    else
        local savedata = s.get("app.SaveDataManager"):getCurrentUserSaveData()
        params = savedata:get_QuestRecruteSearchSetting()
    end

    local target =
        m.getRescueTargetInfo(params.RescueSearchTargetID, params.RescueSearchTargetRoleID)
    ret:set_Rescure(true)
    ret:set_IsLink(false)
    ret:set_Target(target)
    ret:set_QuestType(params.RescueSearchQuestType)
    ret:set_QuestDifficulty(params.RescueSearchDifficulty)
    ret:set_IsSameLanguage(params.RescueSearchLanguage == 0)
    ret:set_IsSamePlatform(params.RescueSearchPlatform == 1)
    ret:set_NeedMemberNum(-1)
    ret.FieldId = params.RescueSearchFieldID

    return ret
end

---@return boolean
function this.any_wishlisted()
    local savedata = s.get("app.SaveDataManager"):getCurrentUserSaveData()
    local equip = savedata:get_Equip()
    local wishlist = equip:get_Wishlist()
    return wishlist:getEntryCount() > 0
end

---@param quest_filter QuestFilter
---@param ignored_sessions table<string, boolean>?
---@return app.net_session_manager.SessionManager.cSearchResultQuest[]
function this.get_search_result(quest_filter, ignored_sessions)
    ---@type app.net_session_manager.SessionManager.cSearchResultQuest[]
    local ret = {}

    ignored_sessions = ignored_sessions or {}
    local req_man = s.get("app.NetworkManager"):get_RequestManager()
    local quest_sess = req_man._QuestSession
    local quest_tbl = quest_sess._SearchResultTblQuest
    local limited_array = quest_tbl.SearchResult
    local int32 = util_ref.value_type("System.Int32")

    util_game.do_something_limited(limited_array, function(_, _, value)
        if not value then
            return
        end

        local session_id = value.questSessionId
        if ignored_sessions[session_id] then
            value.questId = -1
        end

        if
            m.isQuestAcceptable(int32:address(), value)
            and this.predicate_quest(value, quest_filter)
        then
            table.insert(ret, value)
        else
            value.questId = -1
            ignored_sessions[session_id] = true
        end
    end)

    return ret
end

function this.is_quest_result_seamless()
    local quest_dir = s.get("app.MissionManager"):get_QuestDirector()
    local param = quest_dir:get_Param()
    return param.IsResultSeamless
end

---@param quest_id app.MissionIDList.ID
---@return app.GUI050000.QUEST_TYPE
function this.get_gui50000_quest_type(quest_id)
    -- app_GUI050000QuestListParts__getQuestViewDataList_NetSearch
    local ret = e.get("app.GUI050000.QUEST_TYPE").KEEP_QUEST

    if quest_id == e.get("app.MissionIDList.ID").MISSION_50001 then
        ret = e.get("app.GUI050000.QUEST_TYPE").GUEST_KEEP_QUEST
    elseif quest_id == e.get("app.MissionIDList.ID").MISSION_50002 then
        ret = e.get("app.GUI050000.QUEST_TYPE").GUEST_DECLARATION_QUEST
    end

    return ret
end

---@param stage app.FieldDef.STAGE
---@param camps System.Int16
---@return app.cStartPointInfo[]
function this.get_starting_points(stage, camps)
    -- app_GUI050001__initStartPoint
    ---@type app.cStartPointInfo[]
    local ret = {}

    ---@param start_point_type app.cStartPointInfo.START_POINT_TYPE
    ---@param gm_id app.GimmickDef.ID
    ---@param camp_id System.Int32
    ---@return app.cStartPointInfo
    local function start_point_ctor(start_point_type, gm_id, camp_id)
        local start_point = util_ref.ctor("app.cStartPointInfo", true)

        start_point:add_ref()
        start_point:call(
            ".ctor(app.cStartPointInfo.START_POINT_TYPE, app.GimmickDef.ID, System.Int32, app.PlayerDef.LAYOUT_ID)",
            start_point_type,
            gm_id,
            camp_id,
            -1
        )

        return start_point
    end

    local camp_man = s.get("app.GimmickManager"):get_CampManager()
    local camp_arr =
        camp_man:call("getQuestStartPointInfoList(app.FieldDef.STAGE, System.Int16)", stage, camps) --[[@as System.Array<app.cCampManager.TentQuestStartPointInfo>]]

    util_game.do_something(camp_arr, function(_, _, value)
        local camp_id = value:get_CampID()
        local start_point = start_point_ctor(
            e.get("app.cStartPointInfo.START_POINT_TYPE").TENT,
            m.getGmIDFromSimpleCampID(camp_id, stage),
            camp_id
        )

        table.insert(ret, start_point)
    end)

    local base_start_point = start_point_ctor(
        e.get("app.cStartPointInfo.START_POINT_TYPE").BASE_CAMP,
        m.getStageBaseCampGmID(stage),
        0
    )
    table.insert(ret, base_start_point)
    return ret
end

---@param stage app.FieldDef.STAGE
---@return app.cStartPointInfo
function this.get_base_starting_point(stage)
    local ret = util_ref.ctor("app.cStartPointInfo", true)

    ret:add_ref()
    ret:call(
        ".ctor(app.cStartPointInfo.START_POINT_TYPE, app.GimmickDef.ID, System.Int32, app.PlayerDef.LAYOUT_ID)",
        e.get("app.cStartPointInfo.START_POINT_TYPE").BASE_CAMP,
        m.getStageBaseCampGmID(stage),
        0,
        -1
    )

    return ret
end

---@param stage app.FieldDef.STAGE
---@param target_em_area System.Array<System.Int32>
---@param camps System.Int16
---@return app.cStartPointInfo
function this.get_closest_starting_point(stage, target_em_area, camps)
    local starting_points = this.get_starting_points(stage, camps)
    local camp_ids = util_table.map_table(starting_points, function(o)
        return starting_points[o].CampID
    end) --[[@as {[CampId]: app.cStartPointInfo}]]

    local distances = data.get_camp_distances(
        stage,
        util_game.system_array_to_lua(target_em_area),
        util_table.keys(camp_ids)
    )

    if not distances then
        return this.get_base_starting_point(stage)
    end

    local sorted_distances = util_table.sort(util_table.keys(distances), function(a, b)
        return distances[a] < distances[b]
    end)
    local closest_camp = sorted_distances[1]
    return camp_ids[closest_camp]
end

---@return boolean
function this.is_auto_start_quest()
    local config_mod = config.current.mod

    return (
        config_mod.auto_start_quest == mod_enum.auto_start_quest.START_AND_DEPART
        or config_mod.auto_start_quest == mod_enum.auto_start_quest.START_AND_PREP
    )
        and config_mod.ignore_manualaccept
        and config_mod.ignore_passcode
end

---@return boolean
function this.is_auto_search()
    local config_mod = config.current.mod

    return (
        this.is_auto_start_quest()
        or config_mod.auto_start_quest == mod_enum.auto_start_quest.PICK
    ) and config_mod.auto_search == mod_enum.auto_search_quest.SEARCH
end

---@return RoutineSearchQuestMode
function this.get_search_mode()
    local config_mod = config.current.mod
    local routine_search = require("BetterSoS.better_sos.routine_search")

    if this.is_auto_start_quest() then
        if config_mod.auto_start_quest == mod_enum.auto_start_quest.START_AND_PREP then
            return routine_search.mode.AUTO_START
        elseif config_mod.auto_start_quest == mod_enum.auto_start_quest.START_AND_DEPART then
            return routine_search.mode.AUTO_START_GO
        end
    elseif config_mod.auto_start_quest == mod_enum.auto_start_quest.PICK then
        return routine_search.mode.AUTO_PICK
    end

    return routine_search.mode.SEARCH_ONLY
end

function this.close_current_notify_window()
    local notify = s.get("app.GUIManager"):getNotifyWindowModule()
    notify:closeGUI()
end

function this.close_text_dialog()
    local notify = s.get("app.GUIManager"):getNotifyWindowModule()
    notify:shutdownNotifyWindows(
        e.get("app.GUIDefApp.SHUTDOWN_TYPE").CLOSE_ALL_MENU,
        e.get("ace.GUIDef.SHUTDOWN_MODE").FORCE_CLOSE
    )
end

---@param window_type app.GUIDefApp.NOTIFY_WINDOW_TYPE
---@return app.cGUINotifyWindowInfoApp
function this.get_info_window_app(window_type)
    local ret = util_ref.ctor("app.cGUINotifyWindowInfoApp")
    ret:call(".ctor(app.GUIDefApp.NOTIFY_WINDOW_TYPE)", window_type)
    local obj = util_ref.ctor("System.Object")
    ret:set_Caller(obj)
    ret:set_DispMinTime(math.huge)
    return ret
end

---@param text_guid System.Guid
---@return app.cGUINotifyWindowInfoApp
function this.open_text_dialog(text_guid)
    local app = this.get_info_window_app(e.get("app.GUIDefApp.NOTIFY_WINDOW_TYPE").TEXT_ONLY)
    local text = app:get_TextInfo()
    text:setMessageInfo(text_guid)

    s.get("app.GUIManager"):requestNotifyWindow(app)
    return app
end

---@param text_guid System.Guid
---@param confirm_guid System.Guid
---@return app.cGUINotifyWindowInfoApp
function this.open_confirm_dialog(text_guid, confirm_guid)
    local app = this.get_info_window_app(e.get("app.GUIDefApp.NOTIFY_WINDOW_TYPE").CONFIRM)
    local text = app:get_TextInfo()
    text:setMessageInfo(text_guid)
    text = app:get_ChoisesTextInfo()[0]
    text:setMessageInfo(confirm_guid)

    s.get("app.GUIManager"):requestNotifyWindow(app)
    return app
end

return this
