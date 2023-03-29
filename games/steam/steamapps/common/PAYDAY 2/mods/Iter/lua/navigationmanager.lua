local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

dofile(Iter._path .. 'lua/_navdatapatches.lua')

local mvec3_add = mvector3.add
local mvec3_ang = mvector3.angle
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_div = mvector3.divide
local mvec3_lerp = mvector3.lerp
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_z = mvector3.z
local math_abs = math.abs
local math_max = math.max
local table_insert = table.insert
local table_remove = table.remove

local tmp_vec1 = Vector3()

local _navlink_elements = {}
local _navlink_planned_use = {}

local itr_original_navigationmanager_registercoverunits = NavigationManager.register_cover_units
function NavigationManager:register_cover_units()
	local _debug = self._debug
	self._debug = true
	itr_original_navigationmanager_registercoverunits(self)
	local covers = {}
	for i = #self._covers, 1, -1 do
		local cover = self._covers[i]
		local nav_tracker = cover[3]
		if mvector3.distance(cover[1], nav_tracker:position()) < 60 then
			table.insert(covers, nav_tracker:position())
		else
			table.remove(self._covers, i)
			local location_script_data = self._quad_field:get_script_data(nav_tracker)
			table.delete(location_script_data.covers, cover)
			self._quad_field:destroy_nav_tracker(nav_tracker)
		end
	end
	self._debug = _debug
end

function NavigationManager:itr_make_neighbours_list(navseg_id)
	local navseg = self._nav_segments and self._nav_segments[navseg_id]
	if not navseg then
		return
	end

	local list = {}
	for neighbour_seg_id in pairs(navseg.neighbours) do
		if not self._nav_segments[neighbour_seg_id].disabled then
			table.insert(list, neighbour_seg_id)
		end
	end
	navseg.itr_enabled_neighbours_i = list
end

local itr_original_navigationmanager_registeranimnavlink = NavigationManager.register_anim_nav_link
function NavigationManager:register_anim_nav_link(element)
	local values = element._values
	if not values.itr_from_navseg then
		local intervals = {
			e_nl_fwd_2m = 0,
			e_nl_fwd_4m = 1,
		}

		local tracker = managers.navigation:create_nav_tracker(values.position, true)
		values.itr_from_navseg = tracker:nav_segment()
		tracker:move(values.search_position)
		values.itr_to_navseg = tracker:nav_segment()
		self:destroy_nav_tracker(tracker)

		local so_action = values.so_action
		if type(so_action) == 'string' then
			local interval = math.max(values.interval or 1000, 0)
			if intervals[so_action] then
				values.interval = math.min(interval, intervals[so_action])
			elseif so_action:find('rappel') or so_action:find('rapel') then
				values.interval = math.min(interval, 2)
			elseif so_action:find('jump') then
				values.interval = math.min(interval, 1)
			elseif so_action:find('ladder') then
				values.interval = math.min(interval, 1)
			elseif so_action:find('_clim') then -- climb/climd
				values.interval = math.min(interval, 2)
			elseif so_action:find('e_nl_down_') then
				values.interval = math.min(interval, 1.5)
			elseif so_action:find('e_nl_over_') then
				values.interval = math.min(interval, 1)
			elseif so_action:find('e_nl_up_') then
				values.interval = math.min(interval, 2)
			elseif so_action:find('through') then
				values.interval = math.min(interval, 1)
			end
		end

		values.itr_interval = values.interval or 0
	end
	values.interval = Iter.settings.streamline_path and 0 or values.itr_interval

	itr_original_navigationmanager_registeranimnavlink(self, element)

	local nav_link = element:nav_link()
	if nav_link then
		_navlink_elements[nav_link:key()] = element
	end
end

local itr_original_navigationmanager_unregisteranimnavlink = NavigationManager.unregister_anim_nav_link
function NavigationManager:unregister_anim_nav_link(element)
	local nav_link = element:nav_link()
	if nav_link then
		nav_link:set_delay_time(604800)
		itr_original_navigationmanager_unregisteranimnavlink(self, element)
	end
end

local itr_original_navigationmanager_clbknavfield = NavigationManager.clbk_navfield
function NavigationManager:clbk_navfield(event_name, args, args2, args3)
	local fuckery
	if event_name == 'add_nav_seg_neighbours' then
		for nav_seg_id in pairs(args) do
			local nav_seg = self._nav_segments[nav_seg_id]
			if not nav_seg.disabled_neighbours then
				nav_seg.disabled_neighbours = {}
				fuckery = true
			end
		end
	end

	itr_original_navigationmanager_clbknavfield(self, event_name, args, args2, args3)

	if fuckery then
		for nav_seg_id in pairs(args) do
			local nav_seg = self._nav_segments[nav_seg_id]
			if nav_seg.disabled_neighbours and not next(nav_seg.disabled_neighbours) then
				nav_seg.disabled_neighbours = nil
			end
		end
	end

	if event_name == 'add_nav_seg_neighbours' or event_name == 'remove_nav_seg_neighbours' then
		for nav_seg_id, neighbours in pairs(args) do
			self:itr_make_neighbours_list(nav_seg_id)
			for _, dfghjkrezt in ipairs(neighbours) do
				self:itr_make_neighbours_list(dfghjkrezt)
			end
		end
	end
end

local itr_original_navigationmanager_setnavsegmentstate = NavigationManager.set_nav_segment_state
function NavigationManager:set_nav_segment_state(id, ...)
	itr_original_navigationmanager_setnavsegmentstate(self, id, ...)

	self:itr_make_neighbours_list(id)
	if self._nav_segments[id].neighbours then
		for neighbour_id in pairs(self._nav_segments[id].neighbours) do
			self:itr_make_neighbours_list(neighbour_id)
		end
	end
end

if not Iter.settings.streamline_path then
	return
end

function NavigationManager:itr_get_all_doors_of_segment(segment_id)
	local room_mask = {}
	if self._nav_segments[segment_id] and next(self._nav_segments[segment_id].vis_groups) then
		for _, i_vis_group in ipairs(self._nav_segments[segment_id].vis_groups) do
			local vis_group_rooms = self._visibility_groups[i_vis_group].rooms
			for i_room, _ in pairs(vis_group_rooms) do
				room_mask[i_room] = true
			end
		end
	end

	local all_seg_doors = {}
	local room_neighbours = {}
	for door_id, door in pairs(self._room_doors) do
		local door_rooms = door.rooms
		local r1 = door_rooms[1]
		local r2 = door_rooms[2]
		local rm1 = room_mask[r1]
		local rm2 = room_mask[r2]
		if rm1 or rm2 then
			all_seg_doors[door_id] = door
		end
		if not rm1 then
			room_neighbours[r1] = true
		elseif not rm2 then
			room_neighbours[r2] = true
		end
	end
	return all_seg_doors, room_neighbours
end

function NavigationManager:itr_get_room_to_doors(segment_id, all_seg_doors)
	local result = {}
	for door_id, door in pairs(all_seg_doors) do
		for _, room_id in ipairs(door.rooms) do
			if segment_id == self:get_nav_seg_from_i_room(room_id) then
				local ri = result[room_id]
				if not ri then
					ri = {}
					result[room_id] = ri
				end
				table_insert(ri, door_id)
			end
		end
	end
	return result
end

function NavigationManager:itr_is_contiguous(level, door_flood_levels, room_to_doors)
	local all_doors = self._room_doors
	local level_doors = {}
	local room_pool = {}
	for door_id, door_level in pairs(door_flood_levels) do
		if door_level == level then
			level_doors[door_id] = true
			for _, room_id in ipairs(all_doors[door_id].rooms) do
				if room_to_doors[room_id] then
					room_pool[room_id] = true
				end
			end
		end
	end

	local start = next(room_pool)
	if not start then
		return false
	end
	local to_process = {[start] = true}
	local stop
	repeat
		stop = true
		local old_to_process = to_process
		to_process = {}
		for base_room_id, _ in pairs(old_to_process) do
			room_pool[base_room_id] = nil
			for _, door_id in pairs(room_to_doors[base_room_id]) do
				for _, room_id in ipairs(all_doors[door_id].rooms) do
					if room_pool[room_id] then
						to_process[room_id] = true
						stop = false
					end
				end
				level_doors[door_id] = nil
			end
		end
	until stop

	return not next(level_doors)
end

function NavigationManager:itr_flood(from_doors, room_to_doors)
	local door_flood_levels = {}
	local to_process = {}
	local level = 1
	for _, door_id in pairs(from_doors) do
		if type(door_id) == 'number' then
			door_flood_levels[door_id] = level
			to_process[door_id] = true
		end
	end

	local all_doors = self._room_doors
	local door_level_counts = {}
	door_level_counts[1] = #from_doors
	local stop
	repeat
		stop = true
		level = level + 1
		local old_to_process = to_process
		to_process = {}
		for base_door_id in pairs(old_to_process) do
			for _, room_id in ipairs(all_doors[base_door_id].rooms) do
				local next_doors = room_to_doors[room_id]
				if next_doors then
					for _, door_id in ipairs(next_doors) do
						if not door_flood_levels[door_id] and not to_process[door_id] then
							to_process[door_id] = true
							door_flood_levels[door_id] = level
							local cnt = door_level_counts[level]
							door_level_counts[level] = cnt and cnt + 1 or 1
							stop = false
						end
					end
				end
			end
		end
	until stop

	local room_flood_levels = {}
	for door_id, level in pairs(door_flood_levels) do
		for _, room_id in ipairs(all_doors[door_id].rooms) do
			if room_to_doors[room_id] then -- to filter rooms of this segment
				local room_level = room_flood_levels[room_id]
				room_flood_levels[room_id] = room_level and math.min(room_level, level) or level
			end
		end
	end

	return room_flood_levels, door_flood_levels, door_level_counts
end

function NavigationManager:itr_find_choke_point(room_flood_levels, room_level_counts, room_to_doors, door_flood_levels, important_rooms)
	local lower_levels_contiguity = true
	local level_max = #room_level_counts
	local threshold = math_max(4, level_max / 2)
	for level, count in pairs(room_level_counts) do
		if level > threshold or level == level_max then
			break
		end
		if lower_levels_contiguity then
			lower_levels_contiguity = self:itr_is_contiguous(level, door_flood_levels, room_to_doors)
		end
		if count == 1 then -- choke point exists
			for room_id, room_level in pairs(room_flood_levels) do
				if room_level == level and important_rooms[room_id] then
					local room_data = self._rooms[room_id]
					local r_borders = room_data.borders
					local r_height = room_data.height
					return Vector3((r_borders.x_pos + r_borders.x_neg) / 2, (r_borders.y_pos + r_borders.y_neg) / 2, (r_height.xp_yp + r_height.xn_yn) / 2), lower_levels_contiguity
				end
			end
			break
		end			
	end
end

local tmp_vec = Vector3()
local function itr_add_door_pos_to(sum_pos, all_doors, i_door)
	if type(i_door) == 'number' then
		local door = all_doors[i_door]
		mvec3_lerp(tmp_vec, door.pos, door.pos1, 0.5)
		mvec3_add(sum_pos, tmp_vec)
	elseif alive(i_door) then
		local start_pos = _navlink_elements[i_door:key()]:value('position')
		mvec3_add(sum_pos, start_pos)
	end
end

local function itr_get_rooms_having_access_to_next_level(all_doors, room_to_doors, room_flood_levels, room_neighbours)
	local result = {}
	for room_id, room_level in pairs(room_flood_levels) do
		for _, door_id in ipairs(room_to_doors[room_id]) do
			local rooms = all_doors[door_id].rooms
			local other_room_id = rooms[1] == room_id and rooms[2] or rooms[1]
			local other_room_level = room_flood_levels[other_room_id]
			-- next level OR other navseg
			if other_room_level and other_room_level > room_level or not other_room_level and room_level ~= 1 and room_neighbours[other_room_id] then
				result[room_id] = room_level
				break
			end
		end
	end
	return result
end

function NavigationManager:itr_find_proxies(segment_id)
	local choke_points, choke_point_proxies = {}, {}
	local in_proxies = {}
	local out_proxies = {}
	local all_doors = self._room_doors
	local all_nav_segments = self._nav_segments
	local segment = all_nav_segments[segment_id]
	local all_seg_doors, room_neighbours = self:itr_get_all_doors_of_segment(segment_id)
	local room_to_doors = self:itr_get_room_to_doors(segment_id, all_seg_doors)

	for neighbour_seg_id, door_list in pairs(segment.neighbours) do
		local best_level
		local min_count = 1000
		local level1_contiguous
		local room_flood_levels, door_flood_levels, door_level_counts = self:itr_flood(door_list, room_to_doors)

		local important_rooms = itr_get_rooms_having_access_to_next_level(all_doors, room_to_doors, room_flood_levels, room_neighbours)
		local important_doors = {}
		local room_level_counts = {}
		for room_id, level in pairs(important_rooms) do
			room_level_counts[level] = room_level_counts[level] and room_level_counts[level] + 1 or 1
			if level == 1 then
				for _, door_id in ipairs(room_to_doors[room_id]) do
					if door_flood_levels[door_id] == 1 then
						table_insert(important_doors, door_id)
					end
				end
			end
		end

		for level, count in pairs(door_level_counts) do
			if not self:itr_is_contiguous(level, door_flood_levels, room_to_doors) then
				break
			end
			if count <= min_count then
				best_level = level
				min_count = count
			end
			if level == 1 then
				level1_contiguous = true
			elseif level > 4 then
				break
			end
		end

		if best_level and table.size(all_seg_doors) > 20 then
			local cnt = 0
			local pos = Vector3(0, 0, 0)
			for door_id, level in pairs(door_flood_levels) do
				if level == best_level then
					itr_add_door_pos_to(pos, all_doors, door_id)
					cnt = cnt + 1
				end
			end
			if cnt > 0 and cnt < 5 then
				mvec3_div(pos, cnt)
				out_proxies[neighbour_seg_id] = pos
			end
		end

		local neighbour_in_proxies = all_nav_segments[neighbour_seg_id].in_proxies
		local already_done = neighbour_in_proxies and neighbour_in_proxies[segment_id]
		if already_done ~= nil then
			in_proxies[neighbour_seg_id] = already_done
		elseif level1_contiguous then
			local cnt = 0
			local frontier_center = Vector3(0, 0, 0)
			for _, door_id in ipairs(important_doors) do
				itr_add_door_pos_to(frontier_center, all_doors, door_id)
				cnt = cnt + 1
			end
			if cnt > 2 then
				mvec3_div(frontier_center, cnt)
				local metawidth = 0
				for _, door_id in ipairs(important_doors) do
					local dis
					if type(door_id) == 'number' then
						local door = all_doors[door_id]
						mvec3_lerp(tmp_vec, door.pos, door.pos1, 0.5)
						dis = mvec3_dis_sq(frontier_center, tmp_vec)
					elseif alive(door_id) then
						dis = mvec3_dis_sq(frontier_center, _navlink_elements[door_id:key()]:value('position'))
					end
					if dis and dis > metawidth then
						metawidth = dis
					end
				end
				in_proxies[neighbour_seg_id] = metawidth < (150 * 150) and frontier_center or nil
			end
		end

		if #door_list > 1 then
			local choke_point_pos, lower_levels_contiguity = self:itr_find_choke_point(room_flood_levels, room_level_counts, room_to_doors, door_flood_levels, important_rooms)
			if choke_point_pos then
				local choke_pos = choke_point
				choke_points[neighbour_seg_id] = choke_point_pos

				if lower_levels_contiguity then
					-- pick the closest important door
					local best_pos = Vector3()
					local min_dis = 1000000000
					for _, door_id in ipairs(important_doors) do
						local door = all_doors[door_id]
						if mvec3_dis_sq(door.pos, door.pos1) > 2500 then
							mvec3_lerp(tmp_vec, door.pos, door.pos1, 0.5)
							local dis = mvec3_dis_sq(tmp_vec, choke_point_pos)
							if dis < min_dis then
								min_dis = dis
								mvec3_set(best_pos, tmp_vec)
							end
						else
							for _, pos in ipairs({door.pos, door.pos1}) do
								local dis = mvec3_dis_sq(pos, choke_point_pos)
								if dis < min_dis then
									min_dis = dis
									mvec3_set(best_pos, pos)
								end
							end
						end
					end
					choke_point_proxies[neighbour_seg_id] = best_pos
				end
			end
		end
	end

	return choke_points, choke_point_proxies, in_proxies, out_proxies
end

function NavigationManager:itr_prepare_streamline_data()
	for segment_id, segment in pairs(self._nav_segments) do
		segment.choke_points, segment.choke_point_proxies, segment.in_proxies, segment.out_proxies = self:itr_find_proxies(segment_id)
	end

	for segment_id, segment in pairs(self._nav_segments) do
		for neighbour_seg_id in pairs(segment.neighbours) do
			local choke_point_proxy = segment.choke_point_proxies[neighbour_seg_id]
			if choke_point_proxy then
				local neighbour_choke_point_proxies = self._nav_segments[neighbour_seg_id].choke_point_proxies
				if not neighbour_choke_point_proxies[segment_id] then
					neighbour_choke_point_proxies[segment_id] = choke_point_proxy
				end
			end
		end
	end
end

function NavigationManager:itr_copy_door_data()
	self.itr_room_doors = {}

	for _, segment in pairs(self._nav_segments) do
		for _, door_list in pairs(segment.neighbours) do
			for _, door_id in pairs(door_list) do
				local data = self._room_doors[door_id]
				local center = Vector3()
				mvector3.lerp(center, data.pos, data.pos1, 0.5)
				self.itr_room_doors[door_id] = { center, data.pos, data.pos1 }
			end
		end
	end
end

local itr_original_navigationmanager_sendnavfieldtoengine = NavigationManager.send_nav_field_to_engine
function NavigationManager:send_nav_field_to_engine()
	self:itr_prepare_streamline_data()
	self:itr_copy_door_data()

	for navseg_id in pairs(self._nav_segments) do
		self:itr_make_neighbours_list(navseg_id)
	end

	return itr_original_navigationmanager_sendnavfieldtoengine(self)
end

local function itr_log_navlink_usage(navlink, t)
	local key = navlink:key()
	local navlink_usage = _navlink_planned_use[key]
	if not navlink_usage then
		navlink_usage = {}
		_navlink_planned_use[key] = navlink_usage
	end
	local last_entry = navlink_usage[#navlink_usage]
	if not last_entry or t > last_entry then -- 1 coarse path per frame, no need to stack multiple attempts from the same NPC
		table_insert(navlink_usage, t)
	end
end

local fs_units_per_navseg = FullSpeedSwarm and FullSpeedSwarm.units_per_navseg
local function itr_get_navlink_usage(navlink, t)
	local result = 0
	local n_key = navlink:key()
	local navlink_usage = _navlink_planned_use[n_key]
	if not navlink_usage then
		return 0
	end

	local nu = navlink_usage[1]
	local threshold = t - _navlink_elements[n_key]._values.itr_interval
	while nu and nu < threshold do
		table_remove(navlink_usage, 1)
		nu = navlink_usage[1]
	end
	return #navlink_usage
end

function NavigationManager:itr_get_closest_door_to_pos(all_doors, door_list, pos_from, pos_to, access_pos, navlink_accounting)
	local best_pos, best_pos_with_delay, t, min_congestion_risk
	local best_dis = 1000000000
	local is_direct, through_navlink, through_navlink_with_delay

	for i = #door_list, 1, -1 do
		local i_door = door_list[i]
		if type(i_door) == 'number' then
			for _, door_pos in ipairs(self.itr_room_doors[i_door]) do
				local nav_tracker = self._quad_field:create_nav_tracker(door_pos, true)
				local obstructed = nav_tracker:obstructed()
				self._quad_field:destroy_nav_tracker(nav_tracker)
				if not obstructed then
					local dis = (pos_from and mvec3_dis(pos_from, door_pos) or 0) + mvec3_dis(door_pos, pos_to)
					if dis <= best_dis then
						best_pos = door_pos
						best_dis = dis
						is_direct = true
					end
					break
				end
			end

		elseif is_direct then
			-- qued

		elseif i_door and i_door:alive() and not i_door:is_obstructed() and i_door:check_access(access_pos) then
			local element = _navlink_elements[i_door:key()]
			local start_pos = element:value('position')
			local end_pos = element:nav_link_end_pos()
			local dis = (pos_from and mvec3_dis(pos_from, start_pos) or 0) + mvec3_dis(start_pos, end_pos) + mvec3_dis(end_pos, pos_to)
			local nav_link_delay = element._values.itr_interval
			local congestion_risk = 0
			if nav_link_delay > 0 then
				t = t or TimerManager:game():time()
				local user = element.itr_reserved_by_unit
				congestion_risk = math_max(0, i_door:delay_time() - t)
					+ (
						(alive(user) and user:id() ~= -1 and 0 or 1)
						+ (element.itr_navlink_queue_length or 0)
						+ itr_get_navlink_usage(i_door, t)
					) * nav_link_delay
			end
			if congestion_risk == 0 then
				if dis * 1.4 < best_dis then
					is_direct = false
					best_pos = end_pos
					best_dis = dis * 1.4
					through_navlink = i_door
				end
			elseif not min_congestion_risk or congestion_risk < min_congestion_risk then
				min_congestion_risk = congestion_risk
				best_pos_with_delay = end_pos
				through_navlink_with_delay = i_door
			end
		end
	end

	if is_direct then
		through_navlink = nil
	else
		through_navlink = through_navlink or through_navlink_with_delay
		if through_navlink and navlink_accounting then
			itr_log_navlink_usage(through_navlink, t)
		end
	end

	return best_pos or best_pos_with_delay, through_navlink
end

function NavigationManager:itr_get_door_between(segment1_id, segment2_id, near_pos)
	local door_list = self._nav_segments[segment1_id].neighbours[segment2_id]
	if door_list then
		return self:itr_get_closest_door_to_pos(self._room_doors, door_list, nil, near_pos, nil, true)
	end
end

function NavigationManager:itr_find_best_navlink(segment1_id, segment2_id, access_pos, near_pos, current_navlink_element)
	local door_list = self._nav_segments[segment1_id].neighbours[segment2_id]
	if not door_list then
		return
	end

	local best_dis = 100000000000000
	local best_time_to_wait = 100000000000
	local best_navlink, best_navlink_element
	for i = #door_list, 1, -1 do
		local navlink = door_list[i]
		if type(navlink) == 'userdata' and navlink:alive() and not navlink:is_obstructed() and navlink:check_access(access_pos) then
			local navlink_element = _navlink_elements[navlink:key()]

			local interval = navlink_element._values.itr_interval
			local extra_time_to_go = math_max(0, 1.5 - interval)
			local navpos = navlink_element:value('position')

			local queue_length = navlink_element.itr_navlink_queue_length or 0
			if navlink_element == current_navlink_element then
				queue_length = queue_length - 1
			end

			local time_to_wait = queue_length * (interval + extra_time_to_go)

			if near_pos then
				local my_time_to_go = mvec3_dis(near_pos, navpos) / (self.itr_navlink_coef * 0.7)
				time_to_wait = time_to_wait - extra_time_to_go + math_max(0, my_time_to_go - interval)
			end

			local user = navlink_element.itr_reserved_by_unit
			if alive(user) and user:id() ~= -1 then
				time_to_wait = time_to_wait + interval + math_max(0, mvec3_dis(user:position(), navpos) / self.itr_navlink_coef - interval)
			end

			if time_to_wait < best_time_to_wait then
				best_time_to_wait = time_to_wait
				best_dis = dis
				best_navlink = navlink
				best_navlink_element = navlink_element
			end
		end
	end

	return best_navlink, best_navlink_element
end

local axis = Vector3()
local function itr_get_door_in_alignment(all_doors, door_list, from, to)
	if not from or not to then
		return
	end
	local best_pos, best_angle
	mvec3_set(axis, to)
	mvec3_sub(axis, from)
	for i = #door_list, 1, -1 do
		local i_door = door_list[i]
		if type(i_door) == 'number' then
			local door_pos = all_doors[i_door].center
			mvec3_set(tmp_vec1, door_pos)
			mvec3_sub(tmp_vec1, from)
			local angle = mvec3_ang(axis, tmp_vec1)
			if not best_angle or angle < best_angle then
				best_angle = angle
				best_pos = door_pos
			end
		end
	end
	return best_pos
end

function NavigationManager:itr_get_coarse_pos_between(segment1_id, segment2_id, near_pos, access_pos)
	local doors = self._nav_segments[segment1_id].neighbours[segment2_id]
	if not doors then
		return false
	end

	local segment1 = self._nav_segments[segment1_id]
	local best_pos = segment1.choke_point_proxies[segment2_id]
	if best_pos then
		return best_pos
	end

	best_pos = segment1.out_proxies[segment2_id]
	if best_pos then
		return best_pos
	end

	best_pos = segment1.in_proxies[segment2_id]
	if best_pos then
		return best_pos
	end

	return self:itr_get_closest_door_to_pos(self._room_doors, doors, nil, near_pos, access_pos, false)
end

function NavigationManager:itr_streamline(path, access_pos)
	local all_segs = self._nav_segments
	local all_doors = self._room_doors
	local path_nr = #path
	local step1 = path[1]
	local step2

	if not step1[2] then
		step1[2] = all_segs[step1[1]].pos
	end

	for i = 2, path_nr do
		step2 = path[i]

		local segment1 = all_segs[step1[1]]
		local segment2_id = step2[1]
		local door_list = segment1.neighbours[segment2_id]
		if door_list then
			local navlink
			local segment2 = all_segs[segment2_id]
			local step3 = path[i + 1]
			local segment3 = step3 and all_segs[step3[1]]

			local best_pos = segment1.choke_point_proxies[step2[1]]

			if not best_pos then
				local out_proxy = step3 and (segment3.choke_points[step2[1]] or segment2.out_proxies[step3[1]])
				local in_proxy = segment2.in_proxies[step1[1]] or step3 and all_segs[step3[1]].pos
				best_pos = itr_get_door_in_alignment(all_doors, door_list, step1[2], out_proxy or in_proxy)
			end

			if not best_pos then
				local proxy = step3 and segment2.in_proxies[step3[1]] or path[path_nr][2]
				best_pos, navlink = self:itr_get_closest_door_to_pos(all_doors, door_list, step1[2], proxy, access_pos, true)
				if not best_pos then
					return false
				end
			end

			step2[2] = best_pos
			step2[3] = navlink
		end

		step1 = step2
	end

	path[1][2] = nil
	if path_nr > 1 and path[path_nr - 1][1] ~= path[path_nr][1] then
		path[path_nr + 1] = { path[path_nr][1] }
		path[path_nr][1] = path[path_nr - 1][1]
	end
	return path
end

function NavigationManager:itr_get_accessibility(door_list, access_pos, access_neg)
	local min_congestion_risk, t
	for i = #door_list, 1, -1 do
		local i_door = door_list[i]
		if type(i_door) == 'number' then
			return 0
		elseif i_door and i_door:alive() and not i_door:is_obstructed() and i_door:check_access(access_pos, access_neg) then
			t = t or TimerManager:game():time()
			local element = _navlink_elements[i_door:key()]
			local nav_link_delay = element._values.itr_interval
			if nav_link_delay > 0 then
				local user = element.itr_reserved_by_unit
				congestion_risk = math_max(0, i_door:delay_time() - t)
					+ (
						(alive(user) and user:id() ~= -1 and 0 or 1)
						+ (element.itr_navlink_queue_length or 0)
						+ itr_get_navlink_usage(i_door, t)
					) * nav_link_delay
				if congestion_risk == 0 then
					return 0.1
				elseif not min_congestion_risk or congestion_risk < min_congestion_risk then
					min_congestion_risk = congestion_risk
				end
			end
		end
	end
	return min_congestion_risk or 0.01
end

local function path_copy(path)
	local result = {}
	for i = 1, #path do
		local step_src = path[i]
		local step_dst = {
			step_src[1],
			step_src[2]
		}
		table_insert(result, step_dst)
	end
	return result
end

local function get_coarse_dis(p1, p2, ps)
	local dis = mvec3_dis(p1, p2)
	if ps then
		local ps_z = mvec3_z(ps)
		dis = dis + (math_abs(mvec3_z(p1) - ps_z) + math_abs(mvec3_z(p2) - ps_z)) * 2
	end
	return dis
end

NavigationManager.itr_navlink_coef = 350
NavigationManager.itr_coarse_cache_lifetime = 2
NavigationManager.itr_coarse_fail_retry_t = 3
NavigationManager.itr_coarse_cache = {}

function NavigationManager:_execute_coarce_search(search_data)
	local t = TimerManager:game():time()
	local access_pos = search_data.access_pos
	local next_seg_id = search_data.start_i_seg
	local end_i_seg = search_data.end_i_seg
	local verify_clbk = search_data.verify_clbk

	local bypass_congestion = search_data.bypass_congestion
	if not bypass_congestion then
		if type(search_data.id) ~= 'string' then
			bypass_congestion = true
		else
			local fc = search_data.id:sub(1, 1)
			bypass_congestion = not (fc == 'T' or fc == 'C')
		end
	end

	local path_key = tostring(access_pos) .. ';' .. next_seg_id .. ';' .. end_i_seg
	if verify_clbk then
		path_key = path_key .. 'vc'
	end

	local cached_result = not bypass_congestion and self.itr_coarse_cache[path_key]
	if not cached_result then
		-- qued
	elseif type(cached_result) == 'number' then
		local fail_t = cached_result
		if t - fail_t < self.itr_coarse_fail_retry_t then
			return false
		end
	else
		if t - cached_result.t < self.itr_coarse_cache_lifetime then
			local result = path_copy(cached_result)
			result.t = nil
			return search_data.results_callback and result or self:itr_streamline(result)
		end
	end

	if access_pos and self._quad_field:is_nav_segment_blocked(end_i_seg, access_pos) then
		self.itr_coarse_cache[path_key] = t
		return false
	end

	local all_nav_segments = self._nav_segments
	local access_neg = search_data.access_neg
	local navlink_coef = self.itr_navlink_coef

	local potential_paths = {}
	local seg_to_search = {}
	local discovered_seg = {
		[next_seg_id] = {
			path = tostring(next_seg_id),
			delay = 0,
			steps_nr = 0,
			coarse_dis = 0,
			pos = search_data.from_pos or all_nav_segments[next_seg_id].pos
		}
	}

	local candidate
	repeat
		local navseg = all_nav_segments[next_seg_id]
		local neighbours = navseg.neighbours
		if neighbours then
			local consider_neighbours = true
			local from = discovered_seg[next_seg_id]
			local door_list = neighbours[end_i_seg]
			if door_list then
				local access_cost = bypass_congestion and 0 or self:itr_get_accessibility(door_list, access_pos, access_neg)
				if access_cost then
					local through_pos = self:itr_get_coarse_pos_between(next_seg_id, end_i_seg, from.pos, access_pos)
					consider_neighbours = access_cost > 0 or not through_pos
					if through_pos then
						local tmp = table.map_copy(from)
						tmp.delay = tmp.delay + access_cost
						tmp.coarse_dis = tmp.coarse_dis + get_coarse_dis(tmp.pos, through_pos, navseg.pos) + mvec3_dis(through_pos, search_data.to_pos or all_nav_segments[end_i_seg].pos)
						table_insert(potential_paths, tmp)

						if not candidate or tmp.coarse_dis < candidate.coarse_dis then
							if tmp.delay < 0.2 then
								candidate = tmp
							end
						end
					end
				end
			end

			if consider_neighbours then
				local enabled_neighbours = navseg.itr_enabled_neighbours_i
				for i = #enabled_neighbours, 1, -1 do
					local neighbour_seg_id = enabled_neighbours[i]
					if verify_clbk and not verify_clbk(neighbour_seg_id) then
						-- qued
					elseif access_pos and self._quad_field:is_nav_segment_blocked(neighbour_seg_id, access_pos) then
						-- qued
					else
						local door_list = neighbours[neighbour_seg_id]
						local access_cost = bypass_congestion and 0 or self:itr_get_accessibility(door_list, access_pos, access_neg)
						if access_cost then
							local through_pos = self:itr_get_coarse_pos_between(next_seg_id, neighbour_seg_id, from.pos, access_pos)
							if through_pos then
								local delay = from.delay + access_cost
								local coarse_dis = from.coarse_dis + get_coarse_dis(from.pos, through_pos, navseg.pos)
								local discovered = discovered_seg[neighbour_seg_id]
								if not discovered then
									if not candidate or coarse_dis + delay * navlink_coef < candidate.coarse_dis + candidate.delay * navlink_coef then
										table_insert(seg_to_search, neighbour_seg_id)
										discovered = {
											path = from.path .. ';' .. neighbour_seg_id,
											delay = delay,
											steps_nr = from.steps_nr + 1,
											coarse_dis = coarse_dis,
											pos = through_pos
										}
										discovered_seg[neighbour_seg_id] = discovered
									end
								else
									if coarse_dis + delay * navlink_coef < discovered.coarse_dis + discovered.delay * navlink_coef then
										table_insert(seg_to_search, neighbour_seg_id)
										discovered.path = from.path .. ';' .. neighbour_seg_id
										discovered.delay = delay
										discovered.steps_nr = from.steps_nr + 1
										discovered.coarse_dis = coarse_dis
										discovered.pos = through_pos
									end
								end
							end
						end
					end
				end
			end
		end

		next_seg_id = table_remove(seg_to_search, 1)
	until not next_seg_id

	local best_score = 100000000
	local best_path
	for _, ppath in ipairs(potential_paths) do
		local score = ppath.coarse_dis + ppath.delay * navlink_coef
		if score < best_score then
			best_score = score
			best_path = ppath
		end
	end

	if not best_path then
		self.itr_coarse_cache[path_key] = t
		return false
	end

	local i = 1
	local result = {}
	for idseg in string.gmatch(best_path.path, '%d+') do
		result[i] = { tonumber(idseg) }
		i = i + 1
	end
	result[i] = {
		end_i_seg,
		search_data.to_pos
	}
	result.has_navlinks = best_path.delay > 0
	result.coarse_dis = best_path.coarse_dis

	if best_path.delay == 0 then
		local cache_result = path_copy(result)
		cache_result.t = t
		self.itr_coarse_cache[path_key] = cache_result
	end

	return search_data.results_callback and result or self:itr_streamline(result)
end
