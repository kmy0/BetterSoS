---@diagnostic disable: undefined-field, no-unknown, inject-field

local migration_base = require("BetterSoS.util.misc.migration_base")

local this = migration_base.new("0.1.1")

---@param config MainSettings
function this.fns.player(config)
    if config.mod.ignore_player then
        local j = 1
        for i = 1, config.mod.slider_player - 1 do
            ---@diagnostic disable-next-line: no-unknown
            config.mod.player[tostring(i)] = j
            j = j + 1
        end
    end

    if config.mod.ignore_player_max then
        local j = 1
        for i = 2, config.mod.slider_player_max - 1 do
            ---@diagnostic disable-next-line: no-unknown
            config.mod.player_max[tostring(i)] = j
            j = j + 1
        end
    end
end

return this
