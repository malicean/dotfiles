local BAI = BAI
local multiplier = BAI.Language == "thai" and 2 or 1

local function GetTimeInFormat()
    local format = BAI:GetAAIOption("time_format")
    if format == 1 then
        return "04.20"
    elseif format == 2 then
        return "04.20 s"
    elseif format == 3 then
        return "420"
    elseif format == 4 then
        return "420 s"
    elseif format == 5 then
        return "04 min 20 s"
    else
        return "04:20"
    end
end

local function Center(o1, o2, o1t, o2t)
    o1t = o1t or "bitmap"
    o2t = o2t or "bitmap"
    local woh1
    if o1t == "text" then
        woh1 = select(3, o1:text_rect())
    else
        woh1 = o1:w()
    end
    local woh2
    if o2t == "text" then
        woh2 = select(3, o2:text_rect())
    else
        woh2 = o2:w()
    end
    local fwoh = (woh1 > 1) and woh1 or woh2
    local half = (fwoh / 2) + 2.5
    o1:set_x(o1:x() - half)
    o2:set_x(o2:x() + half)
end

function HUDAssaultCorner:ApplyCompatibility()
    if not PDTHHud then
        BAI:CrashWithErrorHUD("PD:TH HUD Reborn")
    end
    self:InitText()
end

function HUDAssaultCorner:DisableHostagePanelFunctions()
    self._hud_panel:child("num_hostages"):set_visible(false)
    self._hud_panel:child("num_hostages"):set_alpha(0)
    self._show_hostages = function() end
    self._hide_hostages = function() end
end

function HUDAssaultCorner:SetImage(image, panel, icon)
end

function HUDAssaultCorner:InitText()
    local const = pdth_hud.constants
    local panel = self._hud_panel
    local assault_panel = panel:child("assault_panel")
    local captain_assembled = panel:text({
        name = "captain_fully_assembled",
        text = utf8.to_upper(managers.localization:text("hud_captain_active")),
        blend_mode = "normal",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true,
        alpha = 0
    })

    managers.hud:make_fine_text(captain_assembled)
    captain_assembled:set_center_x(assault_panel:center_x())
    captain_assembled:set_top(assault_panel:top() - 20)

    self._captain_panel = panel:panel({
        name = "captain_panel",
        alpha = 0
    })

    local bitmap = self._captain_panel:bitmap({
        name = "img",
        texture = tweak_data.bai.captain.texture,
        h = 32,
        w = 32,
        visible = true
    })

    bitmap:set_center_x(assault_panel:center_x())
    bitmap:set_top(assault_panel:top() - 60)

    self._captain_text = self._captain_panel:text({
        name = "captain_text",
        text = "00%",
        blend_mode = "normal",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true
    })

    managers.hud:make_fine_text(self._captain_text)
    self._captain_text:set_center(bitmap:center())

    Center(bitmap, self._captain_text, "bitmap", "text")

    self._captain_text:set_text("0%")

    self._time_left_panel = panel:panel({
        name = "time_left_panel",
        alpha = 0
    })

    local assault_time_left = self._time_left_panel:text({
        name = "assault_time_left",
        text = managers.localization:text("hud_time_left_short"),
        blend_mode = "normal",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true
    })

    managers.hud:make_fine_text(assault_time_left)
    assault_time_left:set_center_x(assault_panel:center_x())
    assault_time_left:set_top(assault_panel:top() - 20)

    self._time_left_text = self._time_left_panel:text({
        name = "time_left",
        text = GetTimeInFormat(),
        blend_mode = "normal",
        halign = "center",
        valign = "left",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true
    })

    managers.hud:make_fine_text(self._time_left_text)
    self._time_left_text:set_center_x(assault_panel:center_x())
    self._time_left_text:set_top(assault_panel:top() - 20)

    Center(assault_time_left, self._time_left_text, "text", "text")

    self._break_time_panel = panel:panel({
        name = "break_time_panel",
        alpha = 0
    })

    local assault_break_time = self._break_time_panel:text({
        name = "assault_break_time",
        text = managers.localization:text("hud_break_time_left_short"),
        blend_mode = "normal",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true
    })

    managers.hud:make_fine_text(assault_break_time)
    assault_break_time:set_center_x(assault_panel:center_x())
    assault_break_time:set_top(assault_panel:top() - 20)

    self._break_time_text = self._break_time_panel:text({
        name = "break_time_left",
        text = GetTimeInFormat(),
        blend_mode = "normal",
        halign = "center",
        valign = "left",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true
    })

    managers.hud:make_fine_text(self._break_time_text)
    self._break_time_text:set_center_x(assault_panel:center_x())
    self._break_time_text:set_top(assault_panel:top() - 20)

    Center(assault_break_time, self._break_time_text, "text", "text")

    self._spawns_left_panel = panel:panel({
        name = "spawns_left_panel",
        alpha = 0
    })

    local assault_spawns_left = self._spawns_left_panel:text({
        name = "assault_spawns_left",
        text = managers.localization:text("hud_spawns_left_short"),
        blend_mode = "normal",
        halign = "center",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true
    })

    managers.hud:make_fine_text(assault_spawns_left)
    assault_spawns_left:set_center_x(assault_panel:center_x())
    assault_spawns_left:set_top(assault_panel:top() - 40)

    self._spawns_left_text = self._spawns_left_panel:text({
        name = "spawns_left",
        text = "0420",
        blend_mode = "normal",
        halign = "center",
        valign = "left",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true
    })

    managers.hud:make_fine_text(self._spawns_left_text)
    self._spawns_left_text:set_center_x(assault_panel:center_x())
    self._spawns_left_text:set_top(assault_panel:top() - 40)

    Center(assault_spawns_left, self._spawns_left_text, "text", "text")

    self:InitAAIPanelEvents()
    self:InitCaptainPanelEvents()

    BAI:SetCustomText("hud_overdue", "N/A")
end

function HUDAssaultCorner:UpdatePONRBox()
    if not self._point_of_no_return then
        local const = pdth_hud.constants
        self._noreturn_color = BAI:GetColor("escape")
        self._point_of_no_return_color = self._noreturn_color
        if self._hud_panel:child("point_of_no_return_panel") then
            self._hud_panel:remove(self._hud_panel:child("point_of_no_return_panel"))
        end
        local point_of_no_return_panel = self._hud_panel:panel({
            visible = false,
            name = "point_of_no_return_panel",
        })

        local point_of_no_return_text = point_of_no_return_panel:text({
            name = "point_of_no_return_text",
            text = "",
            blend_mode = "normal",
            layer = 1,
            color = self._noreturn_color,
            font_size = const.no_return_t_font_size,
            font = tweak_data.menu.small_font
        })
        point_of_no_return_text:set_text(BAI:IsCustomTextEnabled("escape") and managers.localization:text(self._noreturn_data.text_id) or managers.localization:text("time_escape"))
        managers.hud:make_fine_text(point_of_no_return_text)
        point_of_no_return_text:set_right(point_of_no_return_panel:w())
        point_of_no_return_text:set_top(0)

        local point_of_no_return_timer = point_of_no_return_panel:text({
            name = "point_of_no_return_timer",
            text = "",
            blend_mode = "normal",
            layer = 1,
            color = self._noreturn_color,
            font_size = const.no_return_timer_font_size,
            font = tweak_data.menu.small_font
        })
        managers.hud:make_fine_text(point_of_no_return_timer)
        point_of_no_return_timer:set_right(point_of_no_return_text:right())
        point_of_no_return_timer:set_top(point_of_no_return_text:bottom())
    end
end

function HUDAssaultCorner:set_buff_enabled(buff_name, enabled)
    self._hud_panel:child("captain_fully_assembled"):animate(callback(BAIAnimation, BAIAnimation, enabled and "FadeIn" or "FadeOut"))
end

local _BAI_start_assault_callback = HUDAssaultCorner.start_assault_callback
function HUDAssaultCorner:start_assault_callback()
    _BAI_start_assault_callback(self)
    if not self._assault_endless and BAI:GetOption("show_assault_states") and BAI:IsStateEnabled("build") then
        self:UpdateAssaultText(self:TryToShowEasterEgg("hud_build", "build"))
    end
end

function HUDAssaultCorner:_start_assault(text_list)
    local assault_panel = self._hud_panel:child("assault_panel")
    local num_hostages = self._hud_panel:child("num_hostages")
    local casing_panel = self._hud_panel:child("casing_panel")
    self._assault = true
    assault_panel:set_visible(true)
    num_hostages:set_alpha(0.7)
    casing_panel:set_visible(false)
    self._is_casing_mode = false

    local color, text
    if self._assault_endless then
        color = self._assault_endless_color
        text = "hud_endless"
        if BAI:ShowFSSAI() then
            text = "hud_fss_mod_" .. math.random(3)
        end
    else
        color = self._assault_color
        text = self:GetAssaultText()
    end

    if self._assault_mode == "phalanx" then
        color = self._vip_assault_color
        text = "hud_captain"
        self.assault_type = "captain"
    end

    self:UpdateAssaultText(text)
    self._fx_color = color

    self:_update_assault_hud_color(color)

    assault_panel:stop()
    assault_panel:animate(callback(self, self, "flash_assault_title"), true)

    if BAI:IsHostagePanelHidden(self.assault_type) then
        self:_hide_hostages()
    end

    if alive(self._wave_bg_box) then
        self._wave_bg_box:stop()
        self._wave_bg_box:animate(callback(self, self, "_animate_wave_started"), self)
    end

    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        if self.is_skirmish then
            self:_popup_wave_started()
        end
        BAI:CallEvent(BAI.EventList.AssaultStart)
    end
end

function HUDAssaultCorner:_start_endless_assault(text_list)
    if not self._assault_endless then
        BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
    end
    self._assault_endless = true
    self.assault_type = "endless"
    self:_start_assault(text_list)
    self:_update_assault_hud_color(self._assault_endless_color)
    self:UpdateAssaultText("hud_endless")
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_mode = mode
    local text = self:GetAssaultText()
    local color = self._assault_color
    if mode == "phalanx" then
        color = self._vip_assault_color
        text = "hud_captain"
    end
    self._fx_color = color
    self:_animate_update_assault_hud_color(color)

    self:UpdateAssaultText(text)
    self._assault_vip = mode == "phalanx"

    if mode == "phalanx" then
        if BAI:IsHostagePanelHidden("captain") then
            self:_hide_hostages()
        end
        self._assault_endless = false
    else
        if BAI:IsHostagePanelVisible("assault") then
            self:_show_hostages()
        end
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultState("fade") -- When Captain is defeated, Assault state is automatically set to Fade state
        end
    end
end

function HUDAssaultCorner:show_point_of_no_return_timer(id)
    local delay_time = self._assault and 1.2 or 0
    self:_update_noreturn(id)
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    point_of_no_return_panel:stop()
    point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
    self._point_of_no_return = true
    self:_close_assault_box()
end

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
    self._PoNR_flashing = true
    local const = PDTHHud.constants
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    local function flash_timer(o)
        local t = 0
        while t < 0.5 do
            t = t + coroutine.yield()
            local n = 1 - math.sin(t * 180)
            local r = math.lerp(self._noreturn_color.r, 1, n)
            local g = math.lerp(self._noreturn_color.g, 0.8, n)
            local b = math.lerp(self._noreturn_color.b, 0.2, n)
            o:set_color(Color(r, g, b))

            if BetterLightFX then
                BetterLightFX:StartEvent("PointOfNoReturn")
                BetterLightFX:SetColor(r, g, b, 1, "PointOfNoReturn")
            end

            o:set_font_size(math.lerp(const.no_return_timer_font_size , const.no_return_timer_font_size_pulse, n))
        end
        if BetterLightFX then
            BetterLightFX:EndEvent("PointOfNoReturn")
        end
    end

    local point_of_no_return_timer = point_of_no_return_panel:child("point_of_no_return_timer")
    point_of_no_return_timer:animate(flash_timer)
 end

local _f_update_assault_hud_color = HUDAssaultCorner._update_assault_hud_color
function HUDAssaultCorner:_update_assault_hud_color(color, animation)
    local panel = self._hud_panel
    local assault_panel = panel:child("assault_panel")

    if not animation then
        assault_panel:child("icon_assaultbox"):stop()
    end

    _f_update_assault_hud_color(self, color)
    local control_assault_title = assault_panel:child("control_assault_title")
    control_assault_title:set_color(BAI.settings.hud.pdth_hud_reborn.custom_text_color and BAI:GetColorFromTable(BAI.settings.hud.pdth_hud_reborn.color) or color)
    panel:child("captain_fully_assembled"):set_color(color)
    panel:child("time_left_panel"):child("assault_time_left"):set_color(color)
    self._time_left_text:set_color(color)
    panel:child("break_time_panel"):child("assault_break_time"):set_color(color)
    self._break_time_text:set_color(color)
    panel:child("spawns_left_panel"):child("assault_spawns_left"):set_color(color)
    self._spawns_left_text:set_color(color)
    panel:child("captain_panel"):child("img"):set_color(color)
    self._captain_text:set_color(color)
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetAnimationOption("animate_color_change") then
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):stop()
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"))
    else
        self:_update_assault_hud_color(color)
    end
end

function HUDAssaultCorner:_end_assault()
    if not self.trigger_assault_start_event then
        BAI:CallEvent(BAI.EventList.AssaultEnd)
    end
    local assault_panel = self._hud_panel:child("assault_panel")
    local control_assault_title = assault_panel:child("control_assault_title")
    local num_hostages = self._hud_panel:child("num_hostages")
    self:_show_hostages(1)
    if not self._assault then
        return
    end
    self._assault = false
    self._assault_endless = false
    self.assault_type = nil

    if BetterLightFX then
        BetterLightFX:EndEvent("AssaultIndicator")
    end

    if self:should_display_waves() then
        self:_update_assault_hud_color(self._assault_survived_color)
        self:UpdateAssaultText("hud_survived")
        self._wave_bg_box:stop()
        self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            self:_update_assault_hud_color(self._assault_survived_color)
            self:UpdateAssaultText("hud_survived")
            assault_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        else
            if BAI:GetOption("show_assault_states") then
                BAI:UpdateAssaultStateOverride("control")
            else
                self:_close_assault_box()
                BAI:CallEvent("MoveHUDListBack", self)
            end
        end
    end

    if not self.dont_override_endless then
        self.endless_client = false
    end

    if BAI:IsHostagePanelVisible() then
        self:_show_hostages()
    end

    self.trigger_assault_start_event = true
end

function HUDAssaultCorner:_close_assault_box()
    local assault_panel = self._hud_panel:child("assault_panel")
    assault_panel:set_visible(false)
    assault_panel:stop()
end

function HUDAssaultCorner:_hide_hostages()
    BAI:Animate(self._hud_panel:child("num_hostages"), 0, "FadeOut")
end

function HUDAssaultCorner:_show_hostages(alpha)
    if not self._point_of_no_return then
        BAI:Animate(self._hud_panel:child("num_hostages"), alpha or 0.7, "FadeIn", alpha or 0.7)
    end
end

function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if is_offseted then
        self:start_assault_callback()
    end
end

function HUDAssaultCorner:_set_hostages_offseted(is_offseted)
end

function HUDAssaultCorner:UpdateAssaultText(text)
    local text_title = self._hud_panel:child("assault_panel"):child("control_assault_title")
    if utf8.len(managers.localization:text(text)) > 8 then
        self:UpdateAssaultTextFontSize(text, text_title)
    else
        text_title:set_font_size(22 * multiplier * pdth_hud.Options:GetValue("HUD/Scale"))
        text_title:set_text(utf8.to_upper(managers.localization:text(text)))
        managers.hud:make_fine_text(text_title)
        text_title:set_center_x(self._hud_panel:child("assault_panel"):child("icon_assaultbox"):center_x())
        --text_title:set_center_y(self._hud_panel:child("assault_panel"):child("icon_assaultbox"):center_y())
    end
end

function HUDAssaultCorner:UpdateAssaultTextFontSize(text, text_title)
    local assault_box_icon = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
    local scale = pdth_hud.Options:GetValue("HUD/Scale")
    for i = 21, 1, -1 do --Start at 21, end at 1, step by -1
        text_title:set_font_size(i * multiplier * scale)
        text_title:set_text(utf8.to_upper(managers.localization:text(text)))
        managers.hud:make_fine_text(text_title)
        text_title:set_center_x(assault_box_icon:center_x())
        if text_title:w() < assault_box_icon:w() then
            break -- Exit from loop, because the text is now fully visible and not cut off.
        end
    end
end

function HUDAssaultCorner:OpenAssaultPanelWithAssaultState(assault_state)
    self.trigger_assault_start_event = false
    self:_start_assault(self:_get_state_strings(assault_state))
    self:_update_assault_hud_color(BAI:GetColor(assault_state))
    self:UpdateAssaultText("hud_" .. assault_state)
    self.trigger_assault_start_event = true
    BAI:CallEvent("MoveHUDList", self)
end

function HUDAssaultCorner:SetTextListAndAnimateColor(assault_state, is_control_or_anticipation)
    if assault_state then
        self:_animate_update_assault_hud_color(BAI:GetColor(assault_state))
        if is_control_or_anticipation then
            self:UpdateAssaultText("hud_" .. assault_state)
        else
            self:UpdateAssaultText(self:TryToShowEasterEgg("hud_" .. assault_state, assault_state))
        end
    else
        self:_animate_update_assault_hud_color(self._assault_color)
        self:UpdateAssaultText(self:GetAssaultText())
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    self:UpdateAssaultText("hud_" .. state)
    self:_animate_update_assault_hud_color(BAI:GetColor(state))
end

function HUDAssaultCorner:GetAssaultText()
    if BAI:ShowFSSAI() and BAI:IsCustomTextDisabled("assault") then
        return "hud_fss_mod_" .. math.random(3)
    end
    if BAI:GetOption("show_difficulty_name_instead_of_skulls") and not self.is_crimespree then
        local text = self:GetDifficultyName()
        if text ~= Idstring("risk") then -- For instances where "tweak_data is nil"
            return text
        end
    end
    return "hud_assault"
end

function HUDAssaultCorner:TryToShowEasterEgg(text, text_id)
    if BAI:ShowFSSAI() and BAI:IsCustomTextDisabled(text_id) then
        return "hud_fss_mod_" .. math.random(3)
    end
    return text
end

function HUDAssaultCorner:_set_text_list(text_list)
end

function HUDAssaultCorner:PostAnimationBG(panel)
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not BAI:IsAAIEnabledAndOption("captain_panel") then
        return
    end
    self._captain_text:set_text((BAI:RoundNumber(buff, 0.01) * 100) .. "%")
end