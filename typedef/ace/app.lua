---@meta

---@class app.AppBehavior : via.Behavior
---@class app.cGameContext : via.clr.ManagedObject
---@class app.cGameContextHolder : via.clr.ManagedObject
---@class app.AttackAreaResult : via.clr.ManagedObject
---@class app.cCharacterExtendBase : via.clr.ManagedObject
---@class app.net_session_manager.cSearchSessionInfo : via.clr.ManagedObject
---@class app.GUIBaseApp : ace.GUIBase
---@class app.GUI050000PartsBase : app.cGUIPartsBaseApp
---@class app.cGUIPartsBaseApp : ace.cGUIPartsBase
---@class app.cGUIFlowContextBaseApp : app.cGUIFlowBaseApp
---@class app.cGUIFlowBaseApp : ace.cGUIFlowContextBase
---@class app.cGUINotifyWindowInfoApp : ace.cGUINotifyWindowInfo
---@class app.net_quest_session.cJoinQuestSessionInfo : app.net_session_manager.cJoinSessionInfo
---@class app.net_session_manager.cJoinSessionInfo : via.clr.ManagedObject
---@class app.Net_UserInfo : via.clr.ManagedObject
---@class app.cKeepQuestData : via.clr.ManagedObject
---@class app.cActiveQuestData : via.clr.ManagedObject
---@class app.GimmickBaseApp : ace.GimmickBase
---@class app.cGUI3DMapModelContollerBase : ace.cGUIPartsBase
---@class app.cStreamQuestData : via.clr.ManagedObject
---@class app.cCampManager : via.clr.ManagedObject
---@class app.CharacterBase : app.AppBehavior
---@class app.NetworkRequest : via.clr.ManagedObject

---@class app.net_quest_session.cSearchQuestSessionInfo : app.net_session_manager.cSearchSessionInfo
---@field set_Rescure fun(self: app.net_quest_session.cSearchQuestSessionInfo, val: System.Boolean)
---@field set_IsSameLanguage fun(self: app.net_quest_session.cSearchQuestSessionInfo, val: System.Boolean)
---@field set_IsSamePlatform fun(self: app.net_quest_session.cSearchQuestSessionInfo, val: System.Boolean)
---@field set_IsLink fun(self: app.net_quest_session.cSearchQuestSessionInfo, val: System.Boolean)
---@field set_QuestDifficulty fun(self: app.net_quest_session.cSearchQuestSessionInfo, val: System.Int32)
---@field set_Target fun(self: app.net_quest_session.cSearchQuestSessionInfo, target: app.net_quest_session.cSearchQuestSessionInfo.cTargetInfo)
---@field set_QuestType fun(self: app.net_quest_session.cSearchQuestSessionInfo, val: System.Int32)
---@field set_NeedMemberNum fun(self: app.net_quest_session.cSearchQuestSessionInfo, val: System.Int32)
---@field FieldId System.Int32

---@class app.GUI050000 : app.GUIBaseApp
---@field getRescueSearchSettingHolder fun(self: app.GUI050000): app.GUI050000PartsBase.cRescueSearchSettingParamHolder
---@field search fun(self: app.GUI050000, info: app.net_quest_session.cSearchQuestSessionInfo, id: app.MissionIDList.ID)
---@field get_ViewFlowContext fun(self: app.GUI050000): app.cGUI050000ViewFlow.cContext
---@field _QuestSearchCtrl app.cGUI050000QuestSearchWindowCtrl
---@field _QuestListParts app.GUI050000QuestListParts

---@class app.cGUI050000ViewFlow.cContext : app.cGUIFlowContextBaseApp
---@field IsNextFlow System.Boolean
---@field IsCancel System.Boolean
---@field IsSearchFailed System.Boolean

---@class app.GUI050000PartsBase.cRescueSearchSettingParamHolder : via.clr.ManagedObject
---@field RescueSearchQuestType System.Byte
---@field RescueSearchDifficulty System.Int32
---@field RescueSearchLanguage System.Byte
---@field RescueSearchPlatform System.Byte
---@field RescueSearchTargetID System.Byte
---@field RescueSearchTargetRoleID System.Byte
---@field RescueSearchFieldID System.Byte
---@field saveParam fun(self: app.GUI050000PartsBase.cRescueSearchSettingParamHolder)

---@class app.GUI050000QuestListParts : app.GUI050000PartsBase
---@field decideQuest fun(self: app.GUI050000QuestListParts, quest: app.cGUIQuestViewData)
---@field updateQuestDetailWindow fun(self: app.GUI050000QuestListParts, quest: app.cGUIQuestViewData)
---@field get_IsActive fun(self: app.GUI050000QuestListParts): System.Boolean
---@field get_ViewQuestDataList fun(self: app.GUI050000QuestListParts): System.Array<app.cGUIQuestViewData>

---@class app.cGUI050000QuestSearchWindowCtrl : app.GUI050000PartsBase
---@field _SearchState app.cGUI050000QuestSearchWindowCtrl.SEARCH_STATE

---@class app.NetworkManager : ace.GAElement
---@field get_RequestManager fun(self: app.NetworkManager): app.NetworkRequestManager
---@field get_UserInfoManager fun(self: app.NetworkManager): app.Net_UserInfoManager

---@class app.Net_UserInfoManager : via.clr.ManagedObject
---@field getHostUserInfo fun(self: app.Net_UserInfoManager, type: app.net_session_manager.SESSION_TYPE): app.Net_UserInfo

---@class app.NetworkRequestManager : via.clr.ManagedObject
---@field _QuestSession app.net_quest_session.cQuestSession
---@field eraseRequest fun(self: app.NetworkRequestManager, index: System.UInt32)
---@field FindTargetRequest fun(self: app.NetworkRequestManager, index: System.UInt32): app.NetAbortableRequest
---@field leaveSession fun(self: app.NetworkRequestManager, type: app.net_session_manager.SESSION_TYPE, callback: System.Action<System.Boolean,app.NETWORK_ERROR_CODE> | 0, unknown_bool: System.Boolean)
---@field searchSession fun(self: app.NetworkRequestManager, type: app.net_session_manager.SESSION_TYPE, search_info: app.net_quest_session.cSearchQuestSessionInfo, callback: System.Action<System.Boolean,app.NETWORK_ERROR_CODE>)
---@field joinSession fun(self: app.NetworkRequestManager, type: app.net_session_manager.SESSION_TYPE, join_info: app.net_session_manager.cJoinSessionInfo, callback: System.Action<System.Boolean,app.NETWORK_ERROR_CODE>)

---@class app.net_session_manager.SessionManager : via.clr.ManagedObject
---@field _SearchResultTblQuest app.net_session_manager.SessionManager.cSearchResultTblQuest

---@class app.net_session_manager.SessionManager.cSearchResultTblQuest : via.clr.ManagedObject
---@field SearchResult ace.cLimitedArray<app.net_session_manager.SessionManager.cSearchResultQuest>

---@class app.net_session_manager.SessionManager.cSearchResultQuest : via.clr.ManagedObject
---@field questId app.MissionIDList.ID
---@field memberNum System.Int32
---@field maxMemberNum System.Int32
---@field isLocked System.Boolean
---@field isAutoAccept System.Boolean
---@field startedAt System.Int64
---@field acceptedAt System.Int64
---@field fieldId app.FieldDef.STAGE
---@field questLevel app.QuestDef.EM_REWARD_RANK
---@field exRewards ace.cLimitedArray<app.savedata.cItemWork>
---@field targetMonster ace.cLimitedArray<app.net_quest_session.cSearchQuestSessionInfo.cTargetInfo>
---@field questSessionId System.String
---@field questType app.QuestDef.QUEST_TYPE
---@field campList System.Int16
---@field isBoost System.Boolean
---@field envType app.EnvironmentType.ENVIRONMENT
---@field questTimeLimit System.Int32
---@field questRank app.QuestDef.RANK

---@class app.user_data.ItemData.cData : ace.user_data.ExcelUserData.cData
---@field get_RawName fun(self: app.user_data.ItemData.cData): System.Guid
---@field get_Special fun(self: app.user_data.ItemData.cData): System.Boolean

---@class app.VariousDataManager : ace.GAElement
---@field get_Setting fun(self: app.VariousDataManager) : app.user_data.VariousDataManagerSetting

---@class app.user_data.VariousDataManagerSetting : via.UserData
---@field get_ExQuestRewardSetting fun(self: app.user_data.VariousDataManagerSetting): app.user_data.ExQuestRewardSetting

---@class app.user_data.ExQuestRewardSetting : via.UserData
---@field _ArtianRewardTbl System.Array<app.user_data.ExQuestRewardSetting.cExRewardDataParam>
---@field _AmuletRewardTbl System.Array<app.user_data.ExQuestRewardSetting.cExRewardDataParam>
---@field _SkillGemRewardTbl System.Array<app.user_data.ExQuestRewardSetting.cExRewardDataParam>
---@field _ExjudgeEmRewardArray System.Array<app.user_data.ExQuestRewardSetting.cExJudgeEmReward>

---@class app.user_data.ExQuestRewardSetting.cExRewardDataParam : via.clr.ManagedObject
---@field get_RewardItem fun(self: app.user_data.ExQuestRewardSetting.cExRewardDataParam): app.ItemDef.ID

---@class app.user_data.ExQuestRewardSetting.cExJudgeEmReward : via.clr.ManagedObject
---@field get_ItemID fun(self: app.user_data.ExQuestRewardSetting.cExJudgeEmReward): app.ItemDef.ID

---@class app.net_quest_session.cSearchQuestSessionInfo.cTargetInfo : via.clr.ManagedObject
---@field Id System.Int32
---@field LegendaryId System.Int32
---@field RoleId System.Int32

---@class app.savedata.cItemWork : ace.cSaveDataParam
---@field get_ItemId fun(self: app.savedata.cItemWork): app.ItemDef.ID

---@class app.GUIManager : ace.GUIManagerBase
---@field getNotifyWindowModule fun(self: app.GUIManager): app.cGUISystemModuleNotifyWindowApp
---@field requestNotifyWindow fun(self: app.GUIManager, app: app.cGUINotifyWindowInfoApp)
---@field get_LastInputDeviceIgnoreMouseMove fun(self: app.GUIManager): ace.GUIDef.INPUT_DEVICE
---@field setQuestOrderParam fun(self: app.GUIManager, order_param: app.cGUIQuestOrderParam, start_quest: System.Boolean)
---@field shutdownGUIWithType fun(self: app.GUIManager, type: app.GUIDefApp.SHUTDOWN_TYPE, mode: ace.GUIDef.SHUTDOWN_MODE)
---@field acceptQuestFromSearchResult fun(self: app.GUIManager, quest: app.net_session_manager.SessionManager.cSearchResultQuest, from: app.cGUIQuestOrderParam.QUEST_ORDER_FROM, start_type: app.cGUIQuestOrderParam.QUEST_START_TYPE, invite_req_index: System.Int32)

---@class app.cGUISystemModuleNotifyWindowApp : ace.cGUISystemModuleNotifyWindow
---@field closeGUI fun(self: app.cGUISystemModuleNotifyWindowApp)
---@field shutdownNotifyWindows fun(self: app.cGUISystemModuleNotifyWindowApp, type: app.GUIDefApp.SHUTDOWN_TYPE, mode: ace.GUIDef.SHUTDOWN_MODE)

---@class app.net_quest_session.cQuestSession : app.net_session_manager.SessionManager
---@field applyFilterForSearchResult fun(self: app.net_quest_session.cQuestSession)

---@class app.cGUIQuestViewData : via.clr.ManagedObject
---@field Session app.cGUIQuestViewData.cGUISessionData
---@field get_MissionID fun(self: app.cGUIQuestViewData): app.MissionIDList.ID
---@field set_ActiveQuestData fun(self: app.cGUIQuestViewData, quest_data: app.cActiveQuestData)
---@field get_TargetEmStartArea fun(self: app.cGUIQuestViewData): System.Array<System.Int32>

---@class app.cGUIQuestViewData.cGUISessionData : via.clr.ManagedObject
---@field getHostHunterID fun(self: app.cGUIQuestViewData.cGUISessionData): System.Guid
---@field get_SearchResult fun(self: app.cGUIQuestViewData.cGUISessionData): app.net_session_manager.SessionManager.cSearchResultQuest

---@class app.Net_QuestUserInfo : app.Net_UserInfo
---@field get_KeepQuestData fun(self: app.Net_QuestUserInfo): app.cKeepQuestData

---@class app.MissionManager : ace.GAElement
---@field get_QuestDirector fun(self: app.MissionManager): app.cQuestDirector
---@field getMissionTypeFromID fun(self: app.MissionManager, quest_id: app.MissionIDList.ID): app.MissionTypeList.TYPE
---@field getQuestDataFromMissionId fun(self: app.MissionManager, quest_id: app.MissionIDList.ID): app.cActiveQuestData
---@field getStreamQuestDataFromID fun(self: app.MissionManager, quest_id: app.MissionIDList.ID): app.cStreamQuestData
---@field get_IsQuestEndShowing fun(self: app.MissionManager): System.Boolean
---@field get_IsActiveQuest fun(self: app.MissionManager): System.Boolean

---@class app.cQuestDirector : via.clr.ManagedObject
---@field get_Param fun(self: app.cQuestDirector): app.cQuestFlowParam
---@field acceptQuest fun(self: app.cQuestDirector, quest_data: app.cActiveQuestData, quest_arg: app.cQuestAcceptArg, unknown_bool1: System.Boolean, unknown_bool2: System.Boolean)
---@field goQuest fun(self: app.cQuestDirector, is_seamless: System.Boolean, skip_session: System.Boolean, keep_stage: System.Boolean, supress_auto_save: System.Boolean)

---@class app.GimmickManager : ace.GAElement
---@field get_CampManager fun(self: app.GimmickManager): app.cCampManager

---@class app.cCampManager.TentQuestStartPointInfo : via.clr.ManagedObject
---@field get_CampID fun(self: app.cCampManager.TentQuestStartPointInfo): System.Int32

---@class app.cQuestAcceptArg : via.clr.ManagedObject
---@field StartType app.cGUIQuestOrderParam.QUEST_START_TYPE
---@field IsJoinRescue System.Boolean

---@class app.cGUIQuestOrderParam : via.clr.ManagedObject
---@field QuestType app.GUI050000.QUEST_TYPE
---@field ActiveQuestData app.cActiveQuestData
---@field QuestViewData app.cGUIQuestViewData
---@field IsOnline System.Boolean
---@field IsJoinRescue System.Boolean
---@field SelectStartPointInfo app.cStartPointInfo

---@class app.cStartPointInfo : via.clr.ManagedObject
---@field CampID System.Int32

---@class app.SaveDataManager : ace.SaveDataManagerBase
---@field getCurrentUserSaveData fun(self: app.SaveDataManager): app.savedata.cUserSaveParam

---@class app.savedata.cUserSaveParam : ace.cSaveDataParam
---@field get_Equip fun(self: app.savedata.cUserSaveParam): app.savedata.cEquipParam
---@field get_QuestRecruteSearchSetting fun(self: app.savedata.cUserSaveParam): app.savedata.cQuestRecruteSearchSetting

---@class app.savedata.cEquipParam : ace.cSaveDataParam
---@field get_Wishlist fun(self: app.savedata.cEquipParam): app.savedata.cWishlistParam

---@class app.savedata.cWishlistParam : ace.cSaveDataParam
---@field getEntryCount fun(self: app.savedata.cWishlistParam): System.Int32

---@class app.savedata.cQuestRecruteSearchSetting : ace.cSaveDataParam
---@field RescueSearchQuestType System.Byte
---@field RescueSearchDifficulty System.Int32
---@field RescueSearchLanguage System.Byte
---@field RescueSearchPlatform System.Byte
---@field RescueSearchTargetID System.Byte
---@field RescueSearchTargetRoleID System.Byte
---@field RescueSearchFieldID System.Byte

---@class app.user_data.EnemySpeciesData.cData : ace.user_data.ExcelUserData.cData
---@field get_EmSpeciesName fun(self: app.user_data.EnemySpeciesData.cData): System.Guid

---@class app.NetworkErrorManager : via.clr.ManagedObject
---@field get_DisplayError fun(self: app.NetworkErrorManager): app.NetworkErrorRequest

---@class app.NetworkErrorRequest : via.clr.ManagedObject
---@field get_Func fun(self: app.NetworkErrorRequest): System.Action

---@class app.HunterCharacter : app.CharacterBase
---@field get_IsInBaseCamp fun(self: app.HunterCharacter): System.Boolean

---@class app.PlayerManager : ace.GAElement
---@field getMasterPlayer fun(self: app.PlayerManager): app.cPlayerManageInfo

---@class app.cPlayerManageInfo : via.clr.ManagedObject
---@field get_Character fun(self: app.cPlayerManageInfo): app.HunterCharacter

---@class app.NetAbortableRequest : app.NetworkRequest
---@field set_IsAbort fun(self: app.NetAbortableRequest, val: System.Boolean)

---@class app.cQuestFlowParam : via.clr.ManagedObject
---@field IsResultSeamless System.Boolean
