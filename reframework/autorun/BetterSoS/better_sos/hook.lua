local ace_player = require("BetterSoS.util.ace.player")
local config = require("BetterSoS.config.init")
local e = require("BetterSoS.util.game.enum")
local m = require("BetterSoS.util.ref.methods")
local routine_search = require("BetterSoS.better_sos.routine_search")
local s = require("BetterSoS.util.ref.singletons")
local util_mod = require("BetterSoS.util.mod.init")
local util_ref = require("BetterSoS.util.ref.init")

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
    if config.current.mod.enabled and not routine_search.has_instance() then
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

return this
