local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local nlwads_original_playerstandard_startactionsteelsight = PlayerStandard._start_action_steelsight
function PlayerStandard:_start_action_steelsight(t)
	nlwads_original_playerstandard_startactionsteelsight(self, t)

	local wbase = self._equipped_unit:base()
	local gadget = wbase and wbase.toggle_gadget and wbase:has_gadget() and wbase:get_active_gadget()
	if gadget and gadget.GADGET_TYPE == 'laser' then
		if wbase:is_category('lmg') or wbase:is_category('akimbo') then
			-- qued
		else
			self.nlwads_was_on = wbase:current_gadget_index()
			wbase:gadget_off()
		end
	end
end

local nlwads_original_playerstandard_endactionsteelsight = PlayerStandard._end_action_steelsight
function PlayerStandard:_end_action_steelsight(t)
	nlwads_original_playerstandard_endactionsteelsight(self, t)

	if self.nlwads_was_on then
		self.nlwads_was_on = nil
		self._equipped_unit:base():gadget_on()
	end
end
