if not Global.load_level then
    return
end

BAIAnimation = BAIAnimation or class()
function BAIAnimation:RestorationColorChange(o, nc1, nc2, color_function, oc1, oc2)
    nc1 = nc1 or Color.white
    nc2 = nc2 or Color.white
    oc1 = oc1 or o:child("corner"):color()
    oc2 = oc2 or o:child("corner2"):color()
    color_function = color_function or o.set_color
    local c1 = o:child("corner")
    local c2 = o:child("corner2")
    local t = 0

    while t < 1 do
        t = t + coroutine.yield()
        local r1 = oc1.r + (t * (nc1.r - oc1.r))
        local g1 = oc1.g + (t * (nc1.g - oc1.g))
        local b1 = oc1.b + (t * (nc1.b - oc1.b))
        local r2 = oc2.r + (t * (nc2.r - oc2.r))
        local g2 = oc2.g + (t * (nc2.g - oc2.g))
        local b2 = oc2.b + (t * (nc2.b - oc2.b))
        color_function(Color(c1:color().alpha, r1, g1, b1), Color(c2:color().alpha, r2, g2, b2))
    end
    color_function(nc1, nc2)
end

function BAIAnimation:ColorChange(o, new_color, color_function, old_color)
    new_color = new_color or Color.white
    color_function = color_function or o.set_color
    old_color = old_color or o:color()
    local t = 0

    while t < 1 do
        t = t + coroutine.yield()
        local r = old_color.r + (t * (new_color.r - old_color.r))
        local g = old_color.g + (t * (new_color.g - old_color.g))
        local b = old_color.b + (t * (new_color.b - old_color.b))
        color_function(Color(255, r, g, b), true)
    end
    color_function(new_color, true)
end

function BAIAnimation:NobleHUD_animate_color(o, new_color)
    new_color = new_color or Color.white
    local old_color = o:color()
    local t = 0

    while t < 1 do
        t = t + coroutine.yield()
        local r = old_color.r + (t * (new_color.r - old_color.r))
        local g = old_color.g + (t * (new_color.g - old_color.g))
        local b = old_color.b + (t * (new_color.b - old_color.b))
        o:set_color(Color(255, r, g, b))
    end
    o:set_color(new_color)
end

function BAIAnimation:FadeIn(o, t_alpha)
    local t = o:alpha()
    t_alpha = t_alpha or 1

    while t < t_alpha do
        t = t + coroutine.yield()
        o:set_alpha(t)
    end
    o:set_alpha(t_alpha)
end

function BAIAnimation:FadeOut(o, t_alpha)
    local t = o:alpha()
    t_alpha = t_alpha or 0

    while t > t_alpha do
        t = t - coroutine.yield()
        o:set_alpha(t)
    end
    o:set_alpha(t_alpha)
end

function BAIAnimation:AAIPanel(p, bg)
    bg = managers.hud._hud_assault_corner[bg]:child("bg")

    bg:stop()
    bg:set_color(Color(1, 0, 0, 0))
    bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"))

    self:FadeIn(p)
end

--[[function HUDList_set_offset(box, amount)
    local TOTAL_T = 0.18
	local OFFSET = box._panel:h()
	local from_y = amount and 86 or 108
	local target_y = amount and 108 or 86
	local t = (1 - math.abs(box:y() - target_y) / OFFSET) * TOTAL_T
	while t < TOTAL_T do
		local dt = coroutine.yield()
		t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        managers.hudlist:change_setting("left_list_y", math.lerp(from_y, target_y, lerp))
        --managers.hudlist:change_setting("left_list_y", data.amount and 108 or 86)
		--hostage_panel:set_y(math.lerp(from_y, target_y, lerp))
    end
end]]