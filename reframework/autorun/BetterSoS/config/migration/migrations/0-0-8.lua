---@diagnostic disable: undefined-field, no-unknown, inject-field

local data_mod = require("BetterSoS.data.mod")
local migration_base = require("BetterSoS.util.misc.migration_base")

local this = migration_base.new("0.0.8")

---@param config MainSettings
function this.fns.auto(config)
    if config.mod.auto_start_quest then
        if not config.mod.ignore_passcode or not config.mod.ignore_manualaccept then
            config.mod.auto_start_quest = data_mod.enum.auto_start_quest.DISABLED
        elseif config.mod.combo_quest_start == 1 then
            config.mod.auto_start_quest = data_mod.enum.auto_start_quest.START_AND_DEPART
        elseif config.mod.combo_quest_start == 2 then
            config.mod.auto_start_quest = data_mod.enum.auto_start_quest.START_AND_PREP
        end
    else
        config.mod.auto_start_quest = data_mod.enum.auto_start_quest.DISABLED
    end

    if config.mod.auto_pick_quest then
        config.mod.auto_start_quest = data_mod.enum.auto_start_quest.PICK
    end

    if config.mod.auto_search then
        if config.mod.auto_start_quest == data_mod.enum.auto_start_quest.DISABLED then
            config.mod.auto_search = data_mod.enum.auto_search_quest.DISABLED
        else
            config.mod.auto_search = data_mod.enum.auto_search_quest.SEARCH
        end
    else
        config.mod.auto_search = data_mod.enum.auto_search_quest.DISABLED
    end
end

---@param config MainSettings
function this.fns.host_hr(config)
    if config.mod.ignore_host_hr_lower and not config.mod.ignore_host_hr_upper then
        config.mod.slider_host_hr_upper = 999
        config.mod.ignore_host_hr = true
    elseif config.mod.ignore_host_hr_upper and not config.mod.ignore_host_hr_lower then
        config.mod.slider_host_hr_lower = 1
        config.mod.ignore_host_hr = true
    end
end

---@param config MainSettings
function this.fns.rank(config)
    local j = 1
    if config.mod.ignore_rank_lower then
        for i = 1, config.mod.slider_rank_lower - 1 do
            ---@diagnostic disable-next-line: no-unknown
            config.mod.rank[tostring(i)] = j
            j = j + 1
        end

        config.mod.ignore_rank = true
    end

    if config.mod.ignore_rank_upper then
        for i = config.mod.slider_rank_upper + 1, 10 do
            ---@diagnostic disable-next-line: no-unknown
            config.mod.rank[tostring(i)] = j
            j = j + 1
        end

        config.mod.ignore_rank = true
    end
end

return this
