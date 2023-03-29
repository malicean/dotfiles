local original =
{
    change_assaultbanner_setting = HUDManager.change_assaultbanner_setting,
    InitAAIPanel = HUDAssaultCorner.InitAAIPanel,
    _offset_hostages = HUDAssaultCorner._offset_hostages,
    _set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
}
local POS =
{
    LEFT = 1,
    CENTER = 2,
    RIGHT = 3
}
local BAIFunctionForced = false
function HUDAssaultCorner:ApplyCompatibility()
    if not WolfHUD then
        BAI:CrashWithErrorHUD("WolfHUD")
    end
    if BAI.settings.hudlist_compatibility == 1 then -- Disable detection
        self:LoadWolfHUDOptions()
    end
end

function HUDManager:change_assaultbanner_setting(setting, value)
    original.change_assaultbanner_setting(self, setting, value)
    if self._hud_assault_corner then
        self._hud_assault_corner:QueryOptions(true)
    end
end

function HUDAssaultCorner:InitAAIPanel()
    original.InitAAIPanel(self)
    if Holo and Holo.Options:GetValue("TopHUD") and Holo:ShouldModify("HUD", "Assault") then
        return
    end
    local condition = false -- Variable to determine if we should move the AAI panel
    if not (self.AAIPanel and self.wolfhud.hudlist_show_hostages) then
        condition = true
    end
    if self:should_display_waves() and condition then -- Looks like Vanilla hostage panel has been disabled by WolfHUD's HUDList, let's move the AAI Panel in Safehouse Raid/Holdout
        condition = false
    end
    if self.wolfhud.hostages_hidden then -- Hostages hidden by BAI or WolfHUD => move AAI Panel
        condition = false
    end
    if condition then
        return
    end

    self._time_left_panel:set_x(self._hud_panel:w() - self._time_left_panel:w())
    self._break_time_panel:set_x(self._time_left_panel:x())
    self._spawns_left_panel:set_right(self._time_left_panel:left() - 3)
end

function HUDAssaultCorner:WaveCounterEnabled()
    return false
end

function HUDAssaultCorner:ApplyObjectivesOffset(offset)
    if managers.hud._hud_objectives and managers.hud._hud_objectives.apply_offset then
        managers.hud._hud_objectives:apply_offset(offset)
    end
end

function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted, box_h)
    if self.wolfhud.position == POS.RIGHT then
        original._offset_hostages(self, hostage_panel, is_offseted, box_h)
    end
end

function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if self.wolfhud.position < POS.RIGHT then -- Left and Center
        if is_offseted then
            self:start_assault_callback()
        elseif self.wolfhud.move_hudlist then
            local offset = self.wolfhud.hostages_hidden and 0 or 46
            self:MoveHUDList(offset)
        end
    else
        original._set_hostage_offseted(self, is_offseted)
    end
end