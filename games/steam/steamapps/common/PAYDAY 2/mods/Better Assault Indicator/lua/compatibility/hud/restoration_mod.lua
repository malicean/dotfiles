local BAI = BAI
function HUDAssaultCorner:ApplyCompatibility()
    if not restoration then
        BAI:CrashWithErrorHUD("Restoration Mod")
    end
    self.is_safehouse_raid = managers.job:current_level_id() == "chill_combat"
    self._v2_corner = restoration.Options:GetValue("HUD/AssaultStyle") == 2
    self:InitCornerText()
    if self._v2_corner then
        dofile(BAI.HUDCompatibilityPath .. "restoration_mod_alpha_corner.lua")
        self:SetVariables()
        BAI:AddHookEvents()
    end
    self._max_waves = 0
    if self:has_waves() then
        self._max_waves = managers.job:current_level_wave_count()
        self._hud_panel:child("wave_panel"):set_visible(true)
        if self._v2_corner then
            self:ForceWaveCounterFunction(0)
        end
    end
end

function HUDAssaultCorner:InitCornerText()
    local corner_panel = self._hud_panel:child("corner_panel")
    local aai = corner_panel:text({
        name="aai",
		text="AAI",
		layer = 11,
		valign="top",
		align = "center",
		vertical = "center",
		x = 0,
		y = 0,
		color = Color.white,
		font_size = 28,
        font = "fonts/font_medium_shadow_mf",
        visible = true,
        alpha = 0
    })
    aai:set_rotation(45)
    aai:set_top(-17)
    aai:set_right(234)
    local brk = corner_panel:text({
        name="break",
		text="Break: ",
		layer = 11,
		valign="top",
		align = "center",
		vertical = "center",
		x = 0,
		y = 0,
		color = Color.white,
		font_size = 28,
        font = "fonts/font_medium_shadow_mf",
        visible = true,
        alpha = 0
    })
    brk:set_rotation(45)
    brk:set_top(-17)
    brk:set_right(234)
end

function HUDAssaultCorner:InitAAIPanel()
    if self._v2_corner then
        return
    end

    local right
    local icons = tweak_data.bai
    if self:has_waves() then
        if self:WaveCounterEnabled() then
            if self._wave_counter == 1 then
                right = self._hud_panel:child("wave_panel"):left() - 3
            else
                right = self._hud_panel:child("hostages_panel"):left() - 3
            end
        else
            right = self._hud_panel:child("wave_panel"):left() - 3
        end
    else
        right = self._hud_panel:child("hostages_panel"):left() - 3
    end

	self._time_left_panel = self._hud_panel:panel({
		name = "time_panel",
		w = 200,
        h = 200,
        alpha = 0,
        visible = true
    })
    local time_panel = self._time_left_panel

    time_panel:set_top(0)
    time_panel:set_right(right)

	self._time_left_text = time_panel:text({
		vertical = "center",
		name = "time_left",
		align = "left",
		text = "04:20",
		y = 0,
		x = time_panel:w() - 42,
		valign = "center",
		w = 40,
        h = 48,
        layer = 1,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })
    local time_left = self._time_left_text

    local time_icon = time_panel:bitmap({
        texture = icons.time_left.texture,
        texture_rect = icons.time_left.texture_rect,
		name = "time_icon",
		layer = 1,
		y = 0,
		x = time_panel:w() - time_left:w() - 48,
        valign = "top",
        h = 48,
        w = 48
    })

    self._break_time_panel = self._hud_panel:panel({
		name = "break_time_panel",
		w = 200,
        h = 200,
        alpha = 0,
        visible = true
    })
    local break_panel = self._break_time_panel

    break_panel:set_top(0)
    break_panel:set_right(right)

	self._break_time_text = break_panel:text({
		vertical = "center",
		name = "break_time_left",
		align = "left",
		text = "04:20",
		y = 0,
		x = time_panel:w() - 42,
		valign = "center",
		w = 40,
        h = 48,
        layer = 1,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })
    local break_time_left = self._break_time_text

    local break_icon = break_panel:bitmap({
        texture = icons.spawns_left.texture,
		name = "break_icon",
		layer = 1,
		y = 0,
		x = break_panel:w() - break_time_left:w() - 48,
        valign = "top",
        h = 48,
        w = 48
    })

    self._spawns_left_panel = self._hud_panel:panel({
		name = "spawns_panel",
		w = 200,
        h = 200,
        alpha = 0,
        visible = true
    })
    local spawns_panel = self._spawns_left_panel

    spawns_panel:set_top(0)
    spawns_panel:set_right(time_panel:left() - 3)

    self._spawns_left_text = spawns_panel:text({
		layer = 1,
		vertical = "center",
		name = "spawns_left",
		align = "left",
		text = "0420",
		y = 0,
		x = spawns_panel:w() - 42,
		valign = "center",
		w = 40,
		h = 48,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })
    local spawns_left = self._spawns_left_text

	local spawns_icon = spawns_panel:bitmap({
        texture = icons.spawns_left.texture,
		name = "spawns_icon",
		layer = 1,
		y = 0,
		x = spawns_panel:w() - spawns_left:w() - 48,
        valign = "top",
        h = 48,
        w = 48
    })

    -- Alignment after creation
    local ow = select(3, time_left:text_rect())
    local hud_overdue = managers.localization:text("hud_overdue")
    time_left:set_text(hud_overdue)
    break_time_left:set_text(hud_overdue)
    local w = select(3, time_left:text_rect())
    if ow == w then
        w = 0
    else
        w = w - ow
    end
    time_left:set_w(40 + w)
    time_panel:set_w(time_panel:w() + w)
    time_panel:set_x(time_panel:x() + (w * 4))
    time_left:set_text("04:20")
    break_time_left:set_w(40 + w)
    break_panel:set_w(break_panel:w() + w)
    break_panel:set_x(time_panel:x())
    break_time_left:set_text("04:20")
    spawns_panel:set_x(spawns_panel:x() + 200)
    self:InitAAIPanelEvents()
end

function HUDAssaultCorner:InitCaptainPanel()
	self._captain_panel = self._hud_panel:panel({
		name = "captain_panel",
		w = 205,
        h = 200,
        y = self._v2_corner and self._hud_panel:child("corner_panel"):h() or (self._hud_panel:child("assault_panel"):h() + 8),
        alpha = 0,
        visible = true
    })
    local captain_panel = self._captain_panel

    if BAI:IsHostagePanelVisible("captain") then
        captain_panel:set_right(self._hud_panel:child("hostages_panel"):left() - 3 + 80)
    else
        captain_panel:set_x(self._hud_panel:w() - 205) -- Change the number when they change it
    end

	local num_reduction = captain_panel:text({
		vertical = "center",
		name = "num_reduction",
		align = "left",
		text = "0%",
		y = 0,
		x = captain_panel:w() - 42,
		valign = "center",
		w = 45,
        h = 48,
        layer = 1,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size * 1.5
    })

    local captain_icon = captain_panel:bitmap({
        texture = tweak_data.bai.captain.texture,
		name = "captain_icon",
		layer = 1,
		y = 0,
		x = captain_panel:w() - num_reduction:w() - 48,
        valign = "top",
        h = 48,
        w = 48
    })

    self:InitCaptainPanelEvents()
end

function HUDAssaultCorner:UpdatePONRBox()
    self._noreturn_color = BAI:GetColor("escape")
    self._hud_panel:child("point_of_no_return_panel"):child("point_of_no_return_text"):set_color(self._noreturn_color)
    self._hud_panel:child("point_of_no_return_panel"):child("point_of_no_return_timer"):set_color(self._noreturn_color)
end

local _BAI_UpdateColors = HUDAssaultCorner.UpdateColors
function HUDAssaultCorner:UpdateColors()
    _BAI_UpdateColors(self)
    self._assault_corner_color, self._assault_corner2_color = BAI:GetColorRestoration("assault")
    self._assault_endless_corner_color, self._assault_endless_corner2_color = BAI:GetColorRestoration("endless")
    self._wave_corner_color, self._wave_corner2_color = BAI:GetColorRestoration("survived")
    self._captain_corner_color, self._captain_corner2_color = BAI:GetColorRestoration("captain")
    if self.is_skirmish then
        self._assault_corner_color, self._assault_corner2_color = BAI:GetColorRestoration("holdout")
    end
end

local _restoration_RestorationValueChanged = HUDAssaultCorner.RestorationValueChanged
function HUDAssaultCorner:RestorationValueChanged()
    _restoration_RestorationValueChanged(self)
    self:UpdateColors()
end

local _BAI_sync_set_assault_mode = HUDAssaultCorner.sync_set_assault_mode
function HUDAssaultCorner:sync_set_assault_mode(mode)
    _BAI_sync_set_assault_mode(self, mode)
    if self._v2_corner then
        if mode == "phalanx" then
            self:_update_corner_color(nil, "captain", true)
            self:SetAlphaCornerText("captain")
        else
            if BAI:GetOption("show_assault_states") then
                self:_update_corner_color("fade", nil, true)
                self:SetAlphaCornerText("fade")
            else
                self:_update_corner_color(nil, "assault", true)
                self:SetAlphaCornerText(self:GetAssaultText())
            end
        end
    end
end

local _BAI_start_endless_assault = HUDAssaultCorner._start_endless_assault
function HUDAssaultCorner:_start_endless_assault(text_list)
    _BAI_start_endless_assault(self, text_list)
    if self._v2_corner then
        self:SetAlphaCornerText("endless")
        self:_update_corner_color(nil, "assault_endless")
    end
end

function HUDAssaultCorner:_start_assault(text_list)
    self._assault = true
    if self._v2_corner then
        local corner_panel = self._hud_panel:child("corner_panel")
        corner_panel:set_visible(true)
        corner_panel:stop()
        corner_panel:animate(callback(self, self, "_animate_assault_corner"))
        if BAI:GetOption("show_assault_states") and BAI:IsStateEnabled("build") and self.assault_type then
            self:SetAlphaCornerText("build")
            self:_update_corner_color("build")
        elseif self.assault_type then
            self:SetAlphaCornerText(self:GetAssaultText())
            self:_update_corner_color(nil, "assault")
        end
    else
        text_list = text_list or {""}
        self:_set_text_list(text_list)
        local assault_panel = self._hud_panel:child("assault_panel")
        local text_panel = assault_panel:child("text_panel")
        if text_panel then
            text_panel:stop()
            text_panel:clear()
        else
            assault_panel:panel({name = "text_panel"})
        end
        assault_panel:set_visible(true)
        text_panel:stop()
        assault_panel:stop()
        assault_panel:animate(callback(self, self, "_animate_assault"))
        text_panel:animate(callback(self, self, "_animate_text"), nil, nil, nil)
    end
    self:_set_feedback_color(self._assault_color)

    if BAI:IsHostagePanelHidden(self.assault_type) then
        self:_hide_hostages()
    end

    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        if self.is_skirmish then
            self:_popup_wave_started()
        end
        BAI:CallEvent(BAI.EventList.AssaultStart)
    end
end

function HUDAssaultCorner:_end_assault()
    if not self._assault then
        self._start_assault_after_hostage_offset = nil
        return
    end
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    self._remove_hostage_offset = true
    self._start_assault_after_hostage_offset = nil
    self._assault = false
    local endless_assault = self._assault_endless
    self._assault_endless = false
    self:_set_feedback_color(nil)
    local corner_panel = self._hud_panel:child("corner_panel")
    corner_panel:set_visible(false)
    corner_panel:stop()
    local assault_panel = self._hud_panel:child("assault_panel")
    local text_panel = assault_panel:child("text_panel")
    text_panel:stop()
    text_panel:clear()
    assault_panel:stop()
    if self:has_waves() then
        assault_panel:set_visible(not self._v2_corner)
        local wave_panel = self._hud_panel:child("wave_panel")

        if self._v2_corner then
            self:_update_corner_color(nil, "wave")
            self:SetAlphaCornerText("survived")
            corner_panel:set_visible(true)
            corner_panel:animate(callback(self, self, "_animate_wave_corner"))
        else
            self:_start_assault(self:_get_survived_assault_strings())
            self:_update_assault_hud_color(self._assault_survived_color)
        end

        wave_panel:animate(callback(self, self, "_animate_wave_completed"), self)

        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else -- Hack! Don't try to fix it
        assault_panel:set_visible(not self._v2_corner)
        if BAI:GetOption("show_wave_survived") then
            if self._v2_corner then
                self:_update_corner_color(nil, "wave")
                self:SetAlphaCornerText("survived")
                corner_panel:set_visible(true)
                corner_panel:animate(callback(self, self, "_animate_wave_corner"))
                corner_panel:animate(callback(self, self, "_animate_normal_wave_completed"))
            else
                self:_start_assault(self:_get_survived_assault_strings(endless_assault))
                self:_update_assault_hud_color(self._assault_survived_color)
                text_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
            end
        else
            if BAI:GetOption("show_assault_states") then
                BAI:UpdateAssaultStateOverride("control", true)
                if BAI:IsHostagePanelVisible() then
                    self:_show_hostages()
                end
            else
                self:_close_assault_panel()
                BAI:CallEvent("MoveHUDListBack", self)
            end
        end
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end

    self.trigger_assault_start_event = true
end

function HUDAssaultCorner:has_waves()
    return self.is_safehouse_raid or self.is_skirmish
end

function HUDAssaultCorner:_animate_normal_wave_corner(panel, hud)
    wait(8.6)
    if BAI:GetOption("show_assault_states") then
        BAI:UpdateAssaultStateOverride("control")
        if BAI:IsHostagePanelVisible() then
            self:_show_hostages()
        end
    else
        self:_close_assault_panel()
        BAI:CallEvent("MoveHUDListBack", self)
    end
end

function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud)
    local wave_text = panel:child("num_waves")
    wait(1.4)
    wave_text:set_text(self:get_completed_waves_string())
    wait(7.2)
    if BAI:GetOption("show_assault_states") then
        BAI:UpdateAssaultStateOverride("control")
    else
        assault_hud:_close_assault_panel()
        BAI:CallEvent("MoveHUDListBack", self)
    end
end

function HUDAssaultCorner:show_point_of_no_return_timer(id)
    local delay_time = self._assault and 1.2 or 0
    self:_close_assault_panel()
    self:_update_noreturn(id)
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    point_of_no_return_panel:stop()
    point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
    self:_hide_hostages()
    self._hud_panel:child("point_of_no_return_panel"):set_visible(true)
    self._point_of_no_return = true
    self:_set_feedback_color(self._noreturn_color)
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    if self._v2_corner then
        self:_update_corner_color(state, nil, true)
        self:SetAlphaCornerText(state)
        self._hud_panel:child("corner_panel"):animate(callback(self, self, "_animate_wave_corner"))
    else
        if override then
            self:_start_assault(self:_get_state_strings(state))
            self:_update_assault_hud_color(BAI:GetColor(state))
        else
            self:_set_text_list(self:_get_state_strings(state))
            self:_animate_update_assault_hud_color(BAI:GetColor(state))
        end
    end
end

function HUDAssaultCorner:OpenAssaultPanelWithAssaultState(assault_state)
    self.trigger_assault_start_event = false
    self:_start_assault(self:_get_state_strings(assault_state))
    if self._v2_corner then
        self._hud_panel:child("corner_panel"):stop()
        self._hud_panel:child("corner_panel"):animate(callback(self, self, "_animate_wave_corner"))
        self:SetAlphaCornerText(assault_state)
        self:_update_corner_color(assault_state, nil, nil)
    else
        self:_update_assault_hud_color(BAI:GetColor(assault_state))
    end
    self:_set_hostage_offseted(true)
    self.trigger_assault_start_event = true
    BAI:CallEvent("MoveHUDList", self)
end

function HUDAssaultCorner:SetTextListAndAnimateColor(assault_state, is_control_or_anticipation)
    if assault_state then
        if self._v2_corner then
            self:_update_corner_color(assault_state, nil, true)
            self:SetAlphaCornerText(assault_state)
        else
            self:_animate_update_assault_hud_color(BAI:GetColor(assault_state))
            if is_control_or_anticipation then
                self:_set_text_list(self:_get_state_strings(assault_state))
            else
                self:_set_text_list(self:_get_assault_strings(assault_state, true))
            end
        end
    else
        if self._v2_corner then
            self:_update_corner_color(nil, "assault", true)
            self:SetAlphaCornerText(self:GetAssaultText())
        else
            self:_animate_update_assault_hud_color(self._assault_color)
            self:_set_text_list(self:_get_assault_strings(nil, true))
        end
    end
end

function HUDAssaultCorner:SetAlphaCornerText(text)
    text = text or "assault"
    if BAI:IsCustomTextDisabled(text) and BAI:ShowFSSAI() then
        text = "fss_mod_" .. math.random(3)
    end
    self._hud_panel:child("corner_panel"):child("corner_title"):set_text(utf8.to_upper(managers.localization:text("hud_" .. text)))
end

local _BAI_get_assault_strings = HUDAssaultCorner._get_assault_strings
function HUDAssaultCorner:_get_assault_strings(state, aai)
    local tbl = _BAI_get_assault_strings(self, state, aai)
    if self._assault_mode ~= "normal" then
        return tbl
    end
    if BAI:GetHUDOption("restoration_mod", "use_alpha_assault_text") and BAI:IsCustomTextDisabled("assault") then
        for k, v in ipairs(tbl) do
            if v ~= Idstring("risk") and v == "hud_assault_assault" then
                tbl[k] = "hud_assault_alpha" .. self:GetFactionAssaultText()
            end
        end
    end
    if BAI:GetHUDOption("restoration_mod", "include_cover_text") then
        table.insert(tbl, 3, "hud_cover")
        table.insert(tbl, 4, "hud_assault_end_line")
        local plus = managers.job:current_difficulty_stars() > 0 and 2 or 0
        table.insert(tbl, 7 + plus, "hud_cover")
        table.insert(tbl, 8 + plus, "hud_assault_end_line")
    end
    return tbl
end

local _BAI_get_assault_endless_strings = HUDAssaultCorner._get_assault_endless_strings
function HUDAssaultCorner:_get_assault_endless_strings()
    local tbl = _BAI_get_assault_endless_strings(self)
    if BAI:GetHUDOption("restoration_mod", "use_alpha_endless_text") and BAI:IsCustomTextDisabled("endless") then
        for k, v in ipairs(tbl) do
            if v ~= Idstring("risk") and v == "hud_assault_endless" then
                tbl[k] = "hud_assault_endless_alpha" .. self:GetFactionAssaultText()
            end
        end
    end
    return tbl
end

function HUDAssaultCorner:GetAssaultText()
    if BAI:ShowFSSAI() then
        return "fss_mod_" .. math.random(3)
    end
    if BAI:GetOption("show_difficulty_name_instead_of_skulls") and not self.is_crimespree then
        local name = self:GetDifficultyName() -- For instances where "tweak_data is nil"
        if name and name ~= Idstring("risk") then
            return name
        end
    end
    return "assault"
end

function HUDAssaultCorner:_update_corner_color(state, color, animate)
    local c1, c2
    if state then
        c1, c2 = BAI:GetColorRestoration(state)
    else
        c1 = self["_" .. color .. "_corner_color"]
        c2 = self["_" .. color .. "_corner2_color"]
    end
    if animate then
        if BAI:GetAnimationOption("enable_animations") then
            local cp = self._hud_panel:child("corner_panel")
            local oc1 = cp:child("corner"):color()
            local oc2 = cp:child("corner2"):color()
            self._hud_panel:child("corner_panel"):animate(callback(BAIAnimation, BAIAnimation, "RestorationColorChange"), c1, c2, callback(self, self, "_callback_animate_update_corner_color"), oc1, oc2)
        else
            self:_callback_animate_update_corner_color(c1, c2)
        end
        return
    end
    self._hud_panel:child("corner_panel"):child("corner"):set_color(c1)
    self._hud_panel:child("corner_panel"):child("corner2"):set_color(c2)
    self._hud_panel:child("corner_panel"):child("aai"):set_color(c1)
    self._hud_panel:child("corner_panel"):child("break"):set_color(c1)
end

function HUDAssaultCorner:_callback_animate_update_corner_color(color, color2)
    self._hud_panel:child("corner_panel"):child("corner"):set_color(color)
    self._hud_panel:child("corner_panel"):child("corner2"):set_color(color2)
    self._hud_panel:child("corner_panel"):child("aai"):set_color(Color(255, color.r, color.g, color.b)) -- Use full alpha when animating
    self._hud_panel:child("corner_panel"):child("break"):set_color(Color(255, color.r, color.g, color.b))
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetAnimationOption("animate_color_change") then
        self._hud_panel:child("assault_panel"):animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"), self._current_assault_color)
    else
        self:_update_assault_hud_color(color)
    end
end

function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted)
    local TOTAL_T = 0.18
    local OFFSET = self._v2_corner and self._hud_panel:child("corner_panel"):h() or self._hud_panel:child("assault_panel"):h() + 8
    local from_y = is_offseted and 0 or OFFSET
    local target_y = is_offseted and OFFSET or 0
    local t = (1 - math.abs(hostage_panel:y() - target_y) / OFFSET) * TOTAL_T
    while t < TOTAL_T do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        hostage_panel:set_y(math.lerp(from_y, target_y, lerp))
    end
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
			o:set_font_size(math.lerp(50, 50 * 1.25, n))
		end
	end
	local point_of_no_return_timer = self._hud_panel:child("point_of_no_return_panel"):child("point_of_no_return_timer")
	point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCorner:PostAnimationBG(panel)
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not BAI:IsAAIEnabledAndOption("captain_panel") then
        return
    end
    self._hud_panel:child("captain_panel"):child("num_reduction"):set_text((BAI:RoundNumber(buff, 0.01) * 100) .. "%")
end

HUDAssaultCorner._close_assault_box = HUDAssaultCorner._close_assault_panel