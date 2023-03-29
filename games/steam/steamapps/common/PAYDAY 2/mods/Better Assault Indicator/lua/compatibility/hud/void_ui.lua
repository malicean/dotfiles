local BAI = BAI
function HUDAssaultCorner:ApplyCompatibility()
    if not VoidUI then
        BAI:CrashWithErrorHUD("Void UI")
    elseif not VoidUI.options.enable_assault then
        BAI:CrashWithErrorHUDOption("Void UI", "Enable Assault panel")
    end
    self._is_safehouse_raid = managers.job:current_level_id() == "chill_combat"
    self._hud_overdue = managers.localization:text("hud_overdue")
    local function Update()
        BAI:SetCustomText("hud_overdue", BAI:GetAAIOption("aai_panel") == 1 and self._hud_overdue or "---")
    end
    BAI:AddEvent(BAI.EventList.Update, Update)
end

function HUDAssaultCorner:InitAAIPanel()
    if not self.AAIPanel then
        return
    end

    local icons = self._icons or {}
    local icons_panel = self._icons_panel
    local highlight_texture = "guis/textures/VoidUI/hud_highlights"
    local bai_icons = tweak_data.bai
    local panel_h = 38 * self._scale
    local panel_w = 44 * self._scale
    local position = 3
    local icon_color = nil
    local text_color = Color.white
    if VoidUI_HMV then
        icon_color = VoidUI.options.generic_colors and VoidUI:GetColor("text_color") or VoidUI:GetColor("cuffed_icon")
        text_color = VoidUI.options.generic_colors and VoidUI:GetColor("text_color") or VoidUI:GetColor("num_cuffed")
    end
    if BAI:GetOption("completely_hide_hostage_panel") then
        position = 2
    end

    self._time_left_panel = icons_panel:panel({
        name = "time_panel",
        w = panel_w,
        h = panel_h,
        alpha = 0
    })
    local time_panel = self._time_left_panel
    table.insert(icons, {panel = time_panel, position = position})
    local time_background = time_panel:bitmap({
        name = "bg",
        texture = highlight_texture,
        texture_rect = {0, 316, 171, 150},
        layer = 1,
        w = panel_w,
        h = panel_h,
        color = Color.black
    })
    local time_border = time_panel:bitmap({
        name = "time_border",
        texture = highlight_texture,
        texture_rect = {172, 316, 171, 150},
        layer = 2,
        w = panel_w,
        h = panel_h,
    })
    local time_icon = time_panel:bitmap({
        name = "time_icon",
        texture = bai_icons.time_left.texture,
        texture_rect = bai_icons.time_left.texture_rect,
        valign = "top",
        alpha = 0.6,
        layer = 2,
        y = 0,
        x = 0,
        h = panel_h / 1.3,
        w = panel_w / 1.7
    })
    time_icon:set_center(time_border:center())
    self._time_left_text = time_panel:text({
        name = "time_left",
        layer = 3,
        vertical = "bottom",
        align = "right",
        text = "04:20",
        y = 0,
        x = 0,
        valign = "center",
        w = panel_w / 1.2,
        h = panel_h,
        color = text_color,
        font = "fonts/font_medium_noshadow_mf",
        font_size = panel_h / 2
    })
    if BAI:GetAAIOption("aai_panel") == 2 then
        BAI:SetCustomText("hud_overdue", "---")
    end
    self._break_time_panel = icons_panel:panel({
        name = "break_time_panel",
        w = panel_w,
        h = panel_h,
        alpha = 0
    })
    local break_panel = self._break_time_panel
    table.insert(icons, {panel = break_panel, position = position})
    local break_background = break_panel:bitmap({
        name = "bg",
        texture = highlight_texture,
        texture_rect = {0, 316, 171, 150},
        layer = 1,
        w = panel_w,
        h = panel_h,
        color = Color.black
    })
    local break_border = break_panel:bitmap({
        name = "break_border",
        texture = highlight_texture,
        texture_rect = {172, 316, 171, 150},
        layer = 2,
        w = panel_w,
        h = panel_h,
    })
    local break_icon = break_panel:bitmap({
        name = "break_icon",
        texture = bai_icons.spawns_left.texture,
        valign = "top",
        alpha = 0.6,
        layer = 2,
        y = 0,
        x = 0,
        h = panel_h / 1.3,
        w = panel_w / 1.7
    })
    break_icon:set_center(break_border:center())
    self._break_time_text = break_panel:text({
        name = "break_time_left",
        layer = 3,
        vertical = "bottom",
        align = "right",
        text = "04:20",
        y = 0,
        x = 0,
        valign = "center",
        w = panel_w / 1.2,
        h = panel_h,
        color = text_color,
        font = "fonts/font_medium_noshadow_mf",
        font_size = panel_h / 2
    })

    self._spawns_left_panel = icons_panel:panel({
        name = "spawns_panel",
        w = panel_w,
        h = panel_h,
        alpha = 0
    })
    local spawns_panel = self._spawns_left_panel
    table.insert(icons, {panel = spawns_panel, position = position + 1})
    local spawns_background = spawns_panel:bitmap({
        name = "bg",
        texture = highlight_texture,
        texture_rect = {0, 316, 171, 150},
        layer = 1,
        w = panel_w,
        h = panel_h,
        color = Color.black
    })
    local spawns_border = spawns_panel:bitmap({
        name = "spawns_border",
        texture = highlight_texture,
        texture_rect = {172, 316, 171, 150},
        layer = 2,
        w = panel_w,
        h = panel_h,
    })
    local spawns_icon = spawns_panel:bitmap({
        name = "spawns_icon",
        texture = bai_icons.spawns_left.texture,
        valign = "top",
        alpha = 0.6,
        layer = 2,
        y = 0,
        x = 0,
        h = panel_h / 1.3,
        w = panel_w / 1.7
    })
    spawns_icon:set_center(spawns_border:center())
    self._spawns_left_text = spawns_panel:text({
        name = "spawns_left",
        layer = 3,
        vertical = "bottom",
        align = "right",
        text = "0420",
        y = 0,
        x = 0,
        valign = "center",
        w = panel_w / 1.2,
        h = panel_h,
        color = text_color,
        font = "fonts/font_medium_noshadow_mf",
        font_size = panel_h / 2
    })
    if icon_color then
        time_icon:set_color(icon_color)
        break_icon:set_color(icon_color)
        spawns_icon:set_color(icon_color)
    end
    self:InitAAIPanelEvents()
     -- So Vanilla code would not crash
    self._time_bg_box = self._time_left_panel
    self._break_time_bg_box = self._break_time_panel
    self._spawns_bg_box = self._spawns_left_panel
end

function HUDAssaultCorner:InitCaptainPanel()
    if not self.AAIPanel then
        return
    end

    self._custom_captain_panel = self._custom_hud_panel:panel({
        name = "custom_captain_panel",
        w = 240 * self._scale,
        h = 240 * self._scale,
        alpha = 1
    })
    self._custom_captain_panel:set_right(self._custom_hud_panel:w())

    local icons = self._icons or {}
    local icons_panel = self._custom_captain_panel
    local highlight_texture = "guis/textures/VoidUI/hud_highlights"
    local bai_icons = tweak_data.bai
    local panel_h = 38 * self._scale
    local panel_w = 44 * self._scale
    local position = 3
    local icon_color = nil
    local text_color = Color.white
    if VoidUI_HMV then
        icon_color = VoidUI.options.generic_colors and VoidUI:GetColor("text_color") or VoidUI:GetColor("cuffed_icon")
        text_color = VoidUI.options.generic_colors and VoidUI:GetColor("text_color") or VoidUI:GetColor("num_cuffed")
    end

    self._captain_panel = icons_panel:panel({
        name = "captain_panel",
        w = panel_w,
        h = panel_h,
        alpha = 0
    })
    local captain_panel = self._captain_panel
    table.insert(icons, {panel = captain_panel, position = position})
    local captain_background = captain_panel:bitmap({
        name = "bg",
        texture = highlight_texture,
        texture_rect = {0, 316, 171, 150},
        layer = 1,
        w = panel_w,
        h = panel_h,
        color = Color.black
    })
    local captain_border = captain_panel:bitmap({
        name = "captain_border",
        texture = highlight_texture,
        texture_rect = {172, 316, 171, 150},
        layer = 2,
        w = panel_w,
        h = panel_h,
    })
    local captain_icon = captain_panel:bitmap({
        name = "captain_icon",
        texture = bai_icons.captain.texture,
        valign = "top",
        alpha = 0.6,
        layer = 2,
        y = 0,
        x = 0,
        h = panel_h / 1.3,
        w = panel_w / 1.7
    })
    captain_icon:set_center(captain_border:center())
    if icon_color then
        captain_icon:set_color(icon_color)
    end
    local num_reduction = captain_panel:text({
        name = "num_reduction",
        layer = 3,
        vertical = "bottom",
        align = "right",
        text = "0%",
        y = 0,
        x = 0,
        valign = "center",
        w = panel_w / 1.2,
        h = panel_h,
        color = text_color,
        font = "fonts/font_medium_noshadow_mf",
        font_size = panel_h / 2
    })

    self:InitCaptainPanelEvents()
end

function HUDAssaultCorner:HideWaveCounter()
    if VoidUI_IB then -- Void UI Infoboxes
        return
    end
    self._icons_panel:child("wave_panel"):set_alpha(0)
    -- Adjust icons position
    for i, icon in ipairs(self._icons) do
        self._icons[i].position = icon.position - 1
    end
end

function HUDAssaultCorner:UpdatePONRBox()
    if not self._point_of_no_return then
        self._noreturn_color = BAI:GetColor("escape")
        self._point_of_no_return_color = self._noreturn_color
        self._custom_hud_panel:child("point_of_no_return_panel"):child("noreturnbox_panel"):child("border"):set_color(self._noreturn_color)
        self._custom_hud_panel:child("point_of_no_return_panel"):child("point_of_no_return_timer"):set_color(self._noreturn_color)
    end
end

function HUDAssaultCorner:_offset_hostage(is_offseted, hostage_panel, big_logo)
    local TOTAL_T = 0.18
    local icons_panel = self._custom_hud_panel:child("icons_panel")
    local panel_right = icons_panel:right()
    local panel_y = icons_panel:y()
    local t = 0
    local hostages_visible = BAI:IsHostagePanelVisible()
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        if is_offseted then
            if hostages_visible then
                icons_panel:set_alpha(math.lerp(1,0,lerp))
            end
        else
            if hostages_visible then
                icons_panel:set_alpha(1)
            end
            icons_panel:set_right(math.lerp(panel_right, self._custom_hud_panel:w(),lerp))
            icons_panel:set_y(math.lerp(panel_y, 0, lerp))
            for _, panels in ipairs(self._icons) do
                panels.panel:set_right(icons_panel:w() - (panels.position - 1) * panels.panel:w() - 4 * (panels.row and panels.row or 0))
                panels.panel:set_y((panels.panel:h() + 3) * (panels.row and panels.row or 0))
            end
        end
        if self._start_assault_after_hostage_offset and lerp > 0.4 then
            self._start_assault_after_hostage_offset = nil
            self:start_assault_callback()
        end
    end
    if is_offseted then
        if big_logo then wait(0.6) end
        TOTAL_T = 0.3
        t = 0
        icons_panel:set_right(big_logo and self._custom_hud_panel:w() - 75 * self._scale or self._custom_hud_panel:w() - 7 * self._scale)
        icons_panel:set_y(big_logo and 47 * self._scale or 32 * self._scale)
        for _, panels in ipairs(self._icons) do
            panels.panel:set_right(icons_panel:w() - (panels.position - 1) * panels.panel:w() - 4 * (panels.row and panels.row or 0))
            panels.panel:set_y(-panels.panel:h() * panels.position)
        end
        if hostages_visible then
            icons_panel:set_alpha(1)
        end
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            for _, panels in ipairs(self._icons) do
                panels.panel:set_y(math.lerp(-panels.panel:h() * panels.position, (panels.panel:h() + 3) * (panels.row and panels.row or 0),lerp))
            end
        end
    end
    if hostages_visible then
        icons_panel:set_alpha(1)
    end
    self:whisper_mode_changed()
    if self._start_assault_after_hostage_offset then
        self._start_assault_after_hostage_offset = nil
        self:start_assault_callback()
    end
    if BAI:IsHostagePanelHidden(self.assault_type) then
        self:_hide_hostages()
    end
end

function HUDAssaultCorner:show_point_of_no_return_timer(id)
    local delay_time = self._assault and 1.3 or 0
    self:_update_noreturn(id)
    local point_of_no_return_panel = self._custom_hud_panel:child("point_of_no_return_panel")
    local noreturnbox_panel = point_of_no_return_panel:child("noreturnbox_panel")
    local text_panel = point_of_no_return_panel:child("text_panel")
    text_panel:script().text_list = {}
    local msg = {
        self._noreturn_data.text_id,
        "hud_assault_end_line",
        self._noreturn_data.text_id,
        "hud_assault_end_line"
    }
    for _, text_id in ipairs(msg) do
        table.insert(text_panel:script().text_list, text_id)
    end
    if noreturnbox_panel:child("text_panel") then
        noreturnbox_panel:child("text_panel"):stop()
        noreturnbox_panel:child("text_panel"):clear()
    else
        noreturnbox_panel:panel({name = "text_panel", x = 19 * self._scale, w = 200 * self._scale})
    end

    noreturnbox_panel:child("text_panel"):stop()
    noreturnbox_panel:child("text_panel"):animate(callback(self, self, "_animate_text"), text_panel:script().text_list, self._noreturn_color)

    self._point_of_no_return = true

    self:_close_assault_box()

    point_of_no_return_panel:stop()
    point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)

    self:_set_feedback_color(self._noreturn_color)
end

function HUDAssaultCorner:_start_assault(text_list)
    if self._point_of_no_return or self._casing then
        return
    end
    text_list = text_list or {""}
    local assault_panel = self._custom_hud_panel:child("assault_panel")
    local assaultbox_panel = assault_panel:child("assaultbox_panel")
    local icon_assaultbox = assault_panel:child("icon_assaultbox")
    local assaultbox_skulls = assault_panel:child("assaultbox_skulls")
    self._badge = VoidUI.options.show_badge
    if self.is_crimespree then
        assaultbox_skulls:set_font_size(15)
        assaultbox_skulls:set_text(managers.crime_spree:server_spree_level())
        local w = select(3, assaultbox_skulls:text_rect())
        if w > assaultbox_skulls:w() then
            assaultbox_skulls:set_font_size(15 * (15 / w))
        end
    end

    self:_set_text_list(text_list)
    self._assault = true

    if assaultbox_panel:child("text_panel") then
        assaultbox_panel:child("text_panel"):stop()
        assaultbox_panel:child("text_panel"):clear()
        assaultbox_panel:child("text_panel"):set_w(VoidUI.options.show_badge and assaultbox_panel:w() or assaultbox_panel:w() - 26 * self._scale)
    else
        assaultbox_panel:panel({name = "text_panel", w = VoidUI.options.show_badge and assaultbox_panel:w() or assaultbox_panel:w() - 30 * self._scale})
    end
    local text_panel = assaultbox_panel:child("text_panel")

    assault_panel:set_visible(true)
    icon_assaultbox:set_visible(VoidUI.options.show_badge)
    if assaultbox_skulls then
        assaultbox_skulls:set_visible(VoidUI.options.show_badge)
    end
    icon_assaultbox:stop()
    icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"), true)
    assaultbox_panel:stop()
    assaultbox_panel:animate(callback(self, self, "_show_assaultbox"), 0.5, true)

    text_panel:stop()
    text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
    self:_set_feedback_color(self._assault_color)
    self:_update_assault_hud_color(self._assault_color)

    if self._assault_mode == "phalanx" and BAI:IsHostagePanelHidden("captain") then
        self:_hide_hostages()
    end

    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        if self._is_safehouse_raid or self.is_skirmish then
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
    local assault_panel = self._custom_hud_panel:child("assault_panel")
    local assaultbox_panel = assault_panel:child("assaultbox_panel")
    local text_panel = assaultbox_panel:child("text_panel")
    self:_set_feedback_color(nil)
    self._assault = false
    local endless_assault = self._assault_endless
    self._assault_endless = false
    self.assault_type = nil

    self._remove_hostage_offset = true
    self._start_assault_after_hostage_offset = nil
    local icon_assaultbox = self._custom_hud_panel:child("assault_panel"):child("icon_assaultbox")
    icon_assaultbox:stop()
    icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"), true)
    if self:should_display_waves() then
        self:_update_assault_hud_color(self._assault_survived_color)
        self:_set_text_list(self:_get_survived_assault_strings())
        text_panel:stop()
        text_panel:clear()
        text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
        text_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        if self._is_safehouse_raid or self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            self:_update_assault_hud_color(self._assault_survived_color)
            self:_set_text_list(self:_get_survived_assault_strings(endless_assault))
            text_panel:stop()
            text_panel:clear()
            text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
            text_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        else
            if BAI:GetOption("show_assault_states") then
                BAI:UpdateAssaultStateOverride("control", true)
                if BAI:IsHostagePanelVisible() then
                    self:_show_hostages()
                end
            else
                self:_close_assault_box()
                BAI:CallEvent("MoveHUDListBack", self)
            end
        end
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end
    self.trigger_assault_start_event = true
end

function HUDAssaultCorner:_hide_icon_assaultbox(icon_assaultbox, big_logo)
    if self._casing_show_hostages then
        self._casing_show_hostages = false
        self:_show_hostages() -- Hack; Figure out a better solution
    end
    if BAI:IsHostagePanelVisible() and not self._casing then
        self:_show_hostages()
    end

    local TOTAL_T = 0.4
    local t = 0

    local assault_panel = self._custom_hud_panel:child("assault_panel")
    local assaultbox_skulls = assault_panel:child("assaultbox_skulls")
    local w = icon_assaultbox:w()
    local h = icon_assaultbox:h()
    local center_x = icon_assaultbox:center_x()
    local center_y = icon_assaultbox:center_y()
    local crime_spree = managers.crime_spree:is_active()

    if VoidUI.options.show_badge and big_logo then
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = t + dt
            icon_assaultbox:set_w(math.lerp(w, 60 * self._scale, t / TOTAL_T))
            icon_assaultbox:set_h(math.lerp(h, 70 * self._scale, t / TOTAL_T))
            icon_assaultbox:set_center_x(center_x)
            icon_assaultbox:set_center_y(center_y)
            if assaultbox_skulls then
                assaultbox_skulls:set_size(icon_assaultbox:w(), icon_assaultbox:h())
                assaultbox_skulls:set_center(icon_assaultbox:center())
                if crime_spree then assaultbox_skulls:set_alpha(math.lerp(1,0, t / TOTAL_T)) end
            end
        end
    end

    TOTAL_T = 0.2
    t = 0
    icon_assaultbox:set_alpha(1)
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = t + dt
        icon_assaultbox:set_w(math.lerp(big_logo and 60 * self._scale or 30 * self._scale, big_logo and 70 * self._scale or 35 * self._scale, t / TOTAL_T))
        icon_assaultbox:set_h(math.lerp(big_logo and 70 * self._scale or 30 * self._scale, big_logo and 80 * self._scale or 35 * self._scale, t / TOTAL_T))
        icon_assaultbox:set_center_x(center_x)
        icon_assaultbox:set_center_y(center_y)
        if assaultbox_skulls then
            assaultbox_skulls:set_size(icon_assaultbox:w(), icon_assaultbox:h())
            assaultbox_skulls:set_center(icon_assaultbox:center())
        end
    end
    if not self._point_of_no_return then
        self:_set_hostage_offseted(false, false)
    else
        self:_set_hostage_offseted(true, true)
    end
    t = 0
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = t + dt
        icon_assaultbox:set_w(math.lerp(big_logo and 70 * self._scale or 35 * self._scale, 0, t / TOTAL_T))
        icon_assaultbox:set_h(math.lerp(big_logo and 80 * self._scale or 35 * self._scale, 0, t / TOTAL_T))
        icon_assaultbox:set_center_x(center_x)
        icon_assaultbox:set_center_y(center_y)
        if assaultbox_skulls then
            assaultbox_skulls:set_size(icon_assaultbox:w(), icon_assaultbox:h())
            assaultbox_skulls:set_center(icon_assaultbox:center())
        end
    end

    icon_assaultbox:set_alpha(0)
    if assaultbox_skulls then
        assaultbox_skulls:set_alpha(0)
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    if override then
        self:_start_assault(self:_get_state_strings(state))
        self:_update_assault_hud_color(BAI:GetColor(state))
    else
        self:SetTextListAndAnimateColor(state, true)
    end
end

function HUDAssaultCorner:_popup_wave_started()
    self:_popup_wave(self:wave_popup_string_start(), self.is_skirmish and tweak_data.screen_colors.skirmish_color or Color(255, 255, 0) / 255) -- If Skirmish -> Orange, otherwise Yellow
end

function HUDAssaultCorner:_set_hostages_offseted(is_offseted, big_logo)
    local hostage_panel = self._custom_hud_panel:child("icons_panel"):child("hostages_panel")
    self._remove_hostage_offset = nil
    hostage_panel:stop()
    self._custom_hud_panel:child("icons_panel"):stop()
    hostage_panel:animate(callback(self, self, "_offset_hostages", is_offseted), VoidUI.options.show_badge and (big_logo and big_logo or true) or false)
    if self.AAIPanel then
        self._time_left_panel:stop()
        self._time_left_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        self._spawns_left_panel:stop()
        self._spawns_left_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        self._break_time_panel:stop()
        self._break_time_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        self._captain_panel:stop()
        self._captain_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)
    end
end

function HUDAssaultCorner:_offset_hostages(is_offseted, hostage_panel, big_logo)
    local TOTAL_T = 0.18
    local icons_panel = self._custom_hud_panel:child("icons_panel")
    local panel_right = icons_panel:right()
    local panel_y = icons_panel:y()
    local t = 0
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        if is_offseted then
            icons_panel:set_alpha(math.lerp(1,0,lerp))
        else
            icons_panel:set_alpha(1)
            icons_panel:set_right(math.lerp(panel_right, self._custom_hud_panel:w(),lerp))
            icons_panel:set_y(math.lerp(panel_y, 0, lerp))
            for _, panels in ipairs(self._icons) do
                panels.panel:set_right(icons_panel:w() - (panels.position - 1) * panels.panel:w() - 4 * (panels.row and panels.row or 0))
                panels.panel:set_y((panels.panel:h() + 3) * (panels.row and panels.row or 0))
            end
        end
    end
    if is_offseted then
        if big_logo then wait(0.6) end
        TOTAL_T = 0.3
        t = 0
        icons_panel:set_right(big_logo and self._custom_hud_panel:w() - 75 * self._scale or self._custom_hud_panel:w() - 7 * self._scale)
        icons_panel:set_y(big_logo and 47 * self._scale or 32 * self._scale)
        for _, panels in ipairs(self._icons) do
            panels.panel:set_right(icons_panel:w() - (panels.position - 1) * panels.panel:w() - 4 * (panels.row and panels.row or 0))
            panels.panel:set_y(-panels.panel:h() * panels.position)
        end
        icons_panel:set_alpha(1)
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            for _, panels in ipairs(self._icons) do
                panels.panel:set_y(math.lerp(-panels.panel:h() * panels.position, (panels.panel:h() + 3) * (panels.row and panels.row or 0),lerp))
            end
        end
    end
    icons_panel:set_alpha(1)
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetAnimationOption("animate_color_change") then
        if self._anim_thread then
            self._custom_hud_panel:child("assault_panel"):child("assaultbox_panel"):stop(self._anim_thread)
        end
        self._anim_thread = self._custom_hud_panel:child("assault_panel"):child("assaultbox_panel"):animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"), self._current_assault_color)
    else
        self:_update_assault_hud_color(color)
    end
end

function HUDAssaultCorner:PostAnimationBG(panel)
    local bg = panel:child("bg")
    bg:stop()
    bg:animate(callback(self, self, "_blink_background"))
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not (self.AAIPanel and BAI:IsAAIEnabledAndOption("captain_panel")) then
        return
    end
    self._captain_panel:child("num_reduction"):set_text((BAI:RoundNumber(buff, 0.01) * 100) .. "%")
    self:PostAnimationBG(self._captain_panel)
end

function HUDAssaultCorner:DisableHostagePanelFunctions()
    self._custom_hud_panel:child("icons_panel"):child("hostages_panel"):set_visible(false)
    self._custom_hud_panel:child("icons_panel"):child("hostages_panel"):set_alpha(0)
    self._hostages_disabled = true
end