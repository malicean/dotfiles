local BAI = BAI
dofile(BAI.LuaPath .. "compatibility.lua")
function HUDManager:InitVariables()
    self._assault_mode = "assault"
    if BAI.IsClient then
        local function SetTime5(active)
            if not active then
                self:SetTimeLeft(5)
            end
        end
        BAI:AddEvent(BAI.EventList.Captain, SetTime5)
        if BAI._cache.level_id == "hox_1" then
            local function SetSpawnsLocal()
                self:SetSpawnsLeft(BAI:CalculateSpawnsFromDiff())
            end
            BAI:AddEvent(BAI.EventList.NormalAssaultOverride, SetTime5, nil, 1)
            BAI:AddEvent(BAI.EventList.NormalAssaultOverride, SetSpawnsLocal, nil, 2)
        end
        BAI:AddEvent(BAI.EventList.AssaultStart, function()
            managers.enemy.force_spawned = 0
        end)
    end
    BAI:AddEvent(BAI.EventList.EndlessAssaultStart, function()
        BAI._cache.AssaultType = BAI.Enum.AssaultType.Endless
    end, nil, 100)
    BAI:AddEvent(BAI.EventList.AssaultEnd, function()
        BAI._cache.AssaultType = BAI.Enum.AssaultType.None
    end)
    BAI:AddEvents({BAI.EventList.AssaultStart, BAI.EventList.NormalAssaultOverride}, function()
        BAI._cache.AssaultType = BAI.Enum.AssaultType.Normal
    end, nil, 200)
end

function HUDManager:GetAssaultMode()
    return self._assault_mode
end

function HUDManager:StartEndlessAssault()
    if BAI._cache.AssaultType == BAI.Enum.AssaultType.NoReturn then
        return
    end
    self:SetEndlessClient()
    self._hud_assault_corner:StartEndlessAssault()
end

function HUDManager:SetEndlessClient()
    self._hud_assault_corner:SetEndlessClient()
end

function HUDManager:SetCompatibleHost(BAIHost)
    BAI:SetCompatibleHost(BAIHost)
    self._hud_assault_corner:SetCompatibleHost(BAIHost)
end

function HUDManager:SetNormalAssaultOverride()
    if BAI._cache.AssaultType ~= BAI.Enum.AssaultType.Endless then
        return
    end
    BAI._cache.AssaultType = BAI.Enum.AssaultType.Normal
    BAI:CallEvent(BAI.EventList.NormalAssaultOverride)
end

function HUDManager:UpdateColors()
    self._hud_assault_corner:UpdateColors()
end

local _f_sync_set_assault_mode = HUDManager.sync_set_assault_mode
function HUDManager:sync_set_assault_mode(mode, ...)
    if self._assault_mode ~= mode then
        self._assault_vip = mode == "phalanx"
        self._assault_mode = mode
        BAI._cache.AssaultType = BAI.Enum.AssaultType[self._assault_vip and "Captain" or "Normal"]
        BAI:CallEvent(BAI.EventList.Captain, self._assault_vip)
        _f_sync_set_assault_mode(self, mode, ...)
    end
end

local _f_show_point_of_no_return_timer = HUDManager.show_point_of_no_return_timer
function HUDManager:show_point_of_no_return_timer(tweak_id, ...)
    BAI:CallEvent(BAI.EventList.NoReturn, true, tweak_id)
    BAI._cache.AssaultType = BAI.Enum.AssaultType.NoReturn
    _f_show_point_of_no_return_timer(self, tweak_id, ...)
end

local _f_hide_point_of_no_return_timer = HUDManager.hide_point_of_no_return_timer
function HUDManager:hide_point_of_no_return_timer(...)
    BAI:CallEvent(BAI.EventList.NoReturn, false)
    BAI._cache.AssaultType = BAI.Enum.AssaultType.None
    _f_hide_point_of_no_return_timer(self, ...)
end

function HUDManager:IsHost()
    return BAI.IsHost
end

function HUDManager:IsClient()
    return BAI.IsClient
end

function HUDManager:IsSkirmish()
    return BAI._cache.is_skirmish
end

function HUDManager:GetTimeLeft()
    return BAI._cache.client_time_left - TimerManager:game():time()
end

function HUDManager:GetSpawnsLeft()
    return math.floor(BAI._cache.client_spawns_left - managers.enemy.force_spawned)
end

function HUDManager:GetBreakTimeLeft()
    return BAI._cache.client_break_time_left - TimerManager:game():time()
end

function HUDManager:SetTimeLeft(time)
    if BAI.IsHost then
        return
    end
    BAI._cache.client_time_left = TimerManager:game():time() + time
end

function HUDManager:SetSpawnsLeft(spawns)
    if BAI.IsHost then
        return
    end
    BAI._cache.client_spawns_left = spawns
end

function HUDManager:GetCompatibleHost()
    return BAI.CompatibleHost
end

function HUDManager:GetBAIHost()
    return BAI.BAIHost
end

function HUDManager:SetCaptainBuff(buff)
    if buff < 0 then
        buff = 0
    end
    self._hud_assault_corner:SetCaptainBuff(buff)
end

BAI:Init()
local function ApplyCompatibility(self, class)
    BAI:PostInit()
    class = class or "HUDAssaultCorner"
    BAI:ApplyHUDCompatibility(BAI.settings.hud_compatibility)
    if self._hud_assault_corner and self._hud_assault_corner.InitBAI then
        self:InitVariables()
        self._hud_assault_corner:InitBAI()
        BAI:Log("Successfully initialized") --If the mod doesn't crash above, then this is the good sign that something works here
    else
        BAI:Log("Can't execute code in " .. class .. "! Are you sure it wasn't deleted?", BAI.Enum.LogType.Warning)
    end
end

if ArmStatic and MUIMenu and MUIMenu:ClassEnabled("MUIStats") and MUIStats then
    Hooks:Add("HUDManagerSetupPlayerInfoHudPD2", "BAI_MUI_setup", function(self)
        ApplyCompatibility(self, "MUIStats")
    end)
else
    BAI:Hook(HUDManager, "_create_assault_corner", function(self)
        ApplyCompatibility(self)
    end)
end

local _f_sync_start_assault = HUDManager.sync_start_assault
function HUDManager:sync_start_assault(assault_number, ...)
    BAI:SetTimer()
    _f_sync_start_assault(self, assault_number, ...)
end

--[[if HUDListManager then
    local _f_activate_objective = HUDManager.activate_objective
    function HUDManager:activate_objective(data)
        _f_activate_objective(self, data)
        if self._hud_assault_corner.assault_panel_position == 1 then
            managers.hudlist:change_setting("left_list_y", data.amount and 108 or 86)
        end
    end
end]]

function HUDManager:DebugState(state, override, stealth_broken, no_as_mod)
    managers.chat:_receive_message(1, "[BAI]", "state: " .. tostring(state) .. "; override: " .. tostring(override) .. "; stealth_broken: " .. tostring(stealth_broken) .. "; no_as_mod: " .. tostring(no_as_mod), Color.white)
end

function HUDManager:DebugEvent(event_name)
    managers.chat:_receive_message(1, "[BAI]", "Event called: " .. tostring(event_name), Color.yellow)
end

dofile(BAI.LuaPath .. "network.lua")