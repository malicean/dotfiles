function BLTModDependency:init( parent_mod, id, download_data )
	self._id = id
	self._parent_mod = parent_mod
	self._download_data = download_data
end

function BLTModDependency:GetDownloadURL()
	return self._download_data and self._download_data.download_url
end

function BLTDownloadManager:start_download( update )

	-- Check if the download already going
	if self:get_download( update ) then
		log(string.format( '[Downloads] Download already exists for %s (%s)', update:GetName(), update:GetParentMod():GetName() ))
		return false
	end

	-- Check if this update is allowed to be updated by the download manager
	if update:DisallowsUpdate() then
		MenuCallbackHandler[ update:GetDisallowCallback() ]( MenuCallbackHandler )
		return false
	end

	local url = update:GetDownloadURL()
	if not url then
		return false
	end

	-- Start the download
	local http_id = dohttpreq( url, callback(self, self, 'clbk_download_finished'), callback(self, self, 'clbk_download_progress') )

	-- Cache the download for access
	local download = {
		update = update,
		http_id = http_id,
		state = 'waiting'
	}
	table.insert( self._downloads, download )

	return true
end
