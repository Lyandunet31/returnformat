local HttpService = game:GetService("HttpService")

local function escapeString(str)
	return '"' .. str:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\r", "\\r") .. '"'
end

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

function returntable(tbl)
	if typeof(tbl) ~= "table" then
		return "-- Not a table"
	end

	local output = {}
	table.insert(output, "{")
	for k, v in pairs(tbl) do
		local key = (typeof(k) == "string" and "[" .. escapeString(k) .. "]") or "[" .. tostring(k) .. "]"
		table.insert(output, "    " .. key .. " = " .. serialize(v) .. ",")
	end
	table.insert(output, "}")
	return table.concat(output, "\n")
end

function returnfunction(func)
	if typeof(func) ~= "function" then
		return "-- Not a function"
	end

	local info = debug.getinfo(func, "Sln")
	if not info then
		return "-- Function source not accessible"
	end

	local source = info.source
	local linedefined = info.linedefined
	local lastlinedefined = info.lastlinedefined

	if source:sub(1, 1) == "@" then
		return "-- Function defined in external file: " .. source
	elseif source:sub(1, 1) == "=" then
		return "-- Function defined dynamically (e.g., loadstring)"
	else
		local lines = {}
		for line in source:gmatch("[^\r\n]+") do
			table.insert(lines, line)
		end
		local chunk = {}
		for i = linedefined, lastlinedefined do
			if lines[i] then
				table.insert(chunk, lines[i])
			end
		end
		return table.concat(chunk, "\n")
	end

	return "-- Unable to retrieve function code"
end
function TeleportNetworkOwnerPart(part, position)
	if part and part:IsA("BasePart") and not part.Anchored then
		pcall(function() part:SetNetworkOwner(game:GetService("Players").LocalPlayer) end)
		local bp = Instance.new("BodyPosition")
		bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bp.P = 20000
		bp.D = 1000
		bp.Position = position
		bp.Parent = part
		task.delay(2, function() if bp and bp.Parent then bp:Destroy() end end)
	end
end
local function CreateFeConnection()
    local connection = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lyandunet31/returnformat/refs/heads/main/depencies/createfeconnection.lua", true))()
    return {
        MovePart = function(partName, rotation)
            local fakeModel = workspace:FindFirstChild(game.Players.LocalPlayer.Name .. "_Fake")
            if fakeModel and fakeModel:FindFirstChild(partName) then
                fakeModel[partName].Rotation = rotation
            end
        end
    }
end


getgenv().returntable = returntable
getgenv().TeleportNetworkOwnerPart = TeleportNetworkOwnerPart
getgenv().IsRoUtils = true
getgenv().CreateFeConnection = CreateFeConnection
