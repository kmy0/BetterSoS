local ace_player = require("BetterSoS.util.ace.player")
local config = require("BetterSoS.config.init")
local data = require("BetterSoS.data.init")
local e = require("BetterSoS.util.game.enum")
local m = require("BetterSoS.util.ref.methods")
local routine_search = require("BetterSoS.better_sos.routine_search")
local s = require("BetterSoS.util.ref.singletons")
local util_game = require("BetterSoS.util.game.init")
local util_mod = require("BetterSoS.util.mod.init")
local util_ref = require("BetterSoS.util.ref.init")

local ace_map = data.ace.map

local this = {}
local search_trigger = false

---@param args userdata[]
---@return boolean, app.NETWORK_ERROR_CODE
local function get_network_response(args)
    local success = util_ref.to_bool(args[3])
    local network_error = util_ref.to_int(args[4])
    local response = sdk.to_managed_object(args[5]) --[[@as System.Array<System.Byte>]]
    local err_man = s.get("app.NetworkManager"):get_ErrorManager()
    local tup = err_man:ConvertNetworkErrorMessage(network_error, response)
    return success, tup.Item1
end

function this.search_pre(args)
    if not config.current.mod.enabled then
        return
    end

    local search_info = sdk.to_managed_object(args[3]) --[[@as app.net_quest_session.cSearchQuestSessionInfo]]
    if search_info:get_Rescure() and not routine_search.has_instance() then
        local search_ctrl = sdk.to_managed_object(args[2]) --[[@as app.cGUI050000QuestSearchWindowCtrl]]
        search_ctrl._SearchState = e.get("app.cGUI050000QuestSearchWindowCtrl.SEARCH_STATE").NONE

        routine_search.new(util_mod.get_search_mode(), util_mod.make_quest_filter())
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.on_select_quest_pre(_)
    if
        config.current.mod.enabled
        and routine_search.has_instance()
        and routine_search.is_mode(routine_search.mode.AUTO_PICK)
    then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.update(_)
    if not config.current.mod.enabled then
        search_trigger = false
        return
    end

    if routine_search.has_instance() then
        routine_search.update()
        m.enablePlNoHit()
    elseif
        not search_trigger
        and util_mod.is_auto_search()
        and s.get("app.MissionManager"):get_IsQuestEndShowing()
        and not util_mod.is_quest_result_seamless()
    then
        search_trigger = true
    elseif search_trigger and ace_player.is_in_village() and m.canOpenStartMenu(false) then
        if util_mod.is_auto_search() then
            routine_search.new(util_mod.get_search_mode(), util_mod.make_quest_filter())
        end

        search_trigger = false
    end
end

function this.app_error_pre(args)
    if config.current.mod.enabled and routine_search.has_instance() then
        local err_man = sdk.to_managed_object(args[2]) --[[@as app.NetworkErrorManager]]
        local err_req = err_man:get_DisplayError()

        if err_req:get_Func() then
            m.callbackNetworkError(err_man, 0)
        end
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.search_callback_pre(args)
    if config.current.mod.enabled and routine_search.has_instance() then
        local o = routine_search.get_instance()
        local success, network_error = get_network_response(args)
        o:search_callback(success, network_error)
    end
end

function this.join_callback_pre(args)
    if config.current.mod.enabled and routine_search.has_instance() then
        local o = routine_search.get_instance()
        local success, network_error = get_network_response(args)
        o:join_callback(success, network_error)
    end
end

function this.inject_item_post(_)
    if not config.current.mod.enabled then
        return
    end

    local o = util_ref.get_this() --[[@as app.cGUI050000MemberSettingItemData.cQuestDifficultyData]]
    local choice_value = util_game.system_array_to_lua(o.ChoiceValueList)
    local choice_dif = util_game.system_array_to_lua(o.ChoiceDifficultyList)
    local choice_name = util_game.system_array_to_lua(o.ChoiseNameTextList)
    local guid_any = util_game.parse_guid(ace_map.guid_any)

    table.insert(choice_dif, -1)
    table.insert(choice_name, util_game.lang.get_message_local2(guid_any))
    table.insert(choice_value, -1)

    o.ChoiceDifficultyList = util_game.lua_array_to_system_array(
        choice_dif,
        "app.QuestDef.QUEST_DIFFICULTY_RESCUE_SEARCH_PARAM"
    )
    o.ChoiseNameTextList = util_game.lua_array_to_system_array(choice_name, "System.String")
    o.ChoiceValueList = util_game.lua_array_to_system_array(choice_value, "System.Int32")
end

function this.enable_index_post(_)
    if not config.current.mod.enabled then
        return
    end

    local o = util_ref.get_this() --[[@as app.cGUI050000MemberSettingItemData.cQuestDifficultyData]]
    local index = o.ChoiceValueList:IndexOf(-1)
    if index and not o.ActualEnableIndexList:Contains(-1) then
        o.ActualEnableIndexList:Insert(0, index)
    end
end

function this.get_quest_client_pre(args)
    if not config.current.mod.enabled then
        return
    end

    local quest_data = sdk.to_managed_object(args[2]) --[[@as app.user_data.QuestData]]
    util_ref.thread_store(quest_data:getMissionId())
end

function this.get_quest_client_post(retval)
    if not config.current.mod.enabled then
        return
    end

    local ret = sdk.to_managed_object(retval) --[[@as ace.cGUIMessageInfo]]
    local params = ret:get_Params()

    if params:get_Count() == 0 then
        local msg_id = ret:get_MsgID()
        local txt = util_game.lang.get_message_local2(msg_id)
        ret:set_MsgID(util_game.parse_guid(ace_map.guid_placeholder))
        ret:call(
            "addParam(System.String)",
            string.format(
                "%s %s",
                txt,
                string.format(config.lang:tr("misc.text_quest_id"), util_ref.thread_get())
            )
        )
    else
        local index = params:get_Count() - 1
        local param = params:get_Item(index)

        param.ParamString = string.format(
            "%s %s",
            param.ParamString,
            string.format(config.lang:tr("misc.text_quest_id"), util_ref.thread_get())
        )
        params:set_Item(index, param)
    end
end

return this
