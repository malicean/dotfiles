local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network:is_server() then
	return
end

local pc_original_contourext_add = ContourExt.add
function ContourExt:add(...)
	if not self.pc_blocked then
		return pc_original_contourext_add(self, ...)
	end
end
