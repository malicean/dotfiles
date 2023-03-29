function BLTModManager:_RunAutoCheckForUpdates() -- overwritten just to add a call to IsCheckingForUpdates()

	-- Place a notification that we're checking for autoupdates
	if BLT.Notifications then
		local icon, rect = tweak_data.hud_icons:get_icon_data("csb_pagers")
		self._updates_notification = BLT.Notifications:add_notification( {
			title = managers.localization:text("blt_checking_updates"),
			text = managers.localization:text("blt_checking_updates_help"),
			icon = icon,
			icon_texture_rect = rect,
			color = Color.white,
			priority = 1000,
		} )
	end

	-- Start checking all enabled mods for updates
	local count = 0
	for _, mod in ipairs( self:Mods() ) do
		for _, update in ipairs( mod:GetUpdates() ) do
			if update:IsEnabled() then
				update:CheckForUpdates( callback(self, self, "clbk_got_update") )
				if update:IsCheckingForUpdates() then
					count = count + 1
				end
			end
		end
	end

	-- -- Remove notification if not getting updates
	if count < 1 and self._updates_notification then
		BLT.Notifications:remove_notification( self._updates_notification )
		self._updates_notification = nil
	end

end
