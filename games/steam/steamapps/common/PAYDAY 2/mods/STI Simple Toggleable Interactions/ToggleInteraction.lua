local PlayerStandard__check_action_interact_original = PlayerStandard._check_action_interact
function PlayerStandard:_check_action_interact(t, input)
	if STI.settings.interaction then
		local interrupt_key_press = input.btn_interact_press
			if STI.settings.interact_interrupt_key == 2 then
				interrupt_key_press = input.btn_use_item_press
			end
		if interrupt_key_press and self:_interacting() then
			self:_interupt_action_interact()
			return false
		elseif input.btn_interact_release and self._interact_params then
			if self._interact_params.timer >= STI.settings.min_timer_duration then
				return false
			end
		end
	end

	return PlayerStandard__check_action_interact_original(self, t, input)
end

if not _PlayerStandard__check_use_item then _PlayerStandard__check_use_item = PlayerStandard._check_use_item end
function PlayerStandard:_check_use_item( t, input )
	if STI.settings.equipment then
		if input.btn_use_item_press and self:is_deploying() then
			self:_interupt_action_use_item()
			return false
		elseif input.btn_use_item_release then
			return false
		end
	end

    return _PlayerStandard__check_use_item(self, t, input)
end

