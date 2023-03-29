local BAI = BAI
local BAI_original =
{
    _get_assault_strings = HUDAssaultCorner._get_assault_strings,
    _get_assault_endless_strings = HUDAssaultCorner._get_assault_endless_strings,
    _get_survived_assault_strings = HUDAssaultCorner._get_survived_assault_strings,
    _get_state_strings = HUDAssaultCorner._get_state_strings
}
local function RemoveAssaultTextSpacer(tbl, spacer)
    for i = 1, #tbl, 1 do
        if type(tbl[i]) == "string" and tbl[i] == spacer then
            table.remove(tbl, i)
        end
    end
    return tbl
end

function HUDAssaultCorner:ApplyCompatibility()
    if not CSGOHUD then
        BAI:CrashWithErrorHUD("CS:GO HUD")
    end
    if not CSGOHUD:GetComponentOption("assault_panel") then
        BAI:CrashWithErrorHUDOption("CS:GO HUD", "Components -> Assault Panel")
    end
end

function HUDAssaultCorner:UpdatePONRBox()
    self._noreturn_color = BAI:GetColor("escape")
    self._hud_panel:child("point_of_no_return_panel"):child("noreturn_text"):set_color(self._noreturn_color)
    self._hud_panel:child("point_of_no_return_panel"):child("icon_noreturnbox"):set_color(self._noreturn_color)
end

function HUDAssaultCorner:_get_assault_strings(state, aai)
    local tbl = BAI_original._get_assault_strings(self, state, aai)
    return RemoveAssaultTextSpacer(tbl, self._assault_mode == "normal" and "hud_assault_end_line" or "hud_assault_padlock")
end

function HUDAssaultCorner:_get_assault_endless_strings()
    local tbl = BAI_original._get_assault_endless_strings(self)
    return RemoveAssaultTextSpacer(tbl, "hud_assault_padlock")
end

function HUDAssaultCorner:_get_survived_assault_strings(endless)
    local tbl = BAI_original._get_survived_assault_strings(self, endless)
    local end_line = "hud_assault_" .. (endless and "padlock" or "end_line")
    return RemoveAssaultTextSpacer(tbl, end_line)
end

function HUDAssaultCorner:_get_state_strings(state)
    local tbl = BAI_original._get_state_strings(self, state)
    return RemoveAssaultTextSpacer(tbl, "hud_assault_end_line")
end

function HUDAssaultCorner:SetImage(image)
    if image then
        local texture = tweak_data.csgo.textures.assault_panel.texture
        local texture_rect
        if image == "padlock" then
            self.was_endless = true
            texture = "guis/textures/pd2/hud_icon_padlockbox"
            texture_rect = {0, 0, 32, 32}
        else
		    texture_rect = tweak_data.csgo.textures.assault_panel[image]
        end
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):set_image(texture, unpack(texture_rect))
    end
end

function HUDAssaultCorner:_end_assault()
    if not self._assault then
         self._start_assault_after_hostage_offset = nil
         return
    end
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    self:_set_feedback_color(nil)
    self._assault = false
    local endless_assault = self._assault_endless
    self._assault_endless = false
    self.assault_type = nil
    self._remove_hostage_offset = true
    self._start_assault_after_hostage_offset = nil
    local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	local text_panel = assault_panel:child("text_panel")
    icon_assaultbox:stop()
    if self:should_display_waves() then
        self:_update_assault_hud_color(self._assault_survived_color)
        self:_set_text_list(self:_get_survived_assault_strings())
        text_panel:stop()
        text_panel:animate(callback(self, self, "_animate_text"), assault_panel, nil, callback(self, self, "assault_attention_color_function"))
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))
        self._wave_bg_box:stop()
        self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            self:_update_assault_hud_color(self._assault_survived_color)
            if endless_assault then
                self:SetImage("padlock")
            end
            self:_set_text_list(self:_get_survived_assault_strings(endless_assault))
            text_panel:stop()
            text_panel:animate(callback(self, self, "_animate_text"), assault_panel, nil, callback(self, self, "assault_attention_color_function"))
            icon_assaultbox:stop()
            icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))
            text_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        else
            if BAI:GetOption("show_assault_states") then
                BAI:UpdateAssaultStateOverride("control", true)
            else
                self:_close_assault_box()
                BAI:CallEvent("MoveHUDListBack", self)
            end
        end
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end
    self.trigger_assault_start_event = true -- Used for AssaultStart event; bugfix
end

function HUDAssaultCorner:_hide_icon_assaultbox(icon_assaultbox)
    local t = 1
	while t > 0 do
		t = t - coroutine.yield()
		icon_assaultbox:set_alpha(t)
		if self._remove_hostage_offset and t < 0.3 then
			self:_set_hostage_offseted(false)
		end
	end
    if self._remove_hostage_offset then
        self:_set_hostages_offseted(false)
    end
    icon_assaultbox:set_alpha(0)
    if self._casing_show_hostages then
        self._casing_show_hostages = false
        self:_show_hostages() -- Hack; Figure out a better solution
    end
    if BAI:IsHostagePanelVisible() and not self._casing then
        self:_show_hostages(true) -- Another hack; TODO: Revise BAI animation functions
    end
end

function HUDAssaultCorner:show_point_of_no_return_timer(id)
	local delay_time = self._assault and 1.2 or 0

	self:_close_assault_box()
    self:_update_noreturn(id)

	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")

    self:_hide_hostages()
	point_of_no_return_panel:stop()
	point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
	self:_set_feedback_color(self._noreturn_color)

	self._point_of_no_return = true
end

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
	local function flash_timer(o)
		local t = 0

		while t < 0.5 do
			t = t + coroutine.yield()
			local n = 1 - math.sin(t * 180)
			local r = math.lerp(self._noreturn_color.r, 1, n)
			local g = math.lerp(self._noreturn_color.g, 0.8, n)
			local b = math.lerp(self._noreturn_color.b, 0.2, n)

			o:set_color(Color(r, g, b))
			o:set_font_size(math.lerp(tweak_data.hud_corner.noreturn_size, tweak_data.hud_corner.noreturn_size * 1.25, n))
		end
	end

	local point_of_no_return_timer = self._hud_panel:child("point_of_no_return_panel"):child("noreturn_time")

	point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    if self.was_endless then
        self:SetImage("assault")
        self.was_endless = false
    end
    self:SetTextListAndAnimateColor(state, true)
    if override then
        self:_start_assault(self:_get_state_strings(state))
        self:_update_assault_hud_color(BAI:GetColor(state))
    end
end