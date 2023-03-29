local BAI = BAI
function HUDAssaultCornerVR:show_point_of_no_return_timer(id, ...)
    local delay_time = self._assault and 1.2 or 0

    self:_close_assault_box()
    self:_update_noreturn(id)
    self._hud_panel:child("point_of_no_return_panel"):stop()
    self._hud_panel:child("point_of_no_return_panel"):animate(callback(self, self, "_animate_show_noreturn"), delay_time)
    self._watch_point_of_no_return_timer:set_visible(true)
    self:_set_feedback_color(self._noreturn_color)

    self._point_of_no_return = true

    managers.hud._hud_heist_timer:hide()
end

HUDAssaultCornerVR.VR_InitAAIPanel = HUDAssaultCorner.InitAAIPanel
function HUDAssaultCornerVR:InitAAIPanel()
    self:VR_InitAAIPanel()
    if not self.AAIPanel then
        return
    end
    self._spawns_left_panel:set_x(0)
    self._break_time_panel:set_x(0)
    self._time_left_panel:set_left(self._spawns_left_panel:right())
end

HUDAssaultCornerVR.VR_InitCaptainPanel = HUDAssaultCorner.InitCaptainPanel
function HUDAssaultCorner:InitCaptainPanel()
    self:VR_InitCaptainPanel()
    if not self.AAIPanel then
        return
    end
    self._captain_panel:set_x(0)
end

function HUDAssaultCornerVR:_set_hostage_offseted(is_offseted, ...)
	if is_offseted then
		self:start_assault_callback()
	end
end

function HUDAssaultCornerVR:_set_hostages_offseted(is_offseted, ...)
end

function HUDAssaultCornerVR:UpdateAssaultPanelPosition()
end