
local mdin = {}
function mdin.index(str)
	return '"' .. str:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r") .. '"'
end
