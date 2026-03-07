local cache = require("BetterSoS.util.misc.cache")
local s = require("BetterSoS.util.ref.singletons")

local this = {}

---@return app.cPlayerManageInfo?
function this.get_master_info()
    return s.get("app.PlayerManager"):getMasterPlayer()
end

---@param info app.cPlayerManageInfo
function this.get_char(info)
    return info:get_Character()
end

---@return app.HunterCharacter?
function this.get_master_char()
    local info = this.get_master_info()
    if info then
        return info:get_Character()
    end
end

---@return boolean
function this.is_in_village()
    local master_player = this.get_master_char()
    if not master_player then
        return false
    end

    return master_player:get_IsInBaseCamp()
end

this.get_master_char = cache.memoize(this.get_master_char, function(cached_value)
    ---@cast cached_value app.HunterCharacter
    return cached_value:get_Valid()
end)
this.get_char = cache.memoize(this.get_char, function(cached_value)
    ---@cast cached_value app.HunterCharacter
    return cached_value:get_Valid()
end)

return this
