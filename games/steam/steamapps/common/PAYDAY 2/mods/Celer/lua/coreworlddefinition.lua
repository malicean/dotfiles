local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

core:module('CoreWorldDefinition')

local Celer = _G.Celer
local level_id = Celer:get_level_id()
local cel_original_worlddefinition_createstaticsunit = WorldDefinition._create_statics_unit
local cel_original_worlddefinition_create = WorldDefinition.create
local cel_original_worlddefinition_makeunit = WorldDefinition.make_unit

function Celer.can_be_added_to_unit_group(name)
	if name == 'units/payday2/characters/fps_mover/fps_mover' then
		return false
	elseif name:sub(1, 15) == 'units/dev_tools' then
		return false
	elseif name:sub(1, 17) == 'core/units/light_' then
		return false
	elseif name:sub(1, 13) == 'units/lights/' then
		return false
	elseif name == 'units/pd2_dlc_casino/dev/cas_dev_gambling_chips/cas_dev_gambling_chips' then
		return true
	elseif name:find('/dev/') then
		return false
	elseif name == 'units/world/props/flickering_light/flickering_light' then
		return false
	elseif name:find('occluder') then
		return false
	end
	return true
end

if not Celer.settings['map_change_' .. level_id] then
	-- qued

elseif level_id == 'bex' or level_id == 'skm_bex' then

	Celer:spawn_occluder('16x16', Vector3(-1500, -2100, 390), Rotation(0, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(-1500, -2100, 390), Rotation(0, 90, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-1500, -3025, 390), Rotation(0, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(-1500, -3025, 390), Rotation(0, 90, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-1500, -4400, 950), Rotation(-90, 0, 90))

	Celer:spawn_occluder('16x16', Vector3(2800, -900, -1050), Rotation(0, 0, 0))

	local junk = {
		[101949] = true,
		[102303] = true,
		[102368] = true,
		[102472] = true,
		[102641] = true,
		[102642] = true,
		[103268] = true,
		[103625] = true,
		[103626] = true,
		[103627] = true,
		[103670] = true,
		[103696] = true,
		[103697] = true,
		[103699] = true,
		[103700] = true,
		[103705] = true,
		[103909] = true,
		[103950] = true,
		[103952] = true,
		[103953] = true,
		[104075] = true,
		[104145] = true,
		[800014] = true,
		[800074] = true,
		[800096] = true,
		[800149] = true,
		[800156] = true,
		[800510] = true,
	}
	local ids_inside_bank = {
		[400053] = true,
		[500024] = true,
		[900282] = true,
		[900289] = true,
		[900130] = true,
		[900406] = true,
		[900281] = true,
		[900298] = true,
		[900289] = true,
		[900463] = true,
		[900461] = true,
		[900454] = true,
		[900455] = true,
		[900507] = true,
		[900511] = true,
		[900404] = true,
		[900292] = true,
		[900128] = true,
		[900055] = true,
		[900462] = true,
		[900551] = true,
		[900502] = true,
		[900309] = true,
		[900248] = true,
		[500016] = true,
		[103370] = true,
		[103376] = true,
		[174350] = true,
		[172823] = true,
		[171678] = true,
		[161726] = true,
		[173100] = true,
	}
	local ids_back = {}
	function WorldDefinition:make_unit(data, ...)
		local name = data.name
		local unit_id = data.unit_id
		if junk[unit_id] then
			return
		elseif not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x >= 1075 and x <= 1495 and y >= -2730 and y <= -2100 and z >= 0 and z <= 300 then -- closed bathrooms
			return
		end

		if x > -1522 and x < 1034 and y > -6000 and y < -2136 and z < -10
		or name == 'units/pd2_dlc_bex/architecture/int/bex_int_bank/bex_bank_vaultroom'
		then
			ids_inside_bank[unit_id] = true
		end

		if x >= -1475 and x <= 1700 and y >= -6420 and y <= -3800 and z >= 0 and z <= 300
		or x >= 1250 and x <= 2275 and y >= -3800 and y <= -2860 and z >= 0 and z <= 300
		or x >= -1475 and x <= 2300 and y >= -5400 and y <= -2420 and z >= 300 and z <= 1500
		or x >= -1475 and x <= 2300 and y >= -5400 and y <= -400 and z >= 600 and z <= 1500
		then
			if name == 'units/payday2/architecture/bnk/bnk_int_trolley'
			or name == 'units/payday2/equipment/gen_interactable_door_reinforced/gen_interactable_door_reinforced'
			or name == 'units/payday2/equipment/gen_interactable_door_wooden_a/gen_interactable_door_wooden_a'
			or name == 'units/payday2/equipment/gen_interactable_hack_computer_pear/gen_interactable_hack_computer_pear'
			or name == 'units/payday2/props/bnk_prop_kitchen_cabinets/bnk_prop_kitchen_cabinets'
			or name == 'units/payday2/props/bnk_prop_lounge_tables/bnk_prop_lounge_table_long'
			or name == 'units/payday2/props/bnk_prop_lounge_tables/bnk_prop_lounge_table_round'
			or name == 'units/payday2/props/bnk_prop_lounge_tables/bnk_prop_lounge_table_tall'
			or name == 'units/payday2/props/bnk_prop_office_chair_executive/bnk_prop_office_chair_executive'
			or name == 'units/payday2/props/bnk_prop_office_chair_visitor/bnk_prop_office_chair_visitor'
			or name == 'units/payday2/props/bnk_prop_office_lamp_desk/bnk_prop_office_lamp_desk'
			or name == 'units/payday2/props/bnk_prop_office_lamp_pendent/bnk_prop_office_lamp_pendent_small' and unit_id ~= 900283 and unit_id ~= 900284 and unit_id ~= 900285
			or name == 'units/payday2/props/bnk_prop_office_lamp_table/bnk_prop_office_lamp_table'
			or name == 'units/payday2/props/bnk_prop_office_penstand_calculator/bnk_prop_office_penstand_calculator'
			or name == 'units/payday2/props/bnk_prop_office_tables/bnk_prop_office_table_small'
			or name == 'units/payday2/props/bnk_prop_office_wastebasket/bnk_prop_office_wastebasket'
			or name == 'units/payday2/props/bnk_prop_phone/bnk_prop_phone'
			or name == 'units/payday2/props/com_prop_flowervase/com_prop_flowervase'
			or name == 'units/payday2/props/stn_prop_office_clock/stn_prop_office_clock'
			or name == 'units/payday2/props/stn_prop_office_clock/stn_prop_office_clock_unit'
			or name == 'units/pd2_dlc2/props/bnk_prop_lobby_plant_dracaenafragrans/bnk_prop_lobby_plant_dracaenafragrans_b' and unit_id ~= 500856
			or name == 'units/pd2_dlc2/props/bnk_prop_lobby_plant_dracaenafragrans/bnk_prop_lobby_plant_dracaenafragrans_c'
			or name == 'units/pd2_dlc_arena/architecture/are_supply_room_01/are_supply_long_shelf'
			or name == 'units/pd2_dlc_arena/architecture/are_supply_room_01/are_supply_short_shelf'
			or name == 'units/pd2_dlc_arena/props/are_prop_office_desk_set/are_prop_office_desk_straight'
			or name == 'units/pd2_dlc_arena/props/are_prop_office_lamp_ceiling/are_prop_office_lamp_ceiling_short_static'
			or name == 'units/pd2_dlc_aru/architecture/aru_int/aru_int_wall_bookshelf/aru_int_wall_bookshelf_hidden_safe'
			or name == 'units/pd2_dlc_berry/props/bry_prop_servers/bry_prop_master_server_01'
			or name == 'units/pd2_dlc_berry/props/bry_prop_servers/bry_prop_master_server_02'
			or name == 'units/pd2_dlc_berry/props/bry_prop_servers/bry_prop_master_server_03'
			or name == 'units/pd2_dlc_bex/architecture/ext/bex_ext_bank_facade_glass_ceiling/bex_ext_bank_facade_glass_ceiling'
			or name == 'units/pd2_dlc_bex/props/bex_prop_bank_railing/bex_prop_bank_railing_1m'
			or name == 'units/pd2_dlc_bex/props/bex_prop_bank_railing/bex_prop_bank_railing_pillar' and unit_id ~= 900642
			or name == 'units/pd2_dlc_bex/props/bex_prop_bank_railing/bex_prop_bank_stair_railing_1m' and unit_id ~= 103784
			or name == 'units/pd2_dlc_bex/props/bex_prop_bank_railing/bex_prop_bank_stair_railing_corner'
			or name == 'units/pd2_dlc_bex/props/bex_prop_bank_railing/bex_prop_bank_stair_railing_left_corner'
			or name == 'units/pd2_dlc_bex/props/bex_prop_cup/bex_cup'
			or name == 'units/pd2_dlc_bex/props/bex_prop_office_lamp_wall/bex_prop_office_lamp_wall'
			or name == 'units/pd2_dlc_cage/props/are_prop_office_lamp_desk/are_prop_office_lamp_desk'
			or name == 'units/pd2_dlc_casino/props/cas_prop_lounge_couch/cas_prop_lounge_couch_red'
			or name == 'units/pd2_dlc_chill/props/chl_prop_fan_table/chl_prop_fan_table'
			or name == 'units/pd2_dlc_fish/lxy_prop_equipment_trolley/lxy_prop_equipment_trolley'
			or name == 'units/pd2_dlc_fish/lxy_prop_light_wall/lxy_prop_light_wall_03_off'
			or name == 'units/pd2_dlc_friend/props/sfm_prop_office_table_coffee/sfm_prop_office_table_coffee'
			or name == 'units/pd2_dlc_nmh/props/nmh_prop_cart_b/nmh_prop_cart_b'
			or name == 'units/pd2_dlc_run/props/run_prop_restaurant_chair_01/run_prop_restaurant_chair_01'
			or name == 'units/pd2_dlc_run/props/run_prop_restaurant_table_01/run_prop_restaurant_table_01'
			or name == 'units/pd2_dlc_rvd/props/rvd_prop_ext_pot/rvd_prop_ext_pot'
			or name == 'units/pd2_dlc_vit/props/vit_prop_cabinetroom_table/vit_prop_cabinetroom_table'
			or name == 'units/world/architecture/diamondheist/props/diamondheist_roof_gen_large_01'
			or name == 'units/world/architecture/hospital/props/styrofoamcups/hospital_styrofoam_cups_04'
			or name == 'units/world/props/diamond_heist/apartment/apartment_livingroom/tv_wall/tv_wall'
			or name == 'units/world/props/office/chair/chair_02'
			or name == 'units/world/props/office/chair/office_chair_leather'
			or name == 'units/world/props/office/hospital_watercooler/hospital_watercooler'
			or name:find('bnk_prop_office_desk_shelves')
			or name:find('painting')
			or name:find('signs')
			or name:find('units/pd2_dlc_vit/equipment/vit_interactable_books/vit_interactable_books_')
			then
				ids_inside_bank[unit_id] = true
			end
		end

		if x >= 824 and x <= 1106 and y >= -3349 and y <= -2850 and z >= 400 and z <= 622 -- bathroom 1st floor
		or x >= 825 and x <= 2145 and y >= -5522 and y <= -3523 and z >= 350 and z <= 538 -- backoffice left
		then
			ids_inside_bank[unit_id] = true
		end

		if x >= -825 and x <= 1076 and y >= -5802 and y <= -5400 and z >= 0 and z <= 340 and ids_inside_bank[unit_id] then
			ids_back[unit_id] = true
		end

		return cel_original_worlddefinition_makeunit(self, data, ...)
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.back = {
				ids = ids_back,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3000, -6400, 0),
						width = 1500,
						depth = 1700,
						height = 500,
					}
				}
			}
			self._definition.portal.unit_groups.inside_bank = {
				ids = ids_inside_bank,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1500, -6450, -500),
						width = 900,
						depth = 3500,
						height = 800,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-600, -6450, -500),
						width = 2900,
						depth = 4100,
						height = 800,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1750, -6450, 300),
						width = 4050,
						depth = 6075,
						height = 1200,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'big' or level_id == 'skm_big2' then

	Celer:spawn_occluder('16x16', Vector3(1600, 580, -610), Rotation(0, -90, 0)) -- front right
	Celer:spawn_occluder('16x16', Vector3(1600, 580, -610), Rotation(0, -90, 0), true)
	Celer:spawn_occluder('16x8', Vector3(1600, 1550, -610), Rotation(180, -90, 0))
	Celer:spawn_occluder('16x8', Vector3(1600, 1550, -610), Rotation(180, -90, 0), true)

	Celer:spawn_occluder('16x16', Vector3(3300, 750, -610), Rotation(0, 90, 0)) -- up to bottom, front middle

	Celer:spawn_occluder('16x8', Vector3(3240, -1420, -610), Rotation(180, 90, 0)) -- front left
	Celer:spawn_occluder('16x8', Vector3(3240, -1420, -610), Rotation(180, 90, 0), true)
	Celer:spawn_occluder('16x16', Vector3(1640, -2300, -610), Rotation(180, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(1640, -2300, -610), Rotation(180, 90, 0), true)

	Celer:spawn_occluder('12x8', Vector3(2010, -1012, -675), Rotation(180, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(2010, -1012, -675), Rotation(180, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(700, 750, -610), Rotation(-90, 90, 0)) -- half middle
	Celer:spawn_occluder('16x8', Vector3(700, 750, -610), Rotation(-90, 90, 0), true)
	Celer:spawn_occluder('14x8', Vector3(-610, 815, -700), Rotation(180, 0, 0))
	Celer:spawn_occluder('14x8', Vector3(-610, 815, -700), Rotation(180, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-2800, -975, -790), Rotation(90, 0, 0)) -- vault/back
	Celer:spawn_occluder('16x8', Vector3(-2800, -975, -790), Rotation(90, 0, 0), true)
	Celer:spawn_occluder('4x8', Vector3(-2795, 916, -1000), Rotation(90, 0, -90))
	Celer:spawn_occluder('4x8', Vector3(-2795, 916, -1000), Rotation(90, 0, -90), true)
	Celer:spawn_occluder('16x8', Vector3(-2013, -875, -1500), Rotation(90, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(-2013, -875, -1500), Rotation(90, 0, -90), true)

	local ids_entrance = {
		[105218] = true,
		[105311] = true,
		[104581] = true,
		[105067] = true,
		[105099] = true,
		[105157] = true,
		[105305] = true,
		[105308] = true,
		[105414] = true,
		[105455] = true,
		[105466] = true,
		[105475] = true,
		[105485] = true,
		[105780] = true,
		[105781] = true,
		[106021] = true,
		[106023] = true,
		[106026] = true,
		[106027] = true,
		[106028] = true,
		[106029] = true,
		[106031] = true,
		[106036] = true,
		[400001] = true,
		[400005] = true,
		[400009] = true,
		[400031] = true,
		[400075] = true,
		[400189] = true,
		[400237] = true,
		[400238] = true,
		[400349] = true,
		[400351] = true,
		[400367] = true,
		[400676] = true,
		[400681] = true,
		[400756] = true,
		[400758] = true,
		[400239] = true,
		[400240] = true,
		[400302] = true,
		[400324] = true,
		[400372] = true,
		[400378] = true,
		[400755] = true,
		[400757] = true,
		[400743] = true, -- shared roof
		[104065] = true,
		[101935] = true, -- shared garage
		[106650] = true,
		[106994] = true,
	}
	local ids_garage = {
		[104879] = true, -- shared front
		[102784] = true,
		[101935] = true, -- shared entrance
		[106994] = true,
		[106650] = true,
		[400762] = true, -- shared roof/entrance
		[106044] = true,
		[106045] = true,
		[101809] = true, -- shared roof
	}
	local ids_front = {
		[400002] = true,
		[103999] = true,
		[106065] = true,
		[105696] = true,
		[400185] = true,
		[106830] = true, -- shared roof
		[101947] = true,
		[101961] = true,
		[103155] = true,
		[102125] = true,
		[101646] = true,
		[105214] = true,
		[106095] = true,
		[106096] = true,
		[101288] = true,
		[101263] = true, -- shared roof/entrance
		[400754] = true,
		[106025] = true,
		[106042] = true,
		[106043] = true,
		[101289] = true, -- shared frack0
		[104582] = true,
		[103040] = true,
		[105692] = true,
	}
	local ids_roof = {
		[101267] = true,
		[105307] = true,
		[105309] = true,
		[105310] = true,
		[105315] = true,
		[105316] = true,
		[105317] = true,
		[106521] = true,
		[400672] = true,
		[101283] = true,
		[103164] = true,
		[101809] = true, -- shared garage
		[101594] = true, -- shared front
		[101947] = true,
		[101961] = true,
		[102125] = true,
		[101646] = true,
		[104016] = true,
		[103971] = true,
		[101262] = true,
		[105214] = true,
		[106830] = true,
		[103155] = true,
		[106095] = true,
		[106096] = true,
		[101288] = true,
		[400743] = true, -- shared entrance
		[104065] = true,
	}
	local ids_frack0 = {
		[101289] = true, -- shared front
		[104582] = true,
		[103040] = true,
		[102619] = true,
		[102620] = true,
		[102629] = true,
		[102630] = true,
		[102631] = true,
		[102636] = true,
		[102639] = true,
		[102659] = true,
		[104618] = true,
		[105692] = true,
	}
	local ids_frack1 = {
		[103057] = true,
		[106180] = true,
		[105115] = true,
		[105112] = true,
		[106203] = true,
		[106199] = true,
	}
	local ids_back = {
		[106846] = true, -- shared c4
		[106067] = true,
		[102949] = true,
	}
	local ids_c4 = {
		[105703] = true,
		[400686] = true,
		[400688] = true,
		[400689] = true,
		[400690] = true,
		[400722] = true,
		[400723] = true,
		[400724] = true,
		[400725] = true,
		[104612] = true,
		[102860] = true,
		[106846] = true, -- shared back
	}

	function WorldDefinition:make_unit(data, ...)
		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) or name == 'units/payday2/props/bnk_prop_security_keybox/bnk_prop_security_keybox' then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z
		local unit_id = data.unit_id

		if x >= 3075 and x <= 3185 and y >= 900 and y <= 1676 and z >= -1001 and z <= -625 then
			ids_entrance[unit_id] = true
		end

		if y < 2200 then
			-- qued
		elseif name == 'units/pd2_dlc2/architecture/gov_c_ext/gov_c_ext_roof_corner_a_1x1m'
		or name == 'units/pd2_dlc2/architecture/gov_c_ext/gov_c_ext_roof_baluster_4x1m'
		then
			ids_entrance[unit_id] = true
			ids_roof[unit_id] = true
		end

		if x >= 4700 and y <= -1500 then
			ids_entrance[unit_id] = true
			ids_roof[unit_id] = true
		end

		if x >= 201 and y <= -2500 and z > 900 then
			ids_roof[unit_id] = true
		end

		if x >= 4119 and x <= 4780 and y >= -775 and y <= 775 and z >= -1102 and z <= -700 and not ids_entrance[unit_id] -- entrance
		or x >= 3185 and x <= 3985 and y >= 900 and y <= 1676 and z >= -1000 and z <= -625
		or x >= 3150 and x <= 3419 and y >= -1090 and y <= -1050 and z >= -1000 and z <= -800 -- prelounge
		or x >= 1575 and x <= 3100 and y >= -1201 and y <= -740 and z >= -1001 and z <= -626 -- lounge
		or x >= 74 and x <= 1788 and y >= -1425 and y <= -1025 and z >= -601 and z <= -180 -- corridor boss office
		or x >= 1597 and x <= 2021 and y >= -2075 and y <= -1446 and z >= -1001 and z <= -357 -- stairs garage
		or x >= 1012 and x <= 3225 and y >= 925 and y <= 2100 and z >= -1226 and z <= -615 and not ids_entrance[unit_id] -- desks lvl0
		or x >= 75 and x <= 1575 and y >= -2225 and y <= -750 and z >= -1000 and z <= -615 -- kitchen
		or x >= 1128 and x <= 1234 and y >= 680 and y <= 691 and z >= -934 and z <= -778 -- "books" tellers
		then
			ids_front[unit_id] = true
		end

		if name == 'units/pd2_dlc2/architecture/gov_c_int/gov_c_int_pillaster_a_7m' then
			ids_front[unit_id] = true
			ids_roof[unit_id] = true
			if x > 500 then
				ids_frack1[unit_id] = true
			end
		end

		if x >= 221 and x <= 1788 and y >= -2175 and y <= -1400 and z >= -601 and z <= 225
		or x >= 1542 and x <= 3450 and y >= -540 and y <= 840 and z >= -1003 and z <= -875 -- center
		or x >= 3350 and x <= 4775 and y >= -971 and y <= 1217 and z >= -601 and z <= 170 -- above entrance
		or x >= 797 and x <= 3250 and y >= 1000 and y <= 2025 and z >= -601 and z <= -522 -- desks lvl1
		or name == 'units/pd2_dlc2/architecture/gov_c_int/gov_c_int_baluster_a_2m'
		or name == 'units/pd2_dlc2/architecture/gov_c_int/gov_c_int_stairs_lobby_poles_a'
		or name == 'units/pd2_dlc2/architecture/gov_c_int/gov_c_int_stairs_lobby_poles_b'
		or name == 'units/pd2_dlc2/architecture/gov_c_int/gov_c_int_stairs_lobby_poles_c'
		or name == 'units/payday2/props/bnk_prop_lobby_lamp_ceiling/bnk_prop_lobby_lamp_ceiling'
		or name == 'units/pd2_dlc2/architecture/gov_c_int/gov_c_int_bank_atrium_segment_a'
		or name == 'units/pd2_dlc2/architecture/gov_c_int/gov_c_int_pillar_a_12m'
		or unit_id == 103743
		or unit_id == 106617
		or unit_id == 104618
		or unit_id == 102444
		or unit_id == 103918
		or unit_id == 103932
		or unit_id == 103964
		or unit_id == 105155
		or unit_id == 105073
		or unit_id == 105143
		or unit_id == 105166
		or unit_id == 105368
		or unit_id == 105430
		or unit_id == 105455
		or unit_id == 105486
		or unit_id == 105748
		or unit_id == 105216
		or unit_id == 104955
		or unit_id == 104844
		or unit_id == 105411
		then
			ids_frack1[unit_id] = true
			ids_front[unit_id] = true
			ids_roof[unit_id] = true
		elseif x >= 599 and x <= 1300 and y >= -426 and y <= 425 and z >= -1001 and z <= -950
		or unit_id == 104570
		or name:find('crane')
		then
			ids_front[unit_id] = true
			ids_roof[unit_id] = true
		end

		if unit_id == 105124 then
			-- qued
		elseif x >= -2800 and x <= -425 and y >= -1300 and y <= 1400 and z >= -2000 and z <= -300
		or x >= -2772 and x <= -1411 and y >= -1998 and y <= -438 and z >= -601 and z <= -274 -- objects lvl1
		or x >= -4000 and x <= -2836 and y >= 800 and y <= 1513 and z >= -1001 and z <= -260 -- pres room
		or x >= -6000 and x <= -2800 and y >= -3000 and y <= 776 and z >= -1001 and z <= -200 -- vault
		then
			ids_back[unit_id] = true
		end

		if x >= -7741 and x <= -5000 and y >= 856 and y <= 2354 and z >= -601 and z <= -304
		or x < -4300 and name == 'units/payday2/architecture/com_int_construction_floor/com_int_construction_wall_window_4x3m'
		then
			ids_c4[unit_id] = true
		end

		if name:find('veg_park_tree') then
			if x < -1700 then
				ids_c4[unit_id] = true
				ids_roof[unit_id] = true
			else
				ids_front[unit_id] = true
				ids_roof[unit_id] = true
			end
		end

		return cel_original_worlddefinition_makeunit(self, data, ...)
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.entrance = {
				ids = ids_entrance,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(3060, -2500, -1215),
						width = 4000,
						depth = 5000,
						height = 1815,
					}
				}
			}
			self._definition.portal.unit_groups.garage = {
				ids = ids_garage,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1200, -2500, -1215),
						width = 5860,
						depth = 1090,
						height = 1815,
					}
				}
			}
			self._definition.portal.unit_groups.roof = {
				ids = ids_roof,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-500, -4100, 0),
						width = 4700,
						depth = 6600,
						height = 4000,
					}
				}
			}
			self._definition.portal.unit_groups.front = {
				ids = ids_front,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(0, -2500, -1240),
						width = 7060,
						depth = 5000,
						height = 1465,
					}
				}
			}
			self._definition.portal.unit_groups.frack0 = {
				ids = ids_frack0,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-780, -820, -1000),
						width = 790,
						depth = 2030,
						height = 325,
					}
				}
			}
			self._definition.portal.unit_groups.frack1 = {
				ids = ids_frack1,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-950, -925, -600),
						width = 1325,
						depth = 1725,
						height = 325,
					}
				}
			}
			self._definition.portal.unit_groups.back = {
				ids = ids_back,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5400, -9200, -1500),
						width = 5400,
						depth = 11600,
						height = 1500,
					}
				}
			}
			self._definition.portal.unit_groups.c4 = {
				ids = ids_c4,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-7800, 850, -600),
						width = 2901,
						depth = 1600,
						height = 300,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4900, 1620, -600),
						width = 1900,
						depth = 780,
						height = 300,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'born' then

	function WorldDefinition:_create_statics_unit(data, offset)
		local unit_id = data.unit_data.unit_id
		if unit_id == 100755 then
			data.unit_data.position = Vector3(1837.03, -16557.1, 46.7926)
		elseif unit_id == 100804 then
			data.unit_data.position = Vector3(-9000, -1974, 5)
		end

		return cel_original_worlddefinition_createstaticsunit(self, data, offset)
	end

elseif level_id == 'bph' then

	Celer:spawn_occluder('16x8', Vector3(460, -13560, -200), Rotation(0, 0, 0))
	Celer:spawn_occluder('16x8', Vector3(460, -13560, -200), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(460, -14360, -600), Rotation(-90, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(460, -14360, -600), Rotation(-90, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(-340, -14360, -600), Rotation(180, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(-340, -14360, -600), Rotation(180, 0, -90), true)

	Celer:spawn_occluder('16x16', Vector3(-2500, -13000, 0), Rotation(-90, 0, 0))

	local ids_shower = {
		[103062] = true,
		[103063] = true,
		[103070] = true,
		[103145] = true,
		[600557] = true,
		[102085] = true,
		[500136] = true, -- shared backdrop/roof_access
		[500001] = true,
		[500541] = true, -- shared backdrop
		[500149] = true,
		[500023] = true,
		[500340] = true,
		[500539] = true,
		[500440] = true,
		[500010] = true,
		[500011] = true,
		[500012] = true,
		[500013] = true,
		[500022] = true,
		[500030] = true,
		[500124] = true,
		[601338] = true,
	}
	local ids_cells = {
		[600946] = true, -- shared canteen
		[601279] = true,
		[600904] = true,
	}
	local ids_canteen_laundry = {
		[103154] = true,
		[600558] = true,
		[103145] = true, -- shared cells
		[103128] = true,
		[102461] = true,
		[800000] = true,
		[800002] = true,
		[103150] = true,
		[103155] = true,
		[103156] = true,
		[103151] = true,
		[103152] = true,
		[300255] = true,
		[102030] = true, -- shared backdrop
		[102033] = true,
	}
	local ids_roof_access = {
		[103174] = true,
		[500136] = true, -- shared backdrop/shower
		[500001] = true,
	}
	local ids_backdrop = {
		[601338] = true, -- shared shower
		[102030] = true, -- shared canteen
		[102033] = true,
	}

	function WorldDefinition:make_unit(data, ...)
		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z
		local unit_id = data.unit_id

		local is_roof_stuff = name:find('air_prop_runway_fence')
			or name:find('antenna')
			or name:find('chimney')
			or name:find('razorwire')
			or name:find('roof')
			or name:find('satellite')
			or name:find('watchtower')

		if is_roof_stuff then
			-- qued
		elseif x >= 875 and x <= 3400 and y >= -8200 and y <= -3788 and z >= -200 and z <= 1300 then
			ids_shower[unit_id] = true
		end

		if is_roof_stuff then
			-- qued
		elseif x >= 850 and x <= 3625 and y >= -12650 and y <= -7300 and z >= -125 and z <= 1200
		or x >= 1375 and x <= 2631 and y >= -14079 and y <= -12647 and z >= -128 and z <= 475 -- shared canteen
		then
			ids_cells[unit_id] = true
		end

		if is_roof_stuff then
			-- qued
		elseif x >= -3350 and x <= 4650 and y >= -18100 and y <= -12750 and z >= -200 and z <= 775
		or x >= -1350 and x <= 100 and y >= -12725 and y <= -12350 and z >= 50 and z <= 622
		then
			ids_canteen_laundry[unit_id] = true
		end

		if is_roof_stuff then
			ids_backdrop[unit_id] = true
		elseif x >= -4300 and x <= -2550 and y >= -14300 and y <= -12180 and z >= 75 and z <= 1600 then
			ids_roof_access[unit_id] = true
			if z > 674 then
				ids_backdrop[unit_id] = true
			end
		end

		if name == 'units/pd2_dlc_bph/terrain/bph_rocks/bph_rock_large_01' or name == 'units/pd2_dlc_bph/terrain/bph_rocks/bph_rock_large_02'
		or x > 0 and name == 'units/payday2/architecture/sub/sub_int_platform_catwalk_straight_01/sub_int_platform_catwalk_straight_01'
		then
			ids_backdrop[unit_id] = true
		elseif x < -1500 and y > -10900
		or name == 'units/pd2_dlc_berry/props/bry_prop_moutain_powertower/bry_prop_mountain_powertower'
		or y > -5500 and name == 'units/pd2_dlc_bph/props/bph_prop_prison_window/bph_prop_prison_window_small'
		then
			ids_shower[unit_id] = true
			ids_backdrop[unit_id] = true
		end

		return cel_original_worlddefinition_makeunit(self, data, ...)
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.backdrop.shapes[1] = {
				rotation = Rotation(0, 0, 0),
				position = Vector3(-8000, -12600, -400),
				width = 6200,
				depth = 11200,
				height = 3000,
			}
			ids_backdrop = self._definition.portal.unit_groups.backdrop.ids
			ids_backdrop[103174] = true
			ids_backdrop[500341] = true
			ids_backdrop[101837] = true
			ids_backdrop[500451] = true
			ids_backdrop[500541] = true -- shared shower
			ids_backdrop[500136] = true
			ids_backdrop[500340] = true
			ids_backdrop[500539] = true
			ids_backdrop[500440] = true
			ids_backdrop[500001] = true -- shared shower/roof_access

			self._definition.portal.unit_groups.shower = {
				ids = ids_shower,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(875, -8150, -200),
						width = 2750,
						depth = 4450,
						height = 1500,
					}
				}
			}
			self._definition.portal.unit_groups.cells = {
				ids = ids_cells,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(850, -14100, -125),
						width = 2775,
						depth = 6800,
						height = 1325,
					}
				}
			}
			self._definition.portal.unit_groups.canteen_laundry = {
				ids = ids_canteen_laundry,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3350, -16100, -125),
						width = 6000,
						depth = 3725,
						height = 800,
					}
				}
			}
			self._definition.portal.unit_groups.roof_access = {
				ids = ids_roof_access,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3875, -15800, 75),
						width = 1325,
						depth = 3600,
						height = 1200,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'brb' then

	Celer:spawn_occluder('12x6', Vector3(-25, -1200, 345), Rotation(180, -90, 180))
	Celer:spawn_occluder('12x6', Vector3(-25, -1200, 345), Rotation(180, -90, 180), true)
	Celer:spawn_occluder('12x6', Vector3(900, -1200, 345), Rotation(180, -90, 180))
	Celer:spawn_occluder('12x6', Vector3(900, -1200, 345), Rotation(180, -90, 180), true)

	Celer:spawn_occluder('16x10', Vector3(1525, -1450, 345), Rotation(0, -90, 0))
	Celer:spawn_occluder('16x10', Vector3(1525, -1450, 345), Rotation(0, -90, 0), true)
	Celer:spawn_occluder('16x16', Vector3(2325, -1300, 345), Rotation(0, -90, 0))
	Celer:spawn_occluder('16x16', Vector3(2325, -1300, 345), Rotation(0, -90, 0), true)
	Celer:spawn_occluder('6x8', Vector3(2125, 100, 345), Rotation(180, -90, 0))
	Celer:spawn_occluder('6x8', Vector3(2125, 100, 345), Rotation(180, -90, 0), true)

	Celer:spawn_occluder('32x16', Vector3(5, -360, 800), Rotation(-90, 0, 180))
	Celer:spawn_occluder('5x8', Vector3(25, -400, -450), Rotation(90, 0, 0))

	Celer:spawn_occluder('5x8', Vector3(25, -1400, 350), Rotation(90, 0, 180))
	Celer:spawn_occluder('5x8', Vector3(25, -1400, 350), Rotation(90, 0, 180), true)
	Celer:spawn_occluder('4x8', Vector3(25, -1840, 800), Rotation(90, 0, 90))
	Celer:spawn_occluder('4x8', Vector3(25, -1840, 800), Rotation(90, 0, 90), true)

	Celer:spawn_occluder('13x8', Vector3(2750, -1815, 350), Rotation(0, 0, 180))
	Celer:spawn_occluder('32x32', Vector3(2945, -1815, 2000), Rotation(0, 0, 90))
	Celer:spawn_occluder('32x32', Vector3(3225, -1835, -1600), Rotation(90, 0, 0))

	Celer:spawn_occluder('7x8', Vector3(1560, -1100, 350), Rotation(90, 0, 180))
	Celer:spawn_occluder('7x8', Vector3(1560, -1100, 350), Rotation(90, 0, 180), true)

	Celer:spawn_occluder('18x16', Vector3(1645, -3717, -1100), Rotation(-90, 0, 0))
	Celer:spawn_occluder('18x16', Vector3(1645, -3717, -1100), Rotation(-90, 0, 0), true)
	Celer:spawn_occluder('8x8', Vector3(783, -3730, 500), Rotation(0, 0, 90))
	Celer:spawn_occluder('32x32', Vector3(-1670, -1715, 1000), Rotation(180, 0, 90))
	Celer:spawn_occluder('32x32', Vector3(-1670, -1715, 1000), Rotation(180, 0, 90), true)

elseif level_id == 'chas' then

	Celer:spawn_occluder('16x14', Vector3(-3250, 2224, -400), Rotation(180, 0, -90))
	Celer:spawn_occluder('16x14', Vector3(-3250, 2224, -400), Rotation(180, 0, -90), true)

	Celer:spawn_occluder('16x14', Vector3(-4900, 5100, 275), Rotation(0, 90, 0))
	Celer:spawn_occluder('16x14', Vector3(-4900, 5100, 275), Rotation(0, 90, 0), true)

	Celer:spawn_occluder('32x32', Vector3(-3200, 2800, -1), Rotation(90, 90, 0))
	Celer:spawn_occluder('32x32', Vector3(-3200, 2800, -1), Rotation(90, 90, 0), true)

	Celer:spawn_occluder('8x8', Vector3(-3350, 2224, -400), Rotation(180, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(-3350, 2224, -400), Rotation(180, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(-3190, 1520, 200), Rotation(0, 0, 180))

	Celer:spawn_occluder('32x16', Vector3(-1170, 1125, -400), Rotation(90, 0, 0))
	Celer:spawn_occluder('32x16', Vector3(-1170, 1125, -400), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('6x8', Vector3(-3175, 3733, -100), Rotation(180, 0, 0))
	Celer:spawn_occluder('6x8', Vector3(-3175, 3733, -100), Rotation(180, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-4215, 2075, -100), Rotation(90, 0, 0), true)

	local ids_back_alley = {
		[700238] = true,
		[700240] = true,
		[700775] = true,
		[144540] = true,
		[800057] = true, -- shared road_h
		[600194] = true,
		[500443] = true,
		[500079] = true,
		[800609] = true,
		[2200001] = true, -- shared stairs/whwin/basement
		[800009] = true, -- shared road_h/road_v/back_alley/under_alley
		[800728] = true, -- shared road_h/road_v/back_alley
		[800344] = true, -- shared back_alley/basement/road_h/under_alley
	}
	local ids_basement = {
		[800050] = true,
		[600421] = true,
		[600422] = true,
		[700255] = true, -- shared basement/elevator
		[102243] = true,
		[2200001] = true, -- shared stairs/whwin/elevator
		[800025] = true, -- shared basement/stairs/under_alley
		[800373] = true, -- shared road_h
		[800374] = true,
		[103656] = true,
		[103657] = true,
		[700577] = true,
		[700578] = true,
		[800344] = true, -- shared back_alley/basement/road_h/under_alley
	}
	local ids_elevator = {
		[700255] = true,
		[2200001] = true, -- shared stairs/whwin/elevator
	}
	local ids_road_h = {
		[800343] = true,
		[800062] = true,
		[800063] = true,
		[800064] = true,
		[800065] = true,
		[103632] = true,
		[700367] = true,
		[700666] = true,
		[800345] = true,
		[700983] = true,
		[700985] = true,
		[700987] = true,
		[700989] = true,
		[700982] = true,
		[700459] = true,
		[700677] = true,
		[700678] = true,
		[700986] = true,
		[103656] = true, -- shared basement/road_h
		[103657] = true,
		[700577] = true,
		[700578] = true,
		[102160] = true, -- shared office
		[700292] = true,
		[700684] = true,
		[600381] = true, -- shared road_v
		[800006] = true,
		[103216] = true,
		[600382] = true,
		[700752] = true,
		[800139] = true,
		[700752] = true,
		[800728] = true, -- shared road_h/road_v/back_alley
		[800009] = true, -- shared road_h/road_v/back_alley/under_alley
		[800344] = true, -- shared back_alley/basement/road_h/under_alley
	}
	local ids_road_v = {
		[103004] = true,
		[800021] = true,
		[800015] = true,
		[800006] = true, -- shared road_h
		[700752] = true,
		[800139] = true,
		[700752] = true,
		[800728] = true, -- shared road_h/road_v/back_alley
		[800009] = true, -- shared road_h/road_v/back_alley/under_alley
	}
	local ids_teashop_office = {
		[103193] = true,
		[102160] = true, -- shared road_h
		[700292] = true,
		[700684] = true,
	}
	local ids_teashop_stairs = {
		[2200001] = true, -- shared stairs/whwin/elevator
		[800025] = true, -- shared basement/stairs/under_alley
	}
	local ids_teashop_store = {
		[800040] = true, -- shared road_h
		[800712] = true,
		[700975] = true,
		[700662] = true,
		[700931] = true,
		[800188] = true,
	}
	local ids_under_alley = {
		[800009] = true, -- shared road_h/road_v/back_alley/under_alley
		[800025] = true, -- shared basement/stairs/under_alley
		[800721] = true,
		[800723] = true,
		[800344] = true, -- shared back_alley/basement/road_h/under_alley
	}
	local ids_warehouse_windows = {
		[800025] = true, -- shared basement/stairs/under_alley
	}

	local crap = {
		[103582] = true,
		[101644] = true,
		[102208] = true,
		[102677] = true,
		[102249] = true,
		[102722] = true,
		[103835] = true,
		[100951] = true,
		[103217] = true,
		[100943] = true,
	}

	local side_alley = {
		[102853] = true,
		[102854] = true,
		[103145] = true,
		[103586] = true,
		[103587] = true,
		[133689] = true,
		[144370] = true,
		[600458] = true,
		[600459] = true,
		[700081] = true,
		[700218] = true,
		[700228] = true,
		[700233] = true,
		[700236] = true,
		[700369] = true,
		[700370] = true,
		[700371] = true,
		[700374] = true,
		[700375] = true,
		[700376] = true,
		[700377] = true,
		[700378] = true,
		[700420] = true,
		[700528] = true,
		[700542] = true,
		[700543] = true,
		[700781] = true,
		[700785] = true,
		[700794] = true,
		[700995] = true,
		[701260] = true,
		[701261] = true,
		[701262] = true,
		[701263] = true,
		[701267] = true,
		[701268] = true,
		[701269] = true,
		[701270] = true,
		[701271] = true,
		[701272] = true,
		[701273] = true,
		[701274] = true,
		[701275] = true,
		[701276] = true,
		[701277] = true,
		[701278] = true,
		[701279] = true,
		[701280] = true,
		[701281] = true,
		[701282] = true,
		[701283] = true,
		[701284] = true,
		[701285] = true,
		[701286] = true,
		[701288] = true,
		[701289] = true,
		[701290] = true,
		[701291] = true,
		[701292] = true,
		[701293] = true,
		[701301] = true,
		[800036] = true,
		[800037] = true,
		[800133] = true,

		[145876] = true,
		[145877] = true,
		[145879] = true,
		[700139] = true,
		[700184] = true,
		[700188] = true,
		[700189] = true,
		[700209] = true,
		[700366] = true,
		[700368] = true,
		[700379] = true,
		[700380] = true,
		[700381] = true,
		[700751] = true,
		[700789] = true,
		[700790] = true,
		[701244] = true,
		[701245] = true,
		[701246] = true,
		[701247] = true,
		[701248] = true,
		[701249] = true,
		[701250] = true,
		[701251] = true,
		[701252] = true,
		[701254] = true,
		[701255] = true,
		[701256] = true,
		[701257] = true,
		[701258] = true,
		[800189] = true,
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if crap[unit_id] then
			return
		elseif not Celer.can_be_added_to_unit_group(name)
		or unit_id == 2200001
		then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x >= -2701 and x <= -1618 and y >= 2250 and y <= 3125 and z >= -35 and z <= 300 then
			ids_teashop_office[unit_id] = true
		end

		if x >= -4225 and x <= -1586 and y >= 1000 and y <= 2225 and z >= 0 and z <= 379 then
			ids_teashop_store[unit_id] = true
			if y < 1010 then
				ids_road_h[unit_id] = true
			end
			if x < -4190 then
				ids_back_alley[unit_id] = true
				ids_warehouse_windows[unit_id] = true
			end
		end

		if not ids_teashop_store[unit_id] and not ids_warehouse_windows[unit_id] or y < 900 then
			if y < 1000 and y ~= 0
			or x > 2300 and y < 4000
			or x >= 588 and x <= 1211 and y >= 999 and y <= 2000 and z >= 0 and z <= 170
			or x < -7000
			then
				ids_road_h[unit_id] = true
				if x > -3700 and y < 0
				or x > -1050 and y < 800
				or unit_id == 700562
				or unit_id == 700574
				or unit_id == 500668
				or unit_id == 500457
				then
					ids_road_v[unit_id] = true
				end
			end
		end

		if x > 450 then
			ids_road_v[unit_id] = true
			if y > 4000 and y < 8000 and not (y >= 5148 and x < 1150)
			or unit_id == 500441
			or unit_id == 600192
			or unit_id == 700758
			or unit_id == 800012
			then
				if unit_id ~= 103216 then
					ids_back_alley[unit_id] = true
				end
			end
		elseif y > 8000 then
			ids_road_v[unit_id] = true
		end

		if x >= -4600 and x <= -1400 and y >= 2223 and y <= 5350 and z >= -401 and z <= -100 -- auction & middle
		or x >= -2797 and x <= -1688 and y >= 2664 and y <= 5350 and z >= -400 and z <= 0 and not ids_teashop_office[unit_id] -- auction
		or x >= -3800 and x <= -3639 and y >= 3512 and y <= 3726 and z >= -200 and z <= 157 -- stairs
		then
			ids_basement[unit_id] = true
			if x >= -4600 and x <= -3492 and y >= 2225 and y <= 2667 and z >= -401 and z <= -325 then
				ids_teashop_stairs[unit_id] = true
			end
		end

		if x >= -7601 and x <= -5995 and y >= 3851 and y <= 5120 and z >= -400 and z <= -102 -- vault
		or x >= -7500 and x <= -7100 and y >= 1125 and y <= 2100 and z >= -300 and z <= 0 -- camroom
		or x >= -4600 and x <= -4200 and y >= 1522 and y <= 2020 and z >= -404 and z <= -100 -- camroom2
		then
			ids_basement[unit_id] = true
		elseif x >= -7605 and x <= -4610 and y >= 1122 and y <= 4700 and z >= -602 and z <= 17 then
			ids_basement[unit_id] = true
			ids_warehouse_windows[unit_id] = true
		end

		if x >= -3800 and x <= -2825 and y >= 2250 and y <= 3946 and z >= -200 and z <= 697 then
			ids_teashop_stairs[unit_id] = true
			if x >= -3133 and x <= -2825 and y >= 3350 and y <= 3946 and z >= 400 and z <= 697 and unit_id ~= 103410 then
				ids_back_alley[unit_id] = true
			end
			if x >= -3419 and x <= -2825 and y >= 2360 and y <= 3705 and z >= 0 and z <= 300 then
				ids_teashop_store[unit_id] = true
			end
		end

		if x >= -4017 and x <= -3206 and y >= 3744 and y <= 4060 and z >= 400 and z <= 678 then
			ids_elevator[unit_id] = true
		elseif x >= -4800 and x <= -1962 and y >= 3825 and y <= 5121 and z >= 299 and z <= 678
		or x >= -1125 and x <= -818 and y >= 4458 and y <= 4636 and z >= 524 and z <= 707
		then
			ids_back_alley[unit_id] = true
			if x >= -4614 and x <= -4234 and y >= 3779 and y <= 5083 and z >= 300 and z <= 508 then
				ids_warehouse_windows[unit_id] = true
			end
		end

		if x >= -5594 and x <= -3000 and y >= 5250 and y <= 6364 and z >= -500 and z <= 284
		or x >= -5900 and x <= -4889 and y >= 2725 and y <= 4772 and z >= -600 and z <= -100
		then
			ids_under_alley[unit_id] = true
		end

		if x >= -2800 and x <= -2000 and y >= 5250 and y <= 5250 and z >= 500 and z <= 1273 then
			ids_back_alley[unit_id] = true
			ids_under_alley[unit_id] = true
		end

		if side_alley[unit_id] then
			ids_back_alley[unit_id] = true
			ids_road_h[unit_id] = true
			if unit_id == 800728
			or unit_id == 700995
			or unit_id == 144370
			or unit_id == 800036
			then
				ids_teashop_office[unit_id] = true
			end
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups = {}

			self._definition.portal.unit_groups.basement = {
				ids = ids_basement,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-7600, 1125, -400),
						width = 3000,
						depth = 4000,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4600, 1125, -400),
						width = 3200,
						depth = 4225,
						height = 400,
					}
				}
			}
			self._definition.portal.unit_groups.warehouse_windows = {
				ids = ids_warehouse_windows,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-6500, -700, -100),
						width = 4000,
						depth = 2900,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4800, 1200, 0),
						width = 600,
						depth = 2200,
						height = 600,
					}
				}
			}
			self._definition.portal.unit_groups.back_alley = {
				ids = ids_back_alley,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4800, 3350, 200),
						width = 8000,
						depth = 2025,
						height = 1200,
					}
				}
			}
			self._definition.portal.unit_groups.under_alley = {
				ids = ids_under_alley,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5800, 1125, -400),
						width = 1000,
						depth = 5300,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5700, 5125, -400),
						width = 4500,
						depth = 1300,
						height = 1500,
					}
				}
			}
			self._definition.portal.unit_groups.road_h = {
				ids = ids_road_h,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-6500, -2700, -100),
						width = 10500,
						depth = 5000,
						height = 1000,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2100, 1300, 0),
						width = 1100,
						depth = 3850,
						height = 900,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4800, 1300, 0),
						width = 700,
						depth = 3800,
						height = 900,
					}
				}
			}
			self._definition.portal.unit_groups.road_v = {
				ids = ids_road_v,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1200, -2500, -100),
						width = 10500,
						depth = 8000,
						height = 1500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2000, -500, -100),
						width = 801,
						depth = 500,
						height = 1500,
					}
				}
			}
			self._definition.portal.unit_groups.teashop_store = {
				ids = ids_teashop_store,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-6200, -2400, 0),
						width = 7000,
						depth = 5625,
						height = 800,
					}
				}
			}
			self._definition.portal.unit_groups.teashop_office = {
				ids = ids_teashop_office,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2700, -2400, 0),
						width = 2700,
						depth = 5800,
						height = 800,
					}
				}
			}
			self._definition.portal.unit_groups.teashop_stairs = {
				ids = ids_teashop_stairs,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3800, 2225, -165),
						width = 975,
						depth = 1750,
						height = 900,
					}
				}
			}
			self._definition.portal.unit_groups.elevator = {
				ids = ids_elevator,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4800, 3550, 300),
						width = 2500,
						depth = 1575,
						height = 500,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'chill_combat' then

	local cel_original_worlddefinition_serializetoscript = WorldDefinition._serialize_to_script
	function WorldDefinition:_serialize_to_script(...)
		local result = cel_original_worlddefinition_serializetoscript(self, ...)

		local instances = result.instances
		if instances then
			for i = #instances, 1, -1 do
				local instance = instances[i]
				if Celer.delete_instances[instance.name] then
					table.remove(instances, i)
				end
			end
		end

		return result
	end

	local _spare_units = {
		['units/pd2_dlc_chill/props/chl_prop_jimmy_barstool/chl_prop_jimmy_barstool_v2'] = true,
		['units/pd2_dlc_chill/props/chl_props_trophy_shelf/chl_props_trophy_shelf'] = true,
		['units/pd2_dlc_friend/props/sfm_prop_office_door_whole_black/sfm_prop_office_door_whole_black'] = true,
		['units/pd2_dlc_chill/props/chl_prop_livingroom_coffeetable_b/chl_prop_livingroom_coffeetable_b'] = true,
	}

	local function _is_ok(name, pos)
		local x, y, z = pos.x, pos.y, pos.z
		if name == 'units/dev_tools/level_tools/shadow_caster_10x10' and x - 524.999 < 0.01 and y == 2025 and z == -25 then
			-- otherwise light near Sydney's place
		elseif name == 'units/payday2/architecture/ind/ind_ext_level/ind_ext_fence_pole_2m_grey' and x == -392 and y == -386 and z == -45 then
			-- qued
		elseif not _spare_units[name] then
			if z < -10 then
				if x > 200 and x < 825 and y >= -1500 and y < -1000 then
					-- stairs to lower levels
				elseif x > 230 and x < 1600 and y > -864 and y < 0 then
					-- vault visible through floor window
				else
					return false
				end
			elseif x > 825 and x < 1202 and y > 427 and y < 775 and z > -4 and z < 291 then
				-- bathroom
				return false
			elseif x > 815 and x < 1200 and y > 1220 and y < 1575 and z > 380 and z < 689 then
				-- bathroom
				return false
			elseif x > 1200 and y > 800 then
				return false
			end
		end
		return true
	end

	function WorldDefinition:create_delayed_unit(new_unit_id)
		local spawn_data = self._delayed_units[new_unit_id]
		if spawn_data then
			local unit_data = spawn_data[1]
			if not unit_data.position or _is_ok(unit_data.name, unit_data.position) then
				PackageManager:load_delayed('unit', unit_data.name)
				self:preload_unit(unit_data.name)
				local unit = self:make_unit(unit_data, spawn_data[2])
				if unit then
					unit:set_spawn_delayed(true)
					table.insert(spawn_data[3], unit)
				end
			end
		end
	end

	function WorldDefinition:_create_statics_unit(data, offset)
		local pos = data.unit_data.position
		if not pos or _is_ok(data.unit_data.name, pos) then
			return cel_original_worlddefinition_createstaticsunit(self, data, offset)
		end
	end

elseif level_id == 'dah' then

	Celer:spawn_occluder('16x10', Vector3(-4260, -1770, 760), Rotation(-45, 90, 0))
	Celer:spawn_occluder('16x10', Vector3(-4260, -1770, 760), Rotation(-45, 90, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-3800, -2375, 760), Rotation(0, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(-3800, -2375, 760), Rotation(0, 90, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-3100, -2485, 760), Rotation(45, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(-3100, -2485, 760), Rotation(45, 90, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-2315, -1817, 760), Rotation(90, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(-2315, -1817, 760), Rotation(90, 90, 0), true)

	Celer:spawn_occluder('8x8', Vector3(-3800, -2770, -27), Rotation(143, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(-3800, -2770, -27), Rotation(143, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-4682, -4950, 285), Rotation(90, 0, 0))
	Celer:spawn_occluder('16x8', Vector3(-4682, -4950, 285), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-2073, -2120, 1200), Rotation(226, 0, 90))
	Celer:spawn_occluder('16x8', Vector3(-2073, -2120, 1200), Rotation(226, 0, 90), true)

	Celer:spawn_occluder('4x8', Vector3(-900, -1165, 750), Rotation(180, 0, 0))

	if Network:is_server() then
		function WorldDefinition:_create_statics_unit(data, ...)
			if data.unit_data.unit_id == 704208 then
				-- should have been at Vector3(-2518, -5029, 54)
				-- but it's been "fixed" by adding a new glass at the right position...
				return
			end

			return cel_original_worlddefinition_createstaticsunit(self, data, ...)
		end
	end

elseif level_id == 'des' then

	local ids_ArkeologicalArea = {}
	local ids_BioLab = {}
	local ids_ComputerRoom = {}
	local ids_Escape = {}
	local ids_LaserRoom = {}
	local ids_Hub = {}
	local ids_StartArea = {}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z
		if x == 0 and y == 0 and z == 0
		or not Celer.can_be_added_to_unit_group(name)
		or name:find('des_prop_letter_')
		then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		if x >= -2541 and x <= 2300 and y >= -12804 and y <= -5382 and z >= -1578 and z <= 343
		or x >= 219 and x <= 796 and y >= -3043 and y <= -2095 and z >= 98 and z <= 458
		then
			ids_Hub[unit_id] = true
		end

		if x >= 2605 and x <= 5188 and y >= -4600 and y <= -2477 and z >= -1000 and z <= 800 then
			ids_ArkeologicalArea[unit_id] = true
		end

		if x >= 2039 and x <= 2083 and y >= -3260 and y <= -2996 and z >= -2 and z <= 122 then
			ids_ArkeologicalArea[unit_id] = true
			ids_Hub[unit_id] = nil
		end

		if x >= 2575 and x <= 5400 and y >= -2324 and y <= -122 and z >= -1 and z <= 600
		or x >= 2259 and x <= 2412 and y >= -1632 and y <= -1615 and z >= 0 and z <= 200
		then
			ids_ComputerRoom[unit_id] = true
		end

		if x >= -2293 and x <= -2071 and y >= -447 and y <= 51 and z >= -2 and z <= 293
		or x >= -5006 and x <= -2829 and y >= -1301 and y <= 1130 and z >= -1 and z <= 800
		then
			ids_BioLab[unit_id] = true
		end

		if unit_id == 300005 then
			-- qued
		elseif x >= -2619 and x <= 550 and y >= 0 and y <= 3601 and z >= -4 and z <= 762 and not ids_BioLab[unit_id]
		or x >= -3023 and x <= 243 and y >= 3700 and y <= 6024 and z >= -2 and z <= 117 and not ids_Escape[unit_id]
		then
			ids_StartArea[unit_id] = true
		end

		if x >= -6251 and x <= -2600 and y >= -6799 and y <= -1125 and z >= -2 and z <= 855 then
			ids_LaserRoom[unit_id] = true
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			ids_StartArea = self._definition.portal.unit_groups.StartArea.ids
			ids_StartArea[300215] = true
			ids_StartArea[300124] = true -- shared Hub

			ids_Escape = self._definition.portal.unit_groups.Escape.ids

			ids_BioLab = self._definition.portal.unit_groups.BioLab.ids
			ids_BioLab[400681] = true
			ids_BioLab[402519] = true
			self._definition.portal.unit_groups.BioLab.shapes[2].position = Vector3(-847, -317, -100)

			ids_LaserRoom = self._definition.portal.unit_groups.LaserRoom.ids

			ids_Hub = self._definition.portal.unit_groups.Hub.ids
			ids_Hub[300124] = true -- shared StartArea
			ids_Hub[137056] = true
			ids_Hub[137060] = true
			ids_Hub[137061] = true

			ids_ComputerRoom = self._definition.portal.unit_groups.ComputerRoom.ids
			self._definition.portal.unit_groups.ComputerRoom.shapes = {
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(2530, -2200, -75),
					width = 2500,
					depth = 2089,
					height = 1150,
				},
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(1850, -1700, -75),
					width = 720,
					depth = 1700,
					height = 1150,
				},
				{
					rotation = Rotation(45, 0, 0),
					position = Vector3(1678.41, -996.622, -114),
					width = 1080,
					depth = 1145,
					height = 1000,
				},
			}

			ids_ArkeologicalArea = self._definition.portal.unit_groups.ArkeologicalArea.ids
			self._definition.portal.unit_groups.ArkeologicalArea.shapes = {
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(1768, -4682, -51),
					width = 785,
					depth = 2820,
					height = 1009,
				},
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(2551, -4672, -420),
					width = 3349,
					depth = 2357,
					height = 1200,
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'dinner' then

	local ids_A1_start_room = {}
	local ids_A2_start_alley = {}
	local ids_A3_start_backdrop = {}
	local ids_B1_wh_alley_entrance = {}
	local ids_B2_wh_interior = {}
	local ids_C2_wh_int = {}
	local ids_C1_f0f = {}
	local ids_C1_f0b = {}
	local ids_C1_f1 = {}
	local ids_D1_wh_alley_exit = {}
	local ids_E1_cont_area = {}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name

		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x < -6130
		or ids_A1_start_room[unit_id]
		or ids_A3_start_backdrop[unit_id]
		or name == 'units/vehicles/backdrops/backdrop_airplane_animated'
		or name == 'units/payday2/vehicles/air_vehicle_blackhawk_murky/air_vehicle_blackhawk_murky'
		or name:find('backdrop_skyscrapers')
		then
			-- qued
		else
			ids_A2_start_alley[unit_id] = true
		end

		if x > -6600 and x < -6130 or z < 200 and x < -6600 then
			if ids_A2_start_alley[unit_id] then
				ids_A2_start_alley[unit_id] = nil
				ids_A3_start_backdrop[unit_id] = true
			end
		end

		if x < -14900 and not ids_D1_wh_alley_exit[unit_id] then
			ids_E1_cont_area[unit_id] = true
		end

		if x < -14000 and name == 'units/world/street/street_lights/street_lights_night' then
			ids_A3_start_backdrop[unit_id] = true
			ids_E1_cont_area[unit_id] = true
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.A1_start_room.shapes = {
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(-5500, 2300, 1475),
					width = 2500,
					depth = 4000, 
					height = 425,
				}
			}
			ids_A1_start_room = self._definition.portal.unit_groups.A1_start_room.ids
			ids_A1_start_room[101152] = true
			ids_A1_start_room[103127] = true
			ids_A1_start_room[100291] = true
			ids_A1_start_room[100300] = true
			ids_A1_start_room[103200] = true
			ids_A1_start_room[102533] = true
			ids_A1_start_room[103025] = true

			self._definition.portal.unit_groups.A2_start_alley.shapes = {
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(-6625, 1550, 1050),
					width = 4200,
					depth = 8000,
					height = 1000,
				}
			}
			ids_A2_start_alley = self._definition.portal.unit_groups.A2_start_alley.ids

			self._definition.portal.unit_groups.A3_start_backdrop.shapes = {
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(-6625, 5675, 1025),
					width = 4200,
					depth = 2500, 
					height = 500,
				},
				{
					rotation = Rotation(0, 0, 0),
					position = Vector3(-7000, 4050, 0),
					width = 900,
					depth = 1650, 
					height = 1500,
				}
			}
			ids_A3_start_backdrop = self._definition.portal.unit_groups.A3_start_backdrop.ids
			ids_A3_start_backdrop[100021] = true
			ids_A3_start_backdrop[102985] = true
			ids_A3_start_backdrop[102073] = true -- shared A2
			ids_A3_start_backdrop[102766] = true
			ids_A3_start_backdrop[102814] = true
			ids_A3_start_backdrop[102781] = true
			ids_A3_start_backdrop[102226] = true

			ids_B1_wh_alley_entrance = self._definition.portal.unit_groups.B1_wh_alley_entrance.ids
			ids_B1_wh_alley_entrance[102781] = true

			ids_B2_wh_interior = self._definition.portal.unit_groups.B2_wh_interior.ids
			ids_B2_wh_interior[102086] = true
			ids_B2_wh_interior[100819] = true

			local C1_wh_int = self._definition.portal.unit_groups.C1_wh_int
			C1_wh_int.shapes[2].depth = C1_wh_int.shapes[2].depth + C1_wh_int.shapes[6].width
			table.remove(C1_wh_int.shapes, 6)

			C1_wh_int.shapes[4].height = 400
			table.remove(C1_wh_int.shapes, 5)

			C1_wh_int.shapes[2].position = C1_wh_int.shapes[1].position
			C1_wh_int.shapes[2].width = C1_wh_int.shapes[2].width + C1_wh_int.shapes[1].width
			table.remove(C1_wh_int.shapes, 1)

			ids_C2_wh_int = self._definition.portal.unit_groups.C2_wh_int.ids
			ids_C2_wh_int[102876] = true

			self._definition.portal.unit_groups.C3_wh_exterior = nil

			ids_D1_wh_alley_exit = self._definition.portal.unit_groups.D1_wh_alley_exit.ids

			table.remove(self._definition.portal.unit_groups.E1_cont_area.shapes, 2)
			self._definition.portal.unit_groups.E1_cont_area.shapes[1].position = Vector3(-15950 + 1500, 4815, -98)
			self._definition.portal.unit_groups.E1_cont_area.shapes[1].depth = 9000 + 1500
			ids_E1_cont_area = self._definition.portal.unit_groups.E1_cont_area.ids
			ids_E1_cont_area[101468] = true
			ids_E1_cont_area[100516] = true
			ids_E1_cont_area[103244] = true
			ids_E1_cont_area[102645] = true
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'fex' then

	Celer:spawn_occluder('32x16', Vector3(-890, 3475, 490), Rotation(-90, 90, 0)) -- upstairs
	Celer:spawn_occluder('32x16', Vector3(-890, 3475, 490), Rotation(-90, 90, 0), true)
	Celer:spawn_occluder('16x16', Vector3(-890, 3775, 490), Rotation(180, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(-890, 3775, 490), Rotation(180, 90, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-1575, 1625, -500), Rotation(0, 0, -90)) -- living room
	Celer:spawn_occluder('16x8', Vector3(-1575, 1625, -500), Rotation(0, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(-575, 1640, -1100), Rotation(0, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(-575, 1640, -1100), Rotation(0, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(-915, 2800, -1000), Rotation(90, 0, -90))

	Celer:spawn_occluder('7x8', Vector3(-1325, 3460, 800), Rotation(0, 0, 180))
	Celer:spawn_occluder('7x8', Vector3(-1325, 3460, 800), Rotation(0, 0, 180), true)

	Celer:spawn_occluder('16x10', Vector3(2150, 265, -800), Rotation(0, 0, -90)) -- garage

	Celer:spawn_occluder('16x8', Vector3(1830, 2950, -800), Rotation(90, 0, -90)) -- dining
	Celer:spawn_occluder('16x8', Vector3(1830, 2950, -800), Rotation(90, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(1830, 2425, -800), Rotation(90, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(1830, 2425, -800), Rotation(90, 0, -90), true)

	Celer:spawn_occluder('7x8', Vector3(1425, 1635, 400), Rotation(180, 0, 90))
	Celer:spawn_occluder('7x8', Vector3(1425, 1635, 400), Rotation(180, 0, 90), true)

	Celer:spawn_occluder('9x8', Vector3(910, 1945, 500), Rotation(-90, 0, 180))
	Celer:spawn_occluder('12x6', Vector3(905, 3045, 575), Rotation(-90, 0, 180))

	Celer:spawn_occluder('5x8', Vector3(2130, 1210, 400), Rotation(0, 0, 180)) -- kitchen
	Celer:spawn_occluder('5x8', Vector3(2130, 1210, 400), Rotation(0, 0, 180), true)

	Celer:spawn_occluder('16x8', Vector3(-900, 1300, -800), Rotation(90, 0, -90)) -- entrance
	Celer:spawn_occluder('16x8', Vector3(-1250, 585, -800), Rotation(0, 0, -90))
	Celer:spawn_occluder('9x8', Vector3(740, 575, 500), Rotation(-90, 0, 180))

	Celer:spawn_occluder('16x8', Vector3(-915, 4000, -1000), Rotation(90, 0, -90)) -- sanctum
	Celer:spawn_occluder('16x8', Vector3(50, 4060, -800), Rotation(0, 0, 0))
	Celer:spawn_occluder('16x8', Vector3(-1800, 4060, -800), Rotation(0, 0, 0))

	local junk = {
		[100166] = true,
		[103122] = true,
		[103130] = true,
		[103281] = true,
		[104102] = true,
		[800059] = true,
		[103223] = true,
		[103224] = true,
		[103234] = true,
		[103236] = true,
	}
	local ids_cellar = {
		[800002] = true,
		[800088] = true,
		[800089] = true,
	}
	local ids_front = {
		[154589] = true,
		[700554] = true,
		[700709] = true,
		[700290] = true,
		[700289] = true,
		[700320] = true,
		[700292] = true,
		[700708] = true,
		[700202] = true,
		[700321] = true,
		[700201] = true,
		[800199] = true,
		[157601] = true,
		[800001] = true,
		[500435] = true,
		[800048] = true,
		[800082] = true,
		[700555] = true,
		[700556] = true,
		[700557] = true,
		[700776] = true,
		[147014] = true,
	}
	local excluded_front = {
		[800200] = true,
		[103431] = true,
		[800003] = true,
		[800005] = true,
		[800043] = true,
		[800081] = true,
		[156994] = true,
		[800020] = true,
	}
	local ids_back = {
		[700138] = true,
		[900794] = true,
		[400313] = true,
		[900793] = true,
		[700137] = true,
		[900792] = true,
		[700327] = true,
		[700136] = true,
		[700455] = true,
		[400317] = true,
		[400318] = true,
		[700376] = true,
		[700377] = true,
		[700773] = true,
		[700763] = true,
		[700366] = true,
		[700223] = true,
		[700428] = true,
		[901135] = true,
		[700094] = true,
		[700646] = true,
		[901129] = true,
		[901130] = true,
		[901131] = true,
		[800060] = true,
		[800061] = true,
		[900437] = true,
		[900438] = true,
		[700026] = true,
		[700027] = true,
		[700028] = true,
		[700029] = true,
		[700030] = true,
		[700031] = true,
		[102688] = true,
		[800025] = true, -- shared sanctum
		[135351] = true,
	}
	local excluded_back = {
		[800007] = true,
		[800018] = true,
		[134978] = true,
		[400306] = true,
		[400304] = true,
	}
	local ids_sanctum = {
		[400605] = true,
		[900323] = true,
		[900379] = true,
		[900428] = true,
		[400306] = true,
		[400304] = true,
		[800025] = true, -- shared back
		[135351] = true,
		[800010] = true, -- shared right
	}
	local excluded_sanctum = {
		[103421] = true,
	}
	local ids_upstairs = {
		[800044] = true,
		[800058] = true,
	}
	local excluded_upstairs = {
		[900028] = true,
		[900067] = true,
	}
	local ids_right = {
		[900802] = true,
		[700340] = true,
		[900799] = true,
		[900800] = true,
		[700500] = true,
		[700102] = true,
		[700472] = true,
		[400324] = true,
		[900802] = true,
		[400307] = true,
		[400311] = true,
		[900795] = true, -- shared front
		[900796] = true,
		[900797] = true,
		[300139] = true,
		[800082] = true,
		[103468] = true,
		[103475] = true,
		[103472] = true,
		[500314] = true, -- shared sanctum
		[500315] = true,
		[800010] = true,
		[154422] = true,
		[159172] = true,
		[700566] = true,
		[900135] = true,
		[900103] = true,
		[900945] = true,
	}
	local excluded_right = {
		[800007] = true,
		[800011] = true,
		[800015] = true,
		[700340] = true,
		[700340] = true,
		[700341] = true,
		[700603] = true,
		[700607] = true,
		[700308] = true,
		[700309] = true,
		[700297] = true,
		[134978] = true,
		[700772] = true,
		[700477] = true,
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		if junk[unit_id] then
			return
		end

		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if excluded_upstairs[unit_id] then
			-- qued
		elseif x >= -7000 and x <= -2440 and y >= 2000 and y <= 5500 and z >= -400 and z <= 900
		or x >= -7000 and x <= -2440 and y >= -1250 and y <= 5500 and z >= 450 and z <= 900
		or x >= -2800 and x <= -925 and y >= 1225 and y <= 4275 and z >= 490 and z <= 900
		or x >= -1325 and x <= 1325 and y >= 1225 and y <= 1625 and z >= 490 and z <= 900
		or x >= -2500 and x <= -1079 and y >= 4300 and y <= 5700 and z >= 490 and z <= 800
		then
			ids_upstairs[unit_id] = true
		end

		if x >= -2900 and x <= -2400 and y >= 700 and y <= 1100 then
			-- later
		elseif x >= -5200 and x <= -2450 and y >= -1000 and y <= 2000 and z >= -1600 and z <= 350
		or x >= -5200 and x <= -2450 and y >= 1500 and y <= 5600 and z >= -1600 and z <= -200
		then
			ids_cellar[unit_id] = true
		end

		if excluded_sanctum[unit_id] then
			-- qued
		elseif x >= -280 and x <= 240 and y >= 1950 and y <= 2400 then
			-- qued
		elseif x >= -2425 and x <= 2825 and y >= 1200 and y <= 5500 and z >= -401 and z <= -20
		or x >= 910 and x <= 2900 and y >= 4200 and y <= 5500 and z >= -100 and z <= 502
		then
			ids_sanctum[unit_id] = true
		end

		if excluded_front[unit_id]
		or x >= 1158 and x <= 1876 and y >= 281 and y <= 864 and z >= 0 and z <= 203 -- kitchen
		or x >= 764 and x <= 949 and y >= 772 and y <= 1066 and z >= 0 and z <= 251 -- couloir kitchen/central
		or x >= -2500 and x <= -2245 and y >= 900 and y <= 1073 and z >= 0 and z <= 142 -- side cellar
		or x >= -2025 and x <= -1925 and y >= 600 and y <= 1025 and z >= 0 and z <= 199 -- room near cellar
		or x >= -910 and x <= -680 and y >= 242 and y <= 1228 and z >= 0 and z <= 341 -- couloir cellar/central
		or x >= -475 and x <= -217 and y >= 178 and y <= 838 and z >= -1 and z <= 400 -- central
		or x >= 600 and x <= 1150 and y >= -26 and y <= 616 and z >= 0 and z <= 430 -- central
		or x >= 261 and x <= 401 and y >= 877 and y <= 1081 and z >= 0 and z <= 86 -- central
		or x >= 14 and x <= 160 and y >= 559 and y <= 716 and z >= -3 and z <= 12 -- central christmas tree
		or x == 0 and y == 0 and z == 0
		then
			-- qued
		elseif y < 1200 and not ids_cellar[unit_id] then
			ids_front[unit_id] = true
		end

		if x >= -2900 and x <= -2400 and y >= 700 and y <= 1100 then
			ids_cellar[unit_id] = true
			ids_front[unit_id] = true
		end

		if excluded_right[unit_id]
		or x >= 1719 and x <= 1766 and y >= 1765 and y <= 1935 and z >= 0 and z <= 1
		or x >= 1072 and x <= 1206 and y >= 1682 and y <= 1710 and z >= 0 and z <= 171
		or x >= 1789 and x <= 1825 and y >= 2771 and y <= 2902 and z >= 0 and z <= 186
		then
			-- qued
		elseif x >= 1217 and x <= 1268 and y >= 800 and y <= 953 and z >= 0 and z <= 159 -- kitchen 1
		or x >= 1954 and x <= 2386 and y >= 282 and y <= 919 and z >= 0 and z <= 1 -- kitchen 2
		or x >= 2585 and x <= 2937 and y >= 664 and y <= 1582 and z >= 0 and z <= 193 -- between bedroom & garage
		or x >= 2474 and x <= 3379 and y >= 1689 and y <= 2767 and z >= 0 and z <= 407 -- bedroom
		or x >= 2998 and x <= 3378 and y >= 2675 and y <= 2938 and z >= 0 and z <= 332 -- restroom
		or x >= 925 and x <= 3275 and y >= 1650 and y <= 3878 and z >= -9 and z <= 340 -- dining room + 2 back rooms
		then
			ids_right[unit_id] = true
		end

		if x >= 3268 and x <= 5118 and y >= 5843 and y <= 7896 and z >= -1564 and z <= -912 then -- boat coast
			ids_right[unit_id] = true
			ids_upstairs[unit_id] = true
			ids_sanctum[unit_id] = true
		end

		if excluded_back[unit_id]
		or ids_right[unit_id]
		or ids_sanctum[unit_id]
		or x >= -1135 and x <= -928 and y >= 3350 and y <= 3775 and z >= 0 and z <= 350
		then
			-- qued
		elseif y >= 1650 and z >= -1 and not ids_right[unit_id] and not ids_upstairs[unit_id] then
			ids_back[unit_id] = true
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups = {}

			self._definition.portal.unit_groups.upstairs = {
				ids = ids_upstairs,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2800, 125, 300),
						width = 4125,
						depth = 5600,
						height = 800,
					}
				}
			}
			self._definition.portal.unit_groups.cellar = {
				ids = ids_cellar,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5200, -1000, -1600),
						width = 2750,
						depth = 6600,
						height = 1950,
					}
				}
			}
			self._definition.portal.unit_groups.sanctum = {
				ids = ids_sanctum,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2425, 3400, -300),
						width = 1500,
						depth = 2100,
						height = 550,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-924, 1200, -400),
						width = 1851,
						depth = 4300,
						height = 400,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(926, 3900, -300),
						width = 1900,
						depth = 1600,
						height = 800,
					}
				}
			}
			self._definition.portal.unit_groups.front = {
				ids = ids_front,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2475, -4400, -200),
						width = 6000,
						depth = 6040,
						height = 1100,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2875, 300, -200),
						width = 400,
						depth = 800,
						height = 550,
					}
				}
			}
			self._definition.portal.unit_groups.back = {
				ids = ids_back,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2800, 100, 0),
						width = 6200,
						depth = 5600,
						height = 900,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-575, 1200, -400),
						width = 1150,
						depth = 1200,
						height = 400,
					}
				}
			}
			self._definition.portal.unit_groups.right = {
				ids = ids_right,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-900, 100, 0),
						width = 4300,
						depth = 5700,
						height = 900,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'firestarter_1' then

	function WorldDefinition:_create_statics_unit(data, offset)
		if data.unit_data.unit_id == 102765 then
			return -- no spot => no glow
		elseif data.unit_data.unit_id == 103980 then
			data.unit_data.position = Vector3(1449, 5790, 789)
		end

		local unit = cel_original_worlddefinition_createstaticsunit(self, data, offset)

		if not unit then
			-- qued
		elseif data.unit_data.unit_id == 103986 then
			unit:set_position(Vector3(-5650.42, 5586.73, 2088.54))
			unit:material(Idstring('light_cone')):set_variable(Idstring('intensity'), 0.1)
		end

		return unit
	end

elseif level_id == 'friend' then

	Celer:spawn_occluder('5x8', Vector3(-2925, -2750, -325), Rotation(90, 0, 0))
	Celer:spawn_occluder('5x8', Vector3(-2925, -2750, -325), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('5x8', Vector3(-2925, -3450, -325), Rotation(90, 0, 0))
	Celer:spawn_occluder('5x8', Vector3(-2925, -3450, -325), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(840, -2775, 450), Rotation(-90, 0, 180))
	Celer:spawn_occluder('16x16', Vector3(840, -2775, 450), Rotation(-90, 0, 180), true)

	Celer:spawn_occluder('12x12', Vector3(840, -3470, 500), Rotation(-90, 0, 90))
	Celer:spawn_occluder('12x12', Vector3(840, -3470, 500), Rotation(-90, 0, 90), true)

	Celer:spawn_occluder('12x12', Vector3(-2930, 2150, 350), Rotation(-90, 0, 90))
	Celer:spawn_occluder('12x12', Vector3(-2930, 2150, 350), Rotation(-90, 0, 90), true)

	Celer:spawn_occluder('12x12', Vector3(-1500, -3425, 375), Rotation(-90, 90, 0))
	Celer:spawn_occluder('12x12', Vector3(-1500, -3425, 375), Rotation(-90, 90, 0), true)

	Celer:spawn_occluder('16x16', Vector3(1400, -250, 445), Rotation(-90, 0, 90))
	Celer:spawn_occluder('16x16', Vector3(1400, -250, 445), Rotation(-90, 0, 90), true)

	Celer:spawn_occluder('16x15', Vector3(0, -1900, 1000), Rotation(0, 0, 90))
	Celer:spawn_occluder('16x15', Vector3(0, -1900, 1000), Rotation(0, 0, 90), true)

	Celer:spawn_occluder('7x8', Vector3(25, -248, 0), Rotation(0, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(25, -248, 0), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-2478, -5640, 250), Rotation(0, 0, 90))
	Celer:spawn_occluder('16x16', Vector3(-200, -6210, 170), Rotation(0, 0, 90))
	Celer:spawn_occluder('32x32', Vector3(900, -6210, 170), Rotation(0, 0, 90))
	Celer:spawn_occluder('32x32', Vector3(-3910, -1867, 62), Rotation(90, 0, 90))
	Celer:spawn_occluder('18x16', Vector3(-3910, -4200, -1538), Rotation(90, 0, 0))

	Celer:spawn_occluder('4x8', Vector3(2920, 2750, 200), Rotation(0, 0, 90))
	Celer:spawn_occluder('24x16', Vector3(4080, 2650, 70), Rotation(90, 0, 180))
	Celer:spawn_occluder('16x16', Vector3(3300, 5419, 144), Rotation(-90, 0, 180))

elseif level_id == 'hox_1' then

	local ids_start = {}
	local ids_garage = {}
	local ids_garage_02 = {}
	local ids_road_h0 = {
		[100036] = true,
		[101052] = true,
		[102164] = true,
	}
	local ids_road_h1 = {
		[101026] = true,
		[102016] = true,
		[103007] = true,
		[100160] = true, -- shared h0
		[100600] = true,
		[100959] = true,
		[100963] = true,
		[103303] = true,
		[103306] = true,
		[103309] = true,
		[103312] = true,
	}
	local ids_road_h2 = {
		[103512] = true, -- shared garage
		[101013] = true,
		[300020] = true,
		[300021] = true,
		[300095] = true,
		[300765] = true,
		[300767] = true,
		[300768] = true,
		[800000] = true,
		[800001] = true,
	}
	local ids_road_v0 = {}
	local ids_road_v1 = {}
	local ids_road_v2 = {
		[103512] = true, -- shared garage
		[101013] = true,
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if unit_id == 102482
		or ids_garage[unit_id]
		or ids_garage_02[unit_id]
		or not Celer.can_be_added_to_unit_group(name)
		then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x >= -7050 and x <= -6650 and y >= -8870 and y <= -8424 and z >= -2000 and z <= -2000 then
			ids_start[unit_id] = true
		end

		if unit_id == 100057 or unit_id == 100118 then
			-- qued
		elseif x > 7400 and y > 2650 and z < 2100 then -- garage land
			ids_garage[unit_id] = true
		else
			local extra = 2000
			if y >= -8900 - extra and y <= -4100 + extra and x < 3000 then
				ids_road_h0[unit_id] = true
			end
			if x >= -6600 - extra and x <= -1800 + extra then
				ids_road_v0[unit_id] = true
			end
			if y >= -4100 - extra and y <= 700 + extra then
				ids_road_h1[unit_id] = true
			end
			if x >= -1800 - extra and x <= 3000 + extra then
				ids_road_v1[unit_id] = true
			end
			if y >= 700 - extra and y <= 5500 + extra then
				ids_road_h2[unit_id] = true
			end
			if x >= 3000 - extra and x <= 7800 + extra then
				ids_road_v2[unit_id] = true
			end
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			ids_garage = self._definition.portal.unit_groups.garage.ids
			ids_garage_02 = self._definition.portal.unit_groups.garage_02.ids

			ids_start = self._definition.portal.unit_groups.start.ids
			ids_start[100321] = true
			ids_start[101452] = true
			ids_start[103488] = true
			ids_start[103489] = true
			ids_start[103490] = true
			ids_start[103491] = true
			ids_start[103492] = true
			ids_start[103493] = true
			ids_start[103494] = true
			ids_start[103495] = true
			ids_start[103496] = true

			local block_len = 4800
			local portal_sz = block_len + 700
			local x = -4200
			local y = -6500
			for i = 0, 2 do
				self._definition.portal.unit_groups['road_h' .. i] = {
					shapes = {
						{
							rotation = Rotation(0, 0, 0),
							position = Vector3(-9900, y + (i * block_len) - (portal_sz/2), -2400), 
							width = 19500,
							depth = portal_sz,
							height = 1500,
						}
					}
				}
				self._definition.portal.unit_groups['road_v' .. i] = {
					shapes = {
						{
							rotation = Rotation(0, 0, 0),
							position = Vector3(x + (i * block_len) - (portal_sz/2), -9000, -2400), 
							width = portal_sz,
							depth = 19500,
							height = 1500,
						}
					}
				}
			end
			self._definition.portal.unit_groups.road_h0.ids = ids_road_h0
			self._definition.portal.unit_groups.road_h1.ids = ids_road_h1
			self._definition.portal.unit_groups.road_h2.ids = ids_road_h2
			self._definition.portal.unit_groups.road_v0.ids = ids_road_v0
			self._definition.portal.unit_groups.road_v1.ids = ids_road_v1
			self._definition.portal.unit_groups.road_v2.ids = ids_road_v2

			self._definition.portal.unit_groups.road_h2.shapes[1].depth = 4450
			self._definition.portal.unit_groups.road_v2.shapes[1].depth = 19500 - 5600
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'hox_2' then

	local ids_garage = {}
	local ids_trees = {}
	local ids_evidence = {}
	local ids_it = {}
	local ids_armory0 = {}
	local ids_front = {
		[300417] = true,
		[300944] = true,
		[301158] = true,
		[301852] = true,
		[301854] = true,
		[301855] = true,
		[301856] = true,
		[301857] = true,
		[300702] = true,
		[101781] = true,
		[300453] = true,
		[300673] = true,
		[300675] = true,
		[300676] = true,
		[300689] = true,
		[300695] = true,
		[136394] = true, -- shared IT
		[300574] = true,
		[136840] = true, -- shared armory0
		[136843] = true,
		[136849] = true,
		[136850] = true,
		[136863] = true,
		[136907] = true,
	}
	local ids_infirmary = {
		[300699] = true, -- shared back
		[101580] = true,
		[101835] = true,
		[300823] = true,
		[300002] = true,
		[300433] = true,
		[130322] = true,
	}
	local ids_back = {
		[300693] = true,
		[133350] = true,
		[135690] = true,
		[300003] = true,
		[300981] = true,
		[134341] = true,
		[301620] = true,
		[301570] = true,
		[301841] = true,
		[300002] = true, -- shared evidence/level2
		[300699] = true, -- shared infirmary
		[300418] = true,
		[301645] = true,
		[300562] = true,
		[101580] = true,
		[101835] = true,
		[300823] = true,
		[132525] = true, -- shared level2
	}
	local excluded_back = {
		[101705] = true,
		[130121] = true,
		[300242] = true,
		[300244] = true,
		[300248] = true,
		[300315] = true,
		[300628] = true,
		[300629] = true,
		[300634] = true,
		[300650] = true,
		[300662] = true,
		[301873] = true,
		[301874] = true,
		[301875] = true,
	}
	local ids_level2 = {
		[300505] = true,
		[300507] = true,
		[300512] = true,
		[300514] = true,
		[300520] = true,
		[301469] = true,
		[301510] = true,
		[301240] = true,
		[301242] = true,
		[100231] = true,
		[300091] = true, -- shared back
		[300002] = true, -- shared back/evidence
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x >= -2024 and x <= -1225 and y >= 799 and y <= 1825 and z >= -100 and z <= 670 and unit_id ~= 300410 then
			ids_evidence[unit_id] = true
		end

		if x >= -225 and x <= 800 and y >= 1249 and y <= 2400 and z >= -500 and z <= -175 then
			ids_it[unit_id] = true
		end

		if x >= -2380 and x <= -1425 and y >= 1697 and y <= 2825 and z >= -500 and z <= -125 then
			ids_armory0[unit_id] = true
		end

		if x >= 1025 and x <= 1600 and y >= 3250 and y <= 3600 and z >= 300 and z <= 483
		or x >= -1275 and x <= 800 and y >= 2500 and y <= 3750 and z >= -557 and z <= -215 and not ids_it[unit_id]
		or x >= -801 and x <= 1153 and y >= 2450 and y <= 4086 and z >= -150 and z <= -150 -- lvl0 ceiling
		or x >= -1275 and x <= 800 and y >= 2450 and y <= 3625 and z >= -500 and z <= -100 and unit_id ~= 300584 -- elevators
		then
			ids_front[unit_id] = true
		end

		if x >= -801 and x <= 1153 and y >= 2450 and y <= 4086 and z >= 250 and z <= 250 then -- lvl1 ceiling
			ids_front[unit_id] = true
			if x < -790 then
				ids_evidence[unit_id] = true
			end
		end

		if x >= -801 and x <= 1153 and y >= 2450 and y <= 4086 and z >= 650 and z <= 650 -- lvl2 ceiling
		or name == 'units/pd2_dlc2/csgo_models/props_unique/skylight_broken_large'
		then
			ids_front[unit_id] = true
			ids_level2[unit_id] = true
		end

		if x >= -1734 and x <= 1425 and y >= 4125 and y <= 6350 and z >= -501 and z <= -184 then -- lvl0, near entrance
			if not ids_garage[unit_id] and not ids_trees[unit_id] then
				ids_front[unit_id] = true
			end
		end

		if x >= -1200 and x <= 1980 and y >= 3250 and y <= 6250 and z >= -100 and z <= 275 then -- director's office
			ids_front[unit_id] = true
			if x < -790 then
				ids_evidence[unit_id] = true
			end
		end
		if x >= -1600 and x <= 825 and y >= 4475 and y <= 6075 and z >= 225 and z <= 650 then -- above director's office
			ids_front[unit_id] = true
		end

		if x >= -1200 and x <= -850 and y >= 1252 and y <= 1925 and z >= -100 and z <= 152 then -- to evidence
			ids_front[unit_id] = true
			ids_evidence[unit_id] = true
		end

		if excluded_back[unit_id] then
			-- qued
		elseif x >= -800 and x <= 2025 and y >= -800 and y <= 2000 and z >= -125 and z <= 152 then -- main room
			if name:find('units/pd2_dlc2/architecture/gov_d_ext/') then
				-- qued
			else
				ids_back[unit_id] = true
			end
		elseif x >= -750 and x <= 950 and y >= 2400 and y <= 2425 and z > -100 and z <= 100 -- fb corridor
		or x >= -801 and x <= 1200 and y >= -400 and y <= 1600 and z >= 625 and z <= 675 -- ceiling lvl2
		or x >= 2600 and x <= 3050 and y >= -350 and y <= 1025 and z >= -590 and z <= -590 -- tables outside
		or x >= 799 and x <= 2000 and y >= -787 and y <= 1225 and z >= 250 and z <= 250 -- ceiling lvl1
		or x >= -625 and x <= 100 and y >= 2388 and y <= 2425 and z >= 299 and z <= 500 -- thing middle lvl2
		or x >= -326 and x <= 338 and y >= -776 and y <= -375 and z >= 240 and z <= 477 -- stairs, end
		or x >= -1625 and x <= -1200 and y >= -1575 and y <= 25 and z >= 300 and z <= 675 and not ids_level2[unit_id] -- stuff lvl2, end/right
		or x >= 1225 and x <= 1622 and y >= -1126 and y <= 993 and z >= 300 and z <= 300 and not ids_level2[unit_id] -- furniture lvl2, left
		or y <= 3134 and (name:find('str_veg_park_tree_americanelm') or name:find('stn_prop_courtyard_plantsection_'))
		then
			ids_back[unit_id] = true
		end

		if ids_back[unit_id] then
			if x >= 1600 and z <= 300 then
				ids_infirmary[unit_id] = true
			end
		end

		if x >= -112 and x <= 1275 and y >= -50 and y <= 1250 and z >= 275 and z <= 500 then
			ids_back[unit_id] = true
			ids_level2[unit_id] = true
		end

		if x >= 1204 and x <= 2025 and y >= 2451 and y <= 3200 and z >= -100 and z <= 150
		or unit_id == 101581 -- left corridor stuff
		or unit_id == 101582
		or unit_id == 101583
		or unit_id == 101584
		or unit_id == 101585
		or unit_id == 101586
		or unit_id == 300938
		or unit_id == 301170
		or unit_id == 301172
		or unit_id == 301174
		or unit_id == 301741
		or unit_id == 301848
		or unit_id == 301869
		then
			ids_infirmary[unit_id] = true
			if unit_id ~= 301645 and unit_id ~= 300562 and unit_id ~= 300418 then
				ids_back[unit_id] = nil
			end
		end

		if x >= 455 and x <= 1075 and y >= 1626 and y <= 1975 and z >= 300 and z <= 625
		or x >= -1023 and x <= -800 and y >= -750 and y <= -200 and z >= 300 and z <= 500
		or x >= 1733 and x <= 1830 and y >= 688 and y <= 2126 and z >= 300 and z <= 300
		or x >= 1728 and x <= 1830 and y >= -709 and y <= 5 and z >= 300 and z <= 300
		then
			ids_level2[unit_id] = true
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.garage_hider = nil
			self._definition.portal.unit_groups.building = nil

			self._definition.portal.unit_groups.front = {
				ids = ids_front,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2850, 2025, -900),
						width = 5250,
						depth = 4700, 
						height = 1900,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1250, 825, -100),
						width = 420,
						depth = 1200, 
						height = 750,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(425, 1625, -100),
						width = 1600,
						depth = 400, 
						height = 750,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1225, 650, 300),
						width = 800,
						depth = 1800, 
						height = 500,
					}, 
					{ -- IT
						rotation = Rotation(0, 0, 0),
						position = Vector3(-800, 1250, -500),
						width = 1600,
						depth = 1200, 
						height = 350,
					}
				}
			}
			self._definition.portal.unit_groups.back = {
				ids = ids_back,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2850, -1000, -100),
						width = 5250,
						depth = 3860, 
						height = 1000,
					}
				}
			}
			self._definition.portal.unit_groups.infirmary = {
				ids = ids_infirmary,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1200, -775, -100),
						width = 1100,
						depth = 3975, 
						height = 375,
					}
				}
			}
			self._definition.portal.unit_groups.level2 = {
				ids = ids_level2,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2850, -1000, 235),
						width = 5250,
						depth = 5500, 
						height = 500,
					}
				}
			}
			self._definition.portal.unit_groups.armory0 = {
				ids = ids_armory0,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2400, 1650, -500),
						width = 3200,
						depth = 1500, 
						height = 350,
					}
				}
			}
			self._definition.portal.unit_groups.it = {
				ids = ids_it,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-800, 1250, -500),
						width = 1600,
						depth = 1200, 
						height = 350,
					}
				}
			}

			table.remove(self._definition.portal.unit_groups.archive.shapes, 3) -- ?!
			self._definition.portal.unit_groups.archive.shapes[2].position = Vector3(1425, 4550, -900)
			self._definition.portal.unit_groups.archive.shapes[2].height = 750

			local evidence = self._definition.portal.unit_groups.evidence
			evidence.shapes[1].position = Vector3(-2825, 25 - 750, -100)
			evidence.shapes[1].depth = 2000 + 750
			evidence.shapes[2].width = 560
			evidence.shapes[2].height = 325
			ids_evidence = evidence.ids
			ids_evidence[301558] = true
			ids_evidence[301594] = true
			ids_evidence[301369] = true
			ids_evidence[102269] = true
			ids_evidence[300536] = true -- shared front
			ids_evidence[300869] = true -- shared back
			ids_evidence[300002] = true -- shared back/level2

			ids_garage = self._definition.portal.unit_groups.garage.ids
			ids_garage[101598] = true
			ids_garage[100166] = true
			ids_garage[100168] = true
			ids_garage[100169] = true
			ids_garage[100170] = true
			ids_garage[100171] = true
			ids_garage[100172] = true
			ids_garage[100178] = true
			ids_garage[100179] = true
			ids_garage[100181] = true
			ids_garage[100182] = true
			ids_garage[100184] = true
			ids_garage[100192] = true
			ids_garage[100193] = true
			ids_garage[100194] = true
			ids_garage[100200] = true
			ids_garage[100224] = true
			ids_garage[100227] = true
			ids_garage[100236] = true
			ids_garage[100240] = true
			ids_garage[100161] = true
			ids_garage[100201] = true
			ids_garage[100203] = true
			ids_garage[100204] = true
			ids_garage[100205] = true
			ids_garage[100206] = true
			ids_garage[101598] = true
			ids_garage[102005] = true
			ids_garage[101735] = true
			ids_garage[101993] = true
			ids_garage[100166] = true

			ids_trees = self._definition.portal.unit_groups.trees.ids
			ids_trees[102205] = true
			ids_trees[102206] = true
			ids_trees[102207] = true
			ids_trees[102208] = true
			ids_trees[102209] = true
			ids_trees[300007] = true
			ids_trees[300088] = true
			ids_trees[300921] = true
			ids_trees[300926] = true
			ids_trees[300987] = true
			ids_trees[300988] = true
			ids_trees[300989] = true
			ids_trees[300990] = true
			ids_trees[301290] = true
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'kenaz' or level_id == 'skm_cas' then

	Celer:spawn_occluder('16x16', Vector3(-1800, -2500, -300), Rotation(-90, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(-1800, -1600, -200), Rotation(-90, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(-1800, -750, -150), Rotation(-90, 0, 0))

	Celer:spawn_occluder('16x16', Vector3(-1605, -4600, 250), Rotation(-90, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(-1800, -300, 300), Rotation(-90, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(-1800, -300, 300), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('12x8', Vector3(1840, -3550, -200), Rotation(90, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(1840, -2250, -200), Rotation(90, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(1840, -1450, -200), Rotation(90, 0, 0))

	Celer:spawn_occluder('4x8', Vector3(-180, -1200, 200), Rotation(0, 0, 90))

	Celer:spawn_occluder('16x10', Vector3(2000, -4700, 580), Rotation(90, -90, 0))
	Celer:spawn_occluder('16x10', Vector3(2000, -3100, 500), Rotation(90, -90, 0))
	Celer:spawn_occluder('16x10', Vector3(2000, -1500, 580), Rotation(90, -90, 0))
	Celer:spawn_occluder('16x8', Vector3(-960, -4700, 580), Rotation(90, -90, 0))
	Celer:spawn_occluder('16x8', Vector3(-960, -3100, 500), Rotation(90, -90, 0))
	Celer:spawn_occluder('16x8', Vector3(-960, -1500, 580), Rotation(90, -90, 0))

	local ids_front = {
		[162376] = true,
		[162379] = true,
		[162196] = true,
		[162636] = true,
		[162429] = true,
		[162573] = true,
		[162034] = true, -- shared balcon_right
		[162381] = true, -- shared pool_01
		[162634] = true,
	}
	local ids_vault = {
		[103065] = true,
		[103066] = true,
		[144139] = true,
		[144332] = true,
		[144333] = true,
		[143943] = true, -- shared security/second_part
		[144336] = true,
		[144183] = true,
		[144187] = true,
		[144031] = true,
		[102940] = true, -- shared security
		[144341] = true,
		[144369] = true,
		[100553] = true,
	}
	local ids_security = {
		[102940] = true, -- shared vault
		[100553] = true,
		[143943] = true, -- shared vault/second_part
		[144336] = true,
		[144183] = true,
		[144187] = true,
		[144031] = true,
		[144105] = true, -- shared second_part
		[144340] = true,
	}
	local ids_level1 = {
		[102255] = true,
		[102256] = true,
		[102407] = true,
		[102409] = true,
		[146119] = true,
		[146919] = true,
		[148890] = true,
		[148903] = true,
		[149010] = true,
		[149130] = true,
		[149250] = true,
		[149261] = true,
		[149381] = true,
		[149501] = true,
		[149731] = true,
		[149851] = true,
		[149864] = true,
		[149971] = true,
		[149984] = true,
		[150091] = true,
		[150101] = true,
		[150221] = true,
		[150341] = true,
		[150345] = true,
		[150461] = true,
		[150691] = true,
		[150811] = true,
		[150824] = true,
		[150931] = true,
		[151051] = true,
		[151170] = true,
		[151290] = true,
		[151303] = true,
		[151410] = true,
		[152303] = true,
		[152410] = true,
		[154001] = true,
		[154121] = true,
		[154244] = true,
		[154351] = true,
		[154361] = true,
		[154365] = true,
		[155801] = true,
		[155805] = true,
		[156201] = true,
		[156321] = true,
		[156334] = true,
		[156441] = true,
		[156560] = true,
		[156680] = true,
		[156800] = true,
		[156920] = true,
		[156931] = true,
		[156935] = true,
		[157051] = true,
		[158351] = true,
		[158471] = true,
		[158811] = true,
		[159411] = true,
		[160836] = true,
		[160955] = true,
		[161075] = true,
		[161088] = true,
		[161195] = true,
		[162211] = true,
		[167028] = true,
		[167135] = true,
		[300078] = true,
		[300081] = true,
		[300088] = true,
		[300090] = true,
		[300092] = true,
		[300094] = true,
		[300113] = true,
		[300120] = true,
		[300125] = true,
		[300628] = true,
		[300658] = true,
		[300662] = true,
		[300673] = true,
		[300786] = true,
		[300857] = true,
		[300907] = true,
		[300910] = true,
		[300911] = true,
		[300922] = true,
		[300923] = true,
		[301016] = true,
		[301050] = true,
		[301059] = true,
		[301279] = true,
		[301353] = true,
		[301357] = true,
		[301412] = true,
		[101059] = true, -- shared hotel_end
		[101060] = true,
	}
	local ids_pool_01 = {}
	local ids_second_part = {}
	local ids_balcon_right = {}
	local ids_hotel_start = {}
	local ids_hotel_right = {}
	local ids_hotel_left = {}
	local ids_hotel_end = {}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x >= 99 and x <= 692 and y >= -3177 and y <= -3006 and z >= -500 and z <= -414 then
			-- qued
		elseif y <= -1800 and z <= -600
		or z <= -200 and name == 'units/payday2/props/com_prop_election_lamp_ceiling_small/com_prop_election_lamp_ceiling_small'
		or y <= -2940 and z <= -200
		then
			if y >= -4500 and unit_id ~= 175561 then
				ids_vault[unit_id] = true
			end
		end

		if x >= -1150 and x <= 1200 and y >= 25 and y <= 1163 and z >= -900 and z <= 525 and not ids_security[unit_id]
		then
			ids_security[unit_id] = true
			ids_second_part[unit_id] = nil
		end

		if x >= -263 and x <= 58 and y >= -611 and y <= 140 and z >= -900 and z <= -499 and not ids_security[unit_id] then
			ids_vault[unit_id] = true
			ids_security[unit_id] = true
			ids_second_part[unit_id] = nil
		end

		if y < -8800 and name:find('cas_prop_gambling_showgirl_spotlight') then
			ids_front[unit_id] = true
			ids_pool_01[unit_id] = true
		elseif x >= -3422 and x <= 3250 and y >= -15000 and y <= -9000 and z >= -700 and z <= -288
		or y < -8900 and name == 'units/pd2_dlc_casino/props/cas_prop_lobby_rose_tree/cas_prop_lobby_rose_tree'
		or y < -8570 and x > 1200 and name == 'units/pd2_dlc2/csgo_models/props_foliage/urban_hedge_256_128_high'
		then
			ids_front[unit_id] = true
		elseif x >= -4075 and x <= 3600 and y >= -12170 and y <= -8790 and z >= 0 and z <= 250
		or x >= -2288 and x <= -638 and y >= -8283 and y <= -7380 and z >= -25 and z <= 0
		or x >= -199 and x <= 198 and y >= -8166 and y <= -7783 and z >= 802 and z <= 803
		or x >= 824 and x <= 824 and y >= -8963 and y <= -8324 and z >= 320 and z <= 321
		or y < -5770 and name:find('tree') and unit_id ~= 166048
		then
			ids_front[unit_id] = true
			ids_pool_01[unit_id] = true
		end

		if unit_id == 300053 -- reception
		or x >= -400 and x <= 400 and y >= -5013 and y <= -4975 and z >= -2 and z <= 247
		or name == 'units/pd2_dlc_casino/architecture/cas_int_gambling_pillar_5m_v3/cas_int_gambling_pillar_5m_v3'
		or name == 'units/pd2_dlc_casino/props/cas_prop_lobby_couch_round/cas_prop_lobby_couch_round'
		then
			-- qued
		elseif x >= -1080 and x <= 1080 and y >= -6057 and y <= -4717 and z >= -6 and z <= 400 and unit_id ~= 162299
		then
			ids_front[unit_id] = true
			ids_pool_01[unit_id] = true
		end

		if x > 3500 and name:find('sfm_veg_tree_') and not ids_front[unit_id] and not ids_balcon_right[unit_id] then
			ids_front[unit_id] = true
			ids_balcon_right[unit_id] = true
		end

		if x >= -3000 and x <= -1787 and y >= -2600 and y <= -1016 and z >= 600 and z <= 750 then
			ids_pool_01[unit_id] = true
			if y > -1975 then
				ids_level1[unit_id] = true
			end
		end

		if x >= -2225 and x <= -1800 and y >= -1275 and y <= -775 and z >= 0 and z <= 0
		or x >= -2625 and x <= -2425 and y >= -1775 and y <= -1775 and z >= 0 and z <= 0
		then
			ids_pool_01[unit_id] = true
		end

		if unit_id == 146919 or unit_id == 301126 or unit_id == 301127 then
			-- qued
		elseif x >= -1577 and x <= 2250 and y >= -7175 and y <= -4780 and z >= 500 and z <= 1200 then
			ids_hotel_start[unit_id] = true
		end

		if unit_id == 146119 or unit_id == 300946 or unit_id == 301094 or unit_id == 300951 or unit_id == 300285
		or name:find('cas_int_gambling_ceiling_2x2m')
		then
			-- qued
		elseif x >= -2225 and x <= 1650 and y >= 400 and y <= 2800 and z >= 600 and z <= 1200 then
			ids_hotel_end[unit_id] = true
			ids_second_part[unit_id] = nil
		end

		if unit_id == 146119 then
			-- qued
		elseif x >= -1577 and x <= -1174 and y >= -6600 and y <= -5057 and z >= 698 and z <= 966
		or x >= -1586 and x <= -1122 and y >= 745 and y <= 2459 and z >= 598 and z <= 920
		then
			ids_hotel_left[unit_id] = true
			ids_second_part[unit_id] = nil
		end

		if x >= 1225 and x <= 1636 and y >= -6834 and y <= -5120 and z >= 698 and z <= 984
		or x >= 1224 and x <= 1627 and y >= 682 and y <= 2459 and z >= 598 and z <= 883
		then
			ids_hotel_right[unit_id] = true
			ids_second_part[unit_id] = nil
		end

		if y > 1100 and z < 500 then
			ids_second_part[unit_id] = true
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.front_01 = nil
			self._definition.portal.unit_groups.top_01 = nil

			local second_part = self._definition.portal.unit_groups.second_part
			second_part.shapes[2].position = Vector3(7425, 0, -3175)
			second_part.shapes[2].width = 10000
			second_part.shapes[2].depth = 20400
			second_part.shapes[2].height = 3675

			table.remove(second_part.shapes, 4)
			table.remove(second_part.shapes, 3)
			table.remove(second_part.shapes, 1)

			ids_second_part = second_part.ids
			ids_second_part[142331] = nil
			ids_second_part[159891] = nil
			ids_second_part[159725] = nil
			ids_second_part[159944] = nil
			ids_second_part[159974] = nil
			ids_second_part[159873] = nil
			ids_second_part[157923] = true
			ids_second_part[157925] = true

			local pool_01 = self._definition.portal.unit_groups.pool_01
			pool_01.shapes[1].position = Vector3(-1800, -775, -250)
			pool_01.shapes[1].width = 4200
			pool_01.shapes[1].height = 1300
			pool_01.shapes[3].height = 500
			mvector3.set_y(pool_01.shapes[7].position, -7375)
			mvector3.set_z(pool_01.shapes[7].position, 0)
			pool_01.shapes[7].height = 388
			pool_01.shapes[7].depth = 3625

			table.remove(pool_01.shapes, 6)
			table.remove(pool_01.shapes, 5)
			table.remove(pool_01.shapes, 2)

			ids_pool_01 = pool_01.ids
			ids_pool_01[103083] = true
			ids_pool_01[162258] = true
			ids_pool_01[162594] = true
			ids_pool_01[103081] = true
			ids_pool_01[165565] = true
			ids_pool_01[162080] = true -- shared front
			ids_pool_01[162381] = true
			ids_pool_01[162634] = true

			ids_balcon_right = self._definition.portal.unit_groups.balcon_right.ids
			ids_balcon_right[162096] = true
			ids_balcon_right[162408] = true
			ids_balcon_right[103089] = true
			ids_balcon_right[102402] = true
			ids_balcon_right[103100] = true
			ids_balcon_right[102403] = true
			ids_balcon_right[162252] = true
			ids_balcon_right[103091] = true
			ids_balcon_right[163183] = true
			ids_balcon_right[163184] = true
			ids_balcon_right[163186] = true
			ids_balcon_right[162589] = true
			ids_balcon_right[102399] = true
			ids_balcon_right[102400] = true
			ids_balcon_right[163214] = true
			ids_balcon_right[163187] = true
			ids_balcon_right[162034] = true -- shared front
			ids_balcon_right[162300] = true

			self._definition.portal.unit_groups.hotel_start.ids = ids_hotel_start

			self._definition.portal.unit_groups.front = {
				ids = ids_front,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3500, -12500, -400), 
						width = 7000,
						depth = 7500,
						height = 900,
					}
				}
			}
			self._definition.portal.unit_groups.vault = {
				ids = ids_vault,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-450, -4300, -900), 
						width = 1500,
						depth = 4850,
						height = 700,
					}
				}
			}
			self._definition.portal.unit_groups.level1 = {
				ids = ids_level1,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3200, -7180, 315), 
						width = 7000,
						depth = 10000,
						height = 1100,
					}
				}
			}
			self._definition.portal.unit_groups.security = {
				ids = ids_security,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1150, 0, -500), 
						width = 2350,
						depth = 1800,
						height = 1025,
					},
					{
						position = Vector3(-150, 1800, 100),
						rotation = Rotation(0, 0, 0),
						width = 375,
						depth = 1200,
						height = 400,
					}
				}
			}
			self._definition.portal.unit_groups.hotel_01_left = nil
			self._definition.portal.unit_groups.hotel_02_left = nil
			self._definition.portal.unit_groups.hotel_left = {
				ids = ids_hotel_left,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1800, -6910, 500), 
						width = 1250,
						depth = 9450,
						height = 600,
					}
				}
			}
			self._definition.portal.unit_groups.hotel_01_right = nil
			self._definition.portal.unit_groups.hotel_02_right = nil
			self._definition.portal.unit_groups.hotel_right = {
				ids = ids_hotel_right,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(650, -6910, 500), 
						width = 1200,
						depth = 9450,
						height = 600,
					}
				}
			}
			self._definition.portal.unit_groups.hotel_end = {
				ids = ids_hotel_end,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2200, 400, 600), 
						width = 3820,
						depth = 2400,
						height = 500,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'mex' then

	Celer:spawn_occluder('14x8', Vector3(3525, 3400, 490), Rotation(-90, 90, 0)) -- arizona
	Celer:spawn_occluder('14x8', Vector3(3525, 3400, 490), Rotation(-90, 90, 0), true)

	Celer:spawn_occluder('12x8', Vector3(2000, 3025, 490), Rotation(-90, 90, 0))
	Celer:spawn_occluder('12x8', Vector3(2000, 3025, 490), Rotation(-90, 90, 0), true)

	Celer:spawn_occluder('16x14', Vector3(3000, 3400, 490), Rotation(-90, 90, 0))
	Celer:spawn_occluder('16x14', Vector3(3000, 3400, 490), Rotation(-90, 90, 0), true)

	Celer:spawn_occluder('16x8', Vector3(1575, 1420, 300), Rotation(0, 0, 0))
	Celer:spawn_occluder('16x8', Vector3(1575, 1420, 300), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('4x8', Vector3(2300, 1420, 50), Rotation(0, 0, 0))
	Celer:spawn_occluder('4x8', Vector3(2300, 1420, 50), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('4x8', Vector3(1575, 1420, 400), Rotation(0, 0, 90))
	Celer:spawn_occluder('4x8', Vector3(1575, 1420, 400), Rotation(0, 0, 90), true)

	Celer:spawn_occluder('7x8', Vector3(3135, 695, -200), Rotation(-90, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(3135, 695, -200), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('7x8', Vector3(3135, 800, -200), Rotation(90, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(3135, 800, -200), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('10x8', Vector3(3135, 1675, -300), Rotation(90, 0, 0))
	Celer:spawn_occluder('10x8', Vector3(3135, 1675, -300), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('11x8', Vector3(1565, 695, -200), Rotation(-90, 0, 0))
	Celer:spawn_occluder('11x8', Vector3(1565, 695, -200), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('4x8', Vector3(1860, 1810, 50), Rotation(0, 0, 0))
	Celer:spawn_occluder('4x8', Vector3(1860, 1810, 50), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('7x8', Vector3(1565, 1550, -200), Rotation(-90, 0, 0))
	Celer:spawn_occluder('15x8', Vector3(3300, 3415, -300), Rotation(180, 0, 0))
	Celer:spawn_occluder('10x8', Vector3(960, 2750, 0), Rotation(-90, 0, 0))

	Celer:spawn_occluder('16x8', Vector3(-775, -10450, -2350), Rotation(0, 0, 90)) -- mexico

	Celer:spawn_occluder('7x8', Vector3(0, -9860, -3300), Rotation(0, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(0, -9860, -3300), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('6x8', Vector3(1025, -9860, -3300), Rotation(0, 0, 0))
	Celer:spawn_occluder('6x8', Vector3(1025, -9860, -3300), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('6x8', Vector3(2625, -7188, -3415), Rotation(0, 0, 0))
	Celer:spawn_occluder('6x8', Vector3(2625, -7188, -3415), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('8x8', Vector3(5110, -9935, -3400), Rotation(16, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(5110, -9935, -3400), Rotation(16, 0, 0), true)

	Celer:spawn_occluder('8x8', Vector3(813, -12275, -3400), Rotation(-90, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(813, -12275, -3400), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('16x10', Vector3(1880, -12075, -2500), Rotation(-90, 0, 90))
	Celer:spawn_occluder('16x10', Vector3(1880, -12075, -2500), Rotation(-90, 0, 90), true)

	Celer:spawn_occluder('8x8', Vector3(1880, -13775, -3300), Rotation(-90, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(1880, -13775, -3300), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('11x8', Vector3(3490, -12075, -3500), Rotation(-90, 0, 0))
	Celer:spawn_occluder('11x8', Vector3(3490, -12075, -3500), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('8x8', Vector3(3090, -13175, -3600), Rotation(-90, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(3090, -13175, -3600), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('12x4', Vector3(-375, -12275, -2900), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('6x8', Vector3(2875, -12075, -3500), Rotation(0, 0, 0))
	Celer:spawn_occluder('6x8', Vector3(2875, -12075, -3500), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('4x8', Vector3(1460, -13060, -2700), Rotation(0, 0, 90))
	Celer:spawn_occluder('4x8', Vector3(1460, -13060, -2700), Rotation(0, 0, 90), true)

	Celer:spawn_occluder('6x8', Vector3(750, -13060, -3500), Rotation(0, 0, 0))
	Celer:spawn_occluder('6x8', Vector3(750, -13060, -3500), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(1875, -12075, -3300), Rotation(0, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(1875, -12075, -3300), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(1645, -6500, -3300), Rotation(90, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(1645, -6500, -3300), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('6x8', Vector3(1645, -7445, -3400), Rotation(90, 0, 0))
	Celer:spawn_occluder('6x8', Vector3(1645, -7445, -3400), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(1645, -8350, -3200), Rotation(90, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(1645, -8350, -3200), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(1645, -9050, -3200), Rotation(90, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(1645, -9050, -3200), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('12x4', Vector3(1645, -7375, -2800), Rotation(90, 0, 0))
	Celer:spawn_occluder('12x4', Vector3(1645, -7375, -2800), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('8x8', Vector3(325, -7240, -3500), Rotation(0, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(325, -7240, -3500), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(1645, -6040, -3600), Rotation(90, 0, 0))
	Celer:spawn_occluder('16x16', Vector3(1645, -6040, -3600), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(1620, -7225, -2700), Rotation(90, 90, 0))
	Celer:spawn_occluder('16x16', Vector3(1620, -7225, -2700), Rotation(90, 90, 0), true)

	Celer:spawn_occluder('16x10', Vector3(-975, -9145, -2700), Rotation(0, 0, 90))
	Celer:spawn_occluder('16x10', Vector3(-975, -9145, -2700), Rotation(0, 0, 90), true)

	for y = -8875, -5600, 1600 do
		Celer:spawn_occluder('16x8', Vector3(25, y, -2715), Rotation(-90, 90, 0))
		Celer:spawn_occluder('16x8', Vector3(25, y, -2715), Rotation(-90, 90, 0), true)
	end

	Celer:spawn_occluder('7x8', Vector3(-150, -8860, -3000), Rotation(180, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(-150, -8860, -3000), Rotation(180, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(415, -7225, -2800), Rotation(0, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(415, -7225, -2800), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(990, -7225, -2800), Rotation(0, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(990, -7225, -2800), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(1700, -7215, -3200), Rotation(0, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(1700, -7215, -3200), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(3230, -7175, -3225), Rotation(90, 0, 0))
	Celer:spawn_occluder('3x6', Vector3(3230, -7175, -3225), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('3x6', Vector3(2275, -7790, -2845), Rotation(0, 0, 90)) -- trucks
	Celer:spawn_occluder('3x6', Vector3(2275, -8010, -2845), Rotation(0, 0, 90), true)

	Celer:spawn_occluder('3x6', Vector3(2275, -9165, -2845), Rotation(0, 0, 90))
	Celer:spawn_occluder('3x6', Vector3(2275, -9385, -2845), Rotation(0, 0, 90), true)

	Celer:spawn_occluder('3x6', Vector3(1472, -10971, -2850), Rotation(45, 0, 90))
	Celer:spawn_occluder('3x6', Vector3(1595, -11075, -2850), Rotation(45, 0, 90), true)

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			local small_storehouse_ids = self._definition.portal.unit_groups.mex_small_warehouse.ids
			small_storehouse_ids[700228] = true
			small_storehouse_ids[700231] = true
			small_storehouse_ids[700236] = true
			small_storehouse_ids[703150] = true
			small_storehouse_ids[138882] = true
			small_storehouse_ids[700248] = true
			small_storehouse_ids[702896] = true
			small_storehouse_ids[702937] = true
			small_storehouse_ids[702977] = true
			small_storehouse_ids[703225] = true
			small_storehouse_ids[703259] = true
			small_storehouse_ids[703286] = true
			small_storehouse_ids[703389] = true
			small_storehouse_ids[703423] = true
			small_storehouse_ids[703443] = true
			small_storehouse_ids[900811] = true
			small_storehouse_ids[901119] = true
			small_storehouse_ids[901123] = true
			small_storehouse_ids[901153] = true

			local big_storehouse_ids = self._definition.portal.unit_groups.mex_big_storehouse.ids
			big_storehouse_ids[701274] = true
			big_storehouse_ids[700917] = true
			big_storehouse_ids[700915] = true
			big_storehouse_ids[700924] = true
			big_storehouse_ids[700930] = true
			big_storehouse_ids[700936] = true
			big_storehouse_ids[701052] = true
			big_storehouse_ids[700687] = true
			big_storehouse_ids[700761] = true
			big_storehouse_ids[701032] = true
			big_storehouse_ids[701034] = true
			big_storehouse_ids[701700] = true -- barrels
			big_storehouse_ids[701732] = true
			big_storehouse_ids[701751] = true
			big_storehouse_ids[701809] = true
			big_storehouse_ids[701843] = true
			big_storehouse_ids[701866] = true
			big_storehouse_ids[701906] = true
			big_storehouse_ids[701922] = true
			big_storehouse_ids[701955] = true
			big_storehouse_ids[701672] = true
			big_storehouse_ids[701777] = true
			big_storehouse_ids[701906] = true
			big_storehouse_ids[701269] = true -- mountain_stairs
			big_storehouse_ids[701345] = true
			big_storehouse_ids[701346] = true
			big_storehouse_ids[701350] = true
			big_storehouse_ids[701354] = true
			big_storehouse_ids[701360] = true
			big_storehouse_ids[701366] = true
			big_storehouse_ids[701378] = true
			big_storehouse_ids[701388] = true
			big_storehouse_ids[701461] = true
			big_storehouse_ids[701503] = true
			big_storehouse_ids[701589] = true
			big_storehouse_ids[701632] = true
			big_storehouse_ids[701704] = true
			big_storehouse_ids[701746] = true
			big_storehouse_ids[701862] = true
			big_storehouse_ids[700163] = true -- stuff upstairs
			big_storehouse_ids[701175] = true
			big_storehouse_ids[700591] = true
			big_storehouse_ids[700597] = true
			big_storehouse_ids[700686] = true
			big_storehouse_ids[700688] = true
			big_storehouse_ids[700689] = true
			big_storehouse_ids[700692] = true
			big_storehouse_ids[700697] = true
			big_storehouse_ids[700701] = true
			big_storehouse_ids[700706] = true
			big_storehouse_ids[700709] = true
			big_storehouse_ids[700710] = true
			big_storehouse_ids[700711] = true
			big_storehouse_ids[700830] = true
			big_storehouse_ids[700832] = true
			big_storehouse_ids[700833] = true
			big_storehouse_ids[700840] = true
			big_storehouse_ids[700845] = true
			big_storehouse_ids[700848] = true
			big_storehouse_ids[700854] = true
			big_storehouse_ids[700857] = true
			big_storehouse_ids[700860] = true
			big_storehouse_ids[700861] = true
			big_storehouse_ids[700870] = true
			big_storehouse_ids[700912] = true
			big_storehouse_ids[700913] = true
			big_storehouse_ids[700927] = true
			big_storehouse_ids[700928] = true
			big_storehouse_ids[700934] = true
			big_storehouse_ids[700955] = true
			big_storehouse_ids[700971] = true
			big_storehouse_ids[700972] = true
			big_storehouse_ids[700998] = true
			big_storehouse_ids[700999] = true
			big_storehouse_ids[701013] = true
			big_storehouse_ids[701014] = true
			big_storehouse_ids[701016] = true
			big_storehouse_ids[701018] = true
			big_storehouse_ids[701019] = true
			big_storehouse_ids[701022] = true
			big_storehouse_ids[701023] = true
			big_storehouse_ids[701025] = true
			big_storehouse_ids[701149] = true
			big_storehouse_ids[701160] = true
			big_storehouse_ids[701174] = true
			big_storehouse_ids[701178] = true
			big_storehouse_ids[701183] = true
			big_storehouse_ids[701193] = true
			big_storehouse_ids[701229] = true
			big_storehouse_ids[901307] = true
			big_storehouse_ids[700953] = true
			big_storehouse_ids[701027] = true
			big_storehouse_ids[700776] = true
			big_storehouse_ids[700777] = true
			big_storehouse_ids[700783] = true
			big_storehouse_ids[700793] = true
			big_storehouse_ids[700798] = true
			big_storehouse_ids[700809] = true
			big_storehouse_ids[700814] = true
			big_storehouse_ids[700815] = true
			big_storehouse_ids[700828] = true
			big_storehouse_ids[701046] = true
			big_storehouse_ids[701056] = true
			big_storehouse_ids[701071] = true
			big_storehouse_ids[701158] = true
			big_storehouse_ids[701243] = true
			big_storehouse_ids[701254] = true
			big_storehouse_ids[900656] = true
			big_storehouse_ids[900658] = true
			big_storehouse_ids[700499] = true
			big_storehouse_ids[800080] = true
			big_storehouse_ids[800431] = true
			big_storehouse_ids[800432] = true
			big_storehouse_ids[900060] = true
			big_storehouse_ids[900069] = true
			big_storehouse_ids[900225] = true
			big_storehouse_ids[900226] = true
			big_storehouse_ids[900227] = true
			big_storehouse_ids[900228] = true
			big_storehouse_ids[900232] = true
			big_storehouse_ids[900334] = true
			big_storehouse_ids[900348] = true
			big_storehouse_ids[900374] = true
			big_storehouse_ids[702708] = true
			big_storehouse_ids[702889] = true
			big_storehouse_ids[800551] = true
			big_storehouse_ids[900097] = true
			big_storehouse_ids[900110] = true
			big_storehouse_ids[900111] = true
			big_storehouse_ids[702789] = true
			big_storehouse_ids[702913] = true
			big_storehouse_ids[702953] = true
			big_storehouse_ids[702965] = true
			big_storehouse_ids[703037] = true
			big_storehouse_ids[703057] = true
			big_storehouse_ids[703104] = true
			big_storehouse_ids[703120] = true
			big_storehouse_ids[703187] = true
			big_storehouse_ids[703263] = true
			big_storehouse_ids[703350] = true
			big_storehouse_ids[703398] = true
			big_storehouse_ids[703471] = true
			big_storehouse_ids[900337] = true
			big_storehouse_ids[400110] = true
			big_storehouse_ids[400115] = true
			big_storehouse_ids[400117] = true
			big_storehouse_ids[900041] = true
			big_storehouse_ids[900071] = true
			big_storehouse_ids[900358] = true
			big_storehouse_ids[900361] = true
			big_storehouse_ids[150082] = true
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'moon' then

	Celer:spawn_occluder('24x16', Vector3(-360, -360, 385), Rotation(180, -90, 0))
	Celer:spawn_occluder('16x8', Vector3(-360, -1960, 385), Rotation(180, -90, 0))

	Celer:spawn_occluder('16x16', Vector3(10, -630, 385), Rotation(45 - 90, -90, 0))
	Celer:spawn_occluder('4x8', Vector3(40, 600, 385), Rotation(45 - 90, -90, 0))
	Celer:spawn_occluder('18x16', Vector3(-610, 30, 385), Rotation(45, -90, 0))

	Celer:spawn_occluder('16x8', Vector3(-600, -500, 385), Rotation(90, -90, 0))
	Celer:spawn_occluder('16x8', Vector3(-622, -1373, 385), Rotation(0, -90, 0))
	Celer:spawn_occluder('16x16', Vector3(870, -2745, 385), Rotation(0, -90, 0))

	Celer:spawn_occluder('32x32', Vector3(-500, 500, 905), Rotation(90, -90, 0))
	Celer:spawn_occluder('32x32', Vector3(-700, -3200, 905), Rotation(90, -90, 0))
	Celer:spawn_occluder('16x10', Vector3(500, -500, 905), Rotation(-90, -90, 0))
	Celer:spawn_occluder('32x32', Vector3(0, -700, 905), Rotation(180, -90, 0))
	Celer:spawn_occluder('5x8', Vector3(-50, -1135, 1000), Rotation(90, 90, 0))

	Celer:spawn_occluder('32x32', Vector3(-370, 1380, 905), Rotation(-45, -90, 0))

	local ids_roof = {
		[101490] = true,
		[101492] = true,
		[101498] = true,
		[101705] = true,
		[101732] = true,
		[101759] = true,
		[101828] = true,
		[102126] = true,
		[102131] = true,
		[102134] = true,
		[102141] = true,
		[102148] = true,
		[102150] = true,
		[102151] = true,
		[102161] = true,
		[102183] = true,
		[102185] = true,
		[102187] = true,
		[102188] = true,
		[102192] = true,
		[102207] = true,
		[102227] = true,
		[102239] = true,
		[102240] = true,
		[102245] = true,
		[102248] = true,
		[102249] = true,
		[102251] = true,
		[102253] = true,
		[102256] = true,
		[102260] = true,
		[102263] = true,
		[102274] = true,
		[102867] = true,
		[104346] = true,
		[104347] = true,
		[104348] = true,
		[104349] = true,
		[104350] = true,
		[104351] = true,
		[104352] = true,
		[104353] = true,
		[104355] = true,
		[104358] = true,
		[104361] = true,
		[104362] = true,
		[100246] = true, -- shared boiler
		[104373] = true,
		[104375] = true,
		[104380] = true,
		[104376] = true,
		[104379] = true,
	}
	local ids_stairs_boiler = {
		[100246] = true,
		[101890] = true,
		[102266] = true,
		[104372] = true,
		[104374] = true,
	}
	local excluded_stairs_boiler = {
		[100608] = true,
		[103119] = true,
	}
	local ids_pear_store = {
		[100397] = true,
		[101607] = true,
		[101621] = true,
		[101655] = true,
		[101659] = true,
		[101661] = true,
		[101663] = true,
		[101664] = true,
		[101670] = true,
		[102526] = true,
		[102789] = true,
		[103275] = true,
		[103859] = true,
		[103886] = true,
		[103888] = true,
		[103908] = true,
		[103977] = true,
		[103987] = true,
		[103990] = true,
		[103993] = true,
		[104360] = true,
		[104396] = true,
		[104398] = true,
		[104408] = true,
		[104409] = true,
		[104410] = true,
	}
	local ids_roof_and_2nd_floor = {
		[101618] = true,
		[101574] = true,
		[101995] = true,
		[101993] = true,
		[102005] = true,
		[103322] = true,
		[103345] = true,
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if excluded_stairs_boiler[unit_id] then
			-- qued
		elseif x >= -450 and x <= 1365 and y >= 2050 and z >= 400 and z <= 1400 then
			ids_stairs_boiler[unit_id] = true
		end

		if x >= -2644 and x <= -2374 and y >= -1591 and y <= -891 and z >= 0 and z <= 304
		or x >= -3151 and x <= -2625 and y >= -2400 and y <= -1702 and z >= -37 and z <= 300
		then
			ids_pear_store[unit_id] = true
		end

		if x >= -1232 and x <= -460 and y >= -1252 and y <= -438 and z >= 400 and z <= 481 -- wine
		or x >= -591 and x <= -398 and y >= -1317 and y <= -1127 and z >= 400 and z <= 493
		or x >= -1533 and x <= -1208 and y >= -456 and y <= -456 and z >= 399 and z <= 400
		or x > -2130 and x < -715 and y > -2130 and y < -630 and z > 389 and z < 481 and not name:find('_shelf_') and not name:find('stack') and not name:find('christmas_gift')
		or x >= -1161 and x <= -5 and y >= 875 and y <= 2233 and z >= 386 and z <= 620 -- guffi's
		or x >= -640 and x <= 194 and y >= 1526 and y <= 2500 and z >= 400 and z <= 800
		or x >= 962 and x <= 2576 and y >= -1650 and y <= -953 and z >= 399 and z <= 1350 and unit_id ~= 103158 and unit_id ~= 100627 -- storage stairs
		or x >= 921 and x <= 2721 and y >= -932 and y <= 500 and z >= 399 and z <= 800 -- shoes
		or name:find('com_prop_store_shoe_sign')
		then
			ids_roof_and_2nd_floor[unit_id] = true
		end

		return cel_original_worlddefinition_makeunit(self, data, ...)
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.mall_int_01 = nil

			self._definition.portal.unit_groups.roof = {
				ids = ids_roof,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3200, -3200, 800),
						width = 5800,
						depth = 6200,
						height = 1000,
					}
				}
			}
			self._definition.portal.unit_groups.stairs_boiler = {
				ids = ids_stairs_boiler,
				shapes = {
					{
						rotation = Rotation(45, 0, 0),
						position = Vector3(0, 1410, 400),
						width = 1150,
						depth = 1500,
						height = 900,
					}
				}
			}
			self._definition.portal.unit_groups.pear_store = {
				ids = ids_pear_store,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3750, -2400, 0),
						width = 2600,
						depth = 3660,
						height = 475,
					}
				}
			}
			self._definition.portal.unit_groups.roof_and_2nd_floor = {
				ids = ids_roof_and_2nd_floor,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3900, -3800, 250),
						width = 6700,
						depth = 6800,
						height = 1550,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'mus' or level_id == 'skm_mus' then

	Celer:spawn_occluder('8x8', Vector3(2800, 600, -300), Rotation(-90, 0, 90))

	for _, xy in ipairs({
		{ -1100, -550 }, -- right
		{ -1100, -2150 },
		{ 500, -550 },
		{ 500, -2150 },
		{ 2100, -550 },
		{ 75, 1050 }, -- center
		{ 1675, 1050 },
		{ -1100, 2550 }, -- left
		{ 500, 2550 },
		{ -1100, 4150 },
	}) do
		Celer:spawn_occluder('16x16', Vector3(xy[1], xy[2], -390), Rotation(-90, 90, 0))
		Celer:spawn_occluder('16x16', Vector3(xy[1], xy[2], -350), Rotation(-90, 90, 0), true)
	end
	Celer:spawn_occluder('16x8', Vector3(-1100, 3350, -390), Rotation(0, 90, 0))
	Celer:spawn_occluder('16x8', Vector3(-1100, 3350, -350), Rotation(0, 90, 0), true)

	Celer:spawn_occluder('12x8', Vector3(-250, 2700, -400), Rotation(0, 0, 0)) -- red
	Celer:spawn_occluder('7x8', Vector3(1000, 2225, -400), Rotation(-90, 0, 0))

	Celer:spawn_occluder('7x8', Vector3(1000, -1675, -400), Rotation(-90, 0, 0)) -- blue
	Celer:spawn_occluder('8x8', Vector3(-150, -2300, 400), Rotation(180, 0, 90))
	Celer:spawn_occluder('8x8', Vector3(1000, -2300, 400), Rotation(180, 0, 90))
	Celer:spawn_occluder('7x8', Vector3(-1050, -2385, -400), Rotation(90, 0, 0))
	Celer:spawn_occluder('4x8', Vector3(-1050, -1120, -400), Rotation(90, 0, -90))

	Celer:spawn_occluder('10x8', Vector3(-1500, -2400, -400), Rotation(90, 0, 0))
	Celer:spawn_occluder('10x8', Vector3(-1500, -2400, -400), Rotation(90, 0, 0), true) -- jfr

	Celer:spawn_occluder('16x8', Vector3(1410, 1100, 700), Rotation(90, 0, 90)) -- ground
	Celer:spawn_occluder('16x8', Vector3(1410, 1100, 700), Rotation(90, 0, 90), true)
	Celer:spawn_occluder('16x8', Vector3(1410, 660, 700), Rotation(90, 0, 90))
	Celer:spawn_occluder('16x8', Vector3(1410, 660, 700), Rotation(90, 0, 90), true)

	Celer:spawn_occluder('16x8', Vector3(1410, -1150, 700), Rotation(90, 0, 90))
	Celer:spawn_occluder('16x8', Vector3(1410, -1150, 700), Rotation(90, 0, 90), true)
	Celer:spawn_occluder('16x8', Vector3(1410, -2300, 700), Rotation(90, 0, 90))
	Celer:spawn_occluder('16x8', Vector3(1410, -2300, 700), Rotation(90, 0, 90), true)

	local ids_front = {
		[301272] = true, -- shared basement
		[301277] = true,
		[302767] = true,
		[302813] = true,
		[100823] = true,
		[301554] = true, -- shared roman
		[300565] = true,
		[300745] = true,
		[300021] = true,
		[301407] = true, -- share courtyard/red/blue
		[301374] = true,
		[301350] = true,
	}
	local ids_right = {
		[301240] = true,
		[301243] = true,
		[301249] = true,
	}
	local ids_left = {
		[301518] = true,
		[301489] = true,
		[301500] = true,
		[301505] = true,
		[301331] = true,
		[301245] = true,
		[301142] = true,
		[301053] = true,
		[301101] = true,
		[301362] = true,
		[301392] = true,
		[301286] = true,
		[301552] = true,
		[301557] = true,
		[301582] = true,
		[301580] = true,
		[301437] = true,
		[132890] = true,
		[300722] = true, -- shared left/red/courtyard
		[301174] = true, -- shared curator
		[301408] = true,
		[302396] = true,
		[301359] = true,
	}
	local ids_roman = {
		[300021] = true, -- shared front
		[400067] = true, -- (shadow)
		[301251] = true, -- shared right
	}
	local ids_basement = {}
	local ids_curator = {}
	local ids_red = {
		[101045] = true,
		[132740] = true,
		[133150] = true,
		[300889] = true,
		[300914] = true,
		[300995] = true,
		[301073] = true,
		[301078] = true,
		[301080] = true,
		[301083] = true,
		[301084] = true,
		[301090] = true,
		[301091] = true,
		[301093] = true,
		[301094] = true,
		[301106] = true,
		[301107] = true,
		[301131] = true,
		[301132] = true,
		[301139] = true,
		[301473] = true,
		[301813] = true,
		[302092] = true,
		[302506] = true,
		[302527] = true,
		[302543] = true,
		[302546] = true,
		[300722] = true, -- shared left/red/courtyard
		[301255] = true, -- shared right
		[301257] = true,
		[400170] = true, -- shared left
		[400181] = true,
		[300450] = true,
		[300471] = true,
		[301008] = true, -- shared blue
		[301229] = true,
		[301234] = true,
		[300326] = true, -- shared green
		[302749] = true,
		[302616] = true, -- shared courtyard
	}
	local ids_green = {
		[101042] = true,
		[301634] = true, -- shared courtyard
		[300323] = true, -- shared red
		[300983] = true,
		[301454] = true,
		[301468] = true,
		[301480] = true,
		[301883] = true,
		[300355] = true, -- shared yellow
		[301136] = true,
		[301137] = true,
		[301141] = true,
		[302925] = true,
	}
	local ids_blue = {
		[300264] = true,
		[300375] = true,
		[300394] = true,
		[300701] = true,
		[300723] = true,
		[300959] = true,
		[301225] = true,
		[301247] = true,
		[301365] = true,
		[300326] = true, -- shared red
		[300983] = true,
		[301454] = true,
		[301883] = true,
		[301906] = true,
		[302529] = true,
		[302534] = true,
		[302545] = true,
		[302749] = true,
		[102995] = true, -- shared jfr
		[102890] = true,
		[102891] = true,
		[300426] = true,
		[301255] = true, -- shared right
		[301257] = true,
		[300455] = true,
		[300355] = true, -- shared yellow
		[300714] = true,
		[301002] = true,
		[301154] = true,
		[301160] = true,
		[301191] = true,
		[302925] = true,
		[302616] = true, -- shared courtyard
	}
	local ids_yellow = {
		[101040] = true,
		[101053] = true, -- shared blue
		[300317] = true,
		[300431] = true,
		[300479] = true,
		[300535] = true,
		[301202] = true,
		[301204] = true,
		[301285] = true,
		[301908] = true,
		[302044] = true,
		[302171] = true,
		[300326] = true, -- shared green
		[302611] = true,
		[302612] = true,
		[302749] = true,
	}
	local ids_jfr = {
		[101053] = true, -- shared blue
		[300317] = true,
		[300424] = true,
		[300462] = true,
		[300469] = true,
		[300479] = true,
		[300777] = true,
		[301202] = true,
		[301204] = true,
		[301238] = true,
		[302044] = true,
		[302417] = true,
	}
	local ids_courtyard = {
		[300722] = true, -- shared left/red/courtyard
		[400181] = true, -- shared left
		[300450] = true,
		[300471] = true,
		[300207] = true, -- shared blue
		[301008] = true,
		[301229] = true,
		[301234] = true,
		[301255] = true, -- shared right
		[301257] = true,
		[300455] = true,
		[300355] = true, -- shared yellow
		[300491] = true,
		[300503] = true,
		[300577] = true,
		[301136] = true,
		[301172] = true,
		[301176] = true,
		[301198] = true,
		[302925] = true,
	}
	local ids_cavern = {}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		if unit_id == 300389 or unit_id == 300545 then
			-- qued
		elseif y > 4400 then
			ids_front[unit_id] = true
			ids_left[unit_id] = true
			ids_cavern[unit_id] = true
		elseif y < -4050 then
			ids_front[unit_id] = true
			ids_right[unit_id] = true
		elseif x < -3900
			or x < -3400 and y < -1100
			or x < -3400 and y > 1500
			or x >= -6736 and x <= -1973 and y >= -4152 and y <= -3550
			or y < 0 and name == 'units/pd2_indiana/equipment/mus_interactable_grate_small/mus_interactable_grate_small' -- shared basement
			or x >= -3275 and x <= -3275 and y >= -2500 and y <= -1600 and z >= -951 and z <= -951 -- shared basement
			or x >= -2800 and x <= -2800 and y >= -3150 and y <= -1650 and z >= -1200 and z <= -1200 -- shared basement
		then
			ids_front[unit_id] = true
		end

		if x >= -725 and x <= -124 and y >= 3258 and y <= 3950 and z >= -800 and z <= -301 then
			ids_left[unit_id] = true
		end

		if x >= -775 and x <= 26 and y >= 3525 and y <= 4325 and z >= 150 and z <= 150 then -- stairs ceiling
			ids_left[unit_id] = true
			ids_red[unit_id] = true
		end

		if x >= -2175 and x <= -725 and y >= 3125 and y <= 3750 and z >= -1200 and z <= -500
		or x >= -125 and x <= 425 and y >= 2775 and y <= 3125 and z >= -800 and z <= -800
		then
			ids_left[unit_id] = true
			ids_curator[unit_id] = true
		end

		if x >= 503 and x <= 858 and y >= -3110 and y <= -2825 and z >= -300 and z <= -125 then
			ids_right[unit_id] = true
		end

		if x >= -2825 and x <= 1149 and y >= -2951 and y <= -825 and z >= -801 and z <= -362 and unit_id ~= 102881 and unit_id ~= 102873 then
			ids_roman[unit_id] = true
		end

		if x >= -2800 and x <= -2550 and y >= -1800 and y <= -877 and z >= -800 and z <= -362
		or x >= -2153 and x <= -2075 and y >= -175 and y <= 571 and z >= -701 and z <= -400
		then
			ids_front[unit_id] = true
			ids_roman[unit_id] = true
		end

		if x >= 99 and x <= 700 and y >= 3078 and y <= 3653 and z >= -300 and z <= 0 -- room
		or x >= -575 and x <= 475 and y >= 2800 and y <= 3000 and z >= 200 and z <= 200 -- skylight
		then
			ids_red[unit_id] = true
		end

		if x >= -1050 and x <= 950 and y >= 1550 and y <= 2750 and z >= -301 and z <= 298 and not ids_red[unit_id] then -- all room
			ids_red[unit_id] = true
			ids_courtyard[unit_id] = true
		end

		if x >= 1725 and x <= 2550 and y >= 1402 and y <= 1725 and z >= -300 and z <= -141 -- part of green
		or x >= 0 and x <= 650 and y >= 2450 and y <= 2675 and z >= -300 and z <= -145 -- part of red
		then
			ids_red[unit_id] = true
			ids_green[unit_id] = true
		end

		if x >= 1450 and x <= 2550 and y >= 850 and y <= 2550 and z >= -300 and z <= 300 -- room
		or x >= 1875 and x <= 2115 and y >= -1756 and y <= -788 and z >= -300 and z <= -149 -- shared yellow
		then
			ids_green[unit_id] = true
		end

		if x >= -200 and x <= 401 and y >= -3253 and y <= -2678 and z >= -300 and z <= 0 -- room
		or x >= -2750 and x <= -1765 and y >= -2924 and y <= -2070 and z >= -300 and z <= 106 -- part of jfr
		or x >= -2646 and x <= -1673 and y >= -1108 and y <= -909 and z >= -300 and z <= 100 -- part of jfr
		or x >= 1900 and x <= 2550 and y >= -900 and y <= -712 and z >= -310 and z <= -100 -- shared yellow
		then
			ids_blue[unit_id] = true
		end

		if x >= -1050 and x <= 951 and y >= -2350 and y <= -1149 and z >= -301 and z <= 300 and not ids_blue[unit_id] then
			ids_blue[unit_id] = true
			ids_courtyard[unit_id] = true
		end

		if x >= -575 and x <= 475 and y >= -2600 and y <= -2400 and z >= 200 and z <= 200 -- skylight
		or x >= -801 and x <= 700 and y >= -2678 and y <= -2322 and z >= -300 and z <= 0 -- corridor
		or x >= 462 and x <= 576 and y >= -2274 and y <= -2222 and z >= -300 and z <= -85
		or x >= -547 and x <= -303 and y >= -2094 and y <= -1964 and z >= -300 and z <= -149
		then
			ids_blue[unit_id] = true
			ids_jfr[unit_id] = true
		end

		if x >= -2650 and x <= -1526 and y >= -2950 and y <= -909 and z >= -328 and z <= 300 or unit_id == 102881 or unit_id == 102873 then
			ids_jfr[unit_id] = true
		end

		if x >= 1500 and x <= 1725 and y >= -229 and y <= 650 and z >= -350 and z <= -175 then
			ids_courtyard[unit_id] = true
		end

		if x >= 311 and x <= 434 and y >= -2085 and y <= -1965 and z >= -300 and z <= -190 -- part of blue
		or x >= -640 and x <= -522 and y >= -2274 and y <= -2213 and z >= -300 and z <= -93 -- part of blue
		or x >= 1450 and x <= 2550 and y >= -2150 and y <= -450 and z >= -310 and z <= 296 -- room
		then
			ids_yellow[unit_id] = true
		end

		if x >= -1452 and x <= -1129 and y >= 0 and y <= 3050 and z >= -350 and z <= -20 -- corridor
		or x >= -859 and x <= 751 and y >= -595 and y <= 1049 and z >= -375 and z <= -354 -- fountain++
		or x >= -650 and x <= 340 and y >= -1125 and y <= -999 and z >= -300 and z <= -20 -- stuff blue side
		or x >= -435 and x <= 250 and y >= 1400 and y <= 1525 and z >= -300 and z <= -20 -- stuff red side
		or x >= 975 and x <= 1575 and y >= -200 and y <= 975 and z >= -350 and z <= -20 and unit_id ~= 302298 and unit_id ~= 302282 and not name:find('wall_olive') -- stuff center/back
		then
			if not ids_courtyard[unit_id] and not ids_red[unit_id] and not ids_blue[unit_id] then
				ids_courtyard[unit_id] = true
				ids_red[unit_id] = true
				ids_blue[unit_id] = true
			end
		end

		if x > -3300 and x < 0 and z < -850 and not ids_basement[unit_id] and not ids_curator[unit_id] then
			ids_basement[unit_id] = true
			if y > 0 then
				ids_curator[unit_id] = true
			end
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			ids_cavern = self._definition.portal.unit_groups.cavern.ids
			ids_cavern[101040] = true
			ids_cavern[101042] = true

			self._definition.portal.unit_groups.basement.shapes[7] = {
				rotation = Rotation(0, 0, 0),
				position = Vector3(-4300, -4100, -1000),
				width = 2500,
				depth = 3550,
				height = 400,
			}
			ids_basement = self._definition.portal.unit_groups.basement.ids
			ids_basement[100823] = true -- shared front
			ids_basement[300455] = true -- shared right
			ids_basement[300711] = true
			ids_basement[302509] = true
			ids_basement[302669] = true
			ids_basement[302745] = true
			ids_basement[302817] = true
			ids_basement[302869] = true
			ids_basement[302962] = true

			ids_curator = self._definition.portal.unit_groups.curator.ids
			ids_curator[302786] = true
			ids_curator[302305] = true
			ids_curator[302676] = true
			ids_curator[301729] = true
			ids_curator[301820] = true
			ids_curator[301918] = true
			ids_curator[302071] = true
			ids_curator[101046] = true
			ids_curator[101052] = true
			ids_curator[101054] = true
			ids_curator[101059] = true
			ids_curator[300204] = true
			ids_curator[301720] = true

			self._definition.portal.unit_groups.front = {
				ids = ids_front,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-10000, -4200, -1200),
						width = 6800,
						depth = 8200,
						height = 1100,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3300, 1350, -1200),
						width = 1100,
						depth = 1800,
						height = 300,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3300, -4000, -1200),
						width = 1500,
						depth = 2600,
						height = 450,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5200, -950, -1000),
						width = 4100,
						depth = 2200,
						height = 1100,
					}
				}
			}
			self._definition.portal.unit_groups.left = {
				ids = ids_left,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1925, 2600, -800),
						width = 2100,
						depth = 2000,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1000, 2675, -300),
						width = 850,
						depth = 1700,
						height = 900,
					}
				}
			}
			self._definition.portal.unit_groups.right = {
				ids = ids_right,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(500, -4000, -800),
						width = 900,
						depth = 1325,
						height = 900,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(0, -4000, -800),
						width = 1200,
						depth = 2500,
						height = 400,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1000, -4000, -300),
						width = 400,
						depth = 2000,
						height = 400,
					}
				}
			}
			self._definition.portal.unit_groups.roman = {
				ids = ids_roman,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3150, -4000, -800),
						width = 4600,
						depth = 3200,
						height = 570,
					}
				}
			}
			self._definition.portal.unit_groups.red = {
				ids = ids_red,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2025, 1525, -385),
						width = 3500,
						depth = 3000,
						height = 585,
					}
				}
			}
			self._definition.portal.unit_groups.green = {
				ids = ids_green,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1400, -400, -300),
						width = 1500,
						depth = 3000,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(950, 1100, -350),
						width = 500,
						depth = 2000,
						height = 500,
					}
				}
			}
			self._definition.portal.unit_groups.blue = {
				ids = ids_blue,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1550, -4000, -400),
						width = 3000,
						depth = 2900,
						height = 600,
					}
				}
			}
			self._definition.portal.unit_groups.yellow = {
				ids = ids_yellow,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1400, -2150, -300),
						width = 1500,
						depth = 3000,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(950, -2200, -350),
						width = 500,
						depth = 1800,
						height = 500,
					}
				}
			}
			self._definition.portal.unit_groups.jfr = {
				ids = ids_jfr,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2650, -2950, -300),
						width = 1600,
						depth = 2425,
						height = 500,
					}
				}
			}
			self._definition.portal.unit_groups.courtyard = {
				ids = ids_courtyard,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2000, -1175, -350),
						width = 3400,
						depth = 2750,
						height = 700,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4400, -1000, -700),
						width = 3000,
						depth = 2500,
						height = 1000,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(950, -450, -350),
						width = 775,
						depth = 1300,
						height = 500,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'nmh' then

	local ids_start = {
		[104991] = true,
		[100174] = true, -- shared cafeteria
		[100234] = true,
		[100243] = true,
		[100253] = true, -- shared admin_corridor
		[100276] = true,
		[100291] = true,
		[100315] = true,
		[100316] = true,
		[100321] = true,
		[100330] = true,
		[100332] = true,
		[100333] = true,
		[100340] = true,
		[100344] = true,
		[100531] = true, -- shared reception
		[100532] = true,
	}
	local ids_cafeteria = {
		[100286] = true,
		[100508] = true, -- shared cafeteria
		[100537] = true,
		[100541] = true,
	}
	local ids_admin_corridor = {
		[100375] = true,
		[200147] = true, -- topfloor
	}
	local ids_restrooms = {
		[100886] = true,
		[100919] = true,
		[100922] = true,
		[100972] = true,
		[101237] = true,
		[101300] = true,
		[101347] = true,
		[101399] = true,
		[101450] = true,
		[101484] = true,
		[101519] = true,
		[101566] = true,
	}
	local ids_reception = {
		[100556] = true,
		[100540] = true,
		[100509] = true,
		[200147] = true, -- topfloor
		[200083] = true, -- shared admin_corridor
		[100519] = true,
		[100469] = true,
		[100399] = true,
		[100469] = true,
		[100503] = true,
		[100566] = true,
		[200082] = true,
		[200084] = true,
		[100161] = true, -- shared start
		[101583] = true, -- shared room 407 / 408
		[101656] = true,
		[101592] = true,
		[101568] = true,
		[100630] = true, -- shared room 405 / 414
		[100632] = true,
		[100650] = true,
		[100671] = true,
		[100741] = true,
		[100816] = true,
		[100827] = true,
		[100943] = true,
		[100968] = true,
		[100988] = true,
		[300184] = true,
	}
	local ids_room_405 = {
		[100998] = true, -- shared elevator (room 413)
		[101053] = true,
	}
	local ids_room_407_408 = {
		[102058] = true, -- shared room_411
		[102133] = true,
		[102168] = true,
	}
	local ids_room_409_410 = {
		[101785] = true,
		[101787] = true,
		[101830] = true,
		[101903] = true,
		[101989] = true,
	}
	local ids_room_411 = {
		[200147] = true, -- topfloor
	}
	local ids_room_414 = {}
	local ids_laundry = {
		[101938] = true,
		[101982] = true,
		[102016] = true,
	}
	local ids_elevator = {
		[100217] = true,
		[100479] = true,
		[101772] = true,
		[101828] = true,
		[100837] = true,
		[101863] = true,
		[101934] = true,
		[101948] = true,
		[102062] = true,
		[102074] = true,
		[200028] = true,
		[100632] = true, -- shared room 414
		[100650] = true,
		[100819] = true,
		[100827] = true,
	}
	local ids_isolation_corridor = {}
	local ids_exits = {
		[200000] = true,
		[200028] = true,
		[200145] = true,
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x >= 1215 and x <= 1877 and y >= 432 and y <= 1503 and z >= 0 and z <= 320
		or x >= 577 and x <= 1077 and y >= 830 and y <= 1506 and z >= -2 and z <= 300 and unit_id ~= 100556 -- shared reception
		then
			ids_start[unit_id] = true
		end

		if x >= 2720 and x <= 3769 and y >= 116 and y <= 813 and z >= 0 and z <= 320 -- empty room
		or x >= 2585 and x <= 3767 and y >= 622 and y <= 1485 and z >= -10 and z <= 320 -- cafeteria
		or x >= 2755 and x <= 3804 and y >= -708 and y <= -238 and z >= 0 and z <= 320 -- exam room 401
		or x >= 1893 and x <= 2350 and y >= -708 and y <= -239 and z >= 0 and z <= 320 and unit_id ~= 101145 and unit_id ~= 101838 -- part of exam room 403
		or x >= 3167 and x <= 3768 and y >= -221 and y <= 147 and z >= -1 and z <= 300 -- shared admin_corridor
		then
			ids_cafeteria[unit_id] = true
		end

		if x >= 1269 and x <= 3768 and y >= -222 and y <= 147 and z >= -1 and z <= 320 -- corridor
		or x >= 918 and x <= 1844 and y >= -709 and y <= -234 and z >= 0 and z <= 320 -- exam room 404
		or x >= 2166 and x <= 2735 and y >= -707 and y <= -247 and z >= -1 and z <= 320 and not ids_cafeteria[unit_id] -- part of exam room 403
		or x >= 280 and x <= 1154 and y >= -223 and y <= 830 and z >= 0 and z <= 320 -- shared reception
		then
			ids_admin_corridor[unit_id] = true
		end

		if unit_id == 300017 or unit_id == 100475 or unit_id == 100369 or unit_id == 100263 then -- stairs
			ids_start[unit_id] = true
			ids_cafeteria[unit_id] = true
			ids_admin_corridor[unit_id] = true
		end

		if x >= 113 and x <= 544 and y >= 847 and y <= 1666 and z >= 0 and z <= 320 then
			ids_room_405[unit_id] = true
			ids_room_414[unit_id] = true
		end

		if unit_id == 100950 or unit_id == 100935 or ids_room_405[unit_id] then
			-- qued
		elseif x >= 532 and x <= 768 and y >= -706 and y <= -238 and z >= 0 and z <= 300 -- part of backoffice
		or x >= 279 and x <= 362 and y >= -550 and y <= -233 and z >= 0 and z <= 203 -- another part of backoffice
		or x >= 280 and x <= 1183 and y >= -223 and y <= 1506 and z >= -2 and z <= 320 -- counter
		or x >= -28 and x <= 263 and y >= 919 and y <= 1550 and z >= 0 and z <= 301 -- shared room 405
		or x >= -375 and x <= -238 and y >= -222 and y <= 144 and z >= 0 and z <= 268 -- restrooms
		then
			ids_reception[unit_id] = true
		end

		if x >= -28 and x <= 263 and y >= 919 and y <= 1550 and z >= 0 and z <= 301 then
			ids_room_405[unit_id] = true
			ids_room_414[unit_id] = true
		end

		if x >= -390 and x <= 576 and y >= -1495 and y <= -726 and z >= -1 and z <= 320 then
			ids_restrooms[unit_id] = true
		end

		if x >= -382 and x <= 213 and y >= 175 and y <= 473 and z >= 0 and z <= 244 then
			ids_admin_corridor[unit_id] = true
			ids_restrooms[unit_id] = true
			ids_reception[unit_id] = true
		end

		if x >= -983 and x <= -413 and y >= -110 and y <= 473 and z >= 0 and z <= 301 -- room 407
		or x >= -994 and x <= -413 and y >= 847 and y <= 1522 and z >= -4 and z <= 301 -- room 408
		or x >= 356 and x <= 1183 and y >= 232 and y <= 1007 and z >= 0 and z <= 300 -- shared reception
		or x >= -2804 and x <= -2247 and y >= 1072 and y <= 1334 and z >= -75 and z <= 300 -- annoying part of laundry
		then
			ids_room_407_408[unit_id] = true
		end

		if x >= -999 and x <= -413 and y >= -705 and y <= -128 and z >= -1 and z <= 301 -- room 409
		or x >= -2103 and x <= -1481 and y >= -709 and y <= -127 and z >= -1 and z <= 303 -- room 410
		or x >= -1748 and x <= -716 and y >= -1153 and y <= -991 and z >= 0 and z <= 0 -- corridor, end
		then
			ids_room_409_410[unit_id] = true
		end

		if x >= -2831 and x <= -1710 and y >= -110 and y <= 479 and z >= -4 and z <= 320 -- rooms but front
		or x >= -1750 and x <= -1540 and y >= 436 and y <= 473 and z >= 0 and z <= 239 -- around door
		or x >= -2300 and x <= -2081 and y >= 491 and y <= 800 and z >= 0 and z <= 320 -- corridor, near end
		or x >= -3262 and x <= -3183 and y >= 150 and y <= 1194 and z >= 0 and z <= 300 -- corridor, end
		or x >= 428 and x <= 1180 and y >= 397 and y <= 830 and z >= 0 and z <= 320 -- shared reception
		then
			ids_room_411[unit_id] = true
		end

		if x >= -1668 and x <= -1482 and y >= -108 and y <= 343 and z >= -1 and z <= 300 -- part of 411
		or x >= -2831 and x <= -1839 and y >= 841 and y <= 1657 and z >= -75 and z <= 300 -- all laundry
		then
			ids_room_411[unit_id] = true
			ids_laundry[unit_id] = true
		end

		if x >= -1175 and x <= -637 and y >= 3475 and y <= 3605 and z >= 0 and z <= 300 -- part of room 412
		or x >= -1477 and x <= -1013 and y >= -709 and y <= -189 and z >= -1 and z <= 300 and not ids_room_409_410[unit_id] -- corridor stuff
		or x >= -1463 and x <= -1399 and y >= 75 and y <= 328 and z >= -1 and z <= 207 -- corridor stuff
		or x >= -1825 and x <= -1344 and y >= 852 and y <= 2495 and z >= -4 and z <= 300 and unit_id ~= 101801 and unit_id ~= 104985 and unit_id ~= 101782 and unit_id ~= 101847 -- isorooms
		or x >= -1351 and x <= -1013 and y >= 1146 and y <= 2226 and z >= 0 and z <= 320 -- middle of corridor
		or x >= -1012 and x <= -275 and y >= 1573 and y <= 2113 and z >= -14 and z <= 320 -- middle room
		then
			ids_isolation_corridor[unit_id] = true
		end

		if x >= -1349 and x <= -470 and y >= 3040 and y <= 3605 and z >= 0 and z <= 300 -- room 412
		or x >= -925 and x <= -132 and y >= 2678 and y <= 2836 and z >= 0 and z <= 275 -- corridor stuff
		or x >= -2030 and x <= -1425 and y >= 2604 and y <= 2683 and z >= 0 and z <= 259 -- corridor stuff
		or x >= -432 and x <= 174 and y >= 3039 and y <= 3602 and z >= 0 and z <= 300 -- room 413
		then
			ids_elevator[unit_id] = true
		end

		if unit_id == 200001 or unit_id == 100005 then
			-- qued
		elseif x >= -1351 and x <= -282 and y >= 2132 and y <= 2727 and z >= -1 and z <= 320 then
			ids_isolation_corridor[unit_id] = true
			ids_elevator[unit_id] = true
		end

		if x >= -64 and x <= 382 and y >= 2775 and y <= 3020 and z >= 0 and z <= 300
		or x >= 329 and x <= 509 and y >= 1818 and y <= 2662 and z >= 0 and z <= 235
		then
			ids_elevator[unit_id] = true
			ids_room_405[unit_id] = true
			ids_room_414[unit_id] = true
		end

		if x >= -250 and x <= 227 and y >= 1725 and y <= 2549 and z >= 0 and z <= 301
		or unit_id == 100011 -- reception stuff
		or unit_id == 100763
		or unit_id == 100790
		or unit_id == 100848
		or unit_id == 100854
		or unit_id == 100861
		or unit_id == 100883
		or unit_id == 100901
		or unit_id == 100912
		or unit_id == 100923
		or unit_id == 100940
		or unit_id == 100964
		or unit_id == 200032
		then
			ids_room_405[unit_id] = true
			ids_room_414[unit_id] = true
		end

		if name == 'units/world/props/flickering_light/flickering_light' or unit_id == 101554 then
			-- qued
		elseif x >= -2232 and x <= 3686 and y >= 2300 and y <= 3400 and z >= -825 and z <= -398
		or x < -3450
		or y > 3600
		then
			ids_exits[unit_id] = true
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups = {}

			self._definition.portal.unit_groups.start = {
				ids = ids_start,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(580, 825, 0),
						width = 1300,
						depth = 675,
						height = 300,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1225, 100, 0),
						width = 1325,
						depth = 1400,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.cafeteria = {
				ids = ids_cafeteria,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(2000, -700, 0),
						width = 1750,
						depth = 2175,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.admin_corridor = {
				ids = ids_admin_corridor,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-375, -700, 0),
						width = 4150,
						depth = 1175,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.reception = {
				ids = ids_reception,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-410, -700, 0),
						width = 1785,
						depth = 2200,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.restrooms = {
				ids = ids_restrooms,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-390, -1500, 0),
						width = 975,
						depth = 775,
						height = 300,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-410, -1500, 0),
						width = 675,
						depth = 2325,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.room_405 = {
				ids = ids_room_405,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-410, 490, 0),
						width = 1000,
						depth = 1200,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.room_407_408 = {
				ids = ids_room_407_408,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1450, -100, 0),
						width = 1150,
						depth = 1625,
						height = 300,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1815, 850, 0),
						width = 400,
						depth = 550,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.room_409_410 = {
				ids = ids_room_409_410,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2060, -700, 0),
						width = 1650,
						depth = 600,
						height = 300,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1460, -700, 0),
						width = 450,
						depth = 1000,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.room_411 = {
				ids = ids_room_411,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2850, -100, 0),
						width = 1400,
						depth = 970,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.room_414 = {
				ids = ids_room_414,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-245, 1680, 0),
						width = 750,
						depth = 1340,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.isolation_corridor = {
				ids = ids_isolation_corridor,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1820, -700, 0),
						width = 1525,
						depth = 4300,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.laundry = {
				ids = ids_laundry,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2850, 850, 0),
						width = 1067,
						depth = 2750,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.elevator = {
				ids = ids_elevator,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2815, 2650, 0),
						width = 3300,
						depth = 925,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.exits = {
				ids = ids_exits,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3500, 1825, -700),
						width = 1200,
						depth = 1800,
						height = 20700,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5300, 1825, -200),
						width = 3000,
						depth = 4000,
						height = 900,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3500, 1825, -700),
						width = 5000,
						depth = 1800,
						height = 700,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'peta' then

	Celer:spawn_occluder('24x16', Vector3(128, 1266, 275), Rotation(70, 0, 180))
	Celer:spawn_occluder('24x16', Vector3(128, 1266, 275), Rotation(70, 0, 180), true)
	Celer:spawn_occluder('10x8', Vector3(-2175, 460, 175), Rotation(135, 0, 180))
	Celer:spawn_occluder('10x8', Vector3(-2175, 460, 175), Rotation(135, 0, 180), true)
	Celer:spawn_occluder('18x16', Vector3(-1255, -430, 375), Rotation(135, 0, 180))
	Celer:spawn_occluder('18x16', Vector3(-1255, -430, 375), Rotation(135, 0, 180), true)
	Celer:spawn_occluder('18x16', Vector3(-10, -1725, 375), Rotation(225, 0, 180))
	Celer:spawn_occluder('18x16', Vector3(-10, -1725, 375), Rotation(225, 0, 180), true)
	Celer:spawn_occluder('14x8', Vector3(1568, -153, 375), Rotation(225, 0, 180))
	Celer:spawn_occluder('14x8', Vector3(1568, -153, 375), Rotation(225, 0, 180), true)
	Celer:spawn_occluder('16x16', Vector3(2353, 1227, 375), Rotation(0, 0, 180))
	Celer:spawn_occluder('16x16', Vector3(2353, 1227, 375), Rotation(0, 0, 180), true)
	Celer:spawn_occluder('16x16', Vector3(1025, 1227, 375), Rotation(0, 0, 180))
	Celer:spawn_occluder('16x16', Vector3(1025, 1227, 375), Rotation(0, 0, 180), true)
	Celer:spawn_occluder('10x8', Vector3(-860, 1227, 175), Rotation(0, 0, 180))
	Celer:spawn_occluder('10x8', Vector3(-860, 1227, 175), Rotation(0, 0, 180), true)

	Celer:spawn_occluder('13x8', Vector3(3270, 2875, 875), Rotation(-90, 0, 180))
	Celer:spawn_occluder('13x8', Vector3(3270, 2875, 875), Rotation(-90, 0, 180), true)
	Celer:spawn_occluder('24x16', Vector3(3306, 2900, 485), Rotation(0, 0, 180))
	Celer:spawn_occluder('24x16', Vector3(3306, 2900, 875), Rotation(0, 0, 180), true)

	Celer:spawn_occluder('32x32', Vector3(4965, -1345, 2800), Rotation(180, 0, 180))
	Celer:spawn_occluder('24x16', Vector3(4965, -1345, 1400), Rotation(180, 0, 180), true)
	Celer:spawn_occluder('32x32', Vector3(5000, -5125, 2800), Rotation(180, 0, 180))
	Celer:spawn_occluder('32x32', Vector3(5000, -7370, 2800), Rotation(180, 0, 180), true)
	Celer:spawn_occluder('32x16', Vector3(9800, 1065, 510), Rotation(0, 0, 180))

elseif level_id == 'pex' then

	Celer:spawn_occluder('7x8', Vector3(-467, 2595, -400), Rotation(0, 0, 0))

	Celer:spawn_occluder('8x8', Vector3(290, 2100, 400), Rotation(90, 0, 0))
	Celer:spawn_occluder('8x8', Vector3(290, 2100, 400), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('7x8', Vector3(-717, 2900, 380), Rotation(-90, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(-717, 2900, 380), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('7x8', Vector3(-85, 500, 0), Rotation(90, 0, 0))
	Celer:spawn_occluder('16x14', Vector3(-2100, 2600, 810), Rotation(-90, -90, 0))

	local ids_front = {
		[100041] = true,
		[102155] = true,
		[102208] = true,
		[102209] = true,
		[500145] = true,
		[500146] = true,
		[500147] = true,
		[500148] = true,
		[500458] = true,
		[500473] = true,
		[500482] = true,
		[500489] = true,
		[500815] = true,
		[500852] = true,
		[500853] = true,
		[500854] = true,
		[500860] = true,
		[500891] = true,
		[500917] = true,
		[700034] = true,
		[700035] = true,
		[800010] = true,
		[800013] = true,
		[800126] = true,
		[800383] = true,
		[800653] = true,
		[800671] = true,
		[800703] = true,
		[800706] = true,
		[800720] = true,
		[800725] = true,
		[800726] = true,
		[800728] = true,
		[801014] = true,
		[801015] = true,
		[801016] = true,
		[801021] = true,
		[801032] = true,
		[500729] = true, -- shared behind
		[801203] = true, -- shared garage
		[800678] = true,
		[800933] = true,
		[801225] = true,
		[400005] = true, -- shared front
		[800903] = true, -- shared level0
		[400007] = true, -- shared level0/prison
		[801334] = true, -- shared level1
		[800613] = true,
		[800227] = true,
		[800553] = true,
		[800544] = true,
		[800549] = true,
		[800670] = true,
	}
	local ids_behind = {
		[500042] = true,
		[500054] = true,
		[500142] = true,
		[500143] = true,
		[500144] = true,
		[500157] = true,
		[500168] = true,
		[500369] = true,
	}
	local ids_level0 = {
		[100051] = true,
		[800452] = true,
		[800454] = true,
		[800457] = true,
		[800469] = true,
		[800472] = true,
		[800519] = true,
		[800521] = true,
		[800532] = true,
		[800565] = true,
		[800590] = true,
		[800781] = true,
		[800782] = true,
		[800783] = true,
		[800931] = true,
		[801357] = true,
		[800667] = true, -- shared level1
		[800396] = true,
		[800217] = true,
		[801344] = true,
		[800547] = true,
		[801338] = true,
		[801367] = true,
		[400028] = true,
		[801217] = true,
		[800004] = true,
		[100063] = true, -- shared garage
		[132931] = true,
		[800662] = true,
		[800795] = true,
		[800797] = true,
		[800944] = true,
		[800946] = true,
		[801120] = true,
		[801121] = true,
		[100542] = true, -- shared prison
		[400016] = true,
		[400020] = true, -- shared level0/prison/garage
		[800002] = true, -- shared level0/level1/prison
	}
	local ids_level1 = {
		[800002] = true, -- shared level0/level1/prison
		[400028] = true, -- shared level0
		[801217] = true,
		[800004] = true,
		[500507] = true, -- shared behind
		[102803] = true, -- shared garage
		[147316] = true, -- shared prison
	}
	local ids_garage = {
		[100065] = true,
		[100066] = true,
		[700412] = true,
		[700444] = true,
		[700445] = true,
		[800664] = true,
		[800674] = true,
		[800769] = true,
		[800810] = true,
		[800813] = true,
		[800828] = true,
		[800887] = true,
		[800888] = true,
		[800889] = true,
		[800893] = true,
		[800894] = true,
		[800897] = true,
		[800898] = true,
		[800899] = true,
		[800900] = true,
		[800901] = true,
		[800902] = true,
		[800941] = true,
		[801142] = true,
		[801203] = true,
		[100063] = true, -- shared level0
		[132931] = true,
		[800662] = true,
		[800795] = true,
		[800797] = true,
		[800944] = true,
		[800946] = true,
		[801120] = true,
		[801121] = true,
		[400020] = true, -- shared level0/prison/garage
		[800678] = true, -- shared front
		[800933] = true,
		[801225] = true,
	}
	local ids_prison = {
		[800675] = true,
		[801211] = true,
		[800659] = true,
		[800965] = true,
		[100542] = true, -- shared level0
		[400016] = true,
		[800674] = true,
		[400007] = true, -- shared level0/prison
		[800454] = true,
		[800578] = true,
		[400020] = true, -- shared level0/prison/garage
		[800002] = true, -- shared level0/level1/prison
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if unit_id == 101216
		or unit_id == 102043
		or unit_id == 102622
		or unit_id == 500501
		or unit_id == 500532
		or unit_id == 500539
		or unit_id == 500464
		or unit_id == 500465
		or unit_id == 500469
		or unit_id == 500472
		or unit_id == 500486
		or unit_id == 500497
		or unit_id == 500506
		then
			return
		elseif not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if x >= -701 and x <= -375 and y >= 2275 and y <= 2825 and z >= 300 and z <= 818 -- staircases
		or x >= -3075 and x <= -2577 and y >= 1969 and y <= 2632 and z >= 100 and z <= 941
		then
			ids_level0[unit_id] = true
			ids_level1[unit_id] = true
		end

		if x >= -1525 and x <= -500 and y >= 1925 and y <= 2818 and z >= 99 and z <= 400 then -- cafeteria
			if not (x >= -1101 and x <= -501 and y >= 1925 and y <= 2183 and z >= 100 and z <= 336) and not ids_level0[unit_id] then
				ids_front[unit_id] = true
			end
			ids_level0[unit_id] = true
		end

		if x >= -2100 and x <= -1526 and y >= 1924 and y <= 2625 and z >= 99 and z <= 400 -- next to cafeteria
		or x >= -1076 and x <= -499 and y >= 699 and y <= 1025 and z >= 99 and z <= 400 -- en face
		or x >= -2131 and x <= -1525 and y >= 699 and y <= 1275 and z >= 99 and z <= 400
		or x >= -2526 and x <= -2486 and y >= 1125 and y <= 2051 and z >= 99 and z <= 375
		or x >= -101 and x <= 675 and y >= 1720 and y <= 2076 and z >= 99 and z <= 400 -- restroom
		or x >= -2525 and x <= -1921 and y >= 2756 and y <= 3229 and z >= 99 and z <= 400 -- before jail
		or x >= 336 and x <= 584 and y >= 2820 and y <= 2824 and z >= 125 and z <= 216 -- down stairs
		then
			ids_level0[unit_id] = true
		end

		if x >= -2526 and x <= -600 and y >= 1225 and y <= 1921 and z >= 100 and z <= 400 then -- couloir
			if y > 1500 and x > -1550 and not ids_level0[unit_id] then
				ids_front[unit_id] = true
			end
			ids_level0[unit_id] = true
		end

		if unit_id == 400021 or unit_id == 400029
		or unit_id == 800934 or unit_id == 801246 or unit_id == 801244 -- visible from back
		then
			-- qued
		elseif x >= 300 and x <= 1125 and y >= 2091 and y <= 3025 and z >= 499 and z <= 800 -- room
		or x >= -2078 and x <= 1125 and y >= 1177 and y <= 2065 and z >= 500 and z <= 800 -- long central
		or x >= -1100 and x <= -499 and y >= 700 and y <= 1305 and z >= 500 and z <= 800 -- meeting room
		or x >= -2100 and x <= -1525 and y >= 700 and y <= 972 and z >= 500 and z <= 800
		or x >= -3470 and x <= -700 and y >= 1000 and y <= 2200 and z >= 500 and z <= 800 -- room
		or x >= -2524 and x <= -722 and y >= 2048 and y <= 2801 and z >= 500 and z <= 800
		then
			ids_level1[unit_id] = true
		end

		if x >= -4800 and x <= -950 and y >= -3693 and y <= -2331 and z >= -25 and z <= 0
		or x >= 1625 and x <= 2202 and y >= -2824 and y <= -2224 and z >= -2 and z <= 244
		then
			ids_front[unit_id] = true
		end

		if y >= 981 and y <= 982 and z == 275 and name:find('pex_ext_police_station_window_01')
		or x >= -75 and x <= 1143 and y >= 1183 and y <= 1800 and z >= 100 and z <= 400 and not ids_level0[unit_id] -- reception
		or x >= -1140 and x <= -75 and y >= 699 and y <= 1800 and z >= 100 and z <= 400 and not ids_level0[unit_id] -- couloir
		then
			ids_front[unit_id] = true
			ids_level0[unit_id] = true
		end

		if y == 982 and z == 675 and name:find('pex_ext_police_station_window_01') then
			ids_front[unit_id] = true
			ids_level1[unit_id] = true
		end

		if x >= -3768 and x <= -1525 and y >= 3104 and y <= 4526 and z >= -9 and z <= 300
		or x >= -3975 and x <= -2551 and y >= 2675 and y <= 3300 and z >= 0 and z <= 300
		or x >= -3580 and x <= -3100 and y >= 1971 and y <= 2600 and z >= 0 and z <= 300 and unit_id ~= 400016
		then
			ids_prison[unit_id] = true
		end

		if x >= -3825 and x <= -3173 and y >= 1057 and y <= 1475 and z >= -1 and z <= 300 then
			ids_garage[unit_id] = true
			ids_prison[unit_id] = true
		end

		if x >= -3975 and x <= -2750 and y >= 1225 and y <= 2116 and z >= 0 and z <= 400 and not ids_prison[unit_id] then
			ids_level0[unit_id] = true
			ids_prison[unit_id] = true
		end

		if x >= -1904 and x <= -633 and y >= 636 and y <= 636 and z >= 326 and z <= 1248 then
			ids_garage[unit_id] = true
			ids_front[unit_id] = true
		end

		if x <= -800 and y >= 6500 then
			ids_behind[unit_id] = true
		end

		-- outside
		if x >= -13100 and x <= -11000 and y >= -12250 and y <= -12250 and z >= 0 and z <= 0
		or x >= -7400 and x <= -4600 and y >= -14028 and y <= -10250 and z >= 0 and z <= 1000
		or x <= -7900 and y >= -8200 and y <= 900 and unit_id ~= 500613 and unit_id ~= 500687 and unit_id ~= 500661 and unit_id ~= 500604
		then
			if not name:find('backdrop_city') and not name:find('bdrop_building') then
				ids_front[unit_id] = true
			end
		end

		if unit_id == 101316 then
			-- qued
		elseif x >= -4910 and x <= -2666 and y >= -1850 and y <= 379 and z >= 175 and z <= 175
		or x >= -4924 and x <= -2388 and y >= -1200 and y <= 87 and z >= -259 and z <= -250
		then
			ids_garage[unit_id] = true
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups = {}

			self._definition.portal.unit_groups.front = {
				ids = ids_front,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2900, -5400, -25),
						width = 6600,
						depth = 6060,
						height = 800,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(1150, 650, -25),
						width = 2550,
						depth = 200,
						height = 800,
					}
				}
			}
			self._definition.portal.unit_groups.prison = {
				ids = ids_prison,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3750, 2800, 0),
						width = 3100,
						depth = 1800, 
						height = 400,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4450, 350, 0),
						width = 2350,
						depth = 2800, 
						height = 400,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2150, 1300, 100),
						width = 150,
						depth = 600, 
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.garage = {
				ids = ids_garage,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5200, -2000, -300),
						width = 2650,
						depth = 3900, 
						height = 600,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5200, -2500, -300),
						width = 7500,
						depth = 2850,
						height = 800,
					}
				}
			}
			self._definition.portal.unit_groups.level0 = {
				ids = ids_level0,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2525, 350, 0),
						width = 4050,
						depth = 4200,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-4000, 1200, 0),
						width = 1500,
						depth = 900,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-700, 2300, 100),
						width = 975,
						depth = 525,
						height = 900,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3075, 1925, 0),
						width = 550,
						depth = 700,
						height = 1000,
					},
					{
						position = Vector3(-2940, 4300, 0),
						rotation = Rotation(0, 0, 0),
						width = 500,
						depth = -600,
						height = 300,
					}
				}
			}
			self._definition.portal.unit_groups.level1 = {
				ids = ids_level1,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3600, 500, 350),
						width = 4800,
						depth = 2500,
						height = 650,
					}
				}
			}
			self._definition.portal.unit_groups.behind = {
				ids = ids_behind,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2800, 700, 500),
						width = 1900,
						depth = 2500,
						height = 500,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3000, -4900, -25),
						width = 2000,
						depth = 2500,
						height = 500,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'rvd2' then

	Celer:spawn_occluder('24x16', Vector3(1700, 4325, 500), Rotation(0, 90, 0))
	Celer:spawn_occluder('24x16', Vector3(1700, 4325, 500), Rotation(0, 90, 0), true)

	Celer:spawn_occluder('20x16', Vector3(1700, 3025, 500), Rotation(0, 90, 0))
	Celer:spawn_occluder('20x16', Vector3(1700, 3025, 500), Rotation(0, 90, 0), true)

	Celer:spawn_occluder('12x8', Vector3(3275, 1470, 0), Rotation(0, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(3275, 1470, 0), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('4x8', Vector3(2975, 1470, 0), Rotation(0, 0, -90))
	Celer:spawn_occluder('4x8', Vector3(2975, 1470, 0), Rotation(0, 0, -90), true)

	Celer:spawn_occluder('6x8', Vector3(2385, 4300, 0), Rotation(180, 0, 0))
	Celer:spawn_occluder('6x8', Vector3(2385, 4300, 0), Rotation(180, 0, 0), true)

	Celer:spawn_occluder('32x32', Vector3(5200, 4700, -1600), Rotation(180, 0, 0))
	Celer:spawn_occluder('32x32', Vector3(5200, 4700, -1600), Rotation(180, 0, 0), true)

	Celer:spawn_occluder('32x32', Vector3(1962, -1210, -1600), Rotation(-90, 0, 0))

	local junk = {
		[100955] = true,
		[300228] = true,
		[300271] = true,
		[300442] = true,
		[300524] = true,
		[300560] = true,
		[300648] = true,
		[300675] = true,
		[300851] = true,
		[301030] = true,
		[301059] = true,
		[301098] = true,
		[301142] = true,
		[301280] = true,
		[301505] = true,
		[301530] = true,
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		if junk[unit_id] then
			return
		end

		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z
		local ug = self._definition.portal.unit_groups

		if x > -1600 and x < -300 and y > 1375 and y < 2500 then
			ug.crossroad.ids[unit_id] = true
			ug.street_02.ids[unit_id] = true
			if x > -850 and y < 1800 then
				ug.lower_floor.ids[unit_id] = true
				ug.upper_floor.ids[unit_id] = true
			end
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			if name:find('_limo') or name:find('car_crossover') then
				unit:interaction():set_active(false)
			end
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups = Celer:load_autogen_unit_groups()

			local ug = self._definition.portal.unit_groups

			ug.lower_floor.ids[300617] = true
			ug.lower_floor.ids[400007] = true
			ug.upper_floor.ids[400007] = true
			ug.lower_floor.ids[300899] = true
			ug.upper_floor.ids[300899] = true
			ug.lower_floor.ids[100301] = true
			ug.vault.ids[100452] = true
			ug.escape_01.ids[101028] = true
			ug.escape_02.ids[301265] = true
			ug.street_01.ids[301265] = true
			ug.escape_01.ids[300527] = true
		end
		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'sah' then

	Celer:spawn_occluder('16x8', Vector3(1385, 5150, 200), Rotation(-90, 0, 0))
	Celer:spawn_occluder('16x8', Vector3(1385, 5150, 200), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-1000, 2825, -200), Rotation(-90, 0, 0))

	Celer:spawn_occluder('16x16', Vector3(1000, 1225, -200), Rotation(90, 0, 0))
	Celer:spawn_occluder('16x16', Vector3(1000, 1225, -200), Rotation(90, 0, 0), true)

	Celer:spawn_occluder('12x8', Vector3(1000, 840, 300), Rotation(0, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(1000, 840, 300), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('12x8', Vector3(-2250, 840, 300), Rotation(0, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(-2250, 840, 300), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('12x8', Vector3(1000, 3230, 200), Rotation(0, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(1000, 3230, 200), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('12x8', Vector3(-2250, 3230, 350), Rotation(0, 0, 0))
	Celer:spawn_occluder('12x8', Vector3(-2250, 3230, 350), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-2250, 2065, 1100), Rotation(0, 0, 90))
	Celer:spawn_occluder('16x8', Vector3(-2250, 2065, 1100), Rotation(0, 0, 90), true)

	Celer:spawn_occluder('8x8', Vector3(1400, 2020, 1100), Rotation(0, 0, 90))
	Celer:spawn_occluder('8x8', Vector3(1400, 2020, 1100), Rotation(0, 0, 90), true)

	Celer:spawn_occluder('20x20', Vector3(1370, 3200, 490), Rotation(180, 90, 0))
	Celer:spawn_occluder('20x20', Vector3(1370, 3200, 490), Rotation(180, 90, 0), true)

	Celer:spawn_occluder('20x20', Vector3(600, 425, 490), Rotation(90, 90, 0))
	Celer:spawn_occluder('20x20', Vector3(600, 425, 490), Rotation(90, 90, 0), true)

	Celer:spawn_occluder('32x20', Vector3(-550, 3636, 490), Rotation(-90, 90, 0))
	Celer:spawn_occluder('32x20', Vector3(-550, 3636, 490), Rotation(-90, 90, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-1000, 850, 490), Rotation(0, 90, 0))
	Celer:spawn_occluder('16x8', Vector3(-1000, 850, 490), Rotation(0, 90, 0), true)

	local ids_lobby = {
		[300000] = true,
		[500129] = true,
		[500138] = true,
		[400041] = true, -- shared level1
		[400042] = true,
		[400045] = true,
		[400046] = true,
		[400095] = true,
		[400280] = true,
		[400281] = true,
	}
	local ids_restroom = {}
	local ids_storage = {
		[300813] = true,
		[135564] = true,
		[102358] = true,
		[400152] = true,
		[400154] = true,
		[400393] = true,
		[400406] = true,
		[400140] = true,
		[400141] = true,
		[400142] = true,
		[400143] = true,
		[300609] = true,
		[300621] = true,
		[300553] = true,
		[300596] = true,
		[300531] = true,
		[300525] = true,
		[300586] = true,
		[300590] = true,
		[300595] = true,
		[300006] = true, -- shared level0
		[300255] = true,
		[300314] = true,
		[300329] = true,
		[300379] = true,
		[400388] = true, -- shared level1
		[100882] = true,
		[300181] = true,
		[300219] = true,
		[300057] = true,
		[400413] = true,
		[400500] = true,
		[400501] = true,
		[400255] = true, -- shared auction_room
		[400256] = true,
		[400258] = true,
		[400259] = true,
	}
	local ids_level0 = {
		[300017] = true,
		[300216] = true,
		[300247] = true,
		[300274] = true,
		[300289] = true,
		[300291] = true,
		[300349] = true,
		[300363] = true,
		[300364] = true,
		[300367] = true,
		[300411] = true,
		[300416] = true,
		[300506] = true,
		[300514] = true,
		[300516] = true,
		[300518] = true,
		[300519] = true,
		[300540] = true,
		[300640] = true,
		[300644] = true,
		[300648] = true,
		[300652] = true,
		[102068] = true,
		[103943] = true,
		[144950] = true,
		[145450] = true,
		[146450] = true,
		[145950] = true,
		[300005] = true,
		[400236] = true,
		[400247] = true,
		[400386] = true,
		[300184] = true,
		[300166] = true,
		[300259] = true,
		[400387] = true,
		[400153] = true,
		[400155] = true,
		[400502] = true,
		[400503] = true,
		[400409] = true,
		[136407] = true,
		[400572] = true,
		[400570] = true,
		[400319] = true,
		[400575] = true,
		[400580] = true,
		[400581] = true,
		[400586] = true,
		[400587] = true,
		[400318] = true,
		[400567] = true,
		[400568] = true,
		[400569] = true,
		[400571] = true,
		[400573] = true,
		[400584] = true,
		[400585] = true,
		[400493] = true,
		[400494] = true,
		[300159] = true, -- shared level1
		[300187] = true,
		[300233] = true,
		[300271] = true,
		[300100] = true,
		[300326] = true,
		[400051] = true,
		[400845] = true, -- shared restroom
		[400333] = true,
		[400846] = true,
		[300466] = true, -- shared back/storage
		[300468] = true,
		[300490] = true,
		[400853] = true,
	}
	local ids_level1 = {
		[300739] = true,
		[300740] = true,
		[300759] = true,
		[300774] = true,
		[400351] = true,
		[400127] = true,
		[300305] = true,
		[300125] = true, -- shared back
		[300127] = true,
		[400240] = true,
		[400280] = true,
		[400281] = true,
		[300453] = true,
		[300463] = true,
		[300481] = true,
		[300464] = true,
		[300678] = true,
		[300666] = true,
		[300194] = true,
		[400434] = true,
		[300465] = true,
		[300057] = true, -- shared storage
	}
	local ids_back = {
		[300742] = true,
	}
	local ids_auction_room = {}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if not Celer.can_be_added_to_unit_group(name) or name == 'units/pd2_dlc_sah/props/sah_interactable_hackbox/sah_interactable_hackbox' then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		if unit_id == 500000 or (x == 0 and y == 0 and z == 0) or name:find('sah_main_mesh') or name:find('sah_vault') then
			-- qued
		elseif x >= -746 and x <= 743 and y >= -554 and y <= 378 and z >= -1 and z <= 223 -- comptoir
		or x >= -1173 and x <= 1173 and y >= -1338 and y <= 0 and z >= -8 and z <= 754 -- entree
		or x >= -1416 and x <= 765 and y >= -1432 and y <= -1001 and z >= -8 and z <= 1214 -- fenetres
		or x >= -1267 and x <= 1267 and y >= -1421 and y <= -1148 and z >= 99 and z <= 942 -- dehors pres
		or x >= -2170 and x <= -1600 and y >= -553 and y <= 362 and z >= -149 and z <= 283 -- fontaine
		or x >= 1967 and x <= 2225 and y >= -380 and y <= 363 and z >= -146 and z <= 283 -- fontaine
		or x >= -345 and x <= 334 and y >= -29 and y <= 87 and z >= 510 and z <= 997 -- statues
		then
			ids_lobby[unit_id] = true
		end

		if x >= -1300 and x <= -1018 and y >= 85 and y <= 525 and z >= 0 and z <= 400
		or x >= 1031 and x <= 1725 and y >= -150 and y <= 1025 and z >= -1 and z <= 300
		then
			ids_lobby[unit_id] = nil
			ids_restroom[unit_id] = true
		end

		if x >= 999 and x <= 1825 and y >= 1289 and y <= 2400 and z >= -102 and z <= 299 -- side room right
		or x >= -2214 and x <= -2125 and y >= 875 and y <= 2750 and z >= -100 and z <= 223 -- zone inacc gauche
		or x >= -2000 and x <= -1490 and y >= 3312 and y <= 3525 and z >= -100 and z <= 300 -- side room left, part 1
		then
			ids_level0[unit_id] = true
		end

		if x >= -591 and x <= 1358 and y >= 3460 and y <= 5230 and z >= -112 and z <= 288
		or x >= 202 and x <= 739 and y >= 3338 and y <= 3994 and z >= 38 and z <= 210
		or x >= -2200 and x <= -999 and y >= 2400 and y <= 2866 and z >= -100 and z <= 250 -- zone inacc gauche
		or x >= -2002 and x <= -1527 and y >= 2948 and y <= 3311 and z >= -100 and z <= 300 -- side room left, part 2
		or x >= 1025 and x <= 2250 and y >= 2025 and y <= 3225 and z >= 500 and z <= 823 -- shared level1 stairs BR
		or x >= -2225 and x <= -225 and y >= 3675 and y <= 5272 and z >= -100 and z <= 823 and unit_id ~= 300315 -- shared back
		then
			ids_storage[unit_id] = true
			if unit_id ~= 300466 and unit_id ~= 300490 and unit_id ~= 400853 and unit_id ~= 300468 then 
				ids_level0[unit_id] = nil
			end
		end

		if x >= -2225 and x <= -225 and y >= 3675 and y <= 5272 and z >= -100 and z <= 823 and unit_id ~= 300315 then -- shared storage
			ids_back[unit_id] = true
		end

		if x >= -2727 and x <= -927 and y >= 621 and y <= 3450 and z >= 497 and z <= 855 -- left
		or x >= 928 and x <= 2739 and y >= 581 and y <= 3581 and z >= 497 and z <= 830 -- right
		or x >= -293 and x <= 310 and y >= 415 and y <= 471 and z >= 500 and z <= 574 -- middle front side
		or x >= -293 and x <= 310 and y >= 3564 and y <= 3604 and z >= 500 and z <= 579 -- middle back side
		or x >= -1050 and x <= 1075 and y >= 75 and y <= 377 and z >= 500 and z <= 800 -- utility rooms
		or x >= 1290 and x <= 1375 and y >= 3675 and y <= 4575 and z >= 500 and z <= 823 -- shared back
		then
			ids_level1[unit_id] = true
		end

		if x >= -3390 and x <= 3400 and y >= -12068 and y <= -1470 and z >= -162 and z <= 351 then -- limo area
			if not ids_lobby[unit_id] then
				ids_level1[unit_id] = true
			end
			ids_lobby[unit_id] = true
		end

		if x >= -2225 and x <= 1375 and y >= 3675 and y <= 5275 and z >= 500 and z <= 823 then
			if unit_id ~= 300315 and not ids_level1[unit_id] then
				ids_back[unit_id] = true
			end
		end

		if x >= -2200 and x <= 975 and y >= 739 and y <= 3550 and z >= -105 and z <= 502
		or x >= 1000 and x <= 1400 and y >= 825 and y <= 1250 and z >= -102 and z <= -100
		then
			if ids_restroom[unit_id] or unit_id == 300795 or unit_id == 400254 or unit_id == 400212 then
				-- qued
			elseif not ids_level0[unit_id] then
				ids_level0[unit_id] = true
				ids_auction_room[unit_id] = true
			end
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
			if name:find('_limo') then
				unit:damage():run_sequence_simple('state_interaction_disabled')
			end
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups.lobby = {
				ids = ids_lobby,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3000, -5200, -150),
						width = 6100,
						depth = 6000,
						height = 1200,
					}
				}
			}
			self._definition.portal.unit_groups.restroom = {
				ids = ids_restroom,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1325, -1400, -100),
						width = 3125,
						depth = 3100,
						height = 600,
					}
				}
			}
			self._definition.portal.unit_groups.storage = {
				ids = ids_storage,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2200, 2025, -100),
						width = 4425,
						depth = 3200,
						height = 550,
					}
				}
			}
			self._definition.portal.unit_groups.level0 = {
				ids = ids_level0,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3000, -575, -100),
						width = 6100,
						depth = 5875,
						height = 401,
					}
				}
			}
			self._definition.portal.unit_groups.level1 = {
				ids = ids_level1,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3000, -575, 300),
						width = 6100,
						depth = 5875,
						height = 700,
					}
				}
			}
			self._definition.portal.unit_groups.back = {
				ids = ids_back,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3000, 3250, 300),
						width = 4890,
						depth = 2025,
						height = 700,
					}
				}
			}
			self._definition.portal.unit_groups.auction_room = {
				ids = ids_auction_room,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-1005, 400, -100),
						width = 2010,
						depth = 3250,
						height = 1000,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

elseif level_id == 'vit' then

	Celer:spawn_occluder('12x8', Vector3(-2650, 3600, 0), Rotation(-90, 0, 0)) -- main
	Celer:spawn_occluder('12x8', Vector3(-2650, 3600, 0), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-680, 4825, -200), Rotation(90, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(-680, 4825, -200), Rotation(90, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(900, 3455, 200), Rotation(0, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(900, 3450, 200), Rotation(0, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(-2800, 2475, -275), Rotation(0, 0, 0))
	Celer:spawn_occluder('16x8', Vector3(-2800, 2475, -275), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(-2630, 3800, 0), Rotation(-90, 0, -90))
	Celer:spawn_occluder('16x16', Vector3(-2630, 3800, 0), Rotation(-90, 0, -90), true)

	Celer:spawn_occluder('7x8', Vector3(-790, 3400, -400), Rotation(0, 0, 0))
	Celer:spawn_occluder('7x8', Vector3(-790, 3400, -400), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('16x16', Vector3(1400, 5400, 350), Rotation(90, 0, -90))
	Celer:spawn_occluder('16x16', Vector3(1400, 4050, 350), Rotation(90, 0, -90))

	Celer:spawn_occluder('4x8', Vector3(475, 3075, -50), Rotation(-90, 0, 0)) -- diplomatic
	Celer:spawn_occluder('4x8', Vector3(475, 3075, -50), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('10x8', Vector3(120, 3400, -400), Rotation(0, 0, 0))
	Celer:spawn_occluder('10x8', Vector3(120, 3400, -400), Rotation(0, 0, 0), true)

	Celer:spawn_occluder('4x8', Vector3(-450, 3075, -50), Rotation(-90, 0, 0))
	Celer:spawn_occluder('4x8', Vector3(-450, 3075, -50), Rotation(-90, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-7970, 2675, -600), Rotation(90, 0, -90)) -- west
	Celer:spawn_occluder('16x8', Vector3(-7970, 2675, -600), Rotation(90, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(-9625, 1150, -600), Rotation(180, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(-9625, 1150, -600), Rotation(180, 0, -90), true)

	Celer:spawn_occluder('16x8', Vector3(-7625, 3260, 600), Rotation(0, 0, 180))
	Celer:spawn_occluder('16x8', Vector3(-7625, 3260, 600), Rotation(0, 0, 180), true)

	Celer:spawn_occluder('16x8', Vector3(-8275, 1400, -600), Rotation(180, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(-8275, 1400, -600), Rotation(180, 0, -90), true)

	Celer:spawn_occluder('16x16', Vector3(-8510, 980, -700), Rotation(-135, 0, 0))
	Celer:spawn_occluder('16x16', Vector3(-8510, 980, -700), Rotation(-135, 0, 0), true)

	Celer:spawn_occluder('16x8', Vector3(-9350, 1885, -600), Rotation(180, 0, -90))
	Celer:spawn_occluder('16x8', Vector3(-9350, 1885, -600), Rotation(180, 0, -90), true)

	local ids_peoc = {
		[601157] = true,
		[900263] = true,
		[900337] = true,
		[165054] = true,
		[900365] = true,
		[901285] = true,
	}
	local ids_outside = {}
	local ids_air = {
		[500728] = true,
		[900619] = true, -- shared diplomatic/garden/air
		[500033] = true, -- shared garden
		[900336] = true, -- shared garden/press_room/west_wing/air
	}
	local ids_press_room = {
		[500005] = true,
		[900336] = true, -- shared garden/press_room/west_wing/air
		[900630] = true,
		[900165] = true,
		[901099] = true, -- shared garden/press_room/west_wing/ground_floor
		[100697] = true, -- shared west_wing
		[900955] = true,
		[900858] = true,
		[103877] = true,
		[600125] = true,
		[600132] = true,
	}
	local ids_garden = {
		[500728] = true,
		[900619] = true, -- shared diplomatic/garden/air
		[900336] = true, -- shared garden/press_room/west_wing/air
		[500033] = true, -- shared air
		[500363] = true, -- shared press_room/air/west_wing
		[900165] = true, -- shared west_wing/main_building/garden
		[901099] = true, -- shared garden/press_room/west_wing/ground_floor
		[900513] = true, -- shared garden/tunnel/west_wing
	}
	local ids_main_building = {
		[600485] = true,
		[600486] = true,
		[600488] = true,
		[600090] = true, -- shared garden
		[600094] = true,
		[600504] = true, -- shared tunnel
		[600921] = true,
		[102510] = true,
		[600089] = true,
		[600320] = true,
		[600087] = true,
		[600505] = true,
		[600920] = true,
		[155366] = true,
		[155666] = true,
		[900368] = true,
		[900379] = true,
		[600973] = true,
		[900481] = true,
		[901297] = true, -- shared helipad/tunnel/main
	}
	local ids_west_wing = {
		[900955] = true,
		[901156] = true,
		[900336] = true, -- shared garden/press_room/west_wing/air
		[500363] = true, -- shared press_room/air/west_wing
		[900165] = true, -- shared west_wing/main_building/garden
		[900513] = true, -- shared garden/tunnel/west_wing
		[901099] = true, -- shared garden/press_room/west_wing/ground_floor
	}
	local ids_helipad = {
		[900481] = true,
		[600320] = true,
		[901297] = true, -- shared helipad/tunnel/main
		[600514] = true, -- shared tunnel
		[600515] = true,
		[102009] = true,
		[102110] = true,
		[102511] = true,
		[155366] = true, -- shared diplomatic
		[156592] = true,
		[600087] = true,
		[600089] = true,
		[600332] = true,
		[600333] = true,
		[600453] = true,
		[600884] = true,
		[600885] = true,
		[600986] = true,
		[900307] = true,
		[900393] = true,
		[901181] = true,
		[600886] = true,
		[600887] = true,
		[800351] = true,
		[800352] = true,
		[900511] = true,
		[900872] = true,
		[102016] = true,
		[155666] = true, -- shared main
	}
	local ids_library = {
		[600087] = true, -- shared diplomatic
		[901181] = true,
	}
	local ids_diplomatic = {}
	local ids_tunnel = {
		[900956] = true,
		[600834] = true, -- shared press
		[600835] = true,
		[600836] = true,
		[102281] = true,
		[102273] = true,
		[600839] = true,
		[600819] = true,
		[600820] = true,
		[600505] = true, -- shared main_building
		[900818] = true,
		[600504] = true,
		[600506] = true,
		[101236] = true,
		[500088] = true, -- shared main_building/press_room
		[500091] = true,
		[900513] = true, -- shared garden/tunnel/west_wing
		[901297] = true, -- shared helipad/tunnel/main
		[155666] = true,
		[900481] = true,
		[901099] = true, -- shared garden/press_room/west_wing/ground_floor
		[102278] = true, -- shared press_room
		[500090] = true, -- veg
	}

	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		local name = data.name
		if name:find('units/payday2/architecture/mkp/') then
			return
		elseif not Celer.can_be_added_to_unit_group(name)
		or data.instance == 'unobtanium_001'
		then
			return cel_original_worlddefinition_makeunit(self, data, ...)
		end

		if unit_id == 600418 then
			data.position = Vector3(1350, 4540, 1106)
		end

		local pos = data.position
		local x, y, z = pos.x, pos.y, pos.z

		-- can't be seen
		if y > 5100 and name:find('units/pd2_dlc_vit/architecture/vit_building_main/vit_ext_window_small_')
		or x >= 1710 and x <= 2787 and y >= 4000 and y <= 5296 and z >= 502 and z <= 506
		or unit_id == 500380
		or unit_id == 900416
		or unit_id == 900613
		or unit_id == 900614
		or unit_id == 900778
		or unit_id == 900565
		or unit_id == 900572
		or unit_id == 900573
		or unit_id == 900574
		or unit_id == 900637
		or unit_id == 900651
		or unit_id == 900633
		or unit_id == 141442
		or x > 2800 and name == 'units/pd2_dlc_vit/architecture/vit_building_main/vit_ext_pillar_wall'
		then
			return
		end

		if x >= 3840 and x <= 5169 and y >= 4174 and y <= 4574 and z >= -435 and z <= -78 -- tunnel
		or x >= 5650 and x <= 11000 and y >= 2600 and y <= 6600 and z >= -2026 and z <= 322 -- room
		then
			ids_peoc[unit_id] = true
		end

		if x >= -4976 and x <= -3647 and y >= 3475 and y <= 4177 and z >= -2 and z <= 396
		or x >= -8375 and x <= -5175 and y >= 3274 and y <= 4200 and z >= -2 and z <= 400
		then
			ids_press_room[unit_id] = true
		end

		if name == 'units/pd2_dlc_vit/architecture/vit_building_main/vit_ext_pillar_wall' then
			ids_garden[unit_id] = true
			ids_air[unit_id] = true
			if x < -900 then
				ids_west_wing[unit_id] = true
			end
			if x < -2700 then
				ids_press_room[unit_id] = true
			end
		end

		if unit_id == 900382
		or x < -3000 and name == 'units/pd2_dlc_vit/architecture/vit_ext/vit_ext_west_wing/vit_ext_white_pillar_01'
		then
			ids_press_room[unit_id] = true
			ids_west_wing[unit_id] = true
			ids_garden[unit_id] = true
			ids_air[unit_id] = true
		end

		if x >= -8759 and x <= -7386 and y >= 2924 and y <= 3250 and z >= 79 and z <= 450
		or x >= -10988 and x <= -7282 and y >= -245 and y <= 2957 and z >= 70 and z <= 505
		then
			ids_west_wing[unit_id] = true
		end

		if x >= -8700 and x <= -7378 and y >= -300 and y <= 1200 then -- oval office from ext
			if name:find('str_prop_street_planter_cypress')
			or name:find('vit_prop_oval_office_w')
			or name:find('vit_prop_oval_office_d')
			or name:find('vit_prop_oval_office_cu')
			or name:find('vit_int_oval_office_')
			then
				ids_west_wing[unit_id] = true
				ids_press_room[unit_id] = true
				ids_garden[unit_id] = true
				ids_air[unit_id] = true
			elseif name:find('vit_prop_oval_office_') then
				ids_garden[unit_id] = true
			end
		end

		if x >= -7963 and x <= -7387 and y >= 1867 and y <= 2916 and z >= 80 and z <= 351 then
			if name:find('curtains') or name:find('cabinetroom_chair')	or name:find('painting') then
				ids_garden[unit_id] = true
			end
		end

		if x >= -7360 and x <= -7282 and y >= 1050 and y <= 3022 and z >= 74 and z <= 83 -- mostly west wing glass doors
		or x >= -7104 and x <= -7025 and y >= 0 and y <= 2575 and z >= 75 and z <= 75 -- pillars
			and (name:find('pillar') or name:find('vit_prop_planter_s_portico'))
		or unit_id == 101548
		then
			ids_west_wing[unit_id] = true
			ids_press_room[unit_id] = true
			ids_garden[unit_id] = true
			ids_air[unit_id] = true
		end

		if x >= -2748 and x <= -2733 and y >= 2841 and y <= 5097 and z >= 425 and z <= 1185 -- ext windows left main
		or x < -778 and y >= 2450 and y <= 2460 and name:find('vit_building_main/vit_ext_window_large_')
		or name == 'units/pd2_dlc_vit/architecture/vit_backdrop/vit_backdrop_tile'
		then
			ids_west_wing[unit_id] = true
			ids_garden[unit_id] = true
			ids_air[unit_id] = true
		end

		if x >= -1300 and x <= 1395 and y >= 2246 and y <= 3357 and z >= -1 and z <= 376 then
			ids_diplomatic[unit_id] = true
			if y > 3225 then
				ids_helipad[unit_id] = true
			end
		end

		if name:find('vit_prop_ext_portico_gate') then
			ids_garden[unit_id] = true
			ids_diplomatic[unit_id] = true
			ids_air[unit_id] = true
		end

		if x >= -6925 and x <= -4800 and y >= 3265 and y <= 3275 and z >= 0 and z <= 250 then -- glass_door_top
			ids_press_room[unit_id] = true
			ids_garden[unit_id] = true
		end

		if x >= -3761 and x <= -2651 and y >= 3000 and y <= 4147 and z >= -1 and z <= 421 and unit_id ~= 600811 -- room with crashed humvee
		or x >= -4700 and x <= -3725 and y >= 3265 and y <= 3275 and z >= 0 and z <= 250 -- glass_door_top
		then
			ids_tunnel[unit_id] = true
			ids_press_room[unit_id] = true
			ids_garden[unit_id] = true
		end

		if unit_id == 600572 or unit_id == 600573 then
			ids_helipad[unit_id] = true
			ids_diplomatic[unit_id] = true
		end

		if x >= -644 and x <= 690 and y >= 1127 and y <= 1773 and z >= 0 and z <= 4 then -- bench/doors
			ids_diplomatic[unit_id] = true
			ids_garden[unit_id] = true
			ids_air[unit_id] = true
		end

		if x >= -2649 and x <= 1365 and y >= 2440 and y <= 5296 and z >= 396 and z <= 1150
		or x >= -396 and x <= 450 and y >= 2264 and y <= 2640 and z >= 400 and z <= 623
		then
			ids_main_building[unit_id] = true
		end

		if x >= 1507 and x <= 2787 and y >= 2454 and y <= 3152 and z >= 495 and z <= 506 -- qqs vit_ext_window_large
		or x >= 1069 and x <= 2402 and y >= 2436 and y <= 2437 and z >= 78 and z <= 81 -- qqs windows ground
		or unit_id == 600090
		or unit_id == 600094
		or unit_id == 900465
		or unit_id == 900625
		or unit_id == 900639
		or unit_id == 900641
		or x > -782 and z > 1180 and name == 'units/pd2_dlc_vit/architecture/vit_building_main/vit_ext_window_small_a'
		then
			ids_garden[unit_id] = true
			ids_air[unit_id] = true
		end

		if x >= 904 and x <= 1350 and y >= 4857 and y <= 5296 and z >= 399 and z <= 602 -- shared main_building
		or x >= -1163 and x <= -701 and y >= 4862 and y <= 5296 and z >= 399 and z <= 513 -- shared main_building
		then
			if not name:find('mullplan') then
				ids_tunnel[unit_id] = true
			end
		end

		if x >= 1315 and x <= 1350 and y >= 2658 and y <= 2987 and z >= -1 and z <= 0
		or x >= -1300 and x <= -1259 and y >= 2566 and y <= 2925 and z >= -1 and z <= 192
		then
			ids_garden[unit_id] = true
		end

		if x >= -365 and x <= 400 and y >= 1668 and y <= 1774 and z >= 410 and z <= 416
		or unit_id == 101397 -- entrance stuff visible from outside
		or unit_id == 600405
		or unit_id == 600410
		or unit_id == 600411
		or unit_id == 600428
		or unit_id == 600434
		or unit_id == 600435
		or unit_id == 600493
		or unit_id == 600856
		or unit_id == 600858
		or unit_id == 600860
		or unit_id == 900113
		or unit_id == 900116
		or unit_id == 900196
		or unit_id == 900733
		or unit_id == 900734
		or unit_id == 900736
		or unit_id == 900771
		or unit_id == 900772
		or unit_id == 900775
		or unit_id == 900803
		or unit_id == 900804
		or unit_id == 900808
		or unit_id == 900814
		or unit_id == 900815
		or unit_id == 500378 -- outside props
		or unit_id == 500002
		then
			ids_main_building[unit_id] = true
			ids_garden[unit_id] = true
			ids_air[unit_id] = true
		end

		-- vegetation
		if z > -500 and name:find('tree') or name:find('hedge') or name:find('_bush_') then
			if x > -5600 and x < 4000 and y < 600
			or unit_id == 500044 or unit_id == 500073 or unit_id == 500074 or unit_id == 500075 or unit_id == 500076
			then
				ids_main_building[unit_id] = true
				ids_garden[unit_id] = true
				ids_air[unit_id] = true
				if x > -2600 or y < -3400 then
					ids_diplomatic[unit_id] = true
				end
			end
			if unit_id == 500514 or unit_id == 500515
			or unit_id == 500477 or unit_id == 500588
			or unit_id == 500508 or unit_id == 500507 or unit_id == 500506 or unit_id == 500505 or unit_id == 500504
			or x > -3000 and x < -800 and y > 600 and y < 2400
			then
				ids_garden[unit_id] = true
				ids_diplomatic[unit_id] = true
				ids_air[unit_id] = true
			end
			if y < 2900 then
				ids_garden[unit_id] = true
				ids_air[unit_id] = true
				if x > 500 and (name:find('hedge') or name:find('_bush_') or name:find('littleleaf') or name:find('_birch_'))
				or x > 2500 and y > -1300 and name:find('tree')
				then
					-- qued
				else
					ids_west_wing[unit_id] = true
				end
				if x < 500 then
					ids_press_room[unit_id] = true
				end
			end
		end

		-- some outside stuff, behind
		if y > 7300 or unit_id == 500003 or unit_id == 900556
		or x >= -724 and x <= 769 and y >= 5296 and y <= 6716 and z >= 415 and z <= 416 -- pillars
		or unit_id == 900556
		then
			ids_main_building[unit_id] = true
			ids_press_room[unit_id] = true
			ids_air[unit_id] = true
		end
		if x < -3000 and y > 4225 or unit_id == 500363 then
			ids_press_room[unit_id] = true
			ids_air[unit_id] = true
		end

		-- ground floor subareas
		if x >= 1527 and x <= 2800 and y >= 4052 and y <= 5026 and z >= -16 and z <= 395
		or x >= 493 and x <= 626 and y >= 2512 and y <= 2773 and z >= -1 and z <= 206 -- porcelain from diplo
		then
			ids_library[unit_id] = true
		end

		if x >= -2625 and x <= 2686 and y >= 3398 and y <= 4001 and z >= -1 and z <= 357 --tunnel
		or x >= 2846 and x <= 3723 and y >= 3289 and y <= 3923 and z >= 0 and z <= 423 -- end room
		then
			ids_tunnel[unit_id] = true
		end

		if not ids_west_wing[unit_id]
		and not ids_helipad[unit_id]
		and not ids_diplomatic[unit_id]
		and not ids_tunnel[unit_id]
		and not ids_library[unit_id]
		and not ids_main_building[unit_id]
		and not ids_press_room[unit_id]
		and not ids_garden[unit_id]
		and not ids_peoc[unit_id]
		then
			ids_outside[unit_id] = true
		elseif ids_west_wing[unit_id]
		and ids_helipad[unit_id]
		and ids_diplomatic[unit_id]
		and ids_tunnel[unit_id]
		and ids_library[unit_id]
		and ids_main_building[unit_id]
		and ids_press_room[unit_id]
		and ids_garden[unit_id]
		and ids_air[unit_id]
		then
			ids_outside[unit_id] = true
			ids_west_wing[unit_id] = nil
			ids_helipad[unit_id] = nil
			ids_library[unit_id] = nil
			ids_diplomatic[unit_id] = nil
			ids_tunnel[unit_id] = nil
			ids_main_building[unit_id] = nil
			ids_press_room[unit_id] = nil
			ids_garden[unit_id] = nil
			ids_air[unit_id] = nil
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)
		if unit then
			managers.portal:add_unit(unit)
		end

		return unit
	end

	function WorldDefinition:create(layer, offset)
		if (layer == 'portal' or layer == 'all') and self._definition.portal then
			self._definition.portal.unit_groups = {}

			self._definition.portal.unit_groups.main_building = {
				ids = ids_main_building,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2700, 1500, 350),
						width = 5500,
						depth = 4000,
						height = 1000,
					}
				}
			}
			self._definition.portal.unit_groups.helipad = {
				ids = ids_helipad,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2300, -3300, 0),
						width = 9500,
						depth = 5750,
						height = 475,
					}
				}
			}
			self._definition.portal.unit_groups.library = {
				ids = ids_library,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(525, 2580, -700),
						width = 6000,
						depth = 2400,
						height = 1175,
					}
				}
			}
			self._definition.portal.unit_groups.diplomatic = {
				ids = ids_diplomatic,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2000, 1650, 0),
						width = 3575,
						depth = 3000,
						height = 350,
					}
				}
			}
			self._definition.portal.unit_groups.tunnel = {
				ids = ids_tunnel,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5100, 2425, -700),
						width = 11500,
						depth = 2700,
						height = 1100,
					}
				}
			}
			self._definition.portal.unit_groups.press_room = {
				ids = ids_press_room,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-8400, 2900, 0),
						width = 6500,
						depth = 1300,
						height = 450,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-3650, 2200, 0),
						width = 1000,
						depth = 2000,
						height = 450,
					},
					{
						rotation = Rotation(125, 0, 0),
						position = Vector3(-8000, 2900, 100),
						width = 800,
						depth = 1000,
						height = 350,
					}
				}
			}
			self._definition.portal.unit_groups.garden = {
				ids = ids_garden,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-2650, -3550, 0),
						width = 4100,
						depth = 6125,
						height = 1000,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5000, -1000, 0),
						width = 3750,
						depth = 4000,
						height = 450,
					}
				}
			}
			self._definition.portal.unit_groups.west_wing = {
				ids = ids_west_wing,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-10000, -1250, 0),
						width = 2800,
						depth = 5500,
						height = 450,
					}
				}
			}
			self._definition.portal.unit_groups.air = {
				ids = ids_air,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-5100, -20000, 470),
						width = 11500,
						depth = 20000,
						height = 5000,
					}
				}
			}
			self._definition.portal.unit_groups.outside = {
				ids = ids_outside,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(-13100, -27400, -900),
						width = 25603,
						depth = 34687,
						height = 4000,
					}
				}
			}
			self._definition.portal.unit_groups.peoc = {
				ids = ids_peoc,
				shapes = {
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(2800, 4050, -600),
						width = 3000,
						depth = 650,
						height = 1000,
					},
					{
						rotation = Rotation(0, 0, 0),
						position = Vector3(5650, 2000, -3000),
						width = 5000,
						depth = 8000,
						height = 3000,
					}
				}
			}
		end

		return cel_original_worlddefinition_create(self, layer, offset)
	end

end

if Celer.settings.patch_duplicate_unit_ids then
	Celer.known_units = {}
	local new_id = 2200000
	local cel_original_worlddefinition_makeunit = WorldDefinition.make_unit
	function WorldDefinition:make_unit(data, ...)
		local unit_id = data.unit_id
		if unit_id then
			local previous_data = Celer.known_units[unit_id]
			if previous_data then
				if previous_data.name == data.name and previous_data.position == data.position and previous_data.rotation == data.rotation then
					log('[Celer] ignored duplicate of unit ' .. unit_id)
					return
				end

				while Celer.known_units[new_id] do
					new_id = new_id + 1
				end

				local portals_patched
				for name, group in pairs(managers.portal._unit_groups) do
					if group._ids[unit_id] then
						portals_patched = true
						group._ids[new_id] = true
					end
				end
				if portals_patched and alive(previous_data.unit) then
					managers.portal:remove_from_hide_list(previous_data.unit)
					managers.portal:delete_unit(previous_data.unit)
					managers.portal:remove_unit(previous_data.unit)
				end

				log('[Celer] ID collision on ' .. unit_id .. ', new entry remapped to ' .. new_id .. (portals_patched and ' (portals patched)' or ''))
				-- log('	' .. tostring(previous_data.name))
				-- log('	' .. tostring(data.name))
				data.unit_id = new_id
				data.cel_original_unit_id = unit_id
				unit_id = new_id
			end
			Celer.known_units[unit_id] = data
		end

		local unit = cel_original_worlddefinition_makeunit(self, data, ...)

		if unit_id then
			data.unit = unit
		end

		return unit
	end
end
