local m = require("BetterSoS.util.ref.methods")
local routine_search = require("BetterSoS.better_sos.routine_search")
local s = require("BetterSoS.util.ref.singletons")
local util_mod = require("BetterSoS.util.mod.init")

local this = {}

function this.search_cancel(...)
    if routine_search.has_instance() and routine_search.can_cancel() then
        routine_search.abort()
    end
end

function this.search_start(...)
    if
        not routine_search.has_instance()
        and m.canOpenStartMenu(false)
        and not s.get("app.MissionManager"):get_IsActiveQuest()
    then
        routine_search.new(util_mod.get_search_mode(), util_mod.make_quest_filter())
    end
end

return this
