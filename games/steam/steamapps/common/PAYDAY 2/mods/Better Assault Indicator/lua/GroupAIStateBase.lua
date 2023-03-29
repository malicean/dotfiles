local BAI = BAI
local function Host()
	if BAI._cache.AssaultType ~= BAI.Enum.AssaultType.None then
		return
	end
	BAI:UpdateAssaultState("control", true, true)
	if managers.hud._hud_assault_corner then
    	managers.hud._hud_assault_corner:SetBreakHook(true, 1)
		if not BAI:ASEnabledAndState("control") then
			BAI:CallEvent("MoveHUDList", managers.hud._hud_assault_corner)
		end
	else
		BAI:AddEvent(BAI.EventList.HUDAssaultCornerInit, function(hud)
			hud:SetBreakHook(true, 1)
		end)
	end
end

local function Client()
	if BAI._cache.AssaultType ~= BAI.Enum.AssaultType.None or not Global.statistics_manager.playing_from_start then
		return
	end
	BAI:SetBreakTimer()
	BAI:UpdateAssaultState("control")
	if managers.hud._hud_assault_corner then
		managers.hud._hud_assault_corner:SetBreakHook(true, 1)
		if not BAI:ASEnabledAndState("control") then
			BAI:CallEvent("MoveHUDList", managers.hud._hud_assault_corner)
		end
	else
		BAI:AddEvent(BAI.EventList.HUDAssaultCornerInit, function(hud)
			hud:SetBreakHook(true, 1)
		end)
	end
end

local original =
{
	init = GroupAIStateBase.init,
	load = GroupAIStateBase.load
}

function GroupAIStateBase:init(...)
	original.init(self, ...)
	if BAI:AreAssaultStatesDisabledInTheLevel() then
		return
	end
	if (BAI.IsHost and BAI._cache.level_id ~= "pbr2") or BAI.IsClient then
		self:add_listener("BAI_EnemyWeaponsHot", {
				"enemy_weapons_hot"
		}, BAI.IsHost and Host or Client)
	end
end

function GroupAIStateBase:load(load_data, ...)
    original.load(self, load_data, ...)
    local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
    if law1team then
		if law1team.damage_reduction then
			managers.hud:SetCaptainBuff(law1team.damage_reduction or 0)
		elseif self._hunt_mode then
			managers.hud:SetEndlessClient()
		end
	elseif self._hunt_mode then
		managers.hud:SetEndlessClient()
    end
end

function GroupAIStateBase:GetAssaultState()
    return self._task_data.assault.phase
end