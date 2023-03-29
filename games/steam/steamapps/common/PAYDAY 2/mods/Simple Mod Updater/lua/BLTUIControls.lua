function BLTDownloadControl:smu_update_patchnotes()
	local update = self:parameters().update
	if update.is_simple then
		if update.parent_mod.json_data.simple_changelog_url then
			-- qued
		elseif update.postponed_download then
			self._patch_background:set_color( tweak_data.menu.default_disabled_text_color )
		else
			self._patch_background:set_color( self._highlight_patch and tweak_data.screen_colors.button_stage_2 or (self:parameters().color or tweak_data.screen_colors.button_stage_3) )
		end
	elseif update.is_simple_dependency then
		self._patch_background:set_color( tweak_data.menu.default_disabled_text_color )
	end
end

local smu_original_bltdownloadcontrol_init = BLTDownloadControl.init
function BLTDownloadControl:init( panel, parameters )
	smu_original_bltdownloadcontrol_init( self, panel, parameters )

	local update = parameters and parameters.update
	if update and update.is_simple then
		if update.postponed_download then
			self._download_state:set_text( managers.localization:text('smu_already_downloaded_ready_to_install') )
		end
		self:smu_update_patchnotes()
	end
end

local smu_original_bltdownloadcontrol_mousemoved = BLTDownloadControl.mouse_moved
function BLTDownloadControl:mouse_moved( button, x, y )
	smu_original_bltdownloadcontrol_mousemoved( self, x, y )
	self:smu_update_patchnotes()
end
