local AAIPanel =
{
    Hidden = 0,
    InTheAssaultBox = 1,
    CustomPanel = 2
}
local BAI = BAI

local function GetPanel(self)
    return self._bg_box or self._hud_panel:child("assault_panel")
end

local function Log(hud, auto_detection)
    if auto_detection then
        BAI:Log(hud .. " detected. Compatibility applied.")
    else
        BAI:Log("Compatibility applied for " .. hud .. ".")
    end
end

function HUDAssaultCorner:InitHUDList(compatibility, auto_detection)
    if compatibility == 1 then
        return
    elseif compatibility == 2 then
        if WolfHUD then
            self:InitHUDList(5, true)
        elseif WolfHUDHUDList then
            self:InitHUDList(6, true)
        elseif VHUDPlus then
            self:InitHUDList(4, true)
        elseif HUDListManager then
            self:InitHUDList(3, true)
        end
    elseif compatibility == 3 then
        self:InitHUDList_Vanilla()
        Log("HUDList", auto_detection)
        self.hudlist_detected = true
    elseif compatibility == 4 then
        self:InitHUDList_VanillaHUDPlus()
        Log("HUDList in VanillaHUD Plus", auto_detection)
        self.hudlist_detected = true
        self.disable_moving_assault_panel = true
    elseif compatibility == 5 then
        self:InitHUDList_WolfHUD()
        Log("HUDList in WolfHUD", auto_detection)
        self.hudlist_detected = true
        self.disable_moving_assault_panel = true
    elseif compatibility == 6 then
        self:InitHUDList_WolfHUDStandalone()
        Log("Standalone HUDList from WolfHUD", auto_detection)
        self.hudlist_detected = true
    --[[elseif compatibility == 7 then
        self:InitHoloInfo()
        Log("HoloInfo", auto_detection)
        self.hudlist_detected = true]]
    end
end

function HUDAssaultCorner:InitHUDList_WolfHUD()
    local POS =
    {
        LEFT = 1,
        CENTER = 2,
        RIGHT = 3
    }
    self.MoveHUDList = function (self, offset)
        if self.wolfhud.hudlist_enabled and managers.hud.change_list_setting then
            managers.hud:change_list_setting("right_list_height_offset", offset)
        end
    end
    self:LoadWolfHUDOptions()
    local function Update()
        self:LoadWolfHUDOptions(true)
    end

    BAI:AddEvent(BAI.EventList.Update, Update)

    if not BAI:GetHUDOption("hudlist", "move_hudlist") then
        return
    end

    local offset = 46
    self.wolfhud.move_hudlist = true
    if self.wolfhud.hudlist_enabled and (self.wolfhud.hudlist_show_hostages or BAI:GetOption("completely_hide_hostage_panel")) and BAI._cache.vanilla_style_hud then
        self.wolfhud.hostages_hidden = true
        self:DisableHostagePanelFunctions()
        offset = 0
    end

    local delay = 0.75
    local panel = GetPanel(self)

    local function Endless()
        local offset = panel:h() + 8
        if self.wolfhud.position ~= POS.RIGHT and self.wolfhud.hostages_hidden then
            offset = 0
        else
            if not self.wolfhud.hostages_hidden and BAI:IsHostagePanelVisible("endless") then
                offset = panel:h() + 54
            end
        end
        if self.wolfhud.position == POS.LEFT then
            self:ApplyObjectivesOffset(panel:bottom() + 12)
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.EndlessAssaultStart, Endless, delay)

    local function NoReturn(active)
        local offset = panel:h() + 8
        if self.wolfhud.position ~= POS.RIGHT then
            offset = 0
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.NoReturn, NoReturn, delay)

    local function NormalAssaultOverride()
        local offset = panel:h() + 54
        if self.wolfhud.position ~= POS.RIGHT then
            if self.wolfhud.hostages_hidden and self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox then
                offset = 0
            else
                offset = 46
            end
        else
            if self.wolfhud.hostages_hidden then
                if self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox then
                    offset = 46
                end
            else
                if self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox and BAI:IsHostagePanelHidden("assault") then
                    offset = 46
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.NormalAssaultOverride, NormalAssaultOverride, delay)

    local function Assault()
        local offset = panel:h() + 54
        if self.wolfhud.position ~= POS.RIGHT then
            if self.wolfhud.position == POS.LEFT then
                self:ApplyObjectivesOffset(panel:bottom() + 12)
            end
            if self.wolfhud.hostages_hidden then
                offset = self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox and 0 or 46
            else
                if self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox then
                    offset = BAI:IsHostagePanelVisible("assault") and 46 or 0
                else
                    offset = 46
                end
            end
        else
            if self.wolfhud.hostages_hidden and self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox then
                offset = 46
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.AssaultStart, Assault, delay)

    local function AssaultEnd()
        local offset = panel:h() + 54
        if self.wolfhud.position ~= POS.RIGHT then
            if self.wolfhud.hostages_hidden then
                if BAI:GetAAIOption("show_break_time_left") then
                    offset = 46
                else
                    offset = 0
                end
            else
                if BAI:GetOption("completely_hide_hostage_panel") then
                    if BAI:GetAAIOption("show_break_time_left") then
                        offset = 46
                    else
                        offset = 0
                    end
                else
                    offset = 46
                end
            end
        else
            if self.wolfhud.hostages_hidden then
                if BAI:GetOption("show_assault_states") then
                    if BAI:IsStateEnabled("control") or BAI:GetAAIOption("show_break_time_left") then
                        offset = panel:h() + 54
                    else
                        offset = panel:h() + 8
                    end
                end
            else
                if BAI:GetOption("show_assault_states") and BAI:IsStateDisabled("control") then
                    offset = panel:h() + 8
                end
            end
            --[[if BAI:GetOption("completely_hide_hostage_panel") then
                if BAI:GetOption("show_wave_survived") then
                end
                if BAI:GetOption("show_assault_states") then
                    if BAI:IsStateEnabled("control") then
                        offset = 46
                    end
                else
                end
            end
            if BAI:GetOption("show_assault_states") then
                offset = 46
            else
                offset = BAI:GetOption("completely_hide_hostage_panel") and 0 or 46
            end]]
        end
        if self.wolfhud.position == POS.LEFT then
            local o_offset = 0
            local show_assault_states = BAI:GetOption("show_assault_states")
            if BAI:GetOption("show_wave_survived") then
                if not show_assault_states or (show_assault_states and BAI:IsStateDisabled("control")) then
                    local function MoveObjectives()
                        self:ApplyObjectivesOffset(0)
                    end
                    BAI:DelayCall("WolfHUD_MoveObjectivs", 8.6, MoveObjectives)
                end
                o_offset = panel:bottom() + 12
            else
                if show_assault_states and BAI:IsStateEnabled("control") then
                    o_offset = panel:bottom() + 12
                end
            end
            self:ApplyObjectivesOffset(o_offset)
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.AssaultEnd, AssaultEnd, delay + 0.15)

    local function Captain(active)
        local offset = panel:h() + 54
        if active then
            if self.wolfhud.position == POS.RIGHT then
                if self.wolfhud.hostages_hidden then
                    if not self.wolfhud.bai.captain_panel then
                        offset = panel:h() + 8
                    end
                else
                    if not self.wolfhud.bai.captain_panel or BAI:IsHostagePanelHidden("captain") then
                        offset = panel:h() + 8
                    end
                end
            else
                if self.wolfhud.hostages_hidden then
                    offset = self.wolfhud.bai.captain_panel and 46 or 0
                else
                    offset = (self.wolfhud.bai.captain_panel or BAI:IsHostagePanelVisible("captain")) and 46 or 0
                end
            end
        else
            if self.wolfhud.position == POS.RIGHT then
                if self.wolfhud.hostages_hidden then
                    if self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox then
                        offset = panel:h() + 8
                    end
                else
                    if self.wolfhud.bai.aai_panel == AAIPanel.InTheAssaultBox and BAI:IsHostagePanelHidden("assault") then
                        offset = panel:h() + 8
                    end
                end
            else
                if self.wolfhud.hostages_hidden then
                    offset = (self.wolfhud.bai.aai_panel == AAIPanel.CustomPanel) and 46 or 0
                else
                    offset = (self.wolfhud.bai.aai_panel == AAIPanel.CustomPanel or BAI:IsHostagePanelVisible("assault")) and 46 or 0
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.Captain, Captain, delay)

    BAI:AddEvent("MoveHUDList", function(self, assault_state_move)
        local offset = panel:h() + 54
        if self.wolfhud.position == POS.RIGHT then
            if self.wolfhud.hostages_hidden and not BAI:GetAAIOption("show_break_time_left") then
                offset = panel:h() + 8
            end
        else
            if (not self.wolfhud.hostages_hidden or BAI:IsHostagePanelVisible()) or BAI:GetAAIOption("show_break_time_left") then
                offset = 46
            end
        end
        if self.wolfhud.position == POS.LEFT then
            if not BAI:GetAAIOption("show_break_time_left") then
                offset = 0
            end
            self:ApplyObjectivesOffset(panel:bottom() + 12)
        end
        self:MoveHUDList(offset)
    end)

    self:MoveHUDList(offset)

    if self.wolfhud.hudlist_enabled then
        self.update_hudlist_offset = function() end
        self.update_banner_pos = function() end
        if self.wolfhud.position == POS.LEFT then
            local buffs_panel = self._hud_panel:child("buffs_panel")
            local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
            buffs_panel:set_right(icon_assaultbox:left() + icon_assaultbox:w())
        end
    end
end

function HUDAssaultCorner:InitHUDList_WolfHUDStandalone()
    dofile(BAI.HUDCompatibilityPath .. "wolfhud.lua")
    self.LoadWolfHUDOptions = function(self, update)
        if not self.wolfhud then
            self.wolfhud = { bai = {} }
        end
        self.wolfhud.position = math.max(BAI:GetOption("assault_panel_position"), 1, 3)
        self.wolfhud.hudlist_show_hostages = WolfHUDHUDList:getSetting({"HUDList", "ORIGNIAL_HOSTAGE_BOX"}, false)
        if not update then
            self.wolfhud.hudlist_enabled = WolfHUDHUDList:getSetting({"HUDList", "ENABLED"}, true)
        end
        self.wolfhud.bai.aai_visible = BAI:GetOption("show_advanced_assault_info")
        self.wolfhud.bai.aai_panel = BAI:GetAAIOption("aai_panel")
        self.wolfhud.bai.captain_panel = BAI:GetAAIOption("captain_panel")
    end
    self:InitHUDList_WolfHUD()
end

function HUDAssaultCorner:InitHUDList_VanillaHUDPlus()
    self.MoveHUDList = function(self, offset)
        if self.vhudplus.hudlist_enabled and managers.hud.change_list_setting then
            managers.hud:change_list_setting_new("right_list_height_offset", offset)
        end
    end

    self.SetHeistTimerVisibility = function(self, visibility)
        managers.hud._hud_heist_timer._heist_timer_panel:set_visible(visibility)
    end

    self:LoadVanillaHUDPlusOptions()

    -- Main Code
    local function Update()
        self:LoadVanillaHUDPlusOptions(true)
    end

    BAI:AddEvent(BAI.EventList.Update, Update)

    local mui_fix = VHUDPlus:getSetting({"AssaultBanner", "MUI_ASSAULT_FIX"}, false)
    local not_mui_fix = not mui_fix

    if not BAI:GetHUDOption("hudlist", "move_hudlist") then
        if not self.vhudplus.center then
            return
        end
        local function AssaultEnd()
            if BAI:GetOption("show_wave_survived") or BAI:ASEnabledAndState("control") then
                self:SetHeistTimerVisibility(false)
            end
        end
        BAI:AddEvent(BAI.EventList.AssaultEnd, AssaultEnd, 0.05)

        BAI:AddEvent("MoveHUDList", function(self, assault_state_move)
            if assault_state_move then
                self:SetHeistTimerVisibility(not_mui_fix)
            end
        end)

        BAI:AddEvent("MoveHUDListBack", function(self)
            if not_mui_fix then
                self:SetHeistTimerVisibility(not_mui_fix)
            end
        end)
        return
    end

    local panel = GetPanel(self)
    local panel_size =
    {
        full = panel:h() + 54,
        small = panel:h() + 8,
        none = 0
    }

    BAI:AddEvent("MoveHUDList", function(self, assault_state_move)
        local offset = panel_size.full
        if self.vhudplus.center then
            if assault_state_move then
                self:SetHeistTimerVisibility(not_mui_fix)
            end
            if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                if self.vhudplus.hostages_hidden_ex then
                    offset = panel_size.none
                else
                    offset = panel_size.small
                end
            else
                if self.vhudplus.hostages_hidden_ex then
                    if BAI:IsAAIEnabledAndOption("show_break_time_left") then
                        offset = panel_size.small
                    else
                        offset = panel_size.none
                    end
                else
                    offset = panel_size.small
                end
            end
        else
            if assault_state_move then -- Control/Anticipation state is visible
                if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                    if self.vhudplus.hostages_hidden_ex then
                        offset = panel_size.small
                    end
                else
                    if self.vhudplus.hostages_hidden_ex then
                        if not BAI:IsAAIEnabledAndOption("show_break_time_left") then
                            offset = panel_size.small
                        end
                    end
                end
            else
                if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                    if self.vhudplus.hostages_hidden_ex then
                        offset = panel_size.none
                    else
                        offset = panel_size.small
                    end
                else
                    if self.vhudplus.hostages_hidden_ex then
                        if BAI:IsAAIEnabledAndOption("show_break_time_left") then
                            offset = panel_size.small
                        else
                            offset = panel_size.none
                        end
                    else
                        offset = panel_size.small
                    end
                end
            end
        end
        self:MoveHUDList(offset)
    end)

    BAI:AddEvent("MoveHUDListBack", function(self)
        if self.vhudplus.center then
            self:SetHeistTimerVisibility(not_mui_fix)
        end
        local offset = panel_size.small
        if self.vhudplus.hostages_hidden_ex and not BAI:IsAAIEnabledAndOption("show_break_time_left") then
            offset = panel_size.none
        end
        self:MoveHUDList(offset)
    end, 1.50)

    local offset = 46
    self.vhudplus.move_hudlist = true
    if self.vhudplus.hudlist_enabled then
        if (self.vhudplus.hostages_hidden or BAI:GetOption("completely_hide_hostage_panel")) and BAI._cache.vanilla_style_hud then
            self.vhudplus.hostages_hidden_ex = true
            self:DisableHostagePanelFunctions()
            if self.vhudplus.center then
                offset = panel_size.none
            end
        end
    end

    local delay = 0.75

    local function Endless()
        local offset = panel_size.small
        if self.vhudplus.center then
            if self.vhudplus.hostages_hidden_ex or BAI:IsHostagePanelHidden("endless") then
                offset = panel_size.none
            end
        else
            if not self.vhudplus.hostages_hidden_ex and BAI:IsHostagePanelVisible("endless") then
                offset = panel:h() + 54
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.EndlessAssaultStart, Endless, delay + 0.05)

    local function NoReturn(active)
        local offset = panel_size.small
        if self.vhudplus.center then
            offset = panel_size.none
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.NoReturn, NoReturn, delay)

    local function NormalAssaultOverride()
        local offset = panel:h() + 54
        if self.vhudplus.center then
            if self.vhudplus.hostages_hidden_ex and self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                offset = panel_size.none
            else
                offset = 46
            end
        else
            if self.vhudplus.hostages_hidden_ex then
                if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                    offset = 46
                end
            else
                if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox and BAI:IsHostagePanelHidden("assault") then
                    offset = 46
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.NormalAssaultOverride, NormalAssaultOverride, delay)

    local function Assault()
        local offset = panel:h() + 54
        if self.vhudplus.center then
            if self.vhudplus.hostages_hidden_ex then
                offset = self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox and 0 or 46
            else
                if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                    offset = BAI:IsHostagePanelVisible("assault") and 46 or 0
                else
                    offset = 46
                end
            end
        else
            if self.vhudplus.hostages_hidden_ex and self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                offset = 46
            else
                if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox and BAI:IsHostagePanelHidden("assault") then
                    offset = panel_size.small
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.AssaultStart, Assault, delay)

    local function AssaultEnd()
        local offset = panel:h() + 54
        if self.vhudplus.center then
            self:SetHeistTimerVisibility(not_mui_fix)
            if self.vhudplus.hostages_hidden_ex then
                offset = BAI:IsAAIEnabledAndOption("show_break_time_left") and panel_size.small or panel_size.none
            else
                offset = panel_size.small
            end
        else
            if self.vhudplus.hostages_hidden_ex then
                if BAI:GetOption("show_assault_states") then
                    if BAI:IsStateEnabled("control") or BAI:IsAAIEnabledAndOption("show_break_time_left") then
                        if self.vhudplus.bai.aai_panel <= AAIPanel.InTheAssaultBox then
                            offset = panel_size.small
                        else
                            offset = panel:h() + (BAI:IsAAIEnabledAndOption("show_break_time_left") and 54 or 8)
                        end
                    else
                        offset = panel_size.small
                    end
                else
                    return -- HUDList will move in "MoveHUDListBack"
                end
            else
                if BAI:GetOption("show_assault_states") then
                    if BAI:IsStateEnabled("control") or BAI:IsAAIEnabledAndOption("show_break_time_left") then
                        offset = panel:h() + 54
                    else
                        offset = panel_size.small
                    end
                else
                    offset = panel_size.small
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.AssaultEnd, AssaultEnd, 0.90)

    local function Captain(active)
        local offset = panel:h() + 54
        if active then -- Captain panel is visible
            if self.vhudplus.center then
                if BAI:GetAAIOption("captain_panel") then
                    offset = 46
                else
                    offset = (self.vhudplus.hostages_hidden_ex or BAI:IsHostagePanelHidden("captain")) and 0 or 46
                end
            else
                offset = panel:h() + 54
                if not BAI:GetAAIOption("captain_panel") and (self.vhudplus.hostages_hidden_ex or BAI:IsHostagePanelHidden("captain")) then
                    offset = panel_size.small
                end
            end
        else
            local panel_visible = self.vhudplus.bai.aai_panel == AAIPanel.CustomPanel
            local condition = BAI:IsHostagePanelVisible("assault") or panel_visible
            if self.vhudplus.center then
                if self.vhudplus.hostages_hidden_ex then
                    offset = panel_visible and 46 or 0
                else
                    offset = condition and 46 or 0
                end
            else
                if self.vhudplus.hostages_hidden_ex then
                    offset = panel:h() + (panel_visible and 54 or 8)
                else
                    offset = panel:h() + (condition and 54 or 8)
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.Captain, Captain, delay)

    self:MoveHUDList(offset)
end

function HUDAssaultCorner:InitHUDList_Vanilla()
    dofile(BAI.HUDCompatibilityPath .. "vanilla_hudlist.lua")
    self.MoveHUDList = function(self, offset)
        if self.hudlist.hudlist_enabled and HUDListManager.change_setting then
            HUDListManager.change_setting("right_list_y", offset)
        end
    end
    self.hudlist = { bai = {} }
    self:LoadVanillaHUDListOptions()

    -- Main Code
    local function Update()
        self:LoadVanillaHUDListOptions(true)
    end

    BAI:AddEvent(BAI.EventList.Update, Update)

    if self.hudlist.bai.assault_panel_position > 3 then
        return
    end

    local offset = 46
    self.hudlist.move_hudlist = self.hudlist.bai.assault_panel_position == 3
    if self.hudlist.hudlist_enabled and (self.hudlist.hostages_hidden or BAI:GetOption("completely_hide_hostage_panel")) and BAI._cache.vanilla_style_hud then
        self.hudlist.hostages_hidden_ex = true
        self:DisableHostagePanelFunctions()
        if self.hudlist.bai.assault_panel_position < 3 then
            offset = 0
        end
    end

    local delay = 0.75
    local panel = GetPanel(self)

    local function Endless()
        local offset = panel:h() + 8
        if self.hudlist.bai.assault_panel_position ~= 3 then
            if self.hudlist.hostages_hidden_ex or BAI:IsHostagePanelHidden("endless") then
                offset = 0
            end
        else
            if not self.hudlist.hostages_hidden_ex and BAI:IsHostagePanelVisible("endless") then
                offset = panel:h() + 54
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.EndlessAssaultStart, Endless, delay)

    local function NoReturn(active)
        local offset = panel:h() + 8
        if self.hudlist.bai.assault_panel_position < 3 then
            offset = 0
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.NoReturn, NoReturn, delay)

    local function NormalAssaultOverride()
        local offset = panel:h() + 54
        if self.hudlist.bai.assault_panel_position ~= 3 then
            if self.hudlist.hostages_hidden_ex and self.hudlist.bai.aai_panel == AAIPanel.InTheAssaultBox then
                offset = 0
            else
                offset = 46
            end
        else
            if self.hudlist.hostages_hidden_ex then
                if self.hudlist.bai.aai_panel == AAIPanel.InTheAssaultBox then
                    offset = 46
                end
            else
                if self.hudlist.bai.aai_panel == AAIPanel.InTheAssaultBox and BAI:IsHostagePanelHidden("assault") then
                    offset = 46
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.NormalAssaultOverride, NormalAssaultOverride, delay)

    local function Assault()
        local offset = panel:h() + 54
        if self.hudlist.bai.assault_panel_position ~= 3 then
            if self.hudlist.hostages_hidden_ex then
                offset = self.hudlist.bai.aai_panel == AAIPanel.InTheAssaultBox and 0 or 46
            else
                if self.hudlist.bai.aai_panel == AAIPanel.InTheAssaultBox then
                    offset = BAI:IsHostagePanelVisible("assault") and 46 or 0
                else
                    offset = 46
                end
            end
        else
            if self.hudlist.hostages_hidden_ex and self.hudlist.bai.aai_panel == AAIPanel.InTheAssaultBox then
                offset = 46
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.AssaultStart, Assault, delay)

    local function AssaultEnd()
        local offset = panel:h() + 54
        if self.hudlist.bai.assault_panel_position ~= 3 then
            if self.hudlist.hostages_hidden_ex then
                offset = 0
            else
                offset = 46
            end
        else
            if self.hudlist.hostages_hidden_ex then
                if BAI:GetOption("show_assault_states") then
                    if BAI:IsStateEnabled("control") or BAI:GetAAIOption("show_break_time_left") then
                        offset = panel:h() + 54
                    else
                        offset = panel:h() + 8
                    end
                end
            else
                if BAI:GetOption("show_assault_states") and BAI:IsStateDisabled("control") then
                    offset = panel:h() + 8
                end
            end
        end
        self:MoveHUDList(offset)
        if self.hudlist.bai.assault_panel_position == 2 then
            managers.hud._hud_heist_timer._heist_timer_panel:set_visible(false)
        end
    end

    BAI:AddEvent(BAI.EventList.AssaultEnd, AssaultEnd, 0.90)

    local function Captain(active)
        local offset = panel:h() + 54
        if active then -- Captain panel is visible
            if self.hudlist.bai.assault_panel_position ~= 3 then
                if BAI:GetAAIOption("captain_panel") then
                    offset = 46
                else
                    offset = (self.hudlist.hostages_hidden_ex or BAI:IsHostagePanelHidden("captain")) and 0 or 46
                end
            else
                offset = panel:h() + 54
                if not BAI:GetAAIOption("captain_panel") and (self.hudlist.hostages_hidden_ex or BAI:IsHostagePanelHidden("captain")) then
                    offset = panel:h() + 8
                end
            end
        else
            local panel_visible = self.hudlist.bai.aai_panel == AAIPanel.CustomPanel
            local condition = BAI:IsHostagePanelVisible("assault") or panel_visible
            if self.hudlist.bai.assault_panel_position ~= 3 then
                if self.hudlist.hostages_hidden_ex then
                    offset = panel_visible and 46 or 0
                else
                    offset = condition and 46 or 0
                end
            else
                if self.hudlist.hostages_hidden_ex then
                    offset = panel:h() + (panel_visible and 54 or 8)
                else
                    offset = panel:h() + (condition and 54 or 8)
                end
            end
        end
        self:MoveHUDList(offset)
    end

    BAI:AddEvent(BAI.EventList.Captain, Captain, delay)

    BAI:AddEvent("MoveHUDList", function(self, assault_state_move)
        local offset = panel:h() + 54
        if self.hudlist.bai.assault_panel_position == 3 then
            if self.hudlist.hostages_hidden_ex and not BAI:GetAAIOption("show_break_time_left") then
                offset = panel:h() + 8
            end
        else
            if self.hudlist.hostages_hidden_ex and not BAI:GetAAIOption("show_break_time_left") then
                offset = 46
            end
        end
        if self.hudlist.bai.assault_panel_position == 1 then
            offset = 0
            self:ApplyObjectivesOffset(panel:bottom() + 12)
        end
        self:MoveHUDList(offset)
    end)

    self:MoveHUDList(offset)
end

function HUDAssaultCorner:InitHoloInfo()
end