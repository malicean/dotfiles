Hooks:PostHook(CopDamage, "_on_death", "_on_death_remove_countour", function (self)
	local contour = self._unit.contour and self._unit:contour()
	if not contour or not contour._contour_list then
		return
	end

	while contour._contour_list and #contour._contour_list > 0 do
		local t = contour._contour_list[1].type
		contour:_remove(1)
		contour:apply_to_linked("remove", t)
	end

	if contour._update_enabled then
		contour:_chk_update_state()
	end
end)
