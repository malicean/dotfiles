if not BDB_Format_Base then
	dofile(ModPath .. 'lua/_format.lua')
end

_G.BDB_Format_PD2Builder = _G.BDB_Format_PD2Builder or class(BDB_Format_Base)
BDB_Format_PD2Builder._default_url = 'https://pd2builder.netlify.app/'
BDB_Format_PD2Builder._tag = 'pd2builder'

BuilDB:register_url_format(BDB_Format_PD2Builder, true)

BDB_Format_PD2Builder.charString = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,@'

function BDB_Format_PD2Builder:encode_byte(i)
	return self.charString:sub(i + 1, i + 1)
end

function BDB_Format_PD2Builder:decode_byte(c)
	local result = self.charString:find(c, 1, true)
	return result and (result - 1) or -1
end

function BDB_Format_PD2Builder:compress_data(data)
	local count = 1
	local thing = data:sub(1, 1)
	local compressed = ''
	for i = 2, data:len() + 1 do
		local value = data:sub(i, i)
		if value == thing then
			if count > 8 then
				compressed = compressed .. thing .. '-' .. count
				count = 0
			end
			count = count + 1
			goto continue
		end
		if count > 3 then
			compressed = compressed .. thing .. '-' .. count
		else
			compressed = compressed .. thing:rep(count)
		end
		thing = value
		count = 1
		::continue::
	end
	return compressed
end

function BDB_Format_PD2Builder:decompress_data(data)
	data = data:gsub('%%2C', ','):gsub('%%40', '@')
	local decompressed = ''
	local i = 1
	while i <= data:len() do
		local c = data:sub(i, i)
		if data:sub(i + 1, i + 1) == '-' then
			i = i + 2
			decompressed = decompressed .. c:rep(tonumber(data:sub(i, i)))
		else
			decompressed = decompressed .. c
		end
		i = i + 1
	end
	return decompressed
end

function BDB_Format_PD2Builder:get_build_url()
	local skills = ''
	for tree, data in ipairs(tweak_data.skilltree.trees) do
		local subtreeBasicChar = 0
		local subtreeAcedChar = 0
		for i = #data.tiers, 1, -1 do
			local tier = data.tiers[i]
			for _, skill_id in ipairs(tier) do
				local step = managers.skilltree:skill_step(skill_id)
				if step == 1 then
					subtreeBasicChar = bit.bor(subtreeBasicChar, 1)
				elseif step == 2 then
					subtreeAcedChar = bit.bor(subtreeAcedChar, 1)
				end
				subtreeBasicChar = bit.lshift(subtreeBasicChar, 1)
				subtreeAcedChar = bit.lshift(subtreeAcedChar, 1)
			end
		end
		subtreeBasicChar = bit.rshift(subtreeBasicChar, 1) -- undo the last lshift
		subtreeAcedChar = bit.rshift(subtreeAcedChar, 1)
		skills = skills .. self:encode_byte(subtreeBasicChar) .. self:encode_byte(subtreeAcedChar)
	end

	local throwable = self:get_throwable_rank()
	throwable = throwable and ('&t=' .. self:encode_byte(throwable - 1)) or ''

	local deployable = self:get_deployable_rank()
	if not deployable then
		deployable = ''
	else
		deployable = '&d=' .. self:encode_byte(deployable - 1)
		local deployable2 = self:get_second_deployable_rank()
		if deployable2 then
			deployable = deployable .. self:encode_byte(deployable2 - 1)
		end
	end

	local result = (self._url or self._default_url)
		.. '?s=' .. self:compress_data(skills)
		.. '&p=' .. self:encode_byte(managers.skilltree:digest_value(Global.skilltree_manager.specializations.current_specialization, false, 1) - 1)
		.. '&a=' .. self:encode_byte(managers.blackmarket:equipped_armor():sub(-1) - 1)
		.. throwable
		.. deployable

	return result
end

function BDB_Format_PD2Builder:parse_url(url)
	local result = {}
	for k, v in url:gmatch('(%w)=([^&]+)') do
		if k == 's' then
			result[k] = self:decompress_data(v)
		elseif k == 'd' then
			result[k] = v
		else
			result[k] = self:decode_byte(v) + 1
		end
	end
	return result
end

function BDB_Format_PD2Builder:import(url)
	local params = self:parse_url(url)

	if params.s then
		self:reset_skills()

		local skills = {}
		for v in params.s:gmatch('.') do
			table.insert(skills, self:decode_byte(v))
		end
		if #skills ~= #tweak_data.skilltree.trees * 2 then
			return false, 'number of skill trees mismatch'
		end

		for tree_id, tree in ipairs(tweak_data.skilltree.trees) do
			local subtreeBasicChar = skills[tree_id * 2 - 1]
			local subtreeAcedChar = skills[tree_id * 2]
			for tier_id, tier in ipairs(tree.tiers) do
				for j = #tier, 1, -1 do
					local skill = tier[j]
					local level = bit.band(subtreeAcedChar, 1) == 1 and 2 or bit.band(subtreeBasicChar, 1) == 1 and 1 or 0
					for i = 1, level do
						if not self:invest(tree_id, skill, tier_id, i) then
							return false, 'cannot aquire ' .. skill
						end
					end
					subtreeBasicChar = bit.rshift(subtreeBasicChar, 1)
					subtreeAcedChar = bit.rshift(subtreeAcedChar, 1)
				end
			end
		end
	end

	if params.p then
		managers.skilltree:set_current_specialization(tonumber(params.p))
	end

	if params.a then
		managers.blackmarket:equip_armor('level_' .. tonumber(params.a))
	end

	if params.t then
		managers.blackmarket:equip_grenade(self:get_throwable_name(tonumber(params.t)))
	end

	if params.d then
		for i = 1, params.d:len() do
			local d = self:decode_byte(params.d:sub(i, i)) + 1
			local deployable = d and self:get_deployable_name(tonumber(d))
			if deployable then
				managers.blackmarket:equip_deployable({
					name = deployable,
					target_slot = i
				})
			end
		end
	end

	return true
end
