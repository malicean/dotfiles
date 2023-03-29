local BAI = BAI
if BAI:AreAssaultStatesDisabledInTheLevel() then
    return
end

local cache = BAI._cache

local function phase(self)
    local state = self._task_data.assault.phase
    if state ~= "anticipation" then
        BAI:UpdateAssaultState(state)
    end
end

if cache.level_id == "pbr2" and BAI.IsHost then -- Other detection method is in "GroupAIStateBase.lua" file
    BAI:Hook(GroupAIStateBesiege, "_upd_recon_tasks", function(self)
        if self._task_data.recon.tasks and self._task_data.recon.tasks[1] then
            BAI:UpdateAssaultState("control", true, true)
            BAI:Unhook(nil, "_upd_recon_tasks")
            managers.hud._hud_assault_corner:SetBreakHook(true, 1)
            if not BAI:ASEnabledAndState("control") then
                BAI:CallEvent("MoveHUDList", managers.hud._hud_assault_corner)
            end
        end
    end)
end

BAI:Hook(HUDManager, "sync_start_anticipation_music", function(...)
    BAI:UpdateAssaultState("anticipation")
end)

local function IsCorrectAssaultType()
    return BAI:IsNot(cache.AssaultType, BAI.Enum.AssaultType.Endless, BAI.Enum.AssaultType.Captain, BAI.Enum.AssaultType.NoReturn)
end

function BAI:UpdateAssaultState(state, stealth_broken, no_as_mod)
    if state and cache._assault_state ~= state and IsCorrectAssaultType() then
        cache._assault_state = state
        self:CallEvent(self.EventList.AssaultStateChange, state, stealth_broken, no_as_mod)
    end
end

function BAI:UpdateAssaultStateOverride(state, override)
    if state and IsCorrectAssaultType() then
        cache._assault_state = state
        self:CallEvent(self.EventList.AssaultStateChangeOverride, state, override)
    end
end

function BAI:SetAssaultStatesHook(hook)
    if hook then
        self:Hook(GroupAIStateBesiege, "_upd_assault_task", phase)
    else
        self:Unhook(nil, "_upd_assault_task")
    end
end

BAI:SetAssaultStatesHook(true)