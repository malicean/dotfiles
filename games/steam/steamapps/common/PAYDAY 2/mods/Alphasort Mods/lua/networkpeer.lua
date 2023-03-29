local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local as_original_networkpeer_registermod = NetworkPeer.register_mod
function NetworkPeer:register_mod(...)
	as_original_networkpeer_registermod(self, ...)

	table.sort(self._mods, function(a, b)
		return string.lower(a.name) < string.lower(b.name)
	end)
end
