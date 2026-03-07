---@class (exact) RoutineSearchQuest
---@field protected _state RoutineSearchQuestState
---@field protected _mode RoutineSearchQuestMode
---@field protected _actions table<RoutineSearchQuestState, fun(self: RoutineSearchQuest)>
---@field protected _backoff Timer
---@field protected _quests app.net_session_manager.SessionManager.cSearchResultQuest[]
---@field protected _dialog NotifyDialog?
---@field protected _GUI050000 app.GUI050000?
---@field protected _backoff_fn fun(): number
---@field protected _quest app.cGUIQuestViewData?
---@field protected _quest_filter QuestFilter
---@field protected _ignored_sessions table<string, boolean>

---@class RoutineSearchQuestHolder
---@field protected _instance RoutineSearchQuest?

---@class (exact) NotifyDialog
---@field type RoutineSearchQuestDialogType
---@field app app.cGUINotifyWindowInfoApp

local data = require("BetterSoS.data.init")
local e = require("BetterSoS.util.game.enum")
local m = require("BetterSoS.util.ref.methods")
local s = require("BetterSoS.util.ref.singletons")
local timer = require("BetterSoS.util.misc.timer")
local util_game = require("BetterSoS.util.game.init")
local util_misc = require("BetterSoS.util.misc.init")
local util_mod = require("BetterSoS.util.mod.init")
local util_ref = require("BetterSoS.util.ref.init")
local util_table = require("BetterSoS.util.misc.table")

local ace_map = data.ace.map

---@class RoutineSearchQuestHolder
local this = {}

---@class RoutineSearchQuest
local RoutineSearchQuest = {}
---@diagnostic disable-next-line: inject-field
RoutineSearchQuest.__index = RoutineSearchQuest

---@enum RoutineSearchQuestState
this.state = {
    SEARCH = 1,
    WAIT_SEARCH = 2,
    WAIT_BACKOFF = 3,
    FILTER_QUESTS = 4,
    LOAD_QUESTS = 5,
    WAIT_LOAD_QUESTS = 6,
    PICK_OR_START = 7,
    WAIT_JOIN = 8,
    START_QUEST = 9,
    SUCCESS = 10,
    END = 11,
    ERR = 12,
}
---@enum RoutineSearchQuestMode
this.mode = {
    SEARCH_ONLY = 1,
    AUTO_PICK = 2,
    AUTO_START = 3,
    AUTO_START_GO = 4,
}
---@enum RoutineSearchQuestDialogType
local dialog = {
    SEARCH = 1,
    JOIN = 2,
    ERR = 3,
}

---@param mode RoutineSearchQuestMode
---@param quest_filter QuestFilter
---@return RoutineSearchQuest
function RoutineSearchQuest:new(mode, quest_filter)
    local o = {
        _state = 1,
        _mode = mode,
        _quest_filter = quest_filter,
        _quests = {},
        _ignored_sessions = {},
        _actions = {
            [this.state.SEARCH] = RoutineSearchQuest._search,
            [this.state.WAIT_BACKOFF] = RoutineSearchQuest._wait_backoff,
            [this.state.FILTER_QUESTS] = RoutineSearchQuest._filter_quests,
            [this.state.WAIT_SEARCH] = RoutineSearchQuest._do_nothing,
            [this.state.LOAD_QUESTS] = RoutineSearchQuest._load_quests,
            [this.state.WAIT_LOAD_QUESTS] = RoutineSearchQuest._wait_load_quests,
            [this.state.PICK_OR_START] = RoutineSearchQuest._pick_or_start,
            [this.state.WAIT_JOIN] = RoutineSearchQuest._do_nothing,
            [this.state.START_QUEST] = RoutineSearchQuest._start_quest,
            [this.state.SUCCESS] = RoutineSearchQuest._success,
            [this.state.ERR] = RoutineSearchQuest._do_nothing,
        },
        _GUI050000 = util_mod.get_gui_cls("app.GUI050000"),
        _backoff = timer:new(0),
        _backoff_fn = util_misc.make_backoff(nil, 6.0, true),
    }
    ---@cast o RoutineSearchQuest
    setmetatable(o, self)
    return o
end

---@protected
---@param next_state RoutineSearchQuestState
function RoutineSearchQuest:_set_state(next_state)
    self._state = next_state
end

function RoutineSearchQuest:can_cancel()
    return self._state < this.state.START_QUEST
        and self._state ~= this.state.PICK_OR_START
        and self._state ~= this.state.LOAD_QUESTS
end

---@param dialog_type RoutineSearchQuestDialogType
function RoutineSearchQuest:_open_dialog(dialog_type)
    if self._dialog then
        if self._dialog.type == dialog_type then
            return
        elseif self._dialog.type ~= dialog.ERR then
            util_mod.close_text_dialog()
        end
    end

    if dialog_type == dialog.ERR then
        self._dialog = {
            type = dialog_type,
            app = util_mod.open_confirm_dialog(
                util_game.parse_guid(ace_map.guid_no_quests),
                util_game.parse_guid(ace_map.guid_close)
            ),
        }
    elseif dialog_type == dialog.SEARCH then
        self._dialog = {
            type = dialog_type,
            app = util_mod.open_text_dialog(util_game.parse_guid(ace_map.guid_searching)),
        }
    elseif dialog_type == dialog.JOIN then
        self._dialog = {
            type = dialog_type,
            app = util_mod.open_text_dialog(util_game.parse_guid(ace_map.guid_join_quest)),
        }
    end
end

---@protected
function RoutineSearchQuest:_do_nothing() end

---@protected
function RoutineSearchQuest:_search()
    self:_open_dialog(dialog.SEARCH)

    local search_info = util_mod.get_search_info()
    local action = ref_system_action.create_action(
        "System.Action`2<System.Boolean,app.NETWORK_ERROR_CODE>",
        function(success, error_code)
            if
                util_ref.to_bool(success)
                and util_ref.to_int(error_code) == e.get("app.NETWORK_ERROR_CODE").NONE
            then
                self:_set_state(this.state.FILTER_QUESTS)
            else
                self:_set_state(this.state.ERR)
            end
        end
    )

    local req_man = s.get("app.NetworkManager"):get_RequestManager()
    req_man:searchSession(e.get("app.net_session_manager.SESSION_TYPE").QUEST, search_info, action)
    self:_set_state(this.state.WAIT_SEARCH)
    self._backoff:restart(self:_backoff_fn())
end

---@protected
function RoutineSearchQuest:_wait_backoff()
    if not self._backoff:active() then
        self:_set_state(this.state.SEARCH)
    end
end

---@protected
function RoutineSearchQuest:_filter_quests()
    local req_man = s.get("app.NetworkManager"):get_RequestManager()
    local quest_sess = req_man._QuestSession
    quest_sess:applyFilterForSearchResult()
    self._quests = util_mod.get_search_result(self._quest_filter, self._ignored_sessions)

    if #self._quests > 0 then
        self:_set_state(this.state.LOAD_QUESTS)
    else
        self:_set_state(this.state.WAIT_BACKOFF)
    end
end

function RoutineSearchQuest:_load_quests()
    if
        self._GUI050000
        and self._mode ~= this.mode.AUTO_START
        and self._mode ~= this.mode.AUTO_START_GO
    then
        local ctx = self._GUI050000:get_ViewFlowContext()
        m.loadQuestsAfterSearch(ctx)
        ctx.IsNextFlow = true

        self:_set_state(this.state.WAIT_LOAD_QUESTS)
    else
        self:_set_state(this.state.PICK_OR_START)
    end
end

function RoutineSearchQuest:_wait_load_quests()
    if self._GUI050000 then
        local quest_list_parts = self._GUI050000._QuestListParts
        if quest_list_parts:get_IsActive() then
            self:_set_state(this.state.PICK_OR_START)
        end
    else
        self:_set_state(this.state.PICK_OR_START)
    end
end

function RoutineSearchQuest:_pick_or_start()
    if self._mode == this.mode.AUTO_START or self._mode == this.mode.AUTO_START_GO then
        self:_open_dialog(dialog.JOIN)

        local quest = util_table.pick_random_value(self._quests)
        if not quest then
            self:_set_state(this.state.ERR)
            return
        end

        local gui_quest_view = util_ref.ctor("app.cGUIQuestViewData", true)
        gui_quest_view:add_ref()
        gui_quest_view:call(
            ".ctor(app.net_session_manager.SessionManager.cSearchResultQuest)",
            quest
        )
        self._quest = gui_quest_view

        local host_id = gui_quest_view.Session:getHostHunterID()
        local session_id = quest.questSessionId
        local is_rescue = true
        local quest_id = quest.questId
        local password = ""
        local join_sess_info = util_ref.ctor("app.net_quest_session.cJoinQuestSessionInfo", true)

        join_sess_info:add_ref()
        join_sess_info:call(
            ".ctor(System.String, System.Boolean, System.Int32, System.Guid, System.String)",
            session_id,
            is_rescue,
            quest_id,
            host_id,
            password
        )

        local action = ref_system_action.create_action(
            "System.Action`2<System.Boolean,app.NETWORK_ERROR_CODE>",
            function(success, error_code)
                if
                    util_ref.to_bool(success)
                    and util_ref.to_int(error_code) == e.get("app.NETWORK_ERROR_CODE").NONE
                then
                    self:_set_state(this.state.START_QUEST)
                else
                    self._ignored_sessions[quest.questSessionId] = true
                    self:_set_state(this.state.WAIT_BACKOFF)
                end
            end
        )

        local req_man = s.get("app.NetworkManager"):get_RequestManager()
        req_man:call(
            "joinSession(app.net_session_manager.SESSION_TYPE, app.net_session_manager.cJoinSessionInfo, System.Action`2<System.Boolean,app.NETWORK_ERROR_CODE>)",
            e.get("app.net_session_manager.SESSION_TYPE").QUEST,
            join_sess_info,
            action
        )

        self:_set_state(this.state.WAIT_JOIN)
    elseif self._GUI050000 and self._mode == this.mode.AUTO_PICK then
        local quest_list_parts = self._GUI050000._QuestListParts
        local quest_list = quest_list_parts:get_ViewQuestDataList()
        local quest = util_table.pick_random_value(util_game.system_array_to_lua(quest_list))

        if not quest then
            self:_set_state(this.state.ERR)
            return
        end

        quest_list_parts:updateQuestDetailWindow(quest)
        quest_list_parts:decideQuest(quest)

        self:_set_state(this.state.SUCCESS)
    elseif self._mode == this.mode.AUTO_PICK then
        local quest = util_table.pick_random_value(self._quests)
        if not quest then
            self:_set_state(this.state.ERR)
            return
        end

        s.get("app.GUIManager"):acceptQuestFromSearchResult(
            quest,
            e.get("app.cGUIQuestOrderParam.QUEST_ORDER_FROM").MAP_INSTANCE_QUEST,
            e.get("app.cGUIQuestOrderParam.QUEST_START_TYPE").QUEST_COUNTER,
            0
        )
        self:_set_state(this.state.SUCCESS)
    else
        self:_set_state(this.state.SUCCESS)
    end
end

function RoutineSearchQuest:_start_quest()
    if not self._quest then
        self:_set_state(this.state.ERR)
        return
    end

    local user_manager = s.get("app.NetworkManager"):get_UserInfoManager()
    local host_info =
        user_manager:getHostUserInfo(e.get("app.net_session_manager.SESSION_TYPE").QUEST) --[[@as app.Net_QuestUserInfo]]
    local keep_quest_data = host_info:get_KeepQuestData()

    ---@type app.cActiveQuestData
    local quest_data
    if keep_quest_data then
        -- investigation
        quest_data = util_ref.ctor("app.cActiveQuestData", true)
        quest_data:call(".ctor(app.cKeepQuestData)", keep_quest_data)
    else
        -- story, optional, etc.
        local quest_id = self._quest:get_MissionID()
        quest_data = s.get("app.MissionManager"):getQuestDataFromMissionId(quest_id)

        -- event
        if not quest_data then
            quest_data = s.get("app.MissionManager"):getStreamQuestDataFromID(quest_id) --[[@as app.cActiveQuestData]]
        end
    end

    if not quest_data then
        self:_set_state(this.state.ERR)
        return
    end

    self._quest:set_ActiveQuestData(quest_data)

    local quest_search = self._quest.Session:get_SearchResult()
    local start_point = util_mod.get_closest_starting_point(
        quest_search.fieldId,
        self._quest:get_TargetEmStartArea(),
        quest_search.campList
    )

    local host_id = self._quest.Session:getHostHunterID()
    local quest_arg = util_ref.ctor("app.cQuestAcceptArg", true)
    local accepted_time = 0
    quest_arg:add_ref()
    quest_arg:call(
        ".ctor(app.cStartPointInfo, System.Guid, System.Int64)",
        start_point,
        host_id,
        accepted_time
    )
    quest_arg.StartType = e.get("app.cGUIQuestOrderParam.QUEST_START_TYPE").QUEST_COUNTER
    quest_arg.IsJoinRescue = true

    local quest_order_param = util_ref.ctor("app.cGUIQuestOrderParam", true)
    quest_order_param:add_ref()
    quest_order_param.QuestType = util_mod.get_gui50000_quest_type(self._quest:get_MissionID())
    quest_order_param.ActiveQuestData = quest_data
    quest_order_param.QuestViewData = self._quest
    quest_order_param.IsOnline = true
    quest_order_param.IsJoinRescue = true
    quest_order_param.SelectStartPointInfo = start_point

    local quest_director = s.get("app.MissionManager"):get_QuestDirector()
    quest_director:acceptQuest(quest_data, quest_arg, false, false)
    s.get("app.GUIManager")
        :setQuestOrderParam(quest_order_param, self._mode == this.mode.AUTO_START_GO)

    self:_set_state(this.state.SUCCESS)
end

function RoutineSearchQuest:_go_quest()
    if self._mode == this.mode.AUTO_START_GO then
        local quest_director = s.get("app.MissionManager"):get_QuestDirector()
        quest_director:goQuest(false, false, true, false)
    end

    self:_set_state(this.state.SUCCESS)
end

function RoutineSearchQuest:_success()
    if self._mode == this.mode.AUTO_START_GO or self._mode == this.mode.AUTO_START then
        util_mod.close_all_menu()
    else
        util_mod.close_text_dialog()
    end

    self:_set_state(this.state.END)
end

---@return boolean?
function RoutineSearchQuest:update()
    self._actions[self._state](self)

    if self._state == this.state.ERR then
        self:abort()
        return
    end

    if self._state == this.state.END then
        return false
    end

    return true
end

function RoutineSearchQuest:abort()
    local req_man = s.get("app.NetworkManager"):get_RequestManager()
    local request = req_man:FindTargetRequest(e.get("app.NETWORK_REQUEST_LISTTYPE").SESSION)

    if request and util_ref.is_a(request, "app.NetAbortableRequest") then
        ---@cast request app.NetAbortableRequest
        request:set_IsAbort(true)
    end

    req_man:leaveSession(e.get("app.net_session_manager.SESSION_TYPE").QUEST, 0, false)

    if self._GUI050000 then
        local ctx = self._GUI050000:get_ViewFlowContext()
        ctx.IsCancel = true
        ctx.IsSearchFailed = true
    end
    self:_open_dialog(dialog.ERR)
end

---@param mode RoutineSearchQuestMode
---@param quest_filter QuestFilter
---@return boolean?
function this.new(mode, quest_filter)
    if this._instance then
        return
    end

    this._instance = RoutineSearchQuest:new(mode, quest_filter)
    return true
end

---@return boolean
function this.has_instance()
    return this._instance ~= nil
end

function this.update()
    util_misc.try(function()
        local res = this._instance:update()
        if res == nil then
            this.clear()
        elseif not res then
            this._instance = nil
        end
    end, function(err)
        log.debug(err)
        this.abort()
    end)
end

---@return RoutineSearchQuestState
function this.get_state()
    ---@diagnostic disable-next-line: invisible
    return this._instance._state
end

function this.get_mode()
    ---@diagnostic disable-next-line: invisible
    return this._instance._mode
end

---@return RoutineSearchQuest
function this.get_instance()
    return this._instance
end

---@param state RoutineSearchQuestState
---@return boolean
function this.is_state(state)
    return state == this.get_state()
end

---@param mode RoutineSearchQuestMode
---@return boolean
function this.is_mode(mode)
    return mode == this.get_mode()
end

function this.can_cancel()
    return this._instance:can_cancel()
end

function this.abort()
    if this.has_instance() then
        this._instance:abort()
        this.clear()
    end
end

function this.clear()
    if this.has_instance() then
        this._instance = nil
    end
end

return this
