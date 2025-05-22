local function escapeString(str)
	return '"' .. str:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r") .. '"'
end


getgenv().escapeString = escapeString
