_G.BDB_Format_Base = _G.BDB_Format_Base or class()
BDB_Format_Base._default_url = 'invalid_url'
BDB_Format_Base._url = nil
BDB_Format_Base._tag = 'invalid_tag'

function BDB_Format_Base:set_url(url)
	self._url = url
end

function BDB_Format_Base:reset_skills()
	for tree, tree_data in ipairs(tweak_data.skilltree.trees) do
		local points_spent = managers.skilltree:points_spent(tree)
		managers.skilltree:_set_points_spent(tree, 0)
		for i = #tree_data.tiers, 1, -1 do
			local tier = tree_data.tiers[i]
			for _, skill in ipairs(tier) do
				managers.skilltree:_unaquire_skill(skill)
			end
		end
		managers.skilltree:_aquire_points(points_spent, true)
	end
end

function BDB_Format_Base:invest(tree, skill_id, tier, step)
	if not managers.skilltree:has_enough_skill_points(skill_id) then
		return false
	end

	if not managers.skilltree:skill_unlocked(tree, skill_id) then
		return false
	end

	if not managers.skilltree:unlock(skill_id) then
		return false
	end

	local points = managers.skilltree:skill_cost(tier, step)
	local skill_points = managers.skilltree:spend_points(points)
	managers.skilltree:_set_points_spent(tree, managers.skilltree:points_spent(tree) + points)

	if managers.menu_component._skilltree_gui then
		managers.menu_component._skilltree_gui:set_skill_point_text(skill_points)
	end

	return true
end

function BDB_Format_Base:get_deployable_rank(i)
	local equipped = managers.blackmarket:equipped_deployable(i)
	for rank, tbl in ipairs(managers.blackmarket:get_sorted_deployables()) do
		if tbl[1] == equipped then
			return rank
		end
	end
end

function BDB_Format_Base:get_second_deployable_rank()
	return self:get_deployable_rank(2)
end

function BDB_Format_Base:get_deployable_name(rank)
	local deployables = managers.blackmarket:get_sorted_deployables()
	return deployables and deployables[rank] and deployables[rank][1]
end

function BDB_Format_Base:get_throwable_rank()
	local equipped = managers.blackmarket:equipped_grenade()
	for rank, tbl in ipairs(managers.blackmarket:get_sorted_grenades()) do
		if tbl[1] == equipped then
			return rank
		end
	end
end

function BDB_Format_Base:get_throwable_name(rank)
	local grenades = managers.blackmarket:get_sorted_grenades()
	return grenades and grenades[rank] and grenades[rank][1]
end

function BDB_Format_Base:import(url)
	return false
end
