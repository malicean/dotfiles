local original =
{
    InitAAIPanel = HUDAssaultCorner.InitAAIPanel,
    _offset_hostages = HUDAssaultCorner._offset_hostages,
    _set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
}
local BAIFunctionForced = false
function HUDAssaultCorner:ApplyCompatibility()
    if not VHUDPlus then
        BAI:CrashWithErrorHUD("VanillaHUD Plus")
    end
    if BAI.settings.hudlist_compatibility == 1 then -- Disable detection
        self:LoadVanillaHUDPlusOptions()
    end
end

function HUDAssaultCorner:InitAAIPanel()
    original.InitAAIPanel(self)
    if not self.AAIPanel then
        return
    end
    if self:should_display_waves() then
        if VHUDPlus:getSetting({"AssaultBanner", "WAVE_COUNTER"}, true) then
            if self.vhudplus.hostages_hidden_ex then
                self._time_left_panel:set_x(self._hud_panel:w() - self._time_left_panel:w())
            else
                self._time_left_panel:set_right(self._hud_panel:child("hostages_panel"):left() - 3)
            end
        else
            self._time_left_panel:set_right(self._hud_panel:child("wave_panel"):left() - 3)
        end
        self._break_time_panel:set_x(self._time_left_panel:x())
        self._spawns_left_panel:set_right(self._time_left_panel:left() - 3)
        return
    end
    if not self.vhudplus.hostages_hidden_ex then
        return
    end

    self._time_left_panel:set_x(self._hud_panel:w() - self._time_left_panel:w())
    self._break_time_panel:set_x(self._time_left_panel:x())
    self._spawns_left_panel:set_right(self._time_left_panel:left() - 3)
end

function HUDAssaultCorner:WaveCounterEnabled()
    return false
end

function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted, box_h)
    if not self.vhudplus.center then
        original._offset_hostages(self, hostage_panel, is_offseted, box_h)
    end
end

function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if self.vhudplus.center then
        if is_offseted then
            self:start_assault_callback()
        elseif self.vhudplus.move_hudlist then
            local offset = self.vhudplus.hostages_hidden_ex and 0 or 46
            self:MoveHUDList(offset)
        end
    else
        original._set_hostage_offseted(self, is_offseted)
    end
end