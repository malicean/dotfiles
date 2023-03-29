function CrimeSpreeManager:DoesServerHasAssaultExtenderModifier()
    local server_modifiers = self._global.server_modifiers or {}
	for _, data in pairs(server_modifiers) do
        if data and data.id and data.id == "assault_extender" then
            return true
		end
    end
    return false
end