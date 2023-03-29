function BLTMod:AreSimpleDependenciesInstalled() -- operates like BLTMod:AreDependenciesInstalled()
	local id2mod = {}
	for _, mod in ipairs( BLT.Mods:Mods() ) do
		if mod.json_data.simple_update_url then
			local simple_id = SimpleModUpdater:url_to_simple_id( mod.json_data.simple_update_url )
			id2mod[ simple_id ] = mod
		end
	end

	local is_ok = true

	for id, url in pairs( self.json_data.simple_dependencies or {} ) do
		local simple_id = SimpleModUpdater:url_to_simple_id( url )
		local mod = id2mod[ simple_id ]
		if not mod then
			is_ok = false
			local download_data = {
				download_url = simple_id .. '_0.zip',
				is_simple = true
			}
			local dependency = BLTModDependency:new( self, id, download_data )
			dependency.is_simple_dependency = true
			dependency._server_data = { name = id, hash = '123' }
			table.insert( self.missing_dependencies, dependency )
			table.insert( self._errors, 'blt_mod_missing_dependencies' )

		elseif not mod:IsEnabled() then
			is_ok = false
			table.insert( self.disabled_dependencies, mod )
			table.insert( self._errors, 'blt_mod_dependency_disabled' )
		end
	end

	return is_ok
end

function BLTMod:Unsetup()
	for _, tbl in ipairs( { BLT.hook_tables.post, BLT.hook_tables.pre, BLT.hook_tables.wildcards } ) do
		for name, hooks in pairs(tbl) do
			for i = #hooks, 1, -1 do
				local hook = hooks[i]
				if hook.mod == self then
					table.remove(hooks, i)
				end
			end
		end
	end

	self.hooks = nil
	self._persists = nil
end
