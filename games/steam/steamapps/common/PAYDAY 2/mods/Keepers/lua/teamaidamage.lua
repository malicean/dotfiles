local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network:is_client() then
	return
end

local teamais_can_interact

local kpr_original_teamaidamage_init = TeamAIDamage.init
function TeamAIDamage:init(...)
	kpr_original_teamaidamage_init(self, ...)

	if Keepers.settings.teamais_can_interact and not managers.skirmish:is_skirmish() then
		self._char_dmg_tweak.REGENERATE_TIME_AWAY = self._char_dmg_tweak.REGENERATE_TIME
		self.kpr_original_dmg_interval = self._dmg_interval
		self.kpr_next_allowed_dmg_turret_t = -100
		self.kpr_previous_next_allowed_dmg_t = 0
		teamais_can_interact = true
		self._dmg_interval = Keepers.interaction_grace_period
	end
end

local kpr_original_teamaidamage_regenerated = TeamAIDamage._regenerated
function TeamAIDamage:_regenerated()
	local previous_health
	if teamais_can_interact and self._regenerate_t and not self._bleed_out then
		previous_health = self._health
	end

	kpr_original_teamaidamage_regenerated(self)

	if previous_health and previous_health ~= self._HEALTH_INIT then
		self._health = math.min(self._HEALTH_INIT, previous_health + self._HEALTH_INIT * Keepers:get_regen_ratio(self._unit))
		self._health_ratio = self._health / self._HEALTH_INIT
		self._regenerate_t = TimerManager:game():time() + self._char_dmg_tweak.REGENERATE_TIME
	end
end

local kpr_original_teamaidamage_applydamage = TeamAIDamage._apply_damage
function TeamAIDamage:_apply_damage(attack_data, result)
	if teamais_can_interact then
		if attack_data.attacker_unit and attack_data.attacker_unit:base()._type == 'swat_turret' then
			local t = TimerManager:game():time()
			if self.kpr_next_allowed_dmg_turret_t > t then
				self._next_allowed_dmg_t = self.kpr_previous_next_allowed_dmg_t
				attack_data.result = result
				result.type = 'none'
				return 0, 0
			else
				self.kpr_next_allowed_dmg_turret_t = t + self.kpr_original_dmg_interval
			end
		end

		self.kpr_previous_next_allowed_dmg_t = self._next_allowed_dmg_t
	end

	return kpr_original_teamaidamage_applydamage(self, attack_data, result)
end
