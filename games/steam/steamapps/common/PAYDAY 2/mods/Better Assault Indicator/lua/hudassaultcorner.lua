local BAI = BAI
local math_abs = math.abs
local math_max = math.max
local math_min = math.min
local math_sin = math.sin
local math_cos = math.cos
local math_lerp = math.lerp
local math_round = math.round
local table_insert = table.insert
function HUDAssaultCorner:InitAAIPanel()
    if not self.AAIPanel then
        return
    end

    local icons = tweak_data.bai
    local has_waves = self:should_display_waves()
    local panel_h = 38
    local panel_y = 0
    if _G.IS_VR then
        panel_h = 20
        panel_y = 108
    end
    local panel_w = 145
    local icon_wh = panel_h -- Use the same width and height as panel
    local right
    if has_waves then
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
        w = panel_w,
        h = panel_h,
        y = panel_y,
        alpha = 0,
        visible = true
    })
    local time_panel = self._time_left_panel

    time_panel:set_right(right)

    if BAI:IsHostagePanelHidden() and not has_waves then
        time_panel:set_x(self._hud_panel:w() - time_panel:w())
    end

    local time_icon = time_panel:bitmap({
        texture = icons.time_left.texture,
        texture_rect = icons.time_left.texture_rect,
        name = "time_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top",
        h = icon_wh,
        w = icon_wh
    })
    self._time_bg_box = HUDBGBox_create(time_panel, {
        x = 0,
        y = 0,
        w = panel_w - panel_h,
        h = panel_h
    }, {
        blend_mode = "add"
    })

    time_icon:set_right(time_panel:w() + 5)
    time_icon:set_center_y(self._time_bg_box:h() / 2)
    self._time_bg_box:set_right(time_icon:left())

    self._time_left_text = self._time_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "time_left",
        align = "center",
        text = "04:20",
        y = 0,
        x = 0,
        valign = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })

    self._break_time_panel = self._hud_panel:panel({
        name = "break_time_panel",
        w = panel_w,
        h = panel_h,
        y = panel_y,
        alpha = 0,
        visible = true
    })
    local break_time_panel = self._break_time_panel
    break_time_panel:set_x(time_panel:x())
    break_time_panel:set_y(time_panel:y())

    local break_time_icon = break_time_panel:bitmap({
        texture = icons.break_time_left.texture,
        name = "break_time_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top",
        h = icon_wh,
        w = icon_wh
    })
    self._break_time_bg_box = HUDBGBox_create(break_time_panel, {
        x = 0,
        y = 0,
        w = panel_w - panel_h,
        h = panel_h
    }, {
        blend_mode = "add"
    })

    break_time_icon:set_right(break_time_panel:w() + 5)
    break_time_icon:set_center_y(self._break_time_bg_box:h() / 2)
    self._break_time_bg_box:set_right(break_time_icon:left())

    self._break_time_text = self._break_time_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "break_time_left",
        align = "center",
        text = "04:20",
        y = 0,
        x = 0,
        valign = "center",
        w = self._break_time_bg_box:w(),
        h = self._break_time_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })

    local spawns_w = 107.5
    self._spawns_left_panel = self._hud_panel:panel({
        name = "spawns_panel",
        w = spawns_w,
        h = panel_h,
        y = panel_y,
        alpha = 0,
        visible = true
    })
    local spawns_panel = self._spawns_left_panel

    spawns_panel:set_right(time_panel:left() - 3)

    local spawns_icon = spawns_panel:bitmap({
        texture = icons.spawns_left.texture,
        name = "spawns_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top",
        h = icon_wh,
        w = icon_wh
    })
    self._spawns_bg_box = HUDBGBox_create(spawns_panel, {
        x = 0,
        y = 0,
        w = spawns_w - panel_h,
        h = panel_h
    }, {
        blend_mode = "add"
    })

    spawns_icon:set_right(spawns_panel:w() + 7.5)
    spawns_icon:set_center_y(self._spawns_bg_box:h() / 2)
    self._spawns_bg_box:set_right(spawns_icon:left())

    self._spawns_left_text = self._spawns_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "spawns_left",
        align = "center",
        text = "0420",
        y = 0,
        x = 0,
        valign = "center",
        w = self._spawns_bg_box:w(),
        h = self._spawns_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })
    self:InitAAIPanelEvents()
end

function HUDAssaultCorner:InitAAIPanelEvents()
    BAI:AddEvent(BAI.EventList.AssaultStart, function()
        managers.hud._hud_assault_corner:SetHook(true, 1)
        managers.hud._hud_assault_corner:SetBreakHook(false)
    end)
    local function End(active)
        self:SetHook(false)
        self:SetBreakHook(false)
    end
    local function EndBreak()
        self:SetHook(false)
        self:SetBreakHook(true, 1)
    end
    BAI:AddEvent(BAI.EventList.AssaultEnd, EndBreak)
    BAI:AddEvent(BAI.EventList.Captain, function(active)
        managers.hud._hud_assault_corner:SetHook(not active)
    end)
    BAI:AddEvent(BAI.EventList.EndlessAssaultStart, End)
    BAI:AddEvent(BAI.EventList.NoReturn, End)
    BAI:AddEvent(BAI.EventList.NormalAssaultOverride, function()
        managers.hud._hud_assault_corner:SetHook(true)
    end)
end

function HUDAssaultCorner:InitCaptainPanel()
    if not self.AAIPanel then
        return
    end

    local panel_h = 38
    local panel_y = 0
    if _G.IS_VR then
        panel_h = 20
        panel_y = 108
    end
    local icon_wh = panel_h -- Use the same width and height as panel

    self._captain_panel = self._hud_panel:panel({
        name = "captain_panel",
        w = 70,
        h = panel_h,
        x = 0, -- Changed dynamically
        y = panel_y,
        alpha = 0,
        visible = true
    })
    local captain_panel = self._captain_panel

    local captain_icon = captain_panel:bitmap({
        texture = tweak_data.bai.captain.texture,
        name = "captain_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top",
        w = icon_wh,
        h = icon_wh
    })

    if BAI:IsHostagePanelVisible("captain") then
        captain_panel:set_right(self._hud_panel:child("hostages_panel"):left() - 3)
    else
        captain_panel:set_x(self._hud_panel:w() - captain_panel:w())
    end

    self._captain_bg_box = HUDBGBox_create(captain_panel, {
        x = 0,
        y = 0,
        w = 38,
        h = panel_h
    }, {
        blend_mode = "add"
    })

    captain_icon:set_right(captain_panel:w() + 5)
    captain_icon:set_center_y(self._captain_bg_box:h() / 2)
    self._captain_bg_box:set_right(captain_icon:left())

    local num_reduction = self._captain_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "num_reduction",
        align = "center",
        text = "0%",
        y = 0,
        x = 0,
        valign = "center",
        w = self._captain_bg_box:w(),
        h = self._captain_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })

    self:InitCaptainPanelEvents()
end

function HUDAssaultCorner:InitCaptainPanelEvents()
    BAI:AddEvent(BAI.EventList.Captain, function(active)
        managers.hud._hud_assault_corner:SetCaptainHook(active)
    end)
end

function HUDAssaultCorner:InitWaveCounter()
    if not self:should_display_waves() or _G.IS_VR then
        return
    end
    if not self:WaveCounterEnabled() or self._wave_counter <= 1 then
        return
    end
    self:HideWaveCounter()
    if self._wave_counter == 2 then -- In the Assault Box (as a standalone text)
        self:CreateWaveCounterText()
    end
end

function HUDAssaultCorner:UpdateAssaultPanelPosition()
    if self.assault_panel_position then -- Don't update panel when pos is loaded
        return
    end
    if self.assault_panel_position_disabled then
        self.assault_panel_position = 3
        return
    end
    local bai_position = BAI:GetOption("assault_panel_position")
    if bai_position ~= 3 then -- Not Top Right; game and BAI default behavior
        local assault_panel = self._hud_panel:child("assault_panel")
        local casing_panel = self._hud_panel:child("casing_panel")
        local noreturn_panel = self._hud_panel:child("point_of_no_return_panel")
        local buffs_panel = self._hud_panel:child("buffs_panel")
        local left = self._bg_box:w() + assault_panel:child("icon_assaultbox"):w()
        local centre = (self._hud_panel:w() / 2) + (assault_panel:w() / 2) - 61
        local bottom = self._hud_panel:bottom() - assault_panel:h()
        local top = self._hud_panel:h() / 2 - (assault_panel:h() / 2)
        if bai_position == 1 then -- Top Left
            assault_panel:set_right(left)
            casing_panel:set_right(left)
            noreturn_panel:set_right(left)
            buffs_panel:set_right(left + 41)
        elseif bai_position == 2 then -- Top Centre
            assault_panel:set_right(centre)
            casing_panel:set_right(centre)
            noreturn_panel:set_right(centre)
            buffs_panel:set_x(assault_panel:left() + self._bg_box:left() - 203)
            -- Also move other things in the HUD to remove cluttering
            local self = managers.hud -- this self has different reference (managers.hud) in the elseif clause; everywhere else is still managers.hud._hud_assault_corner (or HUDAssaultCorner)
            local timer_msg = self._hud_player_downed._hud_panel:child("downed_panel"):child("timer_msg") -- Downed Timer
            if timer_msg then
                timer_msg:set_y(96)
                self._hud_player_downed._hud.timer:set_y(math_round(timer_msg:bottom() - 6))
            end
            if self:alive("guis/mask_off_hud") then
                self:script("guis/mask_off_hud").mask_on_text:set_y(96) -- Hold [G] to mask up
            end
            timer_msg = self._hud_player_custody._hud_panel:child("custody_panel"):child("timer_msg") -- Released from Custody Timer
            if timer_msg then
                timer_msg:set_y(96)
                self._hud_player_custody._hud_panel:child("custody_panel"):child("timer"):set_y(math_round(timer_msg:bottom() - 6))
            end
        elseif bai_position == 4 then -- Centre Left
            assault_panel:set_right(left)
            assault_panel:set_top(top)
            casing_panel:set_right(left)
            casing_panel:set_top(top)
            noreturn_panel:set_right(left)
            noreturn_panel:set_top(top)
            buffs_panel:set_right(left + 41)
            buffs_panel:set_top(top)
        elseif bai_position == 5 then -- Centre
            assault_panel:set_right(centre)
            assault_panel:set_top(top)
            casing_panel:set_right(centre)
            casing_panel:set_top(top)
            noreturn_panel:set_right(centre)
            noreturn_panel:set_top(top)
            buffs_panel:set_x(assault_panel:left() + self._bg_box:left() - 203)
            buffs_panel:set_top(top)
        elseif bai_position == 6 then -- Centre Right
            assault_panel:set_top(top)
            casing_panel:set_top(top)
            noreturn_panel:set_top(top)
            buffs_panel:set_top(top)
        elseif bai_position == 7 then -- Bottom Left
            assault_panel:set_right(left)
            assault_panel:set_top(bottom)
            casing_panel:set_right(left)
            casing_panel:set_top(bottom)
            noreturn_panel:set_right(left)
            noreturn_panel:set_top(bottom)
            buffs_panel:set_right(left + 41)
            buffs_panel:set_top(bottom)
        elseif bai_position == 8 then -- Bottom Centre
            assault_panel:set_right(centre)
            assault_panel:set_top(bottom)
            casing_panel:set_right(centre)
            casing_panel:set_top(bottom)
            noreturn_panel:set_right(centre)
            noreturn_panel:set_top(bottom)
            buffs_panel:set_x(assault_panel:left() + self._bg_box:left() - 203)
            buffs_panel:set_top(bottom)
        else -- Bottom Right
            assault_panel:set_top(bottom)
            casing_panel:set_top(bottom)
            noreturn_panel:set_top(bottom)
            buffs_panel:set_top(bottom)
        end
    end
    self.assault_panel_position = bai_position
    BAI:Log("Assault Panel Position loaded")
end

local _f_hide_casing = HUDAssaultCorner.hide_casing
function HUDAssaultCorner:hide_casing()
    self._casing_show_hostages = true
    _f_hide_casing(self)
end

local _f_start_assault = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list, ...)
    _f_start_assault(self, text_list, ...)
    if self.was_endless then
        self.was_endless = false
        self:SetImage("assault")
    end
    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        if BAI:GetOption("show_assault_states") and self.is_skirmish then
            self:_popup_wave_started()
        end
        BAI:CallEvent(BAI.EventList.AssaultStart)
    end
end

function HUDAssaultCorner:_start_endless_assault(text_list)
    if self._assault_vip then
        self.was_endless = false
        self:_start_assault(self:_get_assault_strings())
        return
    end
    if not self._assault_endless then
        BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
    end
    self._assault_endless = true
    self.assault_type = "endless"
    self:_start_assault(text_list)
    self:SetImage("padlock")
    self:_update_assault_hud_color(self._assault_endless_color)
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
    local box_text_panel = self._bg_box:child("text_panel")
    box_text_panel:stop()
    box_text_panel:clear()
    self._remove_hostage_offset = true
    self._start_assault_after_hostage_offset = nil
    local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
    icon_assaultbox:stop()
    if self:should_display_waves() then
        self:_update_assault_hud_color(self._assault_survived_color)
        self:_set_text_list(self:_get_survived_assault_strings())
        box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
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
            box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
            icon_assaultbox:stop()
            icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))
            box_text_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
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
    local TOTAL_T = 1
    local t = TOTAL_T
    while t > 0 do
        local dt = coroutine.yield()
        t = t - dt
        local alpha = math_round(math_abs(math_cos(t * 360 * 2)))
        icon_assaultbox:set_alpha(alpha)
        if self._remove_hostage_offset and t < 0.03 then
            self:_set_hostages_offseted(false)
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

function HUDAssaultCorner:SetImage(image)
    if image then
        if image == "padlock" then
            self.was_endless = true
        end
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):set_image("guis/textures/pd2/hud_icon_" .. image .. "box")
    end
end

function HUDAssaultCorner:_get_assault_endless_strings()
    local endless = "hud_assault_endless" .. self:GetFactionAssaultText()
    if managers.job:current_difficulty_stars() > 0 then
        local ids_risk = self:GetRisk()
        return {
            endless,
            "hud_assault_padlock",
            ids_risk,
            "hud_assault_padlock",
            endless,
            "hud_assault_padlock",
            ids_risk,
            "hud_assault_padlock"
        }
    else
        return {
            endless,
            "hud_assault_padlock",
            endless,
            "hud_assault_padlock",
            endless,
            "hud_assault_padlock",
        }
    end
end

function HUDAssaultCorner:UpdatePONRBox()
    self._noreturn_color = BAI:GetColor("escape")
    local panel = self._hud_panel:child("point_of_no_return_panel")
    panel:child("icon_noreturnbox"):set_color(self._noreturn_color)
    local bg_box = self._noreturn_bg_box
    bg_box:child("left_top"):set_color(self._noreturn_color)
    bg_box:child("left_bottom"):set_color(self._noreturn_color)
    bg_box:child("right_top"):set_color(self._noreturn_color)
    bg_box:child("right_bottom"):set_color(self._noreturn_color)
    local text = bg_box:child("point_of_no_return_text")
    local timer = bg_box:child("point_of_no_return_timer")
    text:set_color(self._noreturn_color)
    text:set_text(utf8.to_upper(managers.localization:text(self._noreturn_data.text_id, {time = ""})))
    text:set_right(math_round(timer:left()))
    timer:set_color(self._noreturn_color)
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
            local n = 1 - math_sin(t * 180)
            local r = math_lerp(self._noreturn_color.r, 1, n)
            local g = math_lerp(self._noreturn_color.g, 0.8, n)
            local b = math_lerp(self._noreturn_color.b, 0.2, n)

            o:set_color(Color(r, g, b))
            o:set_font_size(math_lerp(tweak_data.hud_corner.noreturn_size, tweak_data.hud_corner.noreturn_size * 1.25, n))
        end
    end

    local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")

    point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud)
    local wave_text = panel:child("num_waves")
    local bg = panel:child("bg")

    wait(1.4)
    wave_text:set_text(self:get_completed_waves_string())
    bg:stop()
    bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
    wait(7.2)
    if BAI:GetOption("show_assault_states") then
        BAI:UpdateAssaultStateOverride("control")
    else
        assault_hud:_close_assault_box()
        BAI:CallEvent("MoveHUDListBack", self)
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    if self.was_endless then
        self:SetImage("assault")
        self.was_endless = false
    end
    self:SetTextListAndAnimateColor(state, true)
    if override then
        self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):stop()
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):animate(callback(self, self, "_show_icon_assaultbox"))
    end
end

function HUDAssaultCorner:OpenAssaultPanelWithAssaultState(assault_state)
    self.trigger_assault_start_event = false
    self:_start_assault(self:_get_state_strings(assault_state))
    self:_update_assault_hud_color(BAI:GetColor(assault_state))
    self:_set_hostages_offseted(true)
    self.trigger_assault_start_event = true
    BAI:CallEvent("MoveHUDList", self, true)
end

function HUDAssaultCorner:SetTextListAndAnimateColor(assault_state, is_control_or_anticipation)
    if assault_state then
        self:_animate_update_assault_hud_color(BAI:GetColor(assault_state))
        if is_control_or_anticipation then
            self:_set_text_list(self:_get_state_strings(assault_state))
        else
            self:_set_text_list(self:_get_assault_strings(assault_state, true))
        end
    else
        self:_animate_update_assault_hud_color(self._assault_color)
        self:_set_text_list(self:_get_assault_strings(nil, true))
    end
end

function HUDAssaultCorner:StartEndlessAssault()
    self:_start_endless_assault(self:_get_assault_endless_strings())
end

function HUDAssaultCorner:start_assault_callback()
    if self:GetEndlessAssault() then
        self:_start_endless_assault(self:_get_assault_endless_strings())
    else
        self.assault_type = "assault"
        local state_enabled = BAI:GetOption("show_assault_states") and BAI:IsStateEnabled("build") or false
        self:_start_assault(self:_get_assault_strings(state_enabled and "build" or nil, true))
        self:_update_assault_hud_color(state_enabled and BAI:GetColor("build") or self._assault_color) -- Don't animate color transition
        if BAI:ShowAdvancedAssaultInfo() and BAI.IsClient then
            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
        end
    end
end

function HUDAssaultCorner:_get_assault_strings(state, aai) -- Apply Holy water after reading this
    if self._assault_mode == "normal" then
        local wave = self:should_display_waves() and self._wave_counter == 3
        if (state or aai) and (BAI:GetOption("show_assault_states") or BAI:ShowAdvancedAssaultInfo()) and BAI:GetOption("hide_assault_text") then
            local tbl = {}
            local ids_risk = self:GetRisk()
            local risk = managers.job:current_difficulty_stars() > 0
            local state_condition = state and BAI:IsOr(state, "build", "sustain", "fade") and BAI:GetOption("show_assault_states")
            local aai_condition = aai and BAI:ShowAdvancedAssaultInfo() and (BAI:GetAAIOption("aai_panel") == 1 or not self.AAIPanel)
            for i = 1, 3 do -- if i == 1 only, the text dissapears from the assault panel which does not look nice
                if state_condition then
                    tbl[#tbl + 1] = "hud_" .. state
                    tbl[#tbl + 1] = "hud_assault_end_line"
                end
                if aai_condition then -- Adds advanced assault info
                    tbl[#tbl + 1] = "hud_advanced_info"
                    tbl[#tbl + 1] = "hud_assault_end_line"
                end
                if wave then
                    tbl[#tbl + 1] = "hud_wave_counter"
                    tbl[#tbl + 1] = "hud_assault_end_line"
                end
                if risk then
                    tbl[#tbl + 1] = ids_risk
                    tbl[#tbl + 1] = "hud_assault_end_line"
                end
            end
            return tbl
        end
        local assault_text = "hud_assault_assault"
        if BAI:IsCustomTextDisabled("assault") then
            assault_text = assault_text .. self:GetFactionAssaultText()
        end
        local ids_risk = self:GetRisk()
        local tbl = {
            assault_text,
            "hud_assault_end_line",
            assault_text,
            "hud_assault_end_line"
        }
        local risk = managers.job:current_difficulty_stars() > 0
        if risk then -- Adds risk icon
            table_insert(tbl, 3, ids_risk)
            table_insert(tbl, 4, "hud_assault_end_line")
            table_insert(tbl, 7, ids_risk)
            table_insert(tbl, 8, "hud_assault_end_line")
        else
            table_insert(tbl, 5, assault_text) -- Adds another assault line to return text like in Vanilla game
            table_insert(tbl, 6, "hud_assault_end_line")
        end
        if state and BAI:IsOr(state, "build", "sustain", "fade") and BAI:GetOption("show_assault_states") then -- Adds assault state
            local hud_state = "hud_" .. state
            if risk then
                table_insert(tbl, 3, hud_state)
                table_insert(tbl, 4, "hud_assault_end_line")
                table_insert(tbl, 9, hud_state)
                table_insert(tbl, 10, "hud_assault_end_line")
            else
                tbl[3] = hud_state -- Replaces second assault line with assault state
                table_insert(tbl, 7, hud_state)
                table_insert(tbl, 8, "hud_assault_end_line")
            end
            state = true
        else
            state = nil
        end
        if aai and BAI:ShowAdvancedAssaultInfo() and (BAI:GetAAIOption("aai_panel") == 1 or not self.AAIPanel) then -- Adds advanced assault info
            if state then
                table_insert(tbl, 5, "hud_advanced_info")
                table_insert(tbl, 6, "hud_assault_end_line")
                table_insert(tbl, risk and 13 or 11, "hud_advanced_info")
                table_insert(tbl, risk and 14 or 12, "hud_assault_end_line")
            else
                tbl[3] = "hud_advanced_info" -- Replaces second assault line with advanced assault info
                table_insert(tbl, risk and 9 or 7, "hud_advanced_info")
                table_insert(tbl, risk and 10 or 8, "hud_assault_end_line")
            end
            aai = true
        else
            aai = nil
        end
        if wave then
            if state and aai then
                table_insert(tbl, 7, "hud_wave_counter")
                table_insert(tbl, 8, "hud_assault_end_line")
                table_insert(tbl, risk and 17 or 15, "hud_wave_counter")
                table_insert(tbl, risk and 18 or 16, "hud_assault_end_line")
            elseif state or aai then
                table_insert(tbl, 5, "hud_wave_counter")
                table_insert(tbl, 6, "hud_assault_end_line")
                table_insert(tbl, risk and 13 or 11, "hud_wave_counter")
                table_insert(tbl, risk and 14 or 12, "hud_assault_end_line")
            else
                table_insert(tbl, 3, "hud_wave_counter")
                table_insert(tbl, 4, "hud_assault_end_line")
                table_insert(tbl, risk and 9 or 7, "hud_wave_counter")
                table_insert(tbl, risk and 10 or 8, "hud_assault_end_line")
            end
        end
        return tbl
    else
        if managers.job:current_difficulty_stars() > 0 then
            local ids_risk = self:GetRisk()
            return {
                "hud_assault_vip",
                "hud_assault_padlock",
                ids_risk,
                "hud_assault_padlock",
                "hud_assault_vip",
                "hud_assault_padlock",
                ids_risk,
                "hud_assault_padlock"
            }
        else
            return {
                "hud_assault_vip",
                "hud_assault_padlock",
                "hud_assault_vip",
                "hud_assault_padlock",
                "hud_assault_vip",
                "hud_assault_padlock"
            }
        end
    end
end

function HUDAssaultCorner:_get_survived_assault_strings(endless)
    local survived_text = "hud_assault_survived" .. (endless and "_endless" or "")
    local end_line = "hud_assault_" .. (endless and "padlock" or "end_line")
    local wave = self:should_display_waves() and self._wave_counter == 3
    if BAI:IsCustomTextEnabled("survived") then
        survived_text = "hud_assault_survived"
    else
        survived_text = survived_text .. self:GetFactionAssaultText(true)
    end
    if managers.job:current_difficulty_stars() > 0 then
        local ids_risk = self:GetRisk()
        if wave then
            return {
                survived_text,
                end_line,
                "hud_wave_counter",
                end_line,
                ids_risk,
                end_line,
                survived_text,
                end_line,
                "hud_wave_counter",
                end_line,
                ids_risk,
                end_line
            }
        else
            return {
                survived_text,
                end_line,
                ids_risk,
                end_line,
                survived_text,
                end_line,
                ids_risk,
                end_line
            }
        end
    else
        if wave then
            return {
                survived_text,
                end_line,
                "hud_wave_counter",
                end_line,
                survived_text,
                end_line,
                "hud_wave_counter",
                end_line,
                survived_text,
                end_line
            }
        else
            return {
                survived_text,
                end_line,
                survived_text,
                end_line,
                survived_text,
                end_line
            }
        end
    end
end

function HUDAssaultCorner:_get_state_strings(state)
    local state_text = "hud_" .. state
    local break_time = BAI:IsAAIEnabledAndOption("show_break_time_left") and (BAI:GetAAIOption("aai_panel") == 1 or not self.AAIPanel)
    local wave = self:should_display_waves() and self._wave_counter == 3
    if managers.job:current_difficulty_stars() > 0 then
        local ids_risk = self:GetRisk()
        if break_time then
            if wave then
                return {
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line"
                }
            else
                return {
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line"
                }
            end
        else
            if wave then
                return {
                    state_text,
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line"
                }
            else
                return {
                    state_text,
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    ids_risk,
                    "hud_assault_end_line"
                }
            end
        end
    else
        if break_time then
            if wave then
                return {
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                }
            else
                return {
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_break_time_info",
                    "hud_assault_end_line"
                }
            end
        else
            if wave then
                return {
                    state_text,
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    "hud_wave_counter",
                    "hud_assault_end_line"
                }
            else
                return {
                    state_text,
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line",
                    state_text,
                    "hud_assault_end_line"
                }
            end
        end
    end
end

function HUDAssaultCorner:_animate_normal_wave_completed(panel, assault_hud)
    wait(8.6)
    if BAI:GetOption("show_assault_states") then
        BAI:UpdateAssaultStateOverride("control")
    else
        self:_close_assault_box()
        BAI:CallEvent("MoveHUDListBack", self)
    end
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_mode = mode
    self._assault_vip = mode == "phalanx"
    self:_set_text_list(self:_get_assault_strings())
    self:SetImage(self._assault_vip and "padlock" or "assault")
    if mode == "phalanx" then
        self._assault_endless = false
        self:_animate_update_assault_hud_color(self._vip_assault_color)
    else
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultState("fade") -- When Captain is defeated, Assault State is automatically set to Fade state
        else
            self:_animate_update_assault_hud_color(self._assault_color)
        end
    end
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetAnimationOption("enable_animations") and BAI:GetAnimationOption("animate_color_change") then
        if self._anim_thread then
            self._bg_box:stop(self._anim_thread)
        end
        self._anim_thread = self._bg_box:animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"), self._current_assault_color)
    else
        self:_update_assault_hud_color(color)
    end
end

local _f_set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if self.assault_panel_position == 1 then -- Top Left
        local panel = managers.hud._hud_objectives._hud_panel:child("objectives_panel")
        self._remove_hostage_offset = nil

        local panel_h = 0
        if panel then
            panel_h = panel:h()
            panel:stop()
            panel:animate(callback(self, self, "_offset_hostage", is_offseted))
        end

        if HUDListManager then -- Don't trigger assault start twice
            managers.hudlist:list("left_list")._panel:animate(callback(self, self, "_offset_hostages"), is_offseted, panel_h)
        end

        if is_offseted then
            self:start_assault_callback()
        end

        return
    end

    if self.assault_panel_position == 2 then -- Top Center
        self._remove_hostage_offset = nil
        if VoidUI then
            if is_offseted then
                self:start_assault_callback()
            end
            return
        end

        if panel then
            local panel = managers.hud._hud_heist_timer._hud_panel:child("heist_timer_panel")
            panel:stop()
            panel:animate(callback(self, self, "_offset_hostage", is_offseted))
        end

        if is_offseted then
            self:start_assault_callback()
        end

        return
    end

    if self.assault_panel_position ~= 3 then -- Other positions except those above and Top Right
        if is_offseted then
            self:start_assault_callback()
        end
        return
    end

    if self.AAIPanel then
        local offset = is_offseted
        if BAI._cache.detected_hud == 5 then -- HoloUI
            if self._always_offseted then
                offset = true
            end
            if self._always_not_offseted then
                offset = false
            end
        end
        self._time_left_panel:stop()
        self._time_left_panel:animate(callback(self, self, "_offset_hostages"), offset)

        self._spawns_left_panel:stop()
        self._spawns_left_panel:animate(callback(self, self, "_offset_hostages"), offset)

        self._break_time_panel:stop()
        self._break_time_panel:animate(callback(self, self, "_offset_hostages"), offset)

        self._captain_panel:stop()
        self._captain_panel:animate(callback(self, self, "_offset_hostages"), offset)
    end

    _f_set_hostage_offseted(self, is_offseted)
end

function HUDAssaultCorner:_set_hostages_offseted(is_offseted)
    if self.assault_panel_position == 1 then -- Top Left
        local panel = managers.hud._hud_objectives._hud_panel:child("objectives_panel")
        self._remove_hostage_offset = nil

        local panel_h = panel:h()

        panel:stop()
        panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        if HUDListManager then
            local left_list = managers.hudlist:list("left_list")._panel
            left_list:stop()
            left_list:animate(callback(self, self, "_offset_hostages"), is_offseted, panel_h)
        end

        return
    end

    if self.assault_panel_position == 2 then -- Top Center
        self._remove_hostage_offset = nil
        if VoidUI then
            return
        end
        local panel = managers.hud._hud_heist_timer._hud_panel:child("heist_timer_panel")

        panel:stop()
        panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        return
    end

    if self.assault_panel_position ~= 3 then -- Other positions except those above and Top Right
        return
    end

    local hostage_panel = self._hud_panel:child("hostages_panel")
    self._remove_hostage_offset = nil

    hostage_panel:stop()
    hostage_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

    local wave_panel = self._hud_panel:child("wave_panel")

    if wave_panel then
        wave_panel:stop()
        wave_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)
    end

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

function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted) -- Just offseting panels, nothing more!
    local TOTAL_T = 0.18
    local OFFSET = self._bg_box:h() + 8
    local from_y = is_offseted and 0 or OFFSET
    local target_y = is_offseted and OFFSET or 0
    local t = (1 - math_abs(hostage_panel:y() - target_y) / OFFSET) * TOTAL_T
    while t < TOTAL_T do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        hostage_panel:set_y(math_lerp(from_y, target_y, lerp))
    end
end

function HUDAssaultCorner:_offset_hostages_width(hostage_panel, is_offseted) -- Animation for the assault panel when moving on the screen
    local TOTAL_T = 0.18
    local OFFSET = self._bg_box:w()
    local from_x = is_offseted and 0 or OFFSET
    local target_x = is_offseted and OFFSET or 0
    local t = (1 - math_abs(hostage_panel:x() - target_x) / OFFSET) * TOTAL_T
    while t < TOTAL_T do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        hostage_panel:set_x(math_lerp(from_x, target_x, lerp))
    end
end

function HUDAssaultCorner:ShowHostagePanel(t, dt)
    self._hud_panel:child("hostages_panel"):set_alpha(self._hud_panel:child("hostages_panel"):alpha() + dt)
    if self._hud_panel:child("hostages_panel"):alpha() >= 1 then
        managers.hud:remove_updator("HostagePanelVisibility")
    end
end

function HUDAssaultCorner:HideHostagePanel(t, dt)
    self._hud_panel:child("hostages_panel"):set_alpha(self._hud_panel:child("hostages_panel"):alpha() - dt)
    if self._hud_panel:child("hostages_panel"):alpha() <= 0 then
        managers.hud:remove_updator("HostagePanelVisibility")
    end
end

local _f_show_hostages = HUDAssaultCorner._show_hostages
function HUDAssaultCorner:_show_hostages(no_animation)
    if not self._point_of_no_return and self.AnimateHostagesPanel and not no_animation then
        if self.compatibility_flags.AnimateNew then
            BAI:AnimateSafe("HostagePanelVisibility", 1, callback(self, self, "ShowHostagePanel"))
        else
            BAI:Animate(self._hud_panel:child("hostages_panel"), 1, "FadeIn")
        end
        return
    end
    _f_show_hostages(self)
end

local _f_hide_hostages = HUDAssaultCorner._hide_hostages
function HUDAssaultCorner:_hide_hostages(no_animation)
    if self.AnimateHostagesPanel and not no_animation then
        if self.compatibility_flags.AnimateNew then
            BAI:AnimateSafe("HostagePanelVisibility", 0, callback(self, self, "HideHostagePanel"))
        else
            BAI:Animate(self._hud_panel:child("hostages_panel"), 0, "FadeOut")
        end
        return
    end
    _f_hide_hostages(self)
end

function HUDAssaultCorner:PostAnimationBG(panel)
    local bg = panel:child("bg")
    bg:stop()
    bg:set_color(Color(1, 0, 0, 0))
    bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"))
end

function HUDAssaultCorner:ShowTimePanel(t, dt)
    self._time_left_panel:set_alpha(self._time_left_panel:alpha() + dt)
    if self._time_left_panel:alpha() >= 1 then
        self:PostAnimationBG(self._time_bg_box)
        managers.hud:remove_updator("TimePanelVisibility")
    end
end

function HUDAssaultCorner:HideTimePanel(t, dt)
    self._time_left_panel:set_alpha(self._time_left_panel:alpha() - dt)
    if self._time_left_panel:alpha() <= 0 then
        managers.hud:remove_updator("TimePanelVisibility")
    end
end

function HUDAssaultCorner:ShowSpawnsPanel(t, dt)
    self._spawns_left_panel:set_alpha(self._spawns_left_panel:alpha() + dt)
    if self._spawns_left_panel:alpha() >= 1 then
        self:PostAnimationBG(self._spawns_bg_box)
        managers.hud:remove_updator("SpawnsPanelVisibility")
    end
end

function HUDAssaultCorner:HideSpawnsPanel(t, dt)
    self._spawns_left_panel:set_alpha(self._spawns_left_panel:alpha() - dt)
    if self._spawns_left_panel:alpha() <= 0 then
        managers.hud:remove_updator("SpawnsPanelVisibility")
    end
end

function HUDAssaultCorner:ShowBreakTimePanel(t, dt)
    self._break_time_panel:set_alpha(self._break_time_panel:alpha() + dt)
    if self._break_time_panel:alpha() >= 1 then
        self:PostAnimationBG(self._break_time_bg_box)
        managers.hud:remove_updator("BreakTimePanelVisibility")
    end
end

function HUDAssaultCorner:HideBreakTimePanel(t, dt)
    self._break_time_panel:set_alpha(self._break_time_panel:alpha() - dt)
    if self._break_time_panel:alpha() <= 0 then
        managers.hud:remove_updator("BreakTimePanelVisibility")
    end
end

local local_t = 0
local local_t_break = 0
local t_max = BAI:GetAAIOption("aai_panel_update_rate")
function HUDAssaultCorner:SetHook(hook, delay)
    if hook then
        if not BAI:ShowAdvancedAssaultInfo() then -- Rewrite this mess
            return
        end
        if BAI:GetAAIOption("aai_panel") == 1 then
            return
        end
        if not (self.AAIPanel or self.AAIPanelOverride) then
            return
        end
        local extension = ""
        if BAI:GetAAIOption("spawn_numbers") == 2 then
            extension = "BSN" -- Better Spawn Numbers
        end
        if BAI.IsClient then
            extension = extension .. "Client"
        end
        managers.hud:add_updator("BAI_UpdateAAI", callback(self, self, "UpdateAdvancedAssaultInfo" .. extension))
        if BAI:GetAAIOption("show_time_left") then
            if self.compatibility_flags.AnimateNew then
                BAI:AnimateSafe("TimePanelVisibility", 1, callback(self, self, "ShowTimePanel"))
            else
                local function f()
                    BAI:Animate(self._time_left_panel, 1, self.AAIFunction, unpack(self.AAIFunctionArgs1))
                end
                BAI:DelayCall("DelayTimeLeftPanel", delay or 1, f)
            end
        end
        if BAI:GetAAIOption("show_spawns_left") then
            if self.compatibility_flags.AnimateNew then
                BAI:AnimateSafe("SpawnsPanelVisibility", 1, callback(self, self, "ShowSpawnsPanel"))
            else
                local function f()
                    BAI:Animate(self._spawns_left_panel, 1, self.AAIFunction, unpack(self.AAIFunctionArgs2))
                end
                BAI:DelayCall("DelaySpawnsLeftPanel", delay or 1, f)
            end
        end
    else
        managers.hud:remove_updator("BAI_UpdateAAI")
        local_t = 0
        if self.compatibility_flags.AnimateNew then
            BAI:AnimateSafe("TimePanelVisibility", 0, callback(self, self, "HideTimePanel"))
            BAI:AnimateSafe("SpawnsPanelVisibility", 0, callback(self, self, "HideSpawnsPanel"))
        else
            BAI:RemoveDelayedCall("DelayTimeLeftPanel")
            BAI:RemoveDelayedCall("DelaySpawnsLeftPanel")
            BAI:Animate(self._time_left_panel, 0, "FadeOut")
            BAI:Animate(self._spawns_left_panel, 0, "FadeOut")
        end
    end
end

function HUDAssaultCorner:SetBreakHook(hook, delay)
    if hook then
        if not BAI:IsAAIEnabledAndOption("show_break_time_left") then
            return
        end
        if BAI:GetAAIOption("aai_panel") == 1 then
            return
        end
        if not (self.AAIPanel or self.AAIPanelOverride) then
            return
        end
        local extension = ""
        if BAI.IsClient then
            BAI:SetBreakTimer()
            extension = extension .. "Client"
        end
        managers.hud:add_updator("BAI_UpdateBreakTimeInfo", callback(self, self, "UpdateBreakTimeInfo" .. extension))
        if self.compatibility_flags.AnimateNew then
            BAI:AnimateSafe("BreakTimePanelVisibility", 1, callback(self, self, "ShowBreakTimePanel"))
        else
            local function f()
                BAI:Animate(self._break_time_panel, 1, self.AAIFunction, unpack(self.AAIFunctionArgs3))
            end
            BAI:DelayCall("DelayBreakTimePanel", delay or 1, f)
        end
    else
        managers.hud:remove_updator("BAI_UpdateBreakTimeInfo")
        local_t_break = 0
        if self.compatibility_flags.AnimateNew then
            BAI:AnimateSafe("BreakTimePanelVisibility", 0, callback(self, self, "HideBreakTimePanel"))
        else
            BAI:RemoveDelayedCall("DelayBreakTimePanel")
            local function f()
                BAI:Animate(self._break_time_panel, 0, "FadeOut")
            end
            BAI:DelayCall("HideBreakPanel", 1, f)
        end
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfo(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:CalculateTimeLeft())
        self._spawns_left_text:set_text(math_round(math_max(managers.localization:CalculateSpawnsLeft(), 0)))
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoBSN(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:CalculateTimeLeft())
        self._spawns_left_text:set_text(managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()))
        self._spawns_left_text:set_text(managers.hud:GetSpawnsLeft())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoBSNClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()))
        self._spawns_left_text:set_text(managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateBreakTimeInfo(t, dt)
    local_t_break = local_t_break + dt
    if local_t_break > t_max then
        self._break_time_text:set_text(managers.localization:FormatBreakTimeLeft(managers.localization:CalculateTimeLeftNoFormat(0)))
        local_t_break = 0
    end
end

function HUDAssaultCorner:UpdateBreakTimeInfoClient(t, dt)
    local_t_break = local_t_break + dt
    if local_t_break > t_max then
        self._break_time_text:set_text(managers.localization:FormatBreakTimeLeft(managers.hud:GetBreakTimeLeft()))
        local_t_break = 0
    end
end

function HUDAssaultCorner:ShowCaptainPanel(t, dt)
    self._captain_panel:set_alpha(self._captain_panel:alpha() + dt)
    if self._captain_panel:alpha() >= 1 then
        managers.hud:remove_updator("CaptainPanelVisibility")
    end
end

function HUDAssaultCorner:HideCaptainPanel(t, dt)
    self._captain_panel:set_alpha(self._captain_panel:alpha() - dt)
    if self._captain_panel:alpha() <= 0 then
        managers.hud:remove_updator("CaptainPanelVisibility")
    end
end

function HUDAssaultCorner:SetCaptainHook(active)
    if not BAI:IsAAIEnabledAndOption("captain_panel") then
        return
    end
    if self.compatibility_flags.AnimateNew then
        BAI:AnimateSafe("CaptainPanelVisibility", active and 1 or 0, callback(self, self, active and "ShowCaptainPanel" or "HideCaptainPanel"))
    else
        BAI:Animate(self._captain_panel, active and 1 or 0, active and "FadeIn" or "FadeOut")
    end
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not (self.AAIPanel and BAI:IsAAIEnabledAndOption("captain_panel")) then
        return
    end
    self._captain_bg_box:child("num_reduction"):set_text((BAI:RoundNumber(buff, 0.01) * 100) .. "%")
    self:PostAnimationBG(self._captain_bg_box)
end