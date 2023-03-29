local BAI = BAI
local NobleHUD = NobleHUD
if not NobleHUD then
    BAI:CrashWithErrorHUD("Halo: Reach HUD")
end
local as_text = ""
function NobleHUD:SetAssaultPhase(text, send_to_peers)
    -- You picked the wrong house, fool. That's my job!
    --local assault_phase_label = self._score_panel:child("assault_phase_label")
    if text ~= as_text then
        as_text = text
		--assault_phase_label:set_text(text)
		--self:animate(assault_phase_label,"animate_killfeed_text_in",nil,0.3,20,self.color_data.hud_vitalsoutline_blue,self.color_data.hud_text_flash)
		if send_to_peers then -- Atleast I will network your sync message.
			LuaNetworking:SendToPeersExcept(1, self.network_messages.sync_assault, text)
		end
	end
end

function NobleHUD:SetAssaultPhase_BAI(text, text_id)
    if text_id and not BAI:IsOr(text_id, "survived", "escape") and BAI:ShowFSSAI() and BAI:IsCustomTextDisabled(text_id) then
        text = "hud_fss_mod_" .. math.random(3)
    end
    local color = self:GetNobleHUDColor(text_id)
    local assault_phase_label = self._score_panel:child("assault_phase_label")
    if (text and text ~= assault_phase_label:text()) or (color ~= assault_phase_label:color() or false) then
        assault_phase_label:set_text(managers.localization:text(text))
        self:animate(assault_phase_label, "animate_killfeed_text_in", nil, 0.3, 20, color, self.color_data.hud_text_flash)
    end
    self._score_panel:child("aai"):animate(callback(BAIAnimation, BAIAnimation, "NobleHUD_animate_color"), color)
    self._score_panel:child("break"):animate(callback(BAIAnimation, BAIAnimation, "NobleHUD_animate_color"), color)
end

function NobleHUD:GetNobleHUDColor(type)
    if not BAI:GetHUDOption("halo_reach_hud", "use_bai_color") then
        return self.color_data.hud_vitalsoutline_blue
    end
    if type then
        return BAI:GetRightColor(type)
    end
    return self.color_data.hud_vitalsoutline_blue
end

function NobleHUD:SetHostagePanelVisible(visibility)
    BAI:Animate(self._score_panel:child("hostages_panel"), visibility and 1 or 0, visibility and "FadeIn" or "FadeOut")
end

local c = Color.red
local _f_create_score = NobleHUD._create_score
function NobleHUD:_create_score(hud)
    _f_create_score(self, hud)
    local score_panel = self._score_panel
    local aai = score_panel:text({
        name = "aai",
        text = "", -- 999 | 4 min 00 s
        align = "left",
        x = score_panel:child("wave_label"):x(),
        y = score_panel:child("wave_label"):y(),
        color = self.color_data.hud_vitalsoutline_blue,
        kern = self._font_eurostile_kern,
		font = self.fonts.eurostile_normal,
        font_size = 20,
        layer = 4,
        alpha = 0
    })
    local break_time = score_panel:text({
        name = "break",
        text = "", -- 4 min 00 s
        align = "left",
        x = score_panel:child("wave_label"):x(),
        y = score_panel:child("wave_label"):y(),
        color = self.color_data.hud_vitalsoutline_blue,
        kern = self._font_eurostile_kern,
		font = self.fonts.eurostile_normal,
        font_size = 20,
        layer = 4,
        alpha = 0
    })
    local captain_active = score_panel:text({
        name = "captain_active",
        text = managers.localization:text("hud_captain_active"),
        align = "left",
        x = score_panel:child("wave_label"):x(),
        y = score_panel:child("wave_label"):y(),
        color = self.color_data.hud_vitalsoutline_blue,
        kern = self._font_eurostile_kern,
		font = self.fonts.eurostile_normal,
        font_size = 20,
        layer = 4,
        alpha = 0
    })
    local captain_color = BAI:GetRightColor("captain")
    local captain_icon = score_panel:bitmap({
        name = "captain_icon",
        texture = tweak_data.bai.captain.texture,
        w = 20,
        h = 20,
        x = score_panel:child("wave_label"):x(),
        y = score_panel:child("wave_label"):y(),
        layer = 4,
        alpha = 0,
        color = captain_color
    })
    local captain_buff = score_panel:text({
        name = "captain_buff",
        text = "0%",
        align = "left",
        y = score_panel:child("wave_label"):y(),
        color = captain_color,
        kern = self._font_eurostile_kern,
		font = self.fonts.eurostile_normal,
        font_size = 20,
        layer = 4,
        alpha = 0
    })
    captain_buff:set_left(captain_icon:right())
    if BAI:GetHUDOption("halo_reach_hud", "use_bai_color") then
        local cc = BAI:GetColor("escape")
        score_panel:child("ponr_label"):set_color(cc)
        score_panel:child("ponr_timer"):set_color(cc)
        c = cc
    end
    local self = managers.hud._hud_assault_corner
    if self:should_display_waves() then
        aai:set_y(aai:y() - 32) -- Move it above assault phase label when "WaveX/Y" text is visible
    end
    self:SetVariables()
    self:InitCaptainPanelEvents()
    self.AAIPanelUpdate = true
end

function HUDAssaultCorner:UpdatePONRBox()
    if NobleHUD._score_panel and NobleHUD._score_panel:child("ponr_label") and NobleHUD._score_panel:child("ponr_timer") then
        self._noreturn_color = BAI:GetColor("escape")
        self._point_of_no_return_color = self._noreturn_color
        c = self._noreturn_color
        local score_panel = self._score_panel
        score_panel:child("ponr_label"):set_color(c)
        score_panel:child("ponr_timer"):set_color(c)
    end
end

--[[
    Why are you the way that you are?
    Honestly, every time I try to do something fun or exciting, you make it not that way.
    I hate so much about the things you choosed to be...

    This is one of those things.
]]
function NobleHUD:AnimatePONRFlash(beep)
	local ponr_text = self._score_panel:child("ponr_timer")
	self:animate_stop(ponr_text)
	ponr_text:set_font_size(24)
	ponr_text:set_color(c)
	if beep then
		self:animate(ponr_text,"animate_killfeed_text_in",nil,0.5,24,self.color_data.hud_hint_orange,self.color_data.hud_hint_lightorange)
	else -- Stop making my life harder. Seriously!
		self:animate(ponr_text,"animate_killfeed_text_in",nil,0.5,24,c,Color.white)
	end
end

function HUDAssaultCorner:show_point_of_no_return_timer()
    self._point_of_no_return = true
    --NobleHUD:animate(NobleHUD._score_panel:child("assault_phase_label"), "animate_fadeout", nil, 0.3, 1, 1) -- Disabled due to bug
    NobleHUD:SetAssaultPhase_BAI("hud_no_return", "escape")
end

function HUDAssaultCorner:WaveCounterEnabled()
    return false
end

function HUDAssaultCorner:_start_endless_assault(text_list)
    if self._assault_vip then
        NobleHUD:SetAssaultPhase_BAI("hud_captain", "captain")
        return
    end
    if not self._assault_endless then
        BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
    end
    self._assault_endless = true
    self.assault_type = "endless"
    NobleHUD:SetAssaultPhase_BAI("hud_endless", "endless")
end

function HUDAssaultCorner:_start_assault(text_list)
    self._assault = true
    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        BAI:CallEvent(BAI.EventList.AssaultStart)
        if BAI:GetOption("show_assault_states") and BAI:IsStateEnabled("build") then
            NobleHUD:SetAssaultPhase_BAI("hud_build", "build")
        else
            NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
        end
        if self.is_skirmish then
            self:_popup_wave_started()
            if alive(self._wave_bg_box) then
                self._wave_bg_box:stop()
                self._wave_bg_box:animate(callback(self, self, "_animate_wave_started"), self)
            end
        end
    end
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_mode = mode
    self._assault_vip = mode == "phalanx"
    if mode == "phalanx" then
        if BAI:IsHostagePanelHidden("captain") then
            self:_hide_hostages()
        end
        self._assault_endless = false
        NobleHUD:SetAssaultPhase_BAI("hud_captain", "captain")
    else
        if BAI:IsHostagePanelVisible("assault") then
            self:_show_hostages()
        end
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultState("fade") -- When Captain is defeated, Assault state is automatically set to Fade state
        else
            NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
        end
    end
end

if not BAI:GetAAIOption("captain_panel") then
    function HUDAssaultCorner:set_buff_enabled(buff_name, enabled)
        if enabled and not self._enabled then
            self._enabled = true
            --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadein", nil, 0.3, 1, 0) -- Disabled due to bug
            BAI:Animate(NobleHUD._score_panel:child("captain_active"), 1, "FadeIn")
        elseif not enabled then
            self._enabled = false
            BAI:Animate(NobleHUD._score_panel:child("captain_active"), 0, "FadeOut")
            --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadeout", nil, 0.3, 1, 1) -- Disabled due to bug
        end
        if enabled then
            NobleHUD:AddBuff(buff_name)
        else
            NobleHUD:RemoveBuff(buff_name)
        end
    end
end

function HUDAssaultCorner:_end_assault()
    if not self._assault then
         self._start_assault_after_hostage_offset = nil
         return
    end
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    self.assault_type = nil
    self._assault = nil
    self._assault_endless = nil
    if self:should_display_waves() then
        NobleHUD:AnimateNormalWaveComplete(self)
        self._wave_bg_box:stop()
		self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            NobleHUD:AnimateNormalWaveComplete()
        else
            if BAI:GetOption("show_assault_states") then
                BAI:UpdateAssaultStateOverride("control", true)
                if BAI:IsHostagePanelVisible() then
                    self:_show_hostages()
                end
            else
                NobleHUD:_close_assault_box()
                BAI:CallEvent("MoveHUDListBack", self)
            end
        end
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end
    self.trigger_assault_start_event = true
end

function NobleHUD:AnimateNormalWaveComplete(hud)
    self:SetAssaultPhase_BAI("hud_survived", "survived")
    self:AddDelayedCallback(function()
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultStateOverride("control")
            if BAI:IsHostagePanelVisible() then
                hud:_show_hostages()
            end
        else
            self:_close_assault_box()
            BAI:CallEvent("MoveHUDListBack", hud)
        end
    end, nil, 8.6)
end

function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud)
    local wave_text = panel:child("num_waves")
    local bg = panel:child("bg")

    wait(1.4)
    wave_text:set_text(self:get_completed_waves_string())
    bg:stop()
    bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
end

HUDAssaultCorner._close_assault_box = function()
    NobleHUD:_close_assault_box()
end

function NobleHUD:_close_assault_box()
    self:SetAssaultPhase_BAI("noblehud_hud_assault_phase_standby")
end

function HUDAssaultCorner:OpenAssaultPanelWithAssaultState(assault_state)
    NobleHUD:SetAssaultPhase_BAI("hud_" .. assault_state, assault_state)
    BAI:CallEvent("MoveHUDList", self)
end

function HUDAssaultCorner:SetTextListAndAnimateColor(assault_state, is_control_or_anticipation)
    if assault_state then
        NobleHUD:SetAssaultPhase_BAI("hud_" .. assault_state, assault_state)
    else
        NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    NobleHUD:SetAssaultPhase_BAI("hud_" .. state, state)
end

function HUDAssaultCorner:show_casing(mode) --Disables casing mode indicator
end

function HUDAssaultCorner:_show_hostages()
    if not self._point_of_no_return then
        NobleHUD:SetHostagePanelVisible(true)
    end
end

function HUDAssaultCorner:_hide_hostages()
    NobleHUD:SetHostagePanelVisible(false)
end

local local_t = 0
local local_t_break = 0
function HUDAssaultCorner:SetHook(hook)
    if not BAI:ShowAdvancedAssaultInfo() then
        return
    end
    BAI:Animate(NobleHUD._score_panel:child("aai"), hook and 1 or 0, hook and "FadeIn" or "FadeOut")
    if hook then
        --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadein", nil, 0.3, 1, 0) -- Disabled due to bug
        local extension = ""
        if BAI:GetAAIOption("spawn_numbers") == 2 then
            extension = "BSN" -- Better Spawn Numbers
        end
        if self.is_client then
            extension = extension .. "Client"
        end
        managers.hud:add_updator("BAI_UpdateAAI", callback(self, self, "UpdateAdvancedAssaultInfo" .. extension))
    else
        --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadeout", nil, 0.3, 1, 1) -- Disabled due to bug
        managers.hud:remove_updator("BAI_UpdateAAI")
        local_t = 0
    end
end

function HUDAssaultCorner:SetBreakHook(hook, delay)
    if hook then
        if not BAI:IsAAIEnabledAndOption("show_break_time_left") then
            return
        end
        local extension = ""
        if BAI.IsClient then
            BAI:SetBreakTimer()
            extension = extension .. "Client"
        end
        BAI:Animate(NobleHUD._score_panel:child("break"), 1, "FadeIn")
        managers.hud:add_updator("BAI_UpdateBreakTimeInfo", callback(self, self, "UpdateBreakTimeInfo" .. extension))
    else
        managers.hud:remove_updator("BAI_UpdateBreakTimeInfo")
        local_t_break = 0
        BAI:Animate(NobleHUD._score_panel:child("break"), 0, "FadeOut")
    end
end

local t_max = BAI:GetAAIOption("aai_panel_update_rate")
function HUDAssaultCorner:UpdateAdvancedAssaultInfo(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self:UpdateAAIText(managers.localization:CalculateTimeLeft(), math.round(math.max(managers.localization:CalculateSpawnsLeft(), 0)))
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoBSN(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self:UpdateAAIText(managers.localization:CalculateTimeLeft(), managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self:UpdateAAIText(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()), managers.hud:GetSpawnsLeft())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoBSNClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self:UpdateAAIText(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()), managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateBreakTimeInfo(t, dt)
    local_t_break = local_t_break + dt
    if local_t_break > t_max then
        NobleHUD._score_panel:child("break"):set_text(managers.localization:text("hud_break_time_left_short") .. managers.localization:FormatBreakTimeLeft(managers.localization:CalculateTimeLeftNoFormat(0)))
        local_t_break = 0
    end
end

function HUDAssaultCorner:UpdateBreakTimeInfoClient(t, dt)
    local_t_break = local_t_break + dt
    if local_t_break > t_max then
        NobleHUD._score_panel:child("break"):set_text(managers.localization:text("hud_break_time_left_short") .. managers.localization:FormatBreakTimeLeft(managers.hud:GetBreakTimeLeft()))
        local_t_break = 0
    end
end

function HUDAssaultCorner:UpdateAAIText(time, spawns)
    local text
    if self.show_spawns_left then
        text = spawns
    end
    if self.show_time_left then
        if text then
            text = text .. " | " .. time
        else
            text = time
        end
    end
    NobleHUD._score_panel:child("aai"):set_text(text or "")
end

function HUDAssaultCorner:SetVariables()
    self.show_spawns_left = BAI:GetAAIOption("show_spawns_left")
    self.show_time_left = BAI:GetAAIOption("show_time_left")
end

function HUDAssaultCorner:SetCaptainHook(active)
    if not BAI:IsAAIEnabledAndOption("captain_panel") then
        return
    end
    BAI:Animate(NobleHUD._score_panel:child("captain_icon"), active and 1 or 0, active and "FadeIn" or "FadeOut")
    BAI:Animate(NobleHUD._score_panel:child("captain_buff"), active and 1 or 0, active and "FadeIn" or "FadeOut")
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not (self.AAIPanelUpdate and BAI:IsAAIEnabledAndOption("captain_panel")) then
        return
    end
    NobleHUD._score_panel:child("captain_buff"):set_text((BAI:RoundNumber(buff, 0.01) * 100) .. "%")
end