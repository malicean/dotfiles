local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

core:module('SystemMenuManager')

_G.QuickKeyboardInputDialog = _G.QuickKeyboardInputDialog or class(GenericDialog)
_G.QuickKeyboardInputDialog.PANEL_SCRIPT_CLASS = 'QuickKeyboardInputGui'

GenericSystemMenuManager.GENERIC_KEYBOARD_INPUT_DIALOG = _G.QuickKeyboardInputDialog
GenericSystemMenuManager.KEYBOARD_INPUT_DIALOG = _G.QuickKeyboardInputDialog

function _G.QuickKeyboardInputDialog:update_input()
	-- qued
end
