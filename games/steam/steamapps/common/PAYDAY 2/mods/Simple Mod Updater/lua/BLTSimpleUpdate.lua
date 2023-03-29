_G.BLTSimpleUpdate = _G.BLTSimpleUpdate or blt_class( BLTUpdate )

function BLTSimpleUpdate:init( parent_mod, simple_id )
	BLTSimpleUpdate.super.init( self, parent_mod, { host = 'crap' } )
	self.simple_id = simple_id
	self.is_simple = true
	self:SetEnabled( SimpleModUpdater.settings.enabled_updates[ simple_id ] ~= false, true )
end

function BLTSimpleUpdate:SetEnabled( enabled, no_save )
	BLTSimpleUpdate.super.SetEnabled( self, enabled )
	if not no_save then
		SimpleModUpdater.settings.enabled_updates[ self.simple_id ] = enabled
		SimpleModUpdater:save()
	end
end

function BLTSimpleUpdate:GetId()
	return type( self.simple_id ) == 'string' and self.simple_id:match( '([^/]+)$' )
end

function BLTSimpleUpdate:GetDownloadURL()
	return ( '%s_%i.zip' ):format( self.simple_id, self.parent_mod.version )
end

function BLTSimpleUpdate:CheckForUpdates( clbk )
	if SimpleModUpdater.download_enabled then
		BLT.Downloads:start_download( self )
	end
end

function BLTSimpleUpdate:UsesHash()
	return true
end

function BLTSimpleUpdate:ShowChangelog()
	local changes = io.open( self.parent_mod.path .. 'changelog.txt', 'r' )
	if changes then
		local text = SimpleModUpdater:make_text_readable( changes:read( '*all' ) )
		changes:close()
		if text then
			local title = managers.localization:text( 'smu_changelog_title', { mod_name = self.parent_mod:GetName() } )
			local message = text
			local menu_options = {
				{
					text = managers.localization:text( 'smu_changelog_close' ),
					is_cancel_button = true
				}
			}
			local help_menu = QuickMenu:new( title, message, menu_options, true )
		end
	end
end

function BLTSimpleUpdate:ViewPatchNotes()
	local changelog_url = self.parent_mod and self.parent_mod.json_data.simple_changelog_url
	if changelog_url then
		if Steam:overlay_enabled() then
			Steam:overlay_activate( 'url', changelog_url )
		else
			os.execute( 'cmd /c start ' .. changelog_url )
		end
		return
	end

	if not self.postponed_download then -- is during/after installation
		self:ShowChangelog()
	end
end

function BLTSimpleUpdate:GetServerHash()
	return SimpleModUpdater.fake_hash
end
