local original =
{
    InitAAIPanel = HUDAssaultCorner.InitAAIPanel,
    _offset_hostages = HUDAssaultCorner._offset_hostages,
    _set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
}

function HUDAssaultCorner:InitAAIPanel()
    original.InitAAIPanel(self)
    if not (self.AAIPanel and self.hudlist.hostages_hidden) then
        return
    end
    if self:should_display_waves() then
        return
    end

    self._time_left_panel:set_x(self._hud_panel:w() - self._time_left_panel:w())
    self._break_time_panel:set_x(self._time_left_panel:x())
    self._spawns_left_panel:set_right(self._time_left_panel:left() - 3)
end

function HUDAssaultCorner:ApplyObjectivesOffset(offset)
    if managers.hud._hud_objectives and managers.hud._hud_objectives.apply_offset then
        managers.hud._hud_objectives:apply_offset(offset)
    end
end

function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted, box_h)
    if self.hudlist.bai.assault_panel_position == 3 then
        original._offset_hostages(self, hostage_panel, is_offseted, box_h)
    end
end

function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if self.hudlist.bai.assault_panel_position < 3 then
        if is_offseted then
            self:start_assault_callback()
        elseif self.hudlist.move_hudlist then
            local offset = self.hudlist.hostages_hidden and 0 or 46
            self:MoveHUDList(offset)
        end
    else
        original._set_hostage_offseted(self, is_offseted)
    end
end