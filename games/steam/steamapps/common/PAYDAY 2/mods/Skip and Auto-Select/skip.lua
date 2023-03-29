--Delay in seconds before auto-continue. Any negative value to disable auto-continue
local SKIP_STAT_SCREEN_DELAY = 3
local SKIP_LOOT_SCREEN_DELAY = 5
local SKIP_BLACKSCREEN = true

if RequiredScript == "lib/managers/menu/stageendscreengui" then

	local update_original = StageEndScreenGui.update

	function StageEndScreenGui:update(t, ...)
		update_original(self, t, ...)
		if not self._button_not_clickable and SKIP_STAT_SCREEN_DELAY >= 0 then
			self._auto_continue_t = self._auto_continue_t or (t + SKIP_STAT_SCREEN_DELAY)
			if t >= self._auto_continue_t then
				managers.menu_component:post_event("menu_enter")
				game_state_machine:current_state()._continue_cb()
			end
		end
	end

elseif RequiredScript == "lib/managers/menu/lootdropscreengui" then

	local update_original = LootDropScreenGui.update

	function LootDropScreenGui:update(t, ...)
		update_original(self, t, ...)

		if not self._card_chosen then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end
		
		if not self._button_not_clickable and SKIP_LOOT_SCREEN_DELAY >= 0 then
			self._auto_continue_t = self._auto_continue_t or (t + SKIP_LOOT_SCREEN_DELAY)
			if t >= self._auto_continue_t then
				self:continue_to_lobby()
			end
		end
	end

elseif RequiredScript == "lib/states/ingamewaitingforplayers" then

	local update_original = IngameWaitingForPlayersState.update
	
	function IngameWaitingForPlayersState:update(...)
		update_original(self, ...)
		
		if self._skip_promt_shown and SKIP_BLACKSCREEN then
			self:_skip()
		end
	end
	
end