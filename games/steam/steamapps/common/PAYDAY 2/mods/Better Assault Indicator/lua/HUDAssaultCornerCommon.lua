local BAI = BAI
function HUDAssaultCorner:ApplyHooks()
    if not self._applied then
        dofile(BAI.LuaPath .. "assault_states.lua")
        dofile(BAI.LuaPath .. "localizationmanager.lua")
        managers.localization:SetVariables(self.is_client)
        if self.is_host and self.assault_extender_modifier then
            managers.localization:CSAE_Activate()
        end
        BAI:ApplyModCompatibility(1)
        self._applied = true
    end
end

function HUDAssaultCorner:InitBAI()
    self.CompatibleHost = false
    self.BAIHost = false
    self.was_endless = false
    self.is_client = BAI.IsClient
    self.is_host = not self.is_client
    self.assault_type = nil
    self.trigger_assault_start_event = true
    self.is_skirmish = BAI._cache.is_skirmish
    self.is_crimespree = BAI._cache.is_crimespree
    if BAI._cache.MutatorAssaultExtender then
        self.assault_extender_modifier = true
    end
    if self.is_client then
        dofile(BAI.ClientPath .. "EnemyManager.lua")
        if self.is_crimespree then
            self.assault_extender_modifier = managers.crime_spree:DoesServerHasAssaultExtenderModifier()
        end
        if BAI._cache.MutatorEndlessAssaults then
            self:SetEndlessClient()
        end
    end
    dofile(BAI.LuaPath .. "GroupAIStateBesiege.lua")
    self.no_endless_assault_override = BAI:IsPlayingHeistWithFakeEndlessAssault()
    self:ApplyCompatibility()
    self:InitHUDList(BAI.settings.hudlist_compatibility)
    self:SetCompatibilityFlags(BAI._cache.detected_hud)
    self:ApplyHooks()
    if BAI:IsHostagePanelHidden() then
        self:DisableHostagePanelFunctions()
    end
    BAI:LoadCustomText()
    self:UpdateColors()
    self:InitAAIPanel()
    self:InitCaptainPanel()
    self:InitWaveCounter()
    self:UpdateAssaultPanelPosition()
    BAI:CallEvent(BAI.EventList.HUDAssaultCornerInit, self)
end

function HUDAssaultCorner:ApplyCompatibility()
end

function HUDAssaultCorner:SetCompatibilityFlags(hud_number)
    self.compatibility_flags = { AnimateNew = self.Vanilla }
    self.assault_panel_position_disabled = true
    --[[
        Not needed for these huds:
        6 - SydneyHUD => Vanilla
        9 - MUI
        10 - KineticHUD => Vanilla
        11 - Halo: Reach HUD
        12 - Hotline Miami HUD => Vanilla
        13 - VanillaHUD Plus => Vanilla
        14 - WolfHUD => Vanilla
        15 - CS:GO HUD => Vanilla
    ]]
    if (self.Vanilla or hud_number == 2) or BAI:IsOr(hud_number, 3, 4, 5, 7, 8, 16) then -- 3 = Void UI; 4 = Sora's HUD Reborn; 5 = HoloUI; 7 = PD:TH HUD Reborn; 8 = Restoration Mod; 16 = Warframe HUD
        self.AAIPanel = not self._v2_corner
        if hud_number == 3 then -- Void UI
            BAI.Config.CheckCompletelyHostageVisibility = false
            self.compatibility_flags.AnimateNew = true
            if VoidUI_IB then -- Void UI Infoboxes
                self.compatibility_flags.HostagePanelHidder = true
                self.AAIPanel = false
                BAI.IsHostagePanelVisible = function(s, type)
                    return true
                end
            elseif BAI:GetOption("completely_hide_hostage_panel") then
                self:DisableHostagePanelFunctions()
                -- Adjust icons position
                for i, icon in ipairs(self._icons) do
                    self._icons[i].position = icon.position - 1
                end
            end
        elseif hud_number == 4 then -- Sora's HUD Reborn
            self.compatibility_flags.AnimateNew = true
        elseif hud_number == 5 then -- HoloUI
            self.AAIPanel = false
        elseif hud_number == 7 then -- PD:TH HUD Reborn
            self.compatibility_flags.AnimateNew = true
            self.AAIPanel = false
            self.AAIPanelOverride = true
        elseif hud_number == 16 then -- Warframe HUD
            self:DisableHostagePanelFunctions()
            self.AAIPanel = false
        else
            self.AnimateHostagesPanel = true
            if not self._hostages_disabled then
                self._hud_panel:child("hostages_panel"):set_visible(true)
                self._hud_panel:child("hostages_panel"):set_alpha(1)
            end
            self.AAIFunction = "AAIPanel"
            self.AAIFunctionArgs1 = { "_time_bg_box" }
            self.AAIFunctionArgs2 = { "_spawns_bg_box" }
            self.AAIFunctionArgs3 = { "_break_time_bg_box" }
            if hud_number == 2 then
                self.assault_panel_position_disabled = false
            end
            if hud_number == 5 then -- 5 = HoloUI
                self.compatibility_flags.AnimateNew = true
            end
            if hud_number == 8 then -- 8 = Restoration Mod
                self.compatibility_flags.AnimateNew = true
            end
        end
    end
    -- Wave Counter
    if BAI:IsOr(hud_number, 3, 8, 12, 15) then -- VoidUI, Restoration HUD, Hotline Miami HUD or CS:GO HUD
        local o = BAI:GetOption("wave_counter")
        self:ForceWaveCounterFunction(o == 2 and 3 or o)
    elseif BAI:IsOr(hud_number, 4, 5, 6, 7, 11, 13, 14, 16) then -- Sora's HUD Reborn, HoloUI, SydneyHUD, PD:TH HUD Reborn, Halo: Reach HUD, WolfHUD, VanillaHUD+ or Warframe HUD
        self:ForceWaveCounterFunction(0)
    else -- Other HUDs
        self:ForceWaveCounterFunction(BAI:GetOption("wave_counter"))
    end
    --[[
        Not possible for:
        4 - Sora's HUD Reborn
    ]]
    if (self.Vanilla or BAI:IsOr(hud_number, 3, 5, 8, 11)) and not self.compatibility_flags.HostagePanelHidder then
        BAI:AddEvent(BAI.EventList.AssaultStart, function()
            if BAI:IsHostagePanelHidden("assault") then
                managers.hud._hud_assault_corner:_hide_hostages()
            end
        end, 0.5)
        BAI:AddEvent(BAI.EventList.AssaultEnd, function()
            if BAI:IsHostagePanelVisible() then
                managers.hud._hud_assault_corner:_show_hostages()
            end
        end)
        BAI:AddEvent(BAI.EventList.EndlessAssaultStart, function()
            if BAI:IsHostagePanelHidden("endless") then
                managers.hud._hud_assault_corner:_hide_hostages()
            end
        end, 0.5)
        local function Active(active)
            self:set_hostage_visibility(BAI:IsHostagePanelVisible(active and "captain" or "assault"))
        end
        BAI:AddEvents({BAI.EventList.NormalAssaultOverride, BAI.EventList.Captain}, Active)
    end
end

function HUDAssaultCorner:UpdateColors()
    self._assault_color = self.is_skirmish and BAI:GetColor("holdout") or BAI:GetRightColor("assault")
    self._vip_assault_color = BAI:GetRightColor("captain")
    self._assault_endless_color = BAI:GetRightColor("endless")
    self._assault_survived_color = BAI:GetColor("survived")
    self:UpdatePONRBox()
end

function HUDAssaultCorner:UpdatePONRBox()
end

function HUDAssaultCorner:ForceWaveCounterFunction(n)
    self._wave_counter = n or 0
end

function HUDAssaultCorner:InitAAIPanel()
end

function HUDAssaultCorner:InitCaptainPanel()
end

function HUDAssaultCorner:InitWaveCounter()
end

function HUDAssaultCorner:WaveCounterEnabled()
    return true
end

function HUDAssaultCorner:HideWaveCounter()
    local wave_panel = self._hud_panel:child("wave_panel")
    if alive(wave_panel) then  -- In the assault text, if selected
        wave_panel:set_alpha(0)
    end
end

function HUDAssaultCorner:CreateWaveCounterText()
    local assault_panel = self._hud_panel:child("assault_panel")
    local panel = self._full_hud_panel
    if alive(assault_panel) and alive(panel) then
        self._wave_text = panel:text({
            name = "num_waves",
            text = self:get_completed_waves_string(),
            valign = "center",
            vertical = "center",
            align = "center",
            halign = "right",
            w = self._bg_box and self._bg_box:w() or 242,
            h = tweak_data.hud.active_objective_title_font_size,
            layer = 1,
            x = 0,
            y = 0,
            color = Color.white,
            alpha = 0.8,
            font = "fonts/font_medium_shadow_mf",
            font_size = tweak_data.hud.active_objective_title_font_size * 0.9,
        })
        local x_offset, _ = managers.gui_data:safe_to_full(0, 0)
        self._wave_text:set_right(panel:w() - x_offset - assault_panel:child("icon_assaultbox"):w() - 3)
    end
    local function UpdateWaveNumber(...)
        self._wave_text:set_text(self:get_completed_waves_string())
        self._wave_text:stop()
        self._wave_text:animate(function(o)
            local t = 2
            o:set_alpha(0.8)
            while t > 0 do
                local dt = coroutine.yield()
                t = t - dt
                o:set_alpha(0.5 + 0.5 * (0.5 * math_sin(t * 360 * 2) + 0.5))
            end
            o:set_alpha(0.8)
        end)
    end
    BAI:Hook(self, "set_assault_wave_number", UpdateWaveNumber)
end

function HUDAssaultCorner:UpdateAssaultPanelPosition()
end

function HUDAssaultCorner:OpenAssaultPanelWithAssaultState(assault_state)
end

function HUDAssaultCorner:SetTextListAndAnimateColor(state, is_control_or_anticipation)
end

function HUDAssaultCorner:SetImage(image)
end

function HUDAssaultCorner:InitHUDList(compatibility, auto_detection)
end

function HUDAssaultCorner:MoveHUDList(offset)
end

function HUDAssaultCorner:GetFactionAssaultText(ws)
    if BAI:ShowFSSAI() then
        return "_fss_mod_" .. math.random(3)
    end
    if not BAI:GetOption("faction_assault_text") or ws or self.is_crimespree then
        return ""
    end
    local difficulty, faction = BAI._cache.Difficulty, BAI._cache.Faction
    if faction == "russia" then -- Every mission with Akan (Russian) enemies
        return "_russia"
    elseif BAI._cache.level_id == "haunted" or faction == "zombie" then -- Safehouse Nightmare and every mission with zombie enemies
        return "_zombie"
    elseif faction == "murkywater" then -- Every mission with murkywater enemies
        return "_murkywater"
    elseif faction == "federales" then -- Every mission with federales (Spanish FBI) enemies
        return "_federales"
    elseif BAI:IsOr(difficulty, "normal", "hard") then -- Normal, Hard
        return ""
    elseif BAI:IsOr(difficulty, "overkill", "overkill_145") then -- Very Hard, OVERKILL
        return "_fbi"
    elseif BAI:IsOr(difficulty, "easy_wish", "overkill_290") then -- Mayhem, Death Wish
        return "_gensec"
    else --sm_wish; Death Sentence
        return "_zeal"
    end
end

function HUDAssaultCorner:_popup_wave_started()
    self:_popup_wave(self:wave_popup_string_start(), tweak_data.screen_colors.skirmish_color) -- Orange
end

function HUDAssaultCorner:_popup_wave_finished()
    self:_popup_wave(self:wave_popup_string_end(), Color(1, 0.12549019607843137, 0.9019607843137255, 0.12549019607843137)) -- Green
end

function HUDAssaultCorner:SetEndlessClient()
    self.endless_client = true
end

function HUDAssaultCorner:GetRisk()
    local difficulty
    if self.is_crimespree or not BAI:GetOption("show_difficulty_name_instead_of_skulls") then
        difficulty = Idstring("risk")
    else
        difficulty = self:GetDifficultyName()
    end
    return difficulty
end

function HUDAssaultCorner:GetDifficultyName()
    if tweak_data ~= nil then
        return tweak_data.difficulty_name_id
    else
        return Idstring("risk") -- Better safe than sorry
    end
end

function HUDAssaultCorner:GetEndlessAssault()
    if not self.no_endless_assault_override then
        if self.is_host and managers.groupai:state():get_hunt_mode() then
            return true
        end -- Returns nil on host
        return self.endless_client
    end
    return false
end

function HUDAssaultCorner:SetCompatibleHost(BAIHost)
    self.CompatibleHost = true
    self.BAIHost = BAIHost
end

function HUDAssaultCorner:set_hostage_visibility(visibility, no_animation)
    if visibility then
        self:_show_hostages(no_animation)
    else
        self:_hide_hostages(no_animation)
    end
end

function HUDAssaultCorner:DisableHostagePanelFunctions()
    self._hud_panel:child("hostages_panel"):set_visible(false)
    self._hud_panel:child("hostages_panel"):set_alpha(0)
    self._show_hostages = function() end
    self._hide_hostages = function() end
    self._hostages_disabled = true
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override) -- Overriden when needed in HUD
end

function HUDAssaultCorner:LoadWolfHUDOptions(update)
    if not self.wolfhud then
        self.wolfhud = { bai = {} }
    end
    self.wolfhud.position = WolfHUD:getSetting({"AssaultBanner", "POSITION"}, 3)
    self.wolfhud.hudlist_show_hostages = WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_hostages"}, true)
    if not update then
        self.wolfhud.hudlist_enabled = WolfHUD:getSetting({"HUDList", "ENABLED"}, true)
    end
    self.wolfhud.bai.aai_visible = BAI:GetOption("show_advanced_assault_info")
    self.wolfhud.bai.aai_panel = BAI:GetAAIOption("aai_panel")
    self.wolfhud.bai.captain_panel = BAI:GetAAIOption("captain_panel")
end

function HUDAssaultCorner:LoadVanillaHUDPlusOptions(update)
    if not self.vhudplus then
        self.vhudplus = { bai = {} }
    end
    self.vhudplus.center = VHUDPlus:getSetting({"AssaultBanner", "USE_CENTER_ASSAULT"}, true)
    self.vhudplus.hostages_hidden = not VHUDPlus:getSetting({"HUDList", "ORIGNIAL_HOSTAGE_BOX"}, false)
    if not update then
        self.vhudplus.hudlist_enabled = VHUDPlus:getSetting({"HUDList", "ENABLED"}, true)
    end
    if BAI:GetOption("show_advanced_assault_info") then
        self.vhudplus.bai.aai_panel = BAI:GetAAIOption("aai_panel")
    else
        self.vhudplus.bai.aai_panel = 0
    end
    self.vhudplus.bai.aai_visible = BAI:GetOption("show_advanced_assault_info")
    self.vhudplus.bai.captain_panel = BAI:GetAAIOption("captain_panel")
end

function HUDAssaultCorner:LoadVanillaHUDListOptions(update)
    self.hudlist.hostages_hidden = true
    if not update then
        self.hudlist.hudlist_enabled = true
    end
    if BAI._cache.detected_hud ~= 2 then
        self.hudlist.bai.assault_panel_position = 3
    else
        self.hudlist.bai.assault_panel_position = BAI:GetOption("assault_panel_position")
    end
    self.hudlist.bai.aai_visible = BAI:GetOption("show_advanced_assault_info")
    self.hudlist.bai.aai_panel = BAI:GetAAIOption("aai_panel")
    self.hudlist.bai.captain_panel = BAI:GetAAIOption("captain_panel")
end