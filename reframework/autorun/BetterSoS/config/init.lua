---@class MainConfig : ConfigBase
---@field current MainSettings
---@field default MainSettings
---
---@field lang Language
---@field gui GuiConfig
---
---@field max_player integer
---@field max_time integer
---@field max_hr integer
---@field max_grade integer
---
---@field version string
---@field commit string
---@field name string

local config_base = require("BetterSoS.util.misc.config_base")
local lang = require("BetterSoS.config.lang")
local util_misc = require("BetterSoS.util.misc.init")
local util_table = require("BetterSoS.util.misc.table")
local version = require("BetterSoS.config.version")

local mod_name = "BetterSoS"
local config_path = util_misc.join_paths(mod_name, "config.json")

---@class MainConfig
local this = config_base:new(require("BetterSoS.config.defaults.mod"), config_path)

this.version = version.version
this.commit = version.commit
this.name = mod_name

this.max_time = 50
this.max_player = 4
this.max_hr = 999
this.max_grade = 5

this.gui = config_base:new(
    require("BetterSoS.config.defaults.gui"),
    util_misc.join_paths(this.name, "other_configs", "gui.json")
) --[[@as GuiConfig]]
this.lang = lang:new(
    require("BetterSoS.config.defaults.lang"),
    util_misc.join_paths(this.name, "lang"),
    "en-us.json",
    this
)

function this:load()
    local loaded_config = json.load_file(self.path) --[[@as MainSettings?]]
    if loaded_config then
        self.current = util_table.merge_t(self.default, loaded_config)

        --FIXME: probably should deal with this at some point...
        self.current.mod.bind.action = loaded_config.mod.bind.action or {}
    else
        self.current = util_table.deep_copy(self.default)
        self:save_no_timer()
    end
end

---@return boolean
function this.init()
    this:load()
    this.gui:load()
    this.lang:load()

    return true
end

return this
