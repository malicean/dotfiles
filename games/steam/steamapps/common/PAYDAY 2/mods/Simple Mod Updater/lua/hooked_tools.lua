local smu_original_unzip = unzip
function unzip( file_path, dest_dir )
	smu_original_unzip( file_path, dest_dir )

	if SimpleModUpdater.my_zips[ file_path ] then
		local update = SimpleModUpdater.my_zips[ file_path ]

		local notification = update and BLT.Notifications:_get_notification( update.notification_id )
		if notification then
			BLT.Notifications:remove_notification( update.notification_id )

			local folders = SystemFS:list(dest_dir, true)
			local extracted_folder_name = folders and #folders == 1 and folders[1]
			local filename = extracted_folder_name and (dest_dir .. '/' .. extracted_folder_name .. '/changelog.txt')
			if SystemFS:exists(filename) then
				notification.text = managers.localization:text( 'smu_autoinstall_mod_download_complete' )
				update.notification_id = BLT.Notifications:add_notification( notification )

				local new_notification = BLT.Notifications:_get_notification( update.notification_id )
				new_notification.parent_mod = update.parent_mod
			end
		end

		SimpleModUpdater.my_zips[ file_path ] = nil
		SystemFS:delete_file( file_path )
	end
end

local smu_original_file_directoryhash = file.DirectoryHash
file.DirectoryHash = function( path )
	local delim = path:sub(-1)
	local id = path:match( delim .. '([^' .. delim .. ']+)' .. delim .. '[^' .. delim .. ']+' .. delim .. '$' )
	for _, download in ipairs(BLT.Downloads._downloads) do
		local update = download.update
		if update.is_simple or update.is_simple_dependency then
			if id == tostring(download.http_id) or id == update:GetInstallFolder() then
				return SimpleModUpdater.fake_hash
			end
		end
	end

	return smu_original_file_directoryhash( path )
end
