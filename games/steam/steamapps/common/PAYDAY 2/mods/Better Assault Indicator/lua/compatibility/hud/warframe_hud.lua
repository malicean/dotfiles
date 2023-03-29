function HUDAssaultCorner:ApplyCompatibility()
    if not HopLib then
        BAI:CrashWithErrorHUDLibrary("Warframe HUD", "HopLib")
    end
    if not WFHud then
        BAI:CrashWithErrorHUD("Warframe HUD")
    end
end

-- Copy of Warframe's HUD code
function HUDAssaultCorner:show_point_of_no_return_timer(id)
    BAI:DelayCall("BAI_WarframeHUD_CloseAssaultBox", 1, function()
        self:_close_assault_box()
    end)
	local noreturn_data = self:_get_noreturn_data(id)
	WFHud.objective_panel:set_point_of_no_return(managers.localization:to_upper_text(noreturn_data.text_id))
    self._point_of_no_return = true
end

function HUDAssaultCorner:hide_point_of_no_return_timer()
	WFHud.objective_panel:set_point_of_no_return(nil)
    self._point_of_no_return = false
end

function HUDAssaultCorner:_popup_wave_finished()
end