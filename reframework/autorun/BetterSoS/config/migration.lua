---@class Version
---@field major number
---@field minor number
---@field patch number
---@field commit number

local data_mod = require("BetterSoS.data.mod")

local this = {}

---@class Version
local Version = {}
---@diagnostic disable-next-line: inject-field
Version.__index = Version

---@param version_string string 0.0.0-0
---@return Version
function Version.new(version_string)
    local major, minor, patch = version_string:match("(%d+)%.(%d+)%.(%d+)")
    local commit = version_string:match("%-(%d+)") or "0"

    local o = {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch),
        commit = tonumber(commit) or 0,
    }
    return setmetatable(o, Version) --[[@as Version]]
end

---@param a Version
---@param b Version
---@return boolean
function Version.__lt(a, b)
    if a.major ~= b.major then
        return a.major < b.major
    end
    if a.minor ~= b.minor then
        return a.minor < b.minor
    end
    if a.patch ~= b.patch then
        return a.patch < b.patch
    end
    return a.commit < b.commit
end

---@param a Version
---@param b Version
---@return boolean
function Version.__eq(a, b)
    return a.major == b.major and a.minor == b.minor and a.patch == b.patch and a.commit == b.commit
end

function Version.__le(a, b)
    return a < b or a == b
end
function Version.__gt(a, b)
    return not (a <= b)
end
function Version.__ge(a, b)
    return not (a < b)
end

---@return string
function Version:__tostring()
    if self.commit > 0 then
        return string.format(
            "Version(%d.%d.%d-%d)",
            self.major,
            self.minor,
            self.patch,
            self.commit
        )
    end
    return string.format("Version(%d.%d.%d)", self.major, self.minor, self.patch)
end

---@param config table<string, any>
local function to_0_0_8_auto(config)
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

---@param config table<string, any>
local function to_0_0_8_host_hr(config)
    if config.mod.ignore_host_hr_lower and not config.mod.ignore_host_hr_upper then
        config.mod.slider_host_hr_upper = 999
        config.mod.ignore_host_hr = true
    elseif config.mod.ignore_host_hr_upper and not config.mod.ignore_host_hr_lower then
        config.mod.slider_host_hr_lower = 1
        config.mod.ignore_host_hr = true
    end
end

---@param config table<string, any>
local function to_0_0_8_rank(config)
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

this.migrations = {
    ["0.0.8"] = function(config)
        to_0_0_8_auto(config)
        to_0_0_8_host_hr(config)
        to_0_0_8_rank(config)
    end,
}

---@param from string?
---@param to string
---@return string[]
local function get_funcs(from, to)
    from = from or "0.0.0"

    if from == to then
        return {}
    end

    ---@type string[]
    local sorted = {}
    local from_n = Version.new(from)
    local to_n = Version.new(to)
    for ver in pairs(this.migrations) do
        local ver_n = Version.new(ver)
        if ver_n > from_n and ver_n <= to_n then
            table.insert(sorted, ver)
        end
    end

    table.sort(sorted, function(a, b)
        return Version.new(a) < Version.new(b)
    end)

    return sorted
end

---@param from string?
---@param to string
---@return boolean
function this.need_migrate(from, to)
    from = from or "0.0.0"
    return Version.new(from) < Version.new(to)
end

---@param from string?
---@param to string
---@param config MainSettings
function this.migrate(from, to, config)
    local sorted = get_funcs(from, to)
    for i = 1, #sorted do
        local f = this.migrations[sorted[i]]
        f(config)
    end
    config.version = to
end

return this
