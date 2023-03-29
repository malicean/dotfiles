local BAI = BAI
function HUDAssaultCorner:ApplyCompatibility()
    self._hud_panel:child("assault_clone"):child("phase_timer"):set_visible(false)
    --self:_set_phase_time_visible(false)
    BAI:AddEvent(BAI.EventList.NormalAssaultOverride, function()
        managers.hud._hud_assault_corner:_set_phase_time_visible(true)
    end)

    local function ShowTimer()
        self:_set_phase_time_visible(true)
    end

    local function HideTimer()
        self:_set_phase_time_visible(false)
    end

    BAI:AddEvent(BAI.EventList.AssaultStart, ShowTimer)
    BAI:AddEvents({BAI.EventList.EndlessAssaultStart, BAI.EventList.AssaultEnd}, HideTimer)
end

local _BAI_get_assault_strings = HUDAssaultCorner._get_assault_strings
function HUDAssaultCorner:_get_assault_strings(state, aai)
    return _BAI_get_assault_strings(self)
end

function HUDAssaultCorner:_set_assault_phase(phase)
    phase = utf8.to_lower(phase)
    if phase == "regroup" then
        return
    end
	local assault_clone = self._hud_panel:child("assault_clone")
    assault_clone:child("phase_name"):set_text(managers.localization:text("hud_" .. phase))
    assault_clone:child("phase_name"):set_color(BAI:GetColor(phase))
end

function HUDAssaultCorner:_set_phase_time_visible(toggle)
    local assault_clone = self._hud_panel:child("assault_clone")
    assault_clone:child("phase_name"):set_visible(toggle)
    assault_clone:child("phase_timer"):set_visible(toggle)
end

Hooks:PostHook(GroupAIStateBesiege, "_begin_regroup_task", "bai_khud_detect_regroupphase", function(self)
	local end_t = self._task_data.regroup.end_t
    local start_t = self._task_data.regroup.start_t
    if Network:is_server() then 
        KineticHUD:sync_set_assault_phase(utf8.to_upper("regroup")) --todo localize
    end
    --[[if not BAI:IsOr(self._task_data.assault.phase, "control", "anticipation") then -- broken
        managers.hud:set_phase_timer(end_t)
    end]]
	KineticHUD:c_log(end_t - start_t, "Starting regroup: " .. tostring(end_t or "nil"))
end)