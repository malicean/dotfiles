-- Original code written by Kamikaze94. For original code, go see WolfHUD (WolfHUD/lua/AdvAssault.lua)
-- "Fixed" and improved by me
local tweak, gai_state, assault_data, get_value, get_mult
local BAI = BAI
if BAI.IsHost then
    tweak = tweak_data.group_ai.besiege.assault
    if BAI._cache.is_skirmish then
        tweak = tweak_data.group_ai.skirmish.assault
    end
    gai_state = managers.groupai:state()
    assault_data = gai_state and gai_state._task_data.assault
    get_value = gai_state._get_difficulty_dependent_value or function() return 0 end
    get_mult = gai_state._get_balancing_multiplier or function() return 0 end
end
local crimespree = nil
if BAI._cache.is_crimespree then
    crimespree = managers.crime_spree:DoesServerHasAssaultExtenderModifier()
end
local assault_extender = false
local spacer = string.rep(" ", 10)
local sep = string.format("%s%s%s", spacer, managers.localization:text("hud_assault_end_line"), spacer)
local hud = managers.hud
local corner = hud._hud_assault_corner
local math_round = math.round
local math_lerp = math.lerp
local math_max = math.max

local text_original = LocalizationManager.text
function LocalizationManager:text(string_id, macros)
    if string_id == "hud_advanced_info" then
        return self:HUDAdvancedInfo()
    elseif string_id == "hud_break_time_info" then
        return self:HUDBreakTimeInfo()
    elseif string_id == "hud_wave_counter" then
        return self:HUDWaveCounter()
    end
    return text_original(self, string_id, macros)
end

function LocalizationManager:SetVariables(client)
    self.show_spawns_left = BAI:GetAAIOption("show_spawns_left")
    self.spawn_numbers = BAI:GetAAIOption("spawn_numbers")
    self.show_time_left = BAI:GetAAIOption("show_time_left")
    self.is_client = client
end

function LocalizationManager:CSAE_Activate()
    assault_extender = true
end

function LocalizationManager:CalculateSpawnsLeft() -- For better overriding when other mods change spawn calculation
    if tweak and gai_state and assault_data and assault_data.active then
        return get_value(gai_state, tweak.force_pool) * get_mult(gai_state, tweak.force_pool_balance_mul) - assault_data.force_spawned
    end
    return 0
end

function LocalizationManager:CalculateSpawnsLeftClient() -- For better overriding when other mods change spawn calculation
    return get_value(gai_state, tweak.force_pool) * get_mult(gai_state, tweak.force_pool_balance_mul) - assault_data.force_spawned
end

function LocalizationManager:CalculateTimeLeftNoFormat(return_value)
    if tweak and gai_state and assault_data and assault_data.active then
        local add
        local time_left
        time_left = assault_data.phase_end_t - gai_state._t
        if crimespree or assault_extender then
            local sustain_duration = math_lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
            add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
            if add == 0 and gai_state._assault_number == 1 and assault_data.phase == "build" then
                add = sustain_duration / 2
            end
        end
        if assault_data.phase == "build" then
            local sustain_duration = math_lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
            time_left = time_left + sustain_duration + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        elseif assault_data.phase == "sustain" then
            time_left = time_left + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        end
        return time_left
    end
    return return_value or -1
end

function LocalizationManager:CalculateTimeLeft(return_value) -- For better overriding when other mods change assault time left calculation
    return self:FormatTimeLeft(self:CalculateTimeLeftNoFormat(return_value))
end

local function TimeLeftFormat_Overdue(self, time_left)
    return self:text("hud_overdue")
end

local function TimeLeftFormat_Time(self, time_left)
    return "+" .. self:FormatTimeLeft(-time_left)
end

if true then
    LocalizationManager.FormatTimeLeftOverdue = TimeLeftFormat_Overdue
else
    LocalizationManager.FormatTimeLeftOverdue = TimeLeftFormat_Time
end

function LocalizationManager:FormatTimeLeft(time_left)
    if time_left < 0 then
        return self:FormatTimeLeftOverdue(time_left)
    else
        return self:TimeFormat(time_left)
    end
end

function LocalizationManager:FormatBreakTimeLeft(time_left) -- Code optimization purposes
    if time_left == 0 then
        return self:FormatBreakTimeLeft(60)
    elseif time_left < 0 then
        return "+" .. string.gsub(self:FormatBreakTimeLeft(-time_left), "-", "")
    else
        return "-" .. self:TimeFormat(time_left)
    end
end

function LocalizationManager:HUDAdvancedInfo()
    if tweak and gai_state and assault_data and assault_data.active then
        local s = nil

        if self.show_spawns_left then
            local spawns_left
            if self.spawn_numbers == 1 then
                spawns_left = self:text("hud_spawns_left") .. " " .. math_round(math_max(self:CalculateSpawnsLeft(), 0))
            else
                spawns_left = self:text("hud_spawns_left_short") .. " " .. managers.enemy:GetNumberOfEnemies()
            end
            s = string.format("%s", spawns_left)
        end

        if self.show_time_left then
            local time_left = self:text("hud_time_left") .. " " .. self:CalculateTimeLeft()

            if s then
                s = string.format("%s%s%s", s, sep, time_left)
            else
                s = string.format("%s", time_left)
            end
        end

        return s or (self:text("hud_time_left") .. " " .. self:text("hud_overdue"))
    end

    if self.is_client then
        local s = nil

        if self.show_spawns_left then
            local spawns_left
            if self.spawn_numbers == 1 then
                spawns_left = self:text("hud_spawns_left") .. " " .. hud:GetSpawnsLeft()
            else
                spawns_left = self:text("hud_spawns_left_short") .. " " .. managers.enemy:GetNumberOfEnemies()
            end
            s = string.format("%s", spawns_left)
        end

        if self.show_time_left then
            local time_left = self:text("hud_time_left") .. " " .. self:FormatTimeLeft(hud:GetTimeLeft())
            if s then
                return string.format("%s%s%s", s, sep, time_left)
            else
                return string.format("%s", time_left)
            end
        end
    end
    return self:text("hud_time_left") .. " " .. self:text("hud_overdue")
end

function LocalizationManager:HUDBreakTimeInfo()
    if tweak and gai_state and assault_data and assault_data.active then
        return self:text("hud_break_time_left") .. " " .. self:FormatBreakTimeLeft(self:CalculateTimeLeftNoFormat(0))
    end

    if self.is_client then
        return self:text("hud_break_time_left") .. " " .. self:FormatBreakTimeLeft(hud:GetBreakTimeLeft())
    end
    return self:text("hud_break_time_left") .. " " .. self:FormatBreakTimeLeft(-60)
end

local function TimeFormat1(self, time_left)
    return string.format("%.2f", time_left)
end

local function TimeFormat2(self, time_left)
    return string.format("%.2f", time_left) .. " " .. self:text("hud_s")
end

local function TimeFormat3(self, time_left)
    return string.format("%.0f", time_left)
end

local function TimeFormat4(self, time_left)
    return string.format("%.0f", time_left) .. " " .. self:text("hud_s")
end

local function TimeFormat56_Common(time_left)
    local min = math.floor(time_left / 60)
    local s = math.floor(time_left % 60)
    if s >= 60 then
        s = s - 60
        min = min + 1
    end
    return min, s
end

local function TimeFormat5(self, time_left)
    local min, s = TimeFormat56_Common(time_left)
    return string.format("%.0f%s%s%s%.0f%s%s", min, " ", self:text("hud_min"), "  ", s, " ", self:text("hud_s"))
end

local function TimeFormat6(self, time_left)
    local min, s = TimeFormat56_Common(time_left)
    return string.format("%.0f%s%s", min, ":", (s <= 9 and "0" .. s or s))
end

local time_left_format = BAI:GetAAIOption("time_format")
if time_left_format == 1 then
    LocalizationManager.TimeFormat = TimeFormat1
elseif time_left_format == 2 then
    LocalizationManager.TimeFormat = TimeFormat2
elseif time_left_format == 3 then
    LocalizationManager.TimeFormat = TimeFormat3
elseif time_left_format == 4 then
    LocalizationManager.TimeFormat = TimeFormat4
elseif time_left_format == 5 then
    LocalizationManager.TimeFormat = TimeFormat5
else -- 6
    LocalizationManager.TimeFormat = TimeFormat6
end

function LocalizationManager:HUDWaveCounter()
    local macro = {
		current = managers.network:session():is_host() and gai_state:get_assault_number() or corner._wave_number,
		max = corner._max_waves or 0
	}

	return self:to_upper_text("hud_assault_waves", macro)
end