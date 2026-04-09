---@meta

---@class ace.GUIBaseCore : via.Behavior
---@class ace.GAElementBase : via.Behavior
---@class ace.GAElement<T> : ace.GAElementBase
---@class ace.GUIBase : ace.GUIBaseCore
---@class ace.cSaveDataParam : ace.cSaveDataBase
---@class ace.cSaveDataBase : via.clr.ManagedObject
---@class ace.cGUIPartsBase : via.clr.ManagedObject
---@class ace.user_data.ExcelUserData.cData : via.clr.ManagedObject
---@class ace.cGUISystemModuleNotifyWindow : ace.cGUISystemModuleBase
---@class ace.cGUISystemModuleBase: via.clr.ManagedObject
---@class ace.cGUIFlowContextBase : via.clr.ManagedObject
---@class ace.GimmickBase : ace.GimmickBaseCore
---@class ace.GimmickBaseCore : via.Behavior
---@class ace.SaveDataManagerBase : ace.GAElement

---@class ace.GUIManagerBase : ace.GAElement
---@field getGUI fun(self: ace.GUIManagerBase, gui_id: app.GUIID.ID): ace.GUIBase

---@class ace.cGUINotifyWindowInfo : via.clr.ManagedObject
---@field get_Caller fun(self: ace.cGUINotifyWindowInfo): System.Object
---@field get_TextInfo fun(self: ace.cGUINotifyWindowInfo): ace.cGUIMessageInfo
---@field set_Caller fun(self: ace.cGUINotifyWindowInfo, caller: System.Object)
---@field set_DispMinTime fun(self: ace.cGUINotifyWindowInfo, val: System.Single)
---@field get_ChoisesTextInfo fun(self: ace.cGUINotifyWindowInfo): System.Array<ace.cGUIMessageInfo>

---@class ace.cGUIMessageInfo : via.clr.ManagedObject
---@field get_MsgID fun(self: ace.cGUIMessageInfo): System.Guid
---@field setMessageInfo fun(self: ace.cGUIMessageInfo, guid: System.Guid)
---@field set_MsgID fun(self: ace.cGUIMessageInfo, id: System.Guid)
---@field get_Params fun(self: ace.cGUIMessageInfo): System.Array<ace.cGUIMessageInfo.ParamData>

---@class ace.cLimitedArray<T> : {[integer]: T}, System.Object
---@field _Array System.Array<T>
---@field get_Length fun(self: ace.cLimitedArray<any>): System.Int32

---@class ace.PadManager : ace.GAElement
---@field get_MainPad fun(self: ace.PadManager): ace.cPadInfo

---@class ace.cPadInfo : via.clr.ManagedObject
---@field get_KeyOn fun(self: ace.cPadInfo): ace.ACE_PAD_KEY.BITS

---@class ace.MouseKeyboardManager : ace.GAElement
---@field get_MainMouseKeyboard fun(self: ace.MouseKeyboardManager): ace.cMouseKeyboardInfo

---@class ace.cMouseKeyboardInfo : via.clr.ManagedObject
---@field isOn fun(self: ace.cMouseKeyboardInfo, key: ace.ACE_MKB_KEY.INDEX): System.Boolean

---@class ace.cGUIMessageInfo.ParamData : System.ValueType
---@field ParamString System.String
