local smu_original_bltdownloadmanager_startdownload = BLTDownloadManager.start_download
function BLTDownloadManager:start_download( update )
	local download = update.postponed_download
	if download then
		table.insert( self._downloads, download )
		self:clbk_download_finished( download.data, download.http_id )
		return true
	end

	return smu_original_bltdownloadmanager_startdownload( self, update )
end

local smu_original_bltdownloadmanager_clbkdownloadfinished = BLTDownloadManager.clbk_download_finished
function BLTDownloadManager:clbk_download_finished( data, http_id, ... )
	local download = self:get_download_from_http_id( http_id )
	if not download then
		return
	elseif type( data ) == 'string' and data:sub( 1, 2 ) == 'PK' then
		local update = download.update
		if update and update.is_simple then
			if SimpleModUpdater.settings.auto_install then
				update.notification_id = BLT.Notifications:add_notification( {
					title = update:GetParentMod():GetName(),
					text = managers.localization:text( 'smu_autoinstall_mod_update' ),
					priority = 1001,
				} )
			end
			if SimpleModUpdater.settings.auto_install or update.postponed_download then
				local file_path = Application:nice_path( BLTModManager.Constants:DownloadsDirectory() .. tostring(update:GetId()) .. '.zip' )
				SimpleModUpdater.my_zips[ file_path ] = update
				update.postponed_download = nil
			else
				download.data = data
				download.state = 'already_downloaded'
				update.postponed_download = download
				for i, dl in ipairs( self._downloads ) do
					if download == dl then
						table.remove( self._downloads, i )
						break
					end
				end
				BLT.Downloads:add_pending_download( update )
				return
			end
		end
	else
		download.state = 'failed'
		return
	end

	smu_original_bltdownloadmanager_clbkdownloadfinished( self, data, http_id, ... )
end

local smu_bltdownloadmanagergui_setup = BLTDownloadManagerGui.setup
function BLTDownloadManagerGui:setup()
	smu_bltdownloadmanagergui_setup(self)

	if next(BLT.Downloads:pending_downloads()) then
		local padding = self._buttons[2]._panel:top() - self._buttons[1]._panel:bottom()
		local uall_panel = self._buttons[#self._buttons]._panel

		local button = BLTUIButton:new( self._scroll:canvas(), {
			x = uall_panel:x() - uall_panel:w() - padding,
			y = uall_panel:y(),
			w = uall_panel:w(),
			h = uall_panel:h(),
			text = managers.localization:text('menu_restart_game'),
			center_text = true,
			callback = callback( self, self, 'smu_clbk_restart' )
		} )
		table.insert( self._buttons, button )
	end
end

function BLTDownloadManagerGui:smu_clbk_restart()
	setup:load_start_menu()
end
