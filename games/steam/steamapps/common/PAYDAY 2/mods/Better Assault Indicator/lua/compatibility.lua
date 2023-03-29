local BAI = BAI
local HUDs =
{
    [2] = "Vanilla",
    [3] = "VoidUI",
    [4] = "Sora's HUD Reborn",
    [5] = "HoloUI",
    [6] = "SydneyHUD",
    [7] = "PD:TH HUD Reborn",
    [8] = "Restoration Mod",
    [9] = "MUI",
    [10] = "KineticHUD",
    [11] = "Halo: Reach HUD",
    [12] = "Hotline Miami HUD",
    [13] = "VanillaHUD Plus",
    [14] = "WolfHUD",
    [15] = "CS:GO HUD",
    [16] = "Warframe HUD"
}

local Mods =
{
    [2] = "Vanilla",
    [3] = "PAYDAY 2 Hyper Heisting",
    [4] = "Crackdown"
}

local function ApplyHook(params)
    params = params or {}
    if not params.no_hook then
        dofile(BAI.LuaPath .. "hudassaultcorner.lua")
    end
    if params.hud_filename ~= "hudassaultcorner" then
        BAI:LoadHUDCompatibilityFile(params.hud_filename)
    end
    if params.vr then
        dofile(BAI.LuaPath .. "HUDAssaultCornerVR.lua")
    end
end

local function AddHookEvents(as, eas, ae, c, nr, nao)
    local hud = managers.hud._hud_assault_corner
    local function TrueHook()
        hud:SetHook(true)
        hud:SetBreakHook(false)
    end
    local function FalseHook()
        hud:SetHook(false)
        hud:SetBreakHook(false)
    end
    local function FalseHookNAI()
        hud:SetHook(false)
        hud:SetBreakHook(true)
    end
    local function ParameterHook(active)
        hud:SetHook(not active)
        hud:SetBreakHook(false)
    end
    BAI:AddEvent(BAI.EventList.AssaultStart, as or TrueHook)
    BAI:AddEvent(BAI.EventList.EndlessAssaultStart, eas or FalseHook)
    BAI:AddEvent(BAI.EventList.AssaultEnd, ae or FalseHookNAI)
    BAI:AddEvent(BAI.EventList.Captain, c or ParameterHook)
    BAI:AddEvent(BAI.EventList.NoReturn, nr or FalseHook) -- Some heists utilize PONR in such way that it can disabled
    -- Set hook to "FalseHook" to follow in-game implementation when that happens (HUD not updated when PONR disabled)
    BAI:AddEvent(BAI.EventList.NormalAssaultOverride, nao or TrueHook)
end

local function SetCommonHooks()
    local hud = managers.hud._hud_assault_corner
    local function AS(state)
        if not BAI:GetOption("show_assault_states") then
            return
        end
        local is_control_or_anticipation = BAI:IsOr(state, "control", "anticipation")
        if BAI:IsStateDisabled(state) then
            if is_control_or_anticipation then
                if hud._assault then
                    hud._assault = false
                    hud._start_assault_after_hostage_offset = nil
                    hud:_close_assault_box()
                end
            else
                if hud._assault then
                    hud:SetTextListAndAnimateColor(nil, nil)
                end
            end
            return
        end
        if state == "build" or hud._point_of_no_return or hud._no_return then -- no_return is for MUI
            return
        end
        local final = nil
        if is_control_or_anticipation then
            final = hud._assault and "change" or "open"
        else
            final = "change"
        end
        if final == "open" then
            hud:OpenAssaultPanelWithAssaultState(state)
        else
            hud:SetTextListAndAnimateColor(state, is_control_or_anticipation)
        end
    end
    BAI:AddEvent(BAI.EventList.AssaultStateChange, AS, nil, 99)
    local function ASO(state, override)
        if not BAI:GetOption("show_assault_states") then
            return
        end
        local is_control_or_anticipation = BAI:IsOr(state, "control", "anticipation")
        if BAI:IsStateDisabled(state) then
            if is_control_or_anticipation then
                hud:_close_assault_box()
                BAI:CallEvent("MoveHUDListBack", hud)
            else
                hud:SetTextListAndAnimateColor(nil, nil)
                if BAI:ShowAdvancedAssaultInfo() and hud.is_client then
                    LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                end
            end
            return
        end
        if is_control_or_anticipation then
            hud._assault = true
            hud:UpdateAssaultStateOverride_Override(state, override)
        else
            hud:SetTextListAndAnimateColor(state, nil)
        end
    end
    BAI:AddEvent(BAI.EventList.AssaultStateChangeOverride, ASO, nil, 99)
    local function NAO()
        hud:SetImage("assault")
        hud._assault_endless = false
        hud.was_endless = false
        if BAI:GetOption("show_assault_states") then
            if hud.is_host then
                BAI:UpdateAssaultStateOverride(managers.groupai:state():GetAssaultState())
            else
                hud:SetTextListAndAnimateColor(nil, nil)
                if hud.BAIHost then
                    LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                end
            end
        else
            hud:SetTextListAndAnimateColor(nil, nil)
            if BAI:ShowAdvancedAssaultInfo() and hud.is_client then
                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
            end
        end
    end
    BAI:AddEvent(BAI.EventList.NormalAssaultOverride, NAO)
    if BAI.IsHost then
        if BAI._cache.Multiplayer then -- Don't sync Assault States and Normal Assault Override in Single Player, pointless and wasting CPU cycles
            BAI:AddEvent(BAI.EventList.AssaultStateChange, function(state, stealth_broken, no_as_mod)
                BAI:SyncAssaultState(state, nil, stealth_broken, no_as_mod)
            end, nil, 100)
            BAI:AddEvent(BAI.EventList.AssaultStateChangeOverride, function(state, override)
                BAI:SyncAssaultState(state, true)
            end, nil, 100)
        end
        BAI:AddEvent(BAI.EventList.EndlessAssaultStart, function()
            BAI:SetAssaultStatesHook(false)
        end, nil, 100)
        BAI:AddEvent(BAI.EventList.NormalAssaultOverride, function()
            BAI:SetAssaultStatesHook(true)
        end, nil, 100)
        local function SetActive(active)
            BAI:SetAssaultStatesHook(not active)
        end
        BAI:AddEvents({BAI.EventList.NoReturn, BAI.EventList.Captain}, SetActive, nil, 100)
    else
        BAI:AddEvent(BAI.EventList.AssaultStart, function()
            if not BAI:GetOption("show_assault_states") then
                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
            end
        end, 40)
        BAI:AddEvents({BAI.EventList.EndlessAssaultStart, BAI.EventList.NoReturn, BAI.EventList.AssaultEnd}, function()
            BAI:RemoveASCalls()
        end, nil, 99)
        BAI:AddEvent(BAI.EventList.Captain, function(active)
            if active then
                BAI:RemoveASCalls()
            end
        end, nil, 99)
        BAI:AddEvents({BAI.EventList.AssaultStateChange, BAI.EventList.AssaultStateChangeOverride}, function(state, ...)
            if not BAI:IsOr(state, BAI.Enum.AssaultState.Control, BAI.Enum.AssaultState.Anticipation) then
                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
            end
        end)
        --[[local function SetTime()
            hud:SetTimer()
        end
        BAI:AddEvent(BAI.EventList.AssaultStart, SetTime, nil, 99)]]
    end
    if BAI.debug then
        BAI:AddEvent(BAI.EventList.AssaultStateChange, function(state, stealth_broken, no_as_mod)
            managers.hud:DebugState(state, nil, stealth_broken, no_as_mod)
        end)
        BAI:AddEvent(BAI.EventList.AssaultStateChangeOverride, function(state, override)
            managers.hud:DebugState(state, true)
        end)
    end
end

function BAI:AddHookEvents(as, eas, ae, c, nr, nao)
    AddHookEvents(as, eas, ae, c, nr, nao)
end

function BAI:ApplyHUDCompatibility(number, detection)
    if _G.IS_VR then
        SetCommonHooks()
        local filename = "hudassaultcorner"
        if CSGOHUD and CSGOHUD:GetComponentOption("assault_panel") then
            filename = "csgo_hud"
        end
        ApplyHook({ hud_filename = filename, vr = true })
        self._cache.detected_hud = 2
        managers.hud._hud_assault_corner.Vanilla = true
        self:Log("VR Mode detected. VR Mode compatibility applied.")
        return
    end
    if number == 1 then
        if BeardLib then -- Some HUDs require BeardLib, let's check them first
            if restoration and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") and managers.hud._hud_assault_corner._hud_panel:child("corner_panel") then
                self:ApplyHUDCompatibility(8, true)
                return
            elseif PDTHHud and PDTHHud.Options:GetValue("HUD/Assault") then
                self:ApplyHUDCompatibility(7, true)
                return
            elseif NepgearsyHUDReborn then -- Look's like he also forgot to update the code to reflect the mod name change
                self:ApplyHUDCompatibility(4, true)
                return
            elseif Holo and Holo.Options:GetValue("TopHUD") and Holo:ShouldModify("HUD", "Assault") then
                self:ApplyHUDCompatibility(VHUDPlus and 2 or 5, true) -- TODO: Check if VHUDPlus is also crashing other HUDs
                return
            elseif NobleHUD then
                self:ApplyHUDCompatibility(11, true)
                return
            end
        end
        if MUIStats then
            self:ApplyHUDCompatibility(9, true)
        elseif VoidUI and VoidUI.options.enable_assault then
            self:ApplyHUDCompatibility(3, true)
        elseif HMH and HMH:GetOption("assault") then
            self:ApplyHUDCompatibility(12, true)
        elseif CSGOHUD and CSGOHUD:GetComponentOption("assault_panel") then
            self:ApplyHUDCompatibility(15, true)
        elseif SydneyHUD then
            self:ApplyHUDCompatibility(6, true)
        elseif KineticHUD then
            self:ApplyHUDCompatibility(10, true)
        elseif VHUDPlus then
            self:ApplyHUDCompatibility(13, true)
        elseif WolfHUD then
            self:ApplyHUDCompatibility(14, true)
        elseif WFHud and HopLib then
            self:ApplyHUDCompatibility(16, true)
        else
            self:ApplyHUDCompatibility(2, true)
        end
        return
    end
    local params = { hud_filename = "hudassaultcorner" }
    params.vanilla = number == 2
    if number == 3 then
        params.hud_filename = "void_ui"
        if self:GetAAIOption("time_format") == 5 then
            self.settings.advanced_assault_info.time_format = 6
        end
    elseif number == 4 then
        params.hud_filename = "soras_hud_reborn"
        self:Unhook("", "upd_recon_tasks_PostHook")
    elseif number == 5 then
        params.hud_filename = "holoui"
        self:DelayCall("bai_holoui_compatibility", 2, function()
            BAI:Unhook("HoloUI", "start_assault")
            BAI:Unhook("HoloUI", "end_assault")
        end)
    elseif number == 6 then
        params.hud_filename = "sydneyhud"
        params.vanilla = true
    elseif number == 7 then
        params.hud_filename = "pdth_hud_reborn"
    elseif number == 8 then
        params.hud_filename = "restoration_mod"
    elseif number == 9 then
        params.hud_filename = "mui"
        params.no_hook = true
        AddHookEvents()
    elseif number == 10 then
        params.hud_filename = "kinetichud"
        params.vanilla = true
        self:Unhook("khud", "detect_assaultphase")
        self:Unhook("khud", "detect_regroupphase")
    elseif number == 11 then
        params.hud_filename = "halo_reach_hud"
        AddHookEvents()
    elseif number == 12 then
        params.hud_filename = "hotline_miami_hud"
        params.vanilla = true
        self.settings.advanced_assault_info.aai_panel = 2
    elseif number == 13 then
        params.hud_filename = "vanillahud_plus"
        params.vanilla = true
    elseif number == 14 then
        params.hud_filename = "wolfhud"
        params.vanilla = true
    elseif number == 15 then
        params.hud_filename = "csgo_hud"
        params.vanilla = true
    elseif number == 16 then
        params.hud_filename = "warframe_hud"
        params.vanilla = true
    end -- 2 = Vanilla HUD
    SetCommonHooks()
    ApplyHook(params)
    self:Log((detection and (number == 2 and ("No HUD detected. ") or (HUDs[number] .. " detected. ")) or "") .. HUDs[number] .. " compatibility applied.")
    self._cache.vanilla_style_hud = params.vanilla
    self._cache.detected_hud = number
    managers.hud._hud_assault_corner.Vanilla = params.vanilla
end

function BAI:ApplyModCompatibility(number, detection)
    if number == 1 then
        if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY == "HYPERHEISTSHIN" then
            self:ApplyModCompatibility(3, true)
        elseif deathvox then
            self:ApplyModCompatibility(4, true)
        else
            self:ApplyModCompatibility(2, true)
        end
        return
    end
    if number == 3 then
        self:LoadModCompatibilityFile("payday_2_hyper_heisting")
        self.EasterEgg.FSS.AIReactionTimeTooHigh = BAI:IsOr(Global.game_settings.difficulty, "overkill_290", "sm_wish")
    elseif number == 4 then
        self:LoadModCompatibilityFile("crackdown")
        self.EasterEgg.FSS.AIReactionTimeTooHigh = Global.game_settings.difficulty == "sm_wish"
    end -- 2 = Vanilla
    self:Log((detection and (number == 2 and ("No Mod detected. ") or (Mods[number] .. " mod detected. ")) or "") .. Mods[number] .. " mod compatibility applied.")
    self._cache.detected_mod = number
end

function BAI:RemoveASCalls()
    self:RemoveDelayedCall("BAI_AssaultStateChange_Sustain")
    self:RemoveDelayedCall("BAI_AssaultStateChange_Fade")
end