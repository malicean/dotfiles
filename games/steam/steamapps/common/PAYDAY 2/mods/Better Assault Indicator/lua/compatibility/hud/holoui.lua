local BAI = BAI
local _BAI_start_assault = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list)
    _BAI_start_assault(self, text_list)
    if alive(self._bg_box) then
        self._bg_box:stop()
        self._bg_box:child("text_panel"):stop()
        self._bg_box:show()
        self:left_grow(self._bg_box)
        self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._bg_box, nil, callback(self, self, "assault_attention_color_function"))
        if alive(self._wave_bg_box) then
            self._wave_bg_box:child("bg"):stop()
        end
    end
    if BAI:IsHostagePanelHidden(self.assault_type) then
        self:_hide_hostages()
    end
end

function HUDAssaultCorner:_update_assault_hud_color(color)
    self._current_assault_color = color
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetHUDOption("holoui", "update_text_color") then
        if BAI:GetAnimationOption("animate_color_change") then
            if self._anim_thread then
                self._bg_box:stop(self._anim_thread)
            end
            self._anim_thread = self._bg_box:animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"), self._current_assault_color)
        else
            self:_update_assault_hud_color(color)
        end
    end
end

function HUDAssaultCorner:assault_attention_color_function()
    return BAI:GetHUDOption("holoui", "update_text_color") and self._current_assault_color or Holo:GetColor("TextColors/Assault")
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
    if BAI:GetHUDOption("holoui", "update_text_color") then
        self._noreturn_bg_box:child("point_of_no_return_text"):set_color(self._noreturn_color)
    end
end

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
    local flash_timer
    if BAI:GetHUDOption("holoui", "update_text_color") then
        flash_timer = function(o)
            local t = 0
            while t < 0.5 do
                t = t + coroutine.yield()
                local n = 1 - math.sin(t * 180)
                local r = math.lerp(self._noreturn_color.r, 1, n)
                local g = math.lerp(self._noreturn_color.g, 0.8, n)
                local b = math.lerp(self._noreturn_color.b, 0.2, n)
                o:set_color(Color(r, g, b))
                local font_size = (tweak_data.hud_corner.noreturn_size)
                o:set_font_size(math.lerp(font_size, font_size * 1.25, n))
            end
        end
    else
        flash_timer = function(o)
            local t = 0
            while t < 0.5 do
                t = t + coroutine.yield()
                local font_size = (tweak_data.hud_corner.noreturn_size)
                o:set_font_size(math.lerp(font_size, font_size * 1.25, n))
            end
        end
    end
    local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
    point_of_no_return_timer:animate(flash_timer)
end

local _BAI_set_hostages_offseted = HUDAssaultCorner._set_hostages_offseted
function HUDAssaultCorner:_set_hostages_offseted(is_offseted)
    self._is_offseted = is_offseted
    _BAI_set_hostages_offseted(self, is_offseted)
end

local function FixPanel(self, panel, icon, bg_box, text, move_condition, x_correction)
    if move_condition then
        x_correction = x_correction or 0
        bg_box:set_x(bg_box:x() + 38 + x_correction)
        panel:set_w(panel:w() + 38 + x_correction)
    else
        panel:set_righttop(self._hud_panel:w(), 0)
        bg_box:set_right(panel:w())
    end
    bg_box:set_h(32)
    panel:set_h(32)
    panel:child(icon):set_w(32)
    panel:child(icon):set_h(32)
    bg_box:child(text):set_y(-4)
    bg_box:child(text):set_font(Idstring("fonts/font_medium_noshadow_mf"))
    bg_box:child(text):set_font_size(26) -- self._box_height - 6
    HUDBGBox_recreate(bg_box, {
        name = "Hostages",
        w = bg_box:w(),
        h = bg_box:h()
    })
    panel:child(icon):set_right(bg_box:left())
end

local _BAI_InitAAIPanel = HUDAssaultCorner.InitAAIPanel
function HUDAssaultCorner:InitAAIPanel()
    _BAI_InitAAIPanel(self)
    if not self.AAIPanel then
        return
    end
    local final = true
    local correction = 65
    if not self:should_display_waves() then
        final = BAI:IsHostagePanelVisible()
        correction = 0
    end
    FixPanel(self, self._time_left_panel, "time_icon", self._time_bg_box, "time_left", final, correction)
    self._time_bg_box = self._time_bg_box:child("time_left")
    FixPanel(self, self._break_time_panel, "break_time_icon", self._break_time_bg_box, "break_time_left", final, correction)
    self._break_time_bg_box = self._break_time_bg_box:child("break_time_left")
    FixPanel(self, self._spawns_left_panel, "spawns_icon", self._spawns_bg_box, "spawns_left", true, correction)
    self._spawns_bg_box = self._spawns_bg_box:child("spawns_left")
end

local _BAI_InitCaptainPanel = HUDAssaultCorner.InitCaptainPanel
function HUDAssaultCorner:InitCaptainPanel()
    _BAI_InitCaptainPanel(self)
    if not self.AAIPanel then
        return
    end
    FixPanel(self, self._captain_panel, "captain_icon", self._captain_bg_box, "num_reduction", BAI:IsHostagePanelVisible("captain"))
end

function HUDAssaultCorner:PostAnimationBG(panel)
    panel:stop()
    play_value(panel, "alpha", 0.25, {time = 1, callback = function()
        play_value(panel, "alpha", 1, {time = 1})
    end})
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not (self.AAIPanel and BAI:IsAAIEnabledAndOption("captain_panel")) then
        return
    end
    local pbuff = self._captain_bg_box:child("num_reduction")
    pbuff:set_text((BAI:RoundNumber(buff, 0.01) * 100) .. "%")
    self:PostAnimationBG(pbuff)
end