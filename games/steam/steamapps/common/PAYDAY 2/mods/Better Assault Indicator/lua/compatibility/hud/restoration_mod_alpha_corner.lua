local BAI = BAI
local t_total = 0
local t_break_total = 0
local t_max = BAI:GetAAIOption("aai_panel_update_rate")
function HUDAssaultCorner:SetHook(hook)
    if not BAI:ShowAdvancedAssaultInfo() then
        return
    end
    BAI:Animate(self._hud_panel:child("corner_panel"):child("aai"), hook and 1 or 0, hook and "FadeIn" or "FadeOut")
    if hook then
        t_total = 0
        managers.hud:add_updator("BAI_UpdateAAI", callback(self, self, "UpdateAdvancedAssaultInfo"))
    else
        managers.hud:remove_updator("BAI_UpdateAAI")
    end
end

function HUDAssaultCorner:SetBreakHook(hook, delay)
    if not BAI:IsAAIEnabledAndOption("show_break_time_left") then
        return
    end
    if hook then
        if BAI.IsClient then
            BAI:SetBreakTimer()
        end
        managers.hud:add_updator("BAI_UpdateBreakTimeInfo", callback(self, self, "UpdateBreakTimeInfo"))
    else
        managers.hud:remove_updator("BAI_UpdateBreakTimeInfo")
        t_break_total = 0
    end
    BAI:Animate(self._hud_panel:child("corner_panel"):child("break"), hook and 1 or 0, hook and "FadeIn" or "FadeOut")
end

local assault_data
if BAI.IsHost then
    local gai_state = managers.groupai:state()
    assault_data = gai_state and gai_state._task_data.assault
end

function HUDAssaultCorner:SetVariables()
    self.show_spawns_left = BAI:GetAAIOption("show_spawns_left")
    self.spawn_numbers = BAI:GetAAIOption("spawn_numbers")
    self.show_time_left = BAI:GetAAIOption("show_time_left")
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfo(t, dt)
    t_total = t_total + dt
    if t_total < t_max then
        return
    end
    t_total = 0
    if assault_data and assault_data.active then
        local spawns_left, time_left
        if self.show_spawns_left then
            if self.spawn_numbers == 1 then
                spawns_left = math.max(managers.localization:CalculateSpawnsLeft(), 0)
            else
                spawns_left = managers.enemy:GetNumberOfEnemies()
            end
        end

        if self.show_time_left then
            time_left = managers.localization:CalculateTimeLeft()
        end
        self:UpdateAlphaCornerText(time_left, spawns_left)
        return
    end

    if self.is_client then
        local time, spawns
        if self.show_spawns_left then
            if self.spawn_numbers == 1 then
                spawns = managers.hud:GetSpawnsLeft()
            else
                spawns = managers.enemy:GetNumberOfEnemies()
            end
        end

        if self.show_time_left then
            time = managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft())
        end
        self:UpdateAlphaCornerText(time, spawns)
    end
end

function HUDAssaultCorner:UpdateAlphaCornerText(time, spawns)
    local text
    if time then
        text = utf8.to_upper(managers.localization:text("hud_time_left_short") .. time)
    end
    if spawns then
        if text then
            text = text .. " | " .. utf8.to_upper(managers.localization:text("hud_spawns_left_short") .. spawns)
        else
            text = utf8.to_upper(managers.localization:text("hud_time_spawns_short") .. spawns)
        end
    end
    self._hud_panel:child("corner_panel"):child("aai"):set_text(text or "")
end

function HUDAssaultCorner:UpdateBreakTimeInfo(t, dt)
    t_break_total = t_break_total + dt
    if t_break_total < t_max then
        return
    end
    t_break_total = 0
    local break_text = managers.localization:text("hud_break_time_left_short")
    if self.is_host then
        self._hud_panel:child("corner_panel"):child("break"):set_text(break_text .. managers.localization:FormatBreakTimeLeft(managers.localization:CalculateTimeLeftNoFormat(0)))
    else
        self._hud_panel:child("corner_panel"):child("break"):set_text(break_text .. managers.localization:FormatBreakTimeLeft(managers.hud:GetBreakTimeLeft()))
    end
end