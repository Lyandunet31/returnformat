local function serialize(value)
	if typeof(value) == "string" then
		return escapeString(value)
	elseif typeof(value) == "number" or typeof(value) == "boolean" then
		return tostring(value)
	elseif typeof(value) == "nil" then
		return "nil"
	elseif typeof(value) == "table" then
		return returntable(value)
	elseif typeof(value) == "function" then
		return returnfunction(value)
	elseif typeof(value) == "Instance" then
		return "-- Instance: " .. value:GetFullName()
	else
		return "-- Unsupported type: " .. typeof(value)
	end
end



getgenv().serialize = serialize
