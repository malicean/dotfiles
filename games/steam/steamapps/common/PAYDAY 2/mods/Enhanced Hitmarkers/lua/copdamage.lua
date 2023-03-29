local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local function_names = {
	'damage_bullet',
	'damage_fire',
	'damage_explosion',
	'damage_tase',
	'damage_melee',
}
for _, function_name in pairs(function_names) do
	local original_function = CopDamage[function_name]
	local EnhancedHitmarkers = EnhancedHitmarkers
	if original_function then
		CopDamage[function_name] = function(self, attack_data)
			EnhancedHitmarkers.direct_hit = false

			EnhancedHitmarkers.hooked = true
			local result = original_function(self, attack_data)
			EnhancedHitmarkers.hooked = false

			if EnhancedHitmarkers.direct_hit then
				local headshot = attack_data.headshot
				if not headshot and self._head_body_name then
					if not self._damage_reduction_multiplier and not self._char_tweak.ignore_headshot then
						local body = attack_data.col_ray.body
						headshot = body and body:name() == self._ids_head_body_name
					end
				end
				local kill_confirmed = attack_data.result and attack_data.result.type == 'death'
				managers.hud:on_damage_confirmed(kill_confirmed, headshot, EnhancedHitmarkers.damage_scale)
			end

			return result
		end
	end
end

local eh_original_copdamage_syncdamageexplosion = CopDamage.sync_damage_explosion
function CopDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction, weapon_unit)
	EnhancedHitmarkers.direct_hit = false

	EnhancedHitmarkers.hooked = attacker_unit and attacker_unit:slot() == 2
	eh_original_copdamage_syncdamageexplosion(self, attacker_unit, damage_percent, i_attack_variant, death, direction, weapon_unit)
	EnhancedHitmarkers.hooked = false

	if EnhancedHitmarkers.direct_hit then
		managers.hud:on_damage_confirmed(death, false)
	end
end
