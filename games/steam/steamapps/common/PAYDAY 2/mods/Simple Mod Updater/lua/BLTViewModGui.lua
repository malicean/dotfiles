local smu_original_bltviewmodgui_setupmodinfo = BLTViewModGui._setup_mod_info
function BLTViewModGui:_setup_mod_info( mod )
	smu_original_bltviewmodgui_setupmodinfo( self, mod )

	local changes = io.open( mod.path .. 'changelog.txt', 'r' )
	if changes then
		local text = SimpleModUpdater:make_text_readable( changes:read( '*all' ) )
		changes:close()

		local function make_fine_text( text )
			local x,y,w,h = text:text_rect()
			text:set_size( w, h )
			text:set_position( math.round( text:x() ), math.round( text:y() ) )
		end

		local padding = 10
		local info_canvas = self._info_scroll:canvas()
		local changelog = info_canvas:text({
			name = 'changelog',
			x = padding,
			y = padding,
			w = info_canvas:w() - padding * 2,
			font_size = tweak_data.menu.pd2_small_font,
			font = tweak_data.menu.pd2_small_font,
			layer = 10,
			blend_mode = 'add',
			color = Color(0.231373, 0.682353, 0.996078),
			text = text,
			align = 'left',
			vertical = 'top',
			wrap = true,
		})
		make_fine_text( changelog )
		changelog:set_top( padding * 2 + info_canvas:child('contact'):bottom() )

		self._info_scroll:update_canvas_size()
	end
end

local smu_original_bltviewmodgui_setupbuttons = BLTViewModGui._setup_buttons
function BLTViewModGui:_setup_buttons( mod )
	smu_original_bltviewmodgui_setupbuttons( self, mod )

	if self._mod.updates and self._mod.updates[1] and self._mod.updates[1].is_simple then
		for i, btn in ipairs(self._buttons) do
			if btn == self._check_update_button then
				btn:panel():set_visible(false)
				table.remove(self._buttons, i)
				break
			end
		end
		self._check_update_button = nil
	end
end

local smu_original_bltviewmodgui_setup = BLTViewModGui.setup
function BLTViewModGui:setup()
	if SimpleModUpdater.inspect_mod then
		self:make_background()
		self._mod = SimpleModUpdater.inspect_mod
		SimpleModUpdater.inspect_mod = nil
		self:_setup_mod_info( self._mod )
		self:_setup_dev_info( self._mod )
		self:_setup_buttons( self._mod )
		self:refresh()
		return
	end

	return smu_original_bltviewmodgui_setup(self)
end
