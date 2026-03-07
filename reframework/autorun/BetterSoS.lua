local bind = require("BetterSoS.bind.init")
local config = require("BetterSoS.config.init")
local config_menu = require("BetterSoS.gui.init")
local data = require("BetterSoS.data.init")
local hook = require("BetterSoS.better_sos.hook")
local routine_search = require("BetterSoS.better_sos.routine_search")
local util = require("BetterSoS.util.init")
local logger = util.misc.logger.g
---@class MethodUtil
local m = require("BetterSoS.util.ref.methods")

local init = util.misc.init_chain:new(
    "MAIN",
    config.init,
    data.init,
    config_menu.init,
    bind.init,
    data.mod.init
)
local mod = data.mod

m.getRescueTargetInfo = m.wrap(
    m.get(
        "app.GUIUtilApp.QuestUtil.getRescueTargetInfo(System.Int32, app.QuestDef.QUEST_SEARCH_PARAM_ROLE_ID)"
    )
) --[[@as fun(target: System.Int32, role: app.QuestDef.QUEST_SEARCH_PARAM_ROLE_ID): app.net_quest_session.cSearchQuestSessionInfo.cTargetInfo]]
m.getItemData = m.wrap(m.get("app.ItemDef.Data(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): app.user_data.ItemData.cData]]
m.isValidItem = m.wrap(m.get("app.ItemDef.isValidItem(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Boolean]]
m.isBossID = m.wrap(m.get("app.EnemyDef.isBossID(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Boolean]]
m.isEmValid = m.wrap(m.get("app.EnemyDef.isValid(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Boolean]]
m.getEnemyNameGuid = m.wrap(m.get("app.EnemyDef.EnemyName(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): System.Guid]]
m.isJudgeItem = m.wrap(m.get("app.ItemUtil.isJudgeItem(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Boolean]]
m.getStageNameGuid =
    m.wrap(m.get("app.GUIUtilApp.MapUtil.getStageFullName(app.FieldDef.STAGE, System.Guid)")) --[[@as fun(stage: app.FieldDef.STAGE, guid_ptr: integer): System.Boolean]]
m.isMainStage = m.wrap(m.get("app.FieldUtil.isMainStage(app.FieldDef.STAGE)")) --[[@as fun(stage: app.FieldDef.STAGE): System.Boolean]]
m.isArenaStage = m.wrap(m.get("app.FieldUtil.isArenaStage(app.FieldDef.STAGE)")) --[[@as fun(stage: app.FieldDef.STAGE): System.Boolean]]
m.getItemNameGuid = m.wrap(m.get("app.ItemDef.RawName(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Guid]]
m.isQuestAcceptable = m.wrap(
    m.get(
        "app.QuestUtil.checkAcceptable(System.Int32, app.net_session_manager.SessionManager.cSearchResultQuest)"
    )
) --[[@as fun(int32_ptr: integer, quest: app.net_session_manager.SessionManager.cSearchResultQuest): System.Boolean]]
m.loadQuestsAfterSearch = m.wrap_obj(m.get("app.cGUI050000ViewFlow.Flow.QuestSelect.onEnter()")) --[[@as fun(ctx: app.cGUI050000ViewFlow.cContext)]]
m.getStageBaseCampGmID = m.wrap(m.get("app.GUI050001.getStageBaseCampID(app.FieldDef.STAGE)")) --[[@as fun(stage: app.FieldDef.STAGE): System.Int32]]
m.getGmIDFromSimpleCampID =
    m.wrap(m.get("app.GimmickUtil.getGmIDFromSimpleCampID(System.Int32, app.FieldDef.STAGE)")) --[[@as fun(camp_id: System.Int32, stage:  app.FieldDef.STAGE): app.GimmickDef.ID]]
m.getEmSpecies = m.wrap(m.get("app.EnemyDef.Species(app.EnemyDef.ID)")) --[[@as fun(em_id: app.EnemyDef.ID): app.EnemyDef.SPECIES_Fixed]]
m.getSpeciesData = m.wrap(m.get("app.EnemyDef.Data(app.EnemyDef.SPECIES)")) --[[@as fun(species: app.EnemyDef.SPECIES): app.user_data.EnemySpeciesData.cData]]
m.callbackNetworkError = m.wrap_obj(
    m.get_by_regex(util.ref.types.get("app.NetworkErrorManager"), "<showError>.*") --[[@as REMethodDefinition]]
) --[[@as fun(self: app.NetworkErrorManager, idx: System.Int32)]]
m.canOpenStartMenu =
    m.wrap(m.get("app.cGUISystemModuleSystemInputOpenController.canOpenStartMenu(System.Boolean)")) --[[@as fun(check_open_item_slider_flag: System.Boolean): System.Boolean]]
m.enablePlNoHit =
    m.wrap(m.get("app.GUIFlowGUI050001View.cGUI050001ViewFlowBase.makePlInvincible()")) --[[@as fun()]]
m.isItemWishlisted = m.wrap(m.get("app.WishlistUtil.isItemRequiredForWishlist(app.ItemDef.ID)")) --[[@as fun(item_id: app.ItemDef.ID): System.Boolean]]
m.isQuestRequiredForWishlist = m.wrap(
    m.get("app.WishlistUtil.isQuestRequiredForWishlist(app.MissionIDList.ID, app.QuestDef.RANK)")
) --[[@as fun(quest_id: app.MissionIDList.ID, quest_rank: app.QuestDef.RANK): System.Boolean)]]
m.isEnemyRequiredForWishlist =
    m.wrap(m.get("app.WishlistUtil.isEnemyRequiredForWishlist(app.EnemyDef.ID, app.QuestDef.RANK)")) --[[@as fun(em_id: app.EnemyDef.ID, quest_rank: app.QuestDef.RANK): System.Boolean]]
m.isExQuestRequiredForWishlist = m.wrap(
    m.get(
        "app.WishlistUtil.isExQuestRequiredForWishlist(System.Collections.Generic.IEnumerable`1<app.savedata.cItemWork>, app.EnemyDef.ID, app.EnemyDef.ROLE_ID, app.EnemyDef.LEGENDARY_ID, app.QuestDef.RANK, app.QuestDef.EM_REWARD_RANK, System.Boolean)"
    )
) --[[@as fun(rewards: System.Array<app.savedata.cItemWork>, em_id: app.EnemyDef.ID, em_role: app.EnemyDef.ROLE_ID, em_legendary: app.EnemyDef.LEGENDARY_ID, quest_rank: app.QuestDef.RANK, reward_rank: app.QuestDef.EM_REWARD_RANK, check_normal_rewards: System.Boolean): System.Boolean]]

m.hook(
    "app.GUI050000.search(app.net_quest_session.cSearchQuestSessionInfo, app.MissionIDList.ID)",
    hook.search_pre
)
m.hook(
    "app.GUI050000QuestListParts.cQuestList_ViewParts.onSelect(via.gui.SelectItem, System.Int32, System.Int32, System.Boolean)",
    hook.on_select_quest_pre
)
m.hook("app.GUIManager.lateUpdateApp()", nil, hook.update)
m.hook("app.NetworkErrorManager.showError()", hook.app_error_pre)

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) and init.ok then
        local gui_main = config.gui.current.gui.main
        gui_main.is_opened = not gui_main.is_opened
    end

    if not init.failed then
        local errors = logger:format_errors()
        if errors then
            imgui.same_line()
            imgui.text_colored("Error!", mod.map.colors.bad)
            util.imgui.tooltip_exclamation(errors)
        elseif not init.ok then
            imgui.same_line()
            imgui.text_colored("Initializing...", mod.map.colors.info)
        end
    else
        imgui.same_line()
        imgui.text_colored("Init failed!", mod.map.colors.bad)
    end
end)

re.on_application_entry("BeginRendering", function()
    init:init()
end)

re.on_frame(function()
    if not init.ok then
        return
    end

    bind.monitor:monitor()

    local config_gui = config.gui.current.gui

    if not reframework:is_drawing_ui() then
        config_gui.main.is_opened = false
    end

    if config_gui.main.is_opened then
        config_menu.draw()
    end

    config.run_save()
end)

re.on_config_save(function()
    if mod.initialized then
        config.save_no_timer_global()
    end
end)
re.on_script_reset(function()
    if routine_search.has_instance() then
        routine_search.abort()
    end
end)
