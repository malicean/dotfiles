local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local EnhancedHitmarkers = EnhancedHitmarkers

local eh_original_hudhitconfirm_init = HUDHitConfirm.init
function HUDHitConfirm:init(...)
	eh_original_hudhitconfirm_init(self, ...)
	self:eh_setup()
end

function HUDHitConfirm:eh_setup()
	if self._hud_panel:child('headshot_confirm') then
		self._hud_panel:child('headshot_confirm'):set_size(0, 0) -- no hoxhud's red circle allowed
	end

	local tex_kill = EnhancedHitmarkers.kill_texture_db
	local tex_hit = EnhancedHitmarkers.hit_texture_db
	local settings = EnhancedHitmarkers.settings
	local hms = {
		{ name = 'hit_body_confirm', texture = tex_hit, color = settings.body },
		{ name = 'hit_head_confirm', texture = tex_hit, color = settings.head },
		{ name = 'hit_crit_confirm', texture = tex_hit, color = settings.crit },
		{ name = 'hit_hcrit_confirm', texture = tex_hit, color = settings.hcrit },
		{ name = 'kill_body_confirm', texture = tex_kill, color = settings.body },
		{ name = 'kill_head_confirm', texture = tex_kill, color = settings.head },
		{ name = 'kill_crit_confirm', texture = tex_kill, color = settings.crit },
		{ name = 'kill_hcrit_confirm', texture = tex_kill, color = settings.hcrit }
	}

	self.eh_bitmaps = {}
	local hp = self._hud_panel
	local blend_mode = EnhancedHitmarkers:get_blend_mode()
	for i, hm in ipairs(hms) do
		if hp:child(hm.name) then
			hp:remove(hp:child(hm.name))
		end

		local bmp = hp:bitmap({
			valign = 'center',
			halign = 'center',
			visible = false,
			name = hm.name,
			texture = hm.texture,
			color = Color(hm.color),
			layer = i,
			blend_mode = blend_mode
		})

		local h = bmp:texture_height()
		local w = bmp:texture_width()
		if w * 3 == h then
			bmp:set_texture_rect(0, math.mod(math.min(i, 3) - 1, 4) * w, w, w)
		elseif w * 4 == h then
			bmp:set_texture_rect(0, math.mod(i - 1, 4) * w, w, w)
		end

		local final_width = w * (i > 3 and EnhancedHitmarkers.settings.initial_kill_size_ratio or EnhancedHitmarkers.settings.initial_hit_size_ratio)
		bmp:set_size(final_width, final_width)
		bmp:set_center(hp:w() / 2, hp:h() / 2)

		self.eh_bitmaps[i] = bmp
	end
end

function HUDHitConfirm:on_damage_confirmed(kill_confirmed, headshot, damage_scale)
	local index = kill_confirmed and 5 or 1
	if headshot then
		index = index + 1
	end
	if EnhancedHitmarkers.critshot then
		index = index + 2
	end
	local hm = self.eh_bitmaps[index]

	hm:stop()
	if EnhancedHitmarkers.settings.shake then
		local rotation_angle = math.random(0, 8) - 4
		hm:rotate(rotation_angle)
	end
	hm:animate(callback(self, self, '_animate_show'), callback(self, self, 'show_done'), 0.25, damage_scale)
end

function HUDHitConfirm:on_hit_confirmed(damage_scale)
	if EnhancedHitmarkers.hooked then
		EnhancedHitmarkers.direct_hit = true
		EnhancedHitmarkers.critshot = false
		EnhancedHitmarkers.damage_scale = damage_scale
	else
		self.eh_bitmaps[1]:stop()
		self.eh_bitmaps[1]:animate(callback(self, self, '_animate_show'), callback(self, self, 'show_done'), 0.25, damage_scale)
	end
end

function HUDHitConfirm:on_crit_confirmed(damage_scale)
	if EnhancedHitmarkers.hooked then
		EnhancedHitmarkers.direct_hit = true
		EnhancedHitmarkers.critshot = true
		EnhancedHitmarkers.damage_scale = damage_scale
	else
		self.eh_bitmaps[3]:stop()
		self.eh_bitmaps[3]:animate(callback(self, self, '_animate_show'), callback(self, self, 'show_done'), 0.25, damage_scale)
	end
end

function HUDHitConfirm:_animate_show(hint_confirm, done_cb, seconds, damage_scale)
	local is_kill = hint_confirm:layer() > 3
	local growable = is_kill
	local cx, cy = hint_confirm:center()
	damage_scale = damage_scale or 1
	local w = hint_confirm:texture_width()
	local settings = EnhancedHitmarkers.settings

	local initial_size_ratio = is_kill and settings.initial_kill_size_ratio or settings.initial_hit_size_ratio
	local final_width = w * initial_size_ratio
	local final_width_scaled = final_width * damage_scale

	hint_confirm:set_size(final_width_scaled, final_width_scaled)
	hint_confirm:set_center(cx, cy)

	hint_confirm:set_visible(true)
	hint_confirm:set_alpha(1)
	local t = seconds
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local ratio = t / seconds
		hint_confirm:set_alpha(ratio)
		if growable then
			local sz = (1 + settings.grow_ratio * math.sqrt(1 - math.min(1, ratio))) * final_width_scaled
			hint_confirm:set_size(sz, sz)
			hint_confirm:set_center(cx, cy)
		end
	end
	hint_confirm:set_visible(false)
	done_cb()
end
