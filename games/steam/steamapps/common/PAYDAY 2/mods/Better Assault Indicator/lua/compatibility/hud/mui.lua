local BAI = BAI
local MUIStats = MUIStats
local fade, fade_c = ArmStatic.fade_animate, ArmStatic.fade_c_animate
local time_panel, spawns_panel, break_time_panel, captain_panel -- Due to unknown issue, I can't use self in MUIStats
local time_left, spawns_left, break_left, captain_buff -- Same as comment above

local function SetFontSize(o, f)
    o:set_font_size(f)

	local _, _, w_rect, h_rect = o:text_rect()
	o:set_size(w_rect, h_rect)
end

local function AlignRight(img, text)
    text:set_center(img:center())
    text:set_left(img:right())
end

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

function MUIStats:InitBAI()
    self:InitPanels()
    self.is_host = BAI.IsHost
    self.is_client = not self.is_host
    managers.hud.endless_client = false
    managers.hud.no_endless_assault_override = BAI:IsPlayingHeistWithFakeEndlessAssault()
    self.is_skirmish = BAI._cache.is_skirmish
    self.is_crimespree = BAI._cache.is_crimespree
    dofile(BAI.LuaPath .. "localizationmanager.lua")
    dofile(BAI.LuaPath .. "assault_states.lua")
    dofile(BAI.LuaPath .. "GroupAIStateBesiege.lua")
    if self.is_client then
        dofile(BAI.ClientPath .. "EnemyManager.lua")
        if BAI._cache.MutatorEndlessAssaults then
            managers.hud:SetEndlessClient()
        end
        if self.is_crimespree then
            dofile(BAI.ClientPath .. "CrimeSpreeManager.lua")
        end
    end
    self.trigger_assault_start_event = true
    BAI:LoadCustomText()
    BAI:SetCustomText("hud_overdue", "N/A")
    if BAI:IsHostagePanelHidden() then
        self._supplement_list:child("hostages_panel"):set_visible(false)
        self._show_hostages = function() end
        self._hide_hostages = function() end
    end
    BAI:ApplyModCompatibility(1)
    BAI:CallEvent(BAI.EventList.HUDAssaultCornerInit, self)
end

local _f_resize = MUIStats.resize
function MUIStats:resize()
    _f_resize(self)
    self:ResizeBAIPanels()
end

function MUIStats:InitPanels()
    local size = self._muiSize
    local s33 = size / 3
    local muiFont = ArmStatic.font_index(self._muiFont)
    local mui_panel = self._hud_panel:child("stats_panel")
    local tweak_data = tweak_data.bai
    time_panel = mui_panel:panel({
        layer = 1,
        name = "time_left_panel",
        visible = true,
        alpha = 0
    })
    time_panel:bitmap({
        name = "icon",
        texture = tweak_data.time_left.texture,
        texture_rect = tweak_data.time_left.texture_rect,
        w = s33,
        h = s33
    })
    time_panel:text({
        name = "text",
        font = muiFont,
        text = managers.localization:text("hud_time_left"),
        align = "right"
    })
    time_left = time_panel:text({
        name = "amount",
        font = muiFont,
        text = GetTimeInFormat(),
        align = "right"
    })
    break_time_panel = mui_panel:panel({
        layer = 1,
        name = "break_time_left_panel",
        visible = true,
        alpha = 0
    })
    break_time_panel:text({
        name = "text",
        font = muiFont,
        text = managers.localization:text("hud_break_time_left"),
        align = "right"
    })
    break_time_panel:bitmap({
        name = "icon",
        texture = tweak_data.spawns_left.texture,
        w = s33,
        h = s33
    })
    break_left = break_time_panel:text({
        name = "amount",
        font = muiFont,
        text = GetTimeInFormat(),
        align = "right"
    })

    spawns_panel = mui_panel:panel({
        layer = 1,
        name = "spawns_left_panel",
        visible = true,
        alpha = 0
    })
    spawns_panel:bitmap({
        name = "icon",
        texture = tweak_data.spawns_left.texture,
        w = s33,
        h = s33
    })
    spawns_panel:text({
        name = "text",
        font = muiFont,
        text = managers.localization:text("hud_spawns_left" .. (BAI:GetAAIOption("spawn_numbers") == 2 and "_short" or "")),
        align = "right"
    })
    spawns_left = spawns_panel:text({
        name = "amount",
        font = muiFont,
        text = "0420",
        align = "right"
    })

    captain_panel = mui_panel:panel({
        layer = 1,
        name = "captain_panel",
        visible = true,
        alpha = 0
    })
    captain_panel:bitmap({
        name = "icon",
        texture = tweak_data.captain.texture,
        w = s33,
        h = s33
    })
    captain_buff = captain_panel:text({
        name = "amount",
        font = muiFont,
        text = "00%",
        align = "right"
    })

    self:ResizeBAIPanels()

    captain_buff:set_text("0%")

    BAI:AddEvent(BAI.EventList.Captain, function(active)
        MUIStats:SetCaptainHook(active)
    end)
end

function MUIStats:ResizeBAIPanels()
    local panel = self._hud_panel:child("stats_panel")
    local time = time_panel
    local brk = break_time_panel
    local spawns = spawns_panel
    local captain = captain_panel
    local size = self._muiSize
    local s33 = size / 3
    local s332 = s33 * 2
    local wMul = self._muiWMul
    local width = size * wMul

    Figure(time):shape(width, s332)
    Figure(brk):shape(width, s332)
    Figure(spawns):shape(width, s332)
    Figure(captain):shape(width, s332)

    local time_i = time:child("icon") -- Time Left Icon
    local time_t = time:child("text") -- "Time Left:" Text
    local break_i = brk:child("icon") -- Break Time Left Icon
    local break_t = brk:child("text") -- "Break Time Left: " Text
    local captain_i = captain:child("icon") -- Captain Icon
    local captain_t = captain:child("amount") -- Captain Text
    local spawns_i = spawns:child("icon") -- Spawns Left Icon
    local spawns_t = spawns:child("text") -- "Spawns Left:" Text
    local loot_panel = panel:child("loot_panel")

    SetFontSize(time_left, s33)
    SetFontSize(time_t, s33)
    AlignRight(time_i, time_t)
    AlignRight(time_t, time_left)

    SetFontSize(break_left, s33)
    SetFontSize(break_t, s33)
    AlignRight(break_i, break_t)
    AlignRight(break_t, break_left)

    SetFontSize(spawns_left, s33)
    SetFontSize(spawns_t, s33)
    AlignRight(spawns_i, spawns_t)
    AlignRight(spawns_t, spawns_left)

    SetFontSize(captain_buff, s33)
    SetFontSize(captain_t, s33)
    AlignRight(captain_i, captain_t)
    AlignRight(captain_i, captain_buff)

    time:set_y(loot_panel:bottom())
    brk:set_y(time:y())
    spawns:set_y(time:y() + time:child("amount"):h())
    captain:set_y(time:y())
    panel:set_h(spawns:bottom())
end

function MUIStats:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_vip = mode == "phalanx"
    self._assault_mode = mode
    self:UpdateColor(BAI:GetRightColor(mode == "phalanx" and "captain" or "assault"))
    self:set_hostage_visibility(BAI:IsHostagePanelVisible(mode == "phalanx" and "captain" or "assault"))
    if mode == "phalanx" then
        self._assault_endless = false
        self:UpdateAssaultText("hud_captain", "captain")
    else
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultState("fade")
        else
            self:UpdateAssaultText(self:GetAssaultText(), "assault")
        end
    end
end

local _MUI_set_wave = MUIStats.set_wave
function MUIStats:set_wave(wave)
    _MUI_set_wave(self, wave)
    self._wave_number = wave or 0
end

function MUIStats:set_no_return(state)
    if self._no_return == state then
        return
    end
    self._no_return = state
    fade_c(self._heist_time, state and BAI:GetColor("escape") or Color.white, 1)
    self:SetAssaultText("hud_no_return")
    self:UpdateColor(BAI:GetColor("escape"))
    self:_hide_hostages()
end

local _MUI_sync_start_assault = MUIStats.sync_start_assault
function MUIStats:sync_start_assault(wave)
    if self._no_return then
        return
    end
    _MUI_sync_start_assault(self, wave)
    self._assault = true
    if self:GetEndlessAssault() then
        if self._assault_vip then
            return
        end
        if not self._assault_endless then
            self.trigger_assault_start_event = false
            BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
        end
        self._assault_endless = true
        self:UpdateColor(BAI:GetRightColor("endless"))
        self:UpdateAssaultText("hud_endless", "endless")
    else
        if self.trigger_assault_start_event then
            self.trigger_assault_start_event = false
            BAI:CallEvent(BAI.EventList.AssaultStart)
        end
        if not BAI:GetOption("show_difficulty_name_instead_of_skulls") then
            self:UpdateAssaultText("hud_assault", "assault")
        end
        local state_enabled = BAI:GetOption("show_assault_states") and BAI:IsStateEnabled("build") or false
        self:UpdateAssaultText(state_enabled and "hud_build" or "hud_assault", state_enabled and "build" or "assault")
        self:UpdateColor(BAI:GetRightColor(state_enabled and "build" or (self.is_skirmish and "holdout" or "assault")))
        if BAI:ShowAdvancedAssaultInfo() and self.is_client then
            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
        end
    end
    if BAI:IsHostagePanelHidden(self._assault_endless and "endless" or "assault") then
        self:_hide_hostages()
    end
end

function MUIStats:GetEndlessAssault()
    if not managers.hud.no_endless_assault_override then
        if self.is_host and managers.groupai:state():get_hunt_mode() then
            return true
        end -- Returns false
        return managers.hud.endless_client
    end
    return false
end

function MUIStats:StartEndlessAssault()
    self:sync_start_assault(self._wave_number)
end

function MUIStats:start_assault()
    local panel = self._assault_panel
    panel:stop()
    panel:animate(callback(panel, self, "assault_pulse"))
end

function MUIStats:sync_end_assault()
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    local panel = self._assault_panel
    local panel2 = self._wave_panel
    self._assault = false
    self._assault_endless = false
    if BAI:GetOption("show_wave_survived") then
        self:UpdateColor(BAI:GetColor("survived"))
        self:UpdateAssaultText("hud_survived", "survived")
        panel2:animate(callback(panel, self, "WaveSurvived", self))
    else
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultStateOverride("control", true)
        else
            self:_close_assault_box()
        end
    end
    if BAI:IsHostagePanelVisible() then
        self:_show_hostages()
    end
    if not managers.hud.dont_override_endless then
        managers.hud.endless_client = false
    end
    self.trigger_assault_start_event = true
end

function MUIStats.WaveSurvived(o, hud)
    wait(8.6)
    if BAI:GetOption("show_assault_states") then
        BAI:UpdateAssaultStateOverride("control", true)
    else
        hud:_close_assault_box(o)
    end
end

function MUIStats:set_hostage_visibility(visibility)
    if visibility then
        self:_show_hostages()
    else
        self:_hide_hostages()
    end
end

function MUIStats:_hide_hostages()
    BAI:Animate(self._supplement_list:child("hostages_panel"), 0, "FadeOut")
end

function MUIStats:_show_hostages()
    BAI:Animate(self._supplement_list:child("hostages_panel"), 1, "FadeIn")
end

function MUIStats:UpdateColor(color)
    color = color or Color.white
    local panel = self._assault_panel
    fade_c(panel:child("risk"), color, 1)
    fade_c(panel:child("title"), color, 1)
    fade_c(panel:child("icon"), color, 1)
end

function MUIStats:_close_assault_box(p)
    local panel = p or self._assault_panel
    panel:stop()
    panel:animate(callback(panel, self, "assault_end"))
end

function MUIStats:UpdateAssaultText(text, text_id)
    if BAI:ShowFSSAI() and BAI:IsCustomTextDisabled(text_id) then
        text = "hud_fss_mod_" .. math.random(3)
    end
    self:SetAssaultText(text)
end

function MUIStats:SetAssaultText(text)
    self._assault_panel:child("title"):set_text(utf8.to_upper(managers.localization:text(text)))
    self:MakeFineText(self._assault_panel:child("title"))
end

function MUIStats:MakeFineText(text)
    local x, y, w, h = text:text_rect()

    text:set_size(w, h)
    text:set_position(math.round(text:x()), math.round(text:y()))
end

function MUIStats:OpenAssaultPanelWithAssaultState(assault_state)
    self:start_assault()
    self:UpdateAssaultText("hud_" .. assault_state, assault_state)
    self:UpdateColor(BAI:GetColor(assault_state))
    BAI:CallEvent("MoveHUDList", self)
end

function MUIStats:SetTextListAndAnimateColor(assault_state, is_control_or_anticipation)
    if assault_state then
        self:UpdateAssaultText("hud_" .. assault_state, assault_state)
        self:UpdateColor(BAI:GetColor(assault_state))
    else
        self:UpdateAssaultText(self:GetAssaultText(), "assault")
        self:UpdateColor(BAI:GetColor("assault"))
    end
end

function MUIStats:UpdateAssaultStateOverride_Override(state, override)
    self:UpdateAssaultText("hud_" .. state, state)
    self:UpdateColor(BAI:GetColor(state))
end

function MUIStats:GetAssaultText()
    return BAI:GetOption("show_difficulty_name_instead_of_skulls") and tweak_data.difficulty_name_id or "hud_assault"
end

local local_t = 0
local local_t_break = 0
local t_max = BAI:GetAAIOption("aai_panel_update_rate")
function MUIStats:SetHook(hook, delay)
    if hook then
        local function f()
            if not BAI:ShowAdvancedAssaultInfo() then
                return
            end
            local extension = ""
            if BAI:GetAAIOption("spawn_numbers") == 2 then
                extension = "BSN" -- Better Spawn Numbers
            end
            if self.is_client then
                extension = extension .. "Client"
            end
            managers.hud:add_updator("BAI_UpdateAAI", callback(self, self, "UpdateAdvancedAssaultInfo" .. extension))
            if BAI:GetAAIOption("show_time_left") then
                BAI:Animate(time_panel, 1, "FadeIn", self._muiAlpha)
            end
            if BAI:GetAAIOption("show_spawns_left") then
                BAI:Animate(spawns_panel, 1, "FadeIn", self._muiAlpha)
            end
        end
        BAI:DelayCall("ShowAAIPanel", delay or 1, f)
    else
        BAI:RemoveDelayedCall("ShowAAIPanel")
        managers.hud:remove_updator("BAI_UpdateAAI")
        local_t = 0
        BAI:Animate(time_panel, 0, "FadeOut")
        BAI:Animate(spawns_panel, 0, "FadeOut")
    end
end

function MUIStats:SetBreakHook(hook, delay)
    if hook then
        local function f()
            if not BAI:IsAAIEnabledAndOption("show_break_time_left") then
                return
            end
            local extension = ""
            if BAI.IsClient then
                BAI:SetBreakTimer()
                extension = extension .. "Client"
            end
            managers.hud:add_updator("BAI_UpdateBreakTimeInfo", callback(self, self, "UpdateBreakTimeInfo" .. extension))
            BAI:Animate(break_time_panel, 1, "FadeIn", self._muiAlpha)
        end
        BAI:DelayCall("ShowBreakPanel", delay or 1, f)
    else
        BAI:RemoveDelayedCall("ShowBreakPanel")
        managers.hud:remove_updator("BAI_UpdateBreakTimeInfo")
        local_t_break = 0
        BAI:Animate(break_time_panel, 0, "FadeOut")
    end
end

function MUIStats:UpdateAdvancedAssaultInfo(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        time_left:set_text(managers.localization:CalculateTimeLeft())
        spawns_left:set_text(math.round(math.max(managers.localization:CalculateSpawnsLeft(), 0)))
        local_t = 0
    end
end

function MUIStats:UpdateAdvancedAssaultInfoBSN(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        time_left:set_text(managers.localization:CalculateTimeLeft())
        spawns_left:set_text(managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function MUIStats:UpdateAdvancedAssaultInfoClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        time_left:set_text(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()))
        spawns_left:set_text(managers.hud:GetSpawnsLeft())
        local_t = 0
    end
end

function MUIStats:UpdateAdvancedAssaultInfoBSNClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        time_left:set_text(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()))
        spawns_left:set_text(managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function MUIStats:UpdateBreakTimeInfo(t, dt)
    local_t_break = local_t_break + dt
    if local_t_break > t_max then
        break_left:set_text(managers.localization:FormatBreakTimeLeft(managers.localization:CalculateTimeLeftNoFormat(0)))
        local_t_break = 0
    end
end

function MUIStats:UpdateBreakTimeInfoClient(t, dt)
    local_t_break = local_t_break + dt
    if local_t_break > t_max then
        break_left:set_text(managers.localization:FormatBreakTimeLeft(managers.hud:GetBreakTimeLeft()))
        local_t_break = 0
    end
end

function MUIStats:SetCaptainHook(active)
    if not BAI:IsAAIEnabledAndOption("captain_panel") then
        return
    end
    BAI:Animate(captain_panel, active and self._muiAlpha or 0, active and "FadeIn" or "FadeOut")
end

function MUIStats:SetCaptainBuff(buff)
    if not BAI:IsAAIEnabledAndOption("captain_panel") then
        return
    end
    captain_buff:set_text((BAI:RoundNumber(buff, 0.01) * 100) .. "%")
end

function MUIStats:SetImage(image)
end

function MUIStats:SetCompatibleHost(BAIHost)
end

function MUIStats:UpdateColors()
end

-- //
-- // Re-routes
-- //
function HUDManager:SetEndlessClient()
    self.endless_client = true
end