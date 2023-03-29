local smu_original_bltnotificationsgui_mousepressed = BLTNotificationsGui.mouse_pressed
function BLTNotificationsGui:mouse_pressed( button, x, y )
	if not self._enabled or button ~= Idstring( '0' ) then
		return
	end

	if alive(self._content_panel) and self._content_panel:inside(x, y) then
		local current = self._notifications[ self._current ]
		local params = current and current.parameters
		if params and params.parent_mod then
			SimpleModUpdater.inspect_mod = params.parent_mod
			managers.menu:open_node('view_blt_mod')
			managers.menu_component:post_event('menu_enter')
			BLT.Notifications:remove_notification(current.id)
			return true
		end
	end

	return smu_original_bltnotificationsgui_mousepressed( self, button, x, y )
end
