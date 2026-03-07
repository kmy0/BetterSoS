---@meta

---@class via.clr.ManagedObject : via.Object
---@class via.Object : REManagedObject
---@class via.UserData : via.clr.ManagedObject
---@class via.vec3 : Vector3f
---@class via.gui.Window : via.gui.Control
---@class via.gui.View : via.gui.Window
---@class via.gui.Panel : via.gui.Capture
---@class via.gui.Capture : via.gui.Control
---@class via.gui.Element : via.gui.PlayObject
---@class via.gui.DrawableElement : via.gui.PlayObject
---@class via.gui.MaskableElement : via.gui.DrawableElement
---@class via.gui.Control : via.gui.TransformObject
---@class via.gui.TransformObject : via.gui.PlayObject
---@class via.gui.PlayObject : via.clr.ManagedObject

---@class via.Size
---@field w System.Single
---@field h System.Single

---@class via.Float4
---@field x System.Single
---@field y System.Single
---@field z System.Single
---@field w System.Single

---@class via.Point
---@field x System.Single
---@field y System.Single

---@class via.Int2
---@field x System.Int32
---@field y System.Int32

---@class via.Position
---@field x System.Double
---@field y System.Double
---@field z System.Double

---@class via.Float3
---@field x System.Single
---@field y System.Single
---@field z System.Single

---@class via.Color
---@field rgba System.UInt32

---@class via.Component : via.clr.ManagedObject
---@field get_GameObject fun(self: via.Component): via.GameObject
---@field ToString fun(self: via.Component): System.String

---@class via.Behavior : via.Component
---@field get_Started fun(self: via.Behavior): System.Boolean
---@field get_Valid fun(self: via.Behavior): System.Boolean

---@class via.Scene : via.clr.ManagedObject
---@field get_FrameCount fun(self: via.Scene): System.UInt32

---@class via.SceneView : via.gui.TransformObject
---@field get_WindowSize fun(self: via.SceneView): via.Size

---@class via.gui.GUISystem : NativeSingleton
---@field get_MessageLanguage fun(self: via.gui.GUISystem): via.Language

---@class via.SceneManager : NativeSingleton
---@field get_MainView fun(self: via.SceneManager): via.SceneView
---@field get_CurrentScene fun(self: via.SceneManager): via.Scene

---@class via.Application : NativeSingleton
---@field get_DeltaTime fun(self: via.Application): System.Single

---@class via.GameObject : via.clr.ManagedObject
---@field get_Name fun(self: via.GameObject): System.String
---@field get_Transform fun(self: via.GameObject): via.Transform
---@field destroy fun(self: via.GameObject, object: via.GameObject)

---@class via.Transform : via.Component
---@field get_GameObject fun(self: via.Transform): via.GameObject
---@field get_Parent fun(self: via.Transform): via.Transform?
---@field get_Position fun(self: via.Transform): via.vec3

---@class via.gui.GUI : via.Component
---@field get_Enabled fun(self: via.gui.GUI): System.Boolean
---@field get_View fun(self: via.gui.GUI): via.gui.View
---@field set_Enabled fun(self: via.gui.GUI, val: System.Boolean)
