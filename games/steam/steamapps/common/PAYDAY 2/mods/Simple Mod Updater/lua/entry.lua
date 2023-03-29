_G.SimpleModUpdater = _G.SimpleModUpdater or {}
SimpleModUpdater.path = ModPath
SimpleModUpdater.data_path = SavePath .. 'simple_mod_updater.txt'
SimpleModUpdater.download_enabled = Global.load_start_menu == nil
SimpleModUpdater.in_main_menu = Global.load_start_menu ~= false
SimpleModUpdater.fake_hash = 'nope'
SimpleModUpdater.my_zips = {}
SimpleModUpdater.settings = {
	disabled_by_dependency = {},
	enabled_updates = {},
	auto_install = true,
	notify_about_disabled_mods = true
}

local server = 'http://pd2mods.z77.fr/update/'
SimpleModUpdater.legacy_id_to_simple_id = {
	AM = server .. 'AlphasortMods',
	BC = server .. 'BagContour',
	BDB = server .. 'BuilDB',
	CAPP = server .. 'CrewAbilityPiedPiper',
	CMD = server .. 'CivilianMarkerForDropins',
	CTC = server .. 'ClearTextureCache',
	DDI = server .. 'DragDropInventory',
	ENH_HMRK = server .. 'EnhancedHitmarkers',
	FC = server .. 'FadingContour',
	FCB = server .. 'FilteredCameraBeeps',
	FCSCM = server .. 'FixCrimeSpreeConcealmentModifier',
	FS = server .. 'FullSpeedSwarm',
	FSS = server .. 'FlashingSwanSong',
	GCW = server .. 'GoonmodCustomWaypoints',
	ITR = server .. 'Iter',
	KIC = server .. 'KeepItClean',
	KPR = server .. 'Keepers',
	LIWL = server .. 'LessInaccurateWeaponLaser',
	LPI = server .. 'LobbyPlayerInfo',
	LS = server .. 'LobbySettings',
	MDF = server .. 'MrDrFantastic',
	MIC = server .. 'MoveableIntimidatedCop',
	MKP = server .. 'Monkeepers',
	MRK = server .. 'Marking',
	MTGA = server .. 'MakeTechnicianGreatAgain',
	MWS = server .. 'MoreWeaponStats',
	NDB = server .. 'NoDuplicatedBullets',
	NMA = server .. 'NoMutantsAllowed',
	PC = server .. 'PagerContour',
	PGT = server .. 'PleaseGoThere',
	QKI = server .. 'QuickKeyboardInput',
	RIP = server .. 'RenameInventoryPages',
	RTR = server .. 'ReloadThenRun',
	SAP = server .. 'SentryAutoAP',
	SAW = server .. 'SawHelper',
	SDJBL = server .. 'RestructuredMenus',
	SHD = server .. 'SentryHealthDisplay',
	SI = server .. 'SearchInventory',
	SUIS = server .. 'SwitchUnderbarrelInSteelsight',
	TP = server .. 'TPACK',
	YAF = server .. 'YetAnotherFlashlight'
}

function SimpleModUpdater:load()
	local configfile = io.open( self.data_path, 'r' )
	if configfile then
		for k, v in pairs( json.decode(configfile:read('*all')) or {} ) do
			self.settings[k] = v
		end
		configfile:close()
	end
end

function SimpleModUpdater:save()
	local configfile = io.open(self.data_path, 'w+')
	if configfile then
		configfile:write(json.encode(self.settings))
		configfile:close()
	end
end

function SimpleModUpdater:make_text_readable( input ) -- or not
	if type(input) ~= 'string' then
		return ''
	end

	local a, b, c = input:byte(1, 3)
	if a == 239 and b == 187 and c == 191 then -- utf8
		return input:sub(4)
	elseif a == 254 and b == 255 then -- utf16be
		return '[utf16 is not supported]'
	elseif a == 255 and b == 254 then -- utf16le
		return '[utf16 is not supported]'
	end

	return input
end

function SimpleModUpdater:url_to_simple_id( url )
	if type(url) ~= 'string' then
		return
	end

	if url:match('.zip$') then
		url = url:sub(1, -5)
	end

	return url
end

function SimpleModUpdater:legacy_to_simple_id( mod )
	local updates = mod.json_data.updates
	if updates then
		for i, update_data in ipairs( updates ) do
			if not update_data.host and update_data.identifier then
				return self.legacy_id_to_simple_id[ update_data.identifier ]
			end
		end
	end
end

function SimpleModUpdater:check_mod(mod)
	local simple_id
	if mod.json_data.simple_update_url then
		if mod.json_data.updates then
			mod.json_data.updates = nil
			mod.updates = {}
		end
		simple_id = self:url_to_simple_id( mod.json_data.simple_update_url )
	else
		simple_id = self:legacy_to_simple_id( mod )
	end

	if simple_id then
		local new_update = BLTSimpleUpdate:new( mod, simple_id )
		table.insert( mod.updates, new_update )
	end

	local state_changed = false

	if mod:AreSimpleDependenciesInstalled() and #mod:GetDisabledDependencies() == 0 then
		if not mod:IsEnabled() and self.settings.disabled_by_dependency[ mod:GetId() ] then
			log( '[SMU] Found all dependencies, enabling:  ' .. mod:GetId() )
			self.settings.disabled_by_dependency[ mod:GetId() ] = nil
			mod:SetEnabled( true, true )
			mod:Setup()
			state_changed = true
		end
	else
		if mod:IsEnabled() then
			self.settings.disabled_by_dependency[ mod:GetId() ] = true
			log( '[SMU] Missing dependency, disabling:  ' .. mod:GetId() )
			mod:SetEnabled( false, false )
			mod:Unsetup()
			state_changed = true
		end
		if self.in_main_menu then
			for _, dependency in ipairs( mod:GetMissingDependencies() ) do
				DelayedCalls:Add( 'DelayedSMU_pending_dl_' .. dependency:GetId(), 0, function()
					BLT.Downloads:add_pending_download( dependency )
				end)
			end
		end
	end

	return state_changed
end

function SimpleModUpdater:map_all_dependencies()
	local sid2mod = {}
	for _, mod in ipairs( BLT.Mods:Mods() ) do
		if mod.json_data.simple_update_url then
			local simple_id = SimpleModUpdater:url_to_simple_id( mod.json_data.simple_update_url )
			sid2mod[ simple_id ] = mod
		end
	end

	local dependencies = {}

	for _, mod in ipairs( BLT.Mods:Mods() ) do
		local parents = {}

		if mod.json_data then
			for id, url in pairs( mod.json_data.simple_dependencies or {} ) do
				local simple_id = SimpleModUpdater:url_to_simple_id( url )
				local parent = sid2mod[ simple_id ] or false
				table.insert( parents, parent )
			end
		end

		dependencies[ mod ] = parents
	end

	return dependencies
end

function SimpleModUpdater:set_mod_layer(mod, dependencies)
	local layer = 1

	for _, parent in ipairs( dependencies[mod] ) do
		if parent then
			if not parent.simple_layer then
				self:set_mod_layer( parent, dependencies )
			end
			layer = math.max( layer, parent.simple_layer + 1 )
		end
	end

	mod.simple_layer = layer
end

function SimpleModUpdater:check_dependencies()
	local dependencies = self:map_all_dependencies()

	for _, mod in ipairs( BLT.Mods:Mods() ) do
		self:set_mod_layer( mod, dependencies )
	end

	local sorted_mods = clone( BLT.Mods:Mods() )
	table.sort( sorted_mods, function(a, b) return a.simple_layer < b.simple_layer end )

	local state_changed = false
	for _, mod in ipairs( sorted_mods ) do
		state_changed = self:check_mod( mod ) or state_changed
	end

	if state_changed then
		self:save()
		DelayedCalls:Add( 'DelayedSMU_BLTsave', 0, function()
			if type(BLT.Mods.Save) == 'function' then
				BLT.Mods:Save()
			else
				Hooks:Call('BLTOnSaveData', BLT.save_data)
			end
		end)
	end
end

function SimpleModUpdater:notify_about_disabled_mods()
	local disabled_mods = {}
	for _, mod in pairs( BLT.Mods:Mods() ) do
		if not mod:IsEnabled() then
			table.insert( disabled_mods, mod:GetName() )
		end
	end

	if BLT.Notifications and #disabled_mods > 0 then
		DelayedCalls:Add( 'DelayedSMU_notif_disabled', 0, function()
			table.sort( disabled_mods )
			BLT.Notifications:add_notification( {
				title = managers.localization:text( 'smu_x_mods_disabled', { x = #disabled_mods } ),
				text = table.concat( disabled_mods, ', ' ) .. '.',
				priority = 1000,
			} )
		end)
	end
end

function SimpleModUpdater:start()
	self:check_dependencies()

	if self.settings.notify_about_disabled_mods then
		self:notify_about_disabled_mods()
	end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_SMU', function(loc)
	local language_filename

	if not language_filename then
		for _, filename in pairs( file.GetFiles(SimpleModUpdater.path .. 'loc/') ) do
			local str = filename:match( '^(.*).txt$' )
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				language_filename = filename
				break
			end
		end
	end

	if language_filename then
		loc:load_localization_file( SimpleModUpdater.path .. 'loc/' .. language_filename )
	end
	loc:load_localization_file( SimpleModUpdater.path .. 'loc/english.txt', false )
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_SimpleModUpdater', function( menu_manager )
	MenuCallbackHandler.SimpleModUpdater_MenuCheckboxClbk = function( this, item )
		SimpleModUpdater.settings[ item:name() ] = item:value() == 'on'
	end

	MenuCallbackHandler.SimpleModUpdater_MenuSave = function( this, item )
		SimpleModUpdater:save()
	end

	MenuHelper:LoadFromJsonFile( SimpleModUpdater.path .. 'menu/options.txt', SimpleModUpdater, SimpleModUpdater.settings )
end)

dofile(ModPath .. 'lua/hooked_tools.lua')
dofile(ModPath .. 'lua/BLTMod.lua')
dofile(ModPath .. 'lua/BLTModDependency.lua')
dofile(ModPath .. 'lua/BLTModManager.lua')
dofile(ModPath .. 'lua/BLTSimpleUpdate.lua')
if not BLTSuperMod then
	dofile(ModPath .. 'lua/BLTLegacy.lua')
	dofile(ModPath .. 'lua/BLTMenuNodes.lua')
end

SimpleModUpdater:load()
SimpleModUpdater:start()
