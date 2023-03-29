if not SimpleModUpdater and not SystemFS:exists('mods/Simple Mod Updater') then
	local mod_name = ModInstance:GetName()
	local notif_id

	DelayedCalls:Add('Delayed_notif_install_SMU', 0, function()
		notif_id = BLT.Notifications:add_notification( {
			title = mod_name,
			text = 'Additional dependencies are required.\nClick here to install them via Simple Mod Updater.',
			priority = 1000,
		})
		BLT.Notifications:_get_notification(notif_id).kpr_notif_smu = true
	end)

	local tq_original_bltnotificationsgui_mousepressed = BLTNotificationsGui.mouse_pressed
	function BLTNotificationsGui:mouse_pressed(button, x, y)
		if self._enabled and button == Idstring('0') and alive(self._content_panel) and self._content_panel:inside(x, y) then
			local current = self._notifications[self._current]
			if current and current.parameters and current.parameters.kpr_notif_smu then
				BLT.Notifications:remove_notification(notif_id)
				local url = 'http://pd2mods.z77.fr/update/SimpleModUpdater.zip'
				dohttpreq(url, function(data)
					if type(data) ~= 'string' or data:sub(1, 2) ~= 'PK' then
						return
					end
					local dir = BLTModManager.Constants:DownloadsDirectory()
					local zipfile = dir .. 'smu_' .. math.random(100000000) .. '.zip'
					local fh = io.open(zipfile, 'wb+')
					if not fh then
						return
					end
					fh:write(data)
					fh:close()
					unzip(zipfile, BLTModManager.Constants:ModsDirectory())
					SystemFS:delete_file(zipfile)
					setup:load_start_menu()
				end)
				return true
			end
		end
		return tq_original_bltnotificationsgui_mousepressed( self, button, x, y )
	end
end
