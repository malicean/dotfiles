local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network:is_client() then
	return
end

local function _is_bot(unit)
	return alive(unit) and unit:base() and unit:base()._tweak_table
end

local kpr_original_carryinteractionext_interactblocked = CarryInteractionExt._interact_blocked
function CarryInteractionExt:_interact_blocked(player)
	if _is_bot(player) then
		return player:movement():carrying_bag()
	end

	return kpr_original_carryinteractionext_interactblocked(self, player)
end

local kpr_original_carryinteractionext_interact = CarryInteractionExt.interact
function CarryInteractionExt:interact(player)
	if not _is_bot(player) then
		return kpr_original_carryinteractionext_interact(self, player)
	end

	if not player:movement():carrying_bag() then
		CarryInteractionExt.super.super.interact(self, player)

		managers.network:session():send_to_peers_synched_except(1, 'sync_interacted', self._unit, player:id(), self.tweak_data, 1)
		self:sync_interacted(nil, player)

		local carry_data = self._unit:carry_data()
		local unit_name = tweak_data.carry[carry_data:carry_id()].unit or 'units/payday2/pickups/gen_pku_lootbag/gen_pku_lootbag'
		local unit = World:spawn_unit(Idstring(unit_name), self:interact_position(), Rotation())

		managers.network:session():send_to_peers_synched('sync_carry_data', unit, carry_data._carry_id, 1, carry_data._dye_initiated, carry_data._has_dye_pack, carry_data._dye_value_multiplier, self:interact_position(), Vector3(), 0, nil, 0)

		managers.player:sync_carry_data(unit, carry_data._carry_id, 1, carry_data._dye_initiated, carry_data._has_dye_pack, carry_data._dye_value_multiplier, self:interact_position(), Vector3(), 0, nil, 0)

		unit:carry_data():link_to(player, false)
		managers.mission:call_global_event('on_picked_up_carry', self._unit)
	end

	return true
end

local kpr_original_zipLineinteractionext_interactblocked = ZipLineInteractionExt._interact_blocked
function ZipLineInteractionExt:_interact_blocked(player)
	if _is_bot(player) then
		local zipline = self._unit:zipline()
		local is_ok = not zipline:is_interact_blocked() and zipline:is_usage_type_bag() and player:movement():carrying_bag()
		return not is_ok
	end

	return kpr_original_zipLineinteractionext_interactblocked(self, player)
end

local kpr_original_zipLineinteractionext_interact = ZipLineInteractionExt.interact
function ZipLineInteractionExt:interact(player)
	if not _is_bot(player) then
		return kpr_original_zipLineinteractionext_interact(self, player)
	end

	local zipline = self._unit:zipline()
	if zipline:is_usage_type_bag() then
		local bag = player:movement()._carry_unit
		if bag then
			local bcd = bag:carry_data()
			bcd:unlink()
			managers.network:session():send_to_peers_synched('sync_carry_data',
				bag,
				bcd._carry_id,
				bcd._multiplier,
				bcd._dye_initiated,
				bcd._has_dye_pack,
				bcd._dye_value_multiplier,
				self._unit:position(),
				self._unit:rotation(),
				0,
				self._unit,
				0)
			zipline:attach_bag(bag)
			bag:interaction():register_collision_callbacks()
		end
	end
end
