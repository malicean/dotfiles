_G.BuilDB = _G.BuilDB or {}
BuilDB._path = ModPath
BuilDB._db_path = SavePath .. 'buildb_builds.txt'
BuilDB._data_path = SavePath .. 'buildb_settings.txt'
BuilDB._import_menu_id = 'buildb_import'
BuilDB._url_formats = {}
BuilDB.settings = {
	export_format = 'invalid',
}

function BuilDB:register_url_format(cls, set_as_default)
	if type(cls) == 'table' and cls._tag then
		self._url_formats[cls._tag] = cls
		if set_as_default then
			self.settings.export_format = cls._tag
		end
	end
end

function BuilDB:load()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()

		for tag, cls in pairs(self._url_formats) do
			local url_override = self.settings['url_' .. tag]
			if url_override then
				cls:set_url(url_override)
			end
		end
	end
end

function BuilDB:save()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function BuilDB:setup()
	self.fmt = self._url_formats[self.settings.export_format] or self._url_formats['pd2builder']
end

function BuilDB:get_build_url()
	return self.fmt and self.fmt:get_build_url()
end

function BuilDB:import(url)
	for tag, cls in pairs(self._url_formats) do
		if url:find(tag) then
			return cls:import(url)
		end
	end

	return false, 'unknown url type'
end

function BuilDB:read_db()
	local fh = io.open(self._db_path, 'r')
	if fh then
		local result = fh:read('*all')
		fh:close()
		return result:sub(4, -1)
	end
end

function BuilDB:write_db(txt)
	local fh = io.open(self._db_path, 'w')
	if not fh then
		return false
	end

	fh:write(string.char(239, 187, 191) .. txt)
	fh:close()

	return true
end

function BuilDB:check_db()
	if io.file_is_readable(self._db_path) then
		return true
	end

	local example = '# Keep the UTF-8 encoding of this file or some characters may not appear correctly in the game.\n'
		.. '# Only the lines matching the format "URL + 1 tabulation + build title" will be listed in the import menu.\n\n'
		.. 'https://pd2builder.netlify.app/?s=d0-7410-4100100d0-710	Example\n'
		.. 'You can describe your build more precisely without interfering with the menu.\n'
		.. 'Only the first 2 lines following a build link are displayed (above the list).\n'
		.. 'So this line won\'t appear.\n'

	return self:write_db(example)
end

function BuilDB:load_db()
	self.builds = {}
	if self:check_db() then
		local ldesc = {}
		for line in io.lines(self._db_path) do
			local url, title = line:match('^(https?://.*)	(.*)$')
			if url then
				if #ldesc > 0 and #self.builds > 0 then
					self.builds[#self.builds].desc = table.concat(ldesc, '\n')
				end
				ldesc = {}
				table.insert(self.builds, { url = url, title = title, desc = '' })
			else
				if #ldesc < 2 then
					table.insert(ldesc, line)
				end
			end
		end
		if #ldesc > 0 and #self.builds > 0 then
			self.builds[#self.builds].desc = table.concat(ldesc, '\n')
		end
	end
end

function BuilDB:look_at_build()
	local build = BuilDB.builds[BuilDB._build_id_to_import]
	Steam:overlay_activate('url', build.url)
end

MenuCallbackHandler.BuilDBHandleHub = function(this, item)
	BuilDB._build_id_to_import = 10000 - item._priority
	local title = managers.localization:text('dialog_skills_respec_title')
	local message = managers.localization:text('buildb_dialog_import_message')
	local menu_options = {
		[1] = {
			text = managers.localization:text('dialog_apply'),
			callback = BuilDB.import_clbk,
		},
		[2] = {
			text = managers.localization:text('buildb_dialog_import_btn_preview'),
			callback = BuilDB.look_at_build,
		},
		[3] = {
			text = managers.localization:text('dialog_cancel'),
			is_cancel_button = true,
		},
	}
	QuickMenu:new(title, message, menu_options, true)
end

function BuilDB:generate_menu(node)
	self:load_db()

	for i, build in ipairs(self.builds) do
		local params = {
			name = 'button_buildb_import-' .. tostring(i),
			text_id = build.title,
			callback = 'BuilDBHandleHub',
			to_upper = false,
			help_id = build.desc,
			localize = false,
			localize_help = false
		}
		local new_item = node:create_item(nil, params)
		new_item._priority = 10000 - i
		node:add_item(new_item)
	end
end

_G.BuilDBCreator = _G.BuilDBCreator or class()
function BuilDBCreator.modify_node(node)
	node:clean_items()
	BuilDB:generate_menu(node)
	managers.menu:add_back_button(node)
	return node
end

function BuilDB:show_menu()
	managers.menu:open_node(self._import_menu_id, {})
	managers.menu:active_menu().renderer.ws:show()
end

function BuilDB:import_clbk()
	managers.menu:back(true)
	local build = BuilDB.builds[BuilDB._build_id_to_import]
	log('[BuilDB] Old: ' .. BuilDB:get_build_url())
	log('[BuilDB] New: ' .. build.url)
	local ok, tip = BuilDB:import(build.url)
	if not ok then
		local title = managers.localization:text('dialog_error_title')
		local message = string.format('%s (%s)', managers.localization:text('error'), tip)
		QuickMenu:new(title, message, {}, true)
	end
end

function BuilDB:get_current_build_main_role()
	local ppb = {}
	local ppt = {}
	for tree, tree_data in ipairs(tweak_data.skilltree.trees) do
		local points_spent = managers.skilltree:points_spent(tree)
		local b = math.floor((tree - 1) / 3) + 1
		ppb[b] = (ppb[b] or 0) + points_spent
		table.insert(ppt, {points_spent, managers.localization:text(tree_data.name_id)})
	end

	local roles = {'st_menu_mastermind', 'st_menu_enforcer', 'st_menu_technician', 'st_menu_ghost', 'st_menu_hoxton_pack', 'menu_loadout_empty'}
	local m = -1
	local r = 6
	for k, v in pairs(ppb) do
		if v > 0 and v > m then
			m = v
			r = k
		end
	end
	local role = managers.localization:text(roles[r])

	table.sort(ppt, function(a, b) return a[1] > b[1] end)
	local descr_tbl = {}
	for i = 1, #ppt do
		if ppt[i][1] > 20 then
			table.insert(descr_tbl, string.format('%s (%i)', ppt[i][2], ppt[i][1]))
		end
	end
	local descr = table.concat(descr_tbl, ', ')

	return role, descr
end

function BuilDB:append_db(url, name, descr)
	local fh = io.open(self._db_path, 'a')
	if not fh then
		return false
	end

	local txt = string.format('\n\n%s	%s\n%s\n', url, name, descr)
	fh:write(txt)
	fh:close()

	return true
end

function BuilDB:save_current_build()
	if not BuilDB:check_db() then
		return
	end

	local current_specialization = managers.skilltree:digest_value(Global.skilltree_manager.specializations.current_specialization, false, 1)	
	local spec_name = managers.localization:text('menu_st_spec_' .. current_specialization)
	local role, descr = self:get_current_build_main_role()
	local build_name = spec_name .. ' ' .. role
	local url = self:get_build_url()

	local function weapon_parts_names(blueprint)
		local parts = {}
		for _, part_id in ipairs(blueprint) do
			if not tweak_data.weapon.factory.parts[part_id].inaccessible then
				table.insert(parts, managers.localization:text(tweak_data.weapon.factory.parts[part_id].name_id))
			end
		end
		return table.concat(parts, '/')
	end

	local equipped_primary = managers.blackmarket:equipped_primary()
	local primary_weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(equipped_primary.factory_id)

	local equipped_secondary = managers.blackmarket:equipped_secondary()
	local secondary_weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(equipped_secondary.factory_id)

	local new_build_1 = ('\n\n%s	'):format(url)
	local new_build_2 = ('%s\n%s\n%s with %s\n%s with %s\n%s\n%s\n'):format(
		build_name,
		descr,
		managers.localization:text(tweak_data.weapon[primary_weapon_id].name_id),
		weapon_parts_names(equipped_primary.blueprint),
		managers.localization:text(tweak_data.weapon[secondary_weapon_id].name_id),
		weapon_parts_names(equipped_secondary.blueprint),
		managers.localization:text(tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].name_id),
		managers.localization:text(tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(false)].name_id)
	)

	local all_builds = self:read_db()
	local title = managers.localization:text('buildb_dialog_edit_builds_file')
	local message = managers.localization:text('buildb_dialog_numenter_reminder')
	local params = {
		set_selection_from = utf8.len(all_builds) + utf8.len(new_build_1),
		set_selection_to = utf8.len(all_builds) + utf8.len(new_build_1) + utf8.len(build_name),
		default_value = all_builds .. new_build_1 .. new_build_2,
		changed_callback = callback(BuilDB, BuilDB, 'write_db'),
		font_size = 20,
		multiline = true,
		word_wrap = true,
		w = 800,
		forced_h = 600,
		use_text_formating = true,
		text_formating_color_table = {
			tweak_data.screen_colors.stats_negative,
			tweak_data.screen_colors.stats_positive,
			tweak_data.screen_colors.stats_positive
		}
	}
	QuickKeyboardInput:new(title, message, params, true)
end

dofile(ModPath .. 'lua/_pd2skills.lua')
dofile(ModPath .. 'lua/_pd2builder.lua')

BuilDB:setup()
BuilDB:load()
BuilDB:save()
