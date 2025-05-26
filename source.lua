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
		task.delay(0.01, function() if bp and bp.Parent then bp:Destroy() end end)
		warn("Teleported Instance To 00000.1")
		warn("Set Network owner")
	end
end

function CreateFeConnection()
    local Players = game:GetService('Players')
    local RunService = game:GetService('RunService')
    local UIS = game:GetService('UserInputService')
    local TweenService = game:GetService('TweenService')
    local Player = Players.LocalPlayer

    local Motors = {
        ['Left Hip'] = 0,
        ['Neck'] = 0,
        ['Left Shoulder'] = 0,
        ['Right Hip'] = 0,
        ['Right Shoulder'] = 0,
    }

    -- Create fake character
    Player.Character.Archivable = true
    local OAN = Player.Character:FindFirstChild("Animate") and Player.Character.Animate:Clone()
    local OCF = Player.Character.PrimaryPart.CFrame
    local FakeCharacter = game:GetObjects('rbxassetid://10117001961')[1]
    FakeCharacter.Name = Player.Name .. '_Fake'
    if OAN then OAN.Parent = FakeCharacter end

    Player.Character:BreakJoints()
    Player.Character = nil

    -- Wait for new character to load
    Player.CharacterAdded:Once(function(NewChar)
        FakeCharacter:PivotTo(OCF)
        FakeCharacter.Parent = workspace
        Player.Character = nil
        Player.Character = FakeCharacter
        workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
        workspace.CurrentCamera.CameraSubject = FakeCharacter.PrimaryPart
        local RealChar = NewChar
        RealChar.Archivable = true

        local t = 0
        local Con1
        Con1 = RunService.Heartbeat:Connect(function(dt)
            t += dt
            RealChar.Torso.CFrame = FakeCharacter.Torso.CFrame
        end)

        task.spawn(function()
            for _, LS in ipairs(FakeCharacter:GetChildren()) do
                if LS:IsA('LocalScript') then
                    LS.Enabled = false
                    task.wait(0.2)
                    LS.Enabled = true
                end
            end
            for _, Part in ipairs(FakeCharacter:GetDescendants()) do
                if Part:IsA('BasePart') then
                    Part.Transparency = 1
                end
            end
            for _, Decal in ipairs(FakeCharacter:GetDescendants()) do
                if Decal:IsA('Decal') then
                    Decal.Transparency = 1
                end
            end
        end)

        RealChar:WaitForChild('Humanoid').StateChanged:Connect(function()
            for _, Part in ipairs(RealChar:GetChildren()) do
                if Part:IsA('BasePart') then
                    Part.CanCollide = false
                end
            end
        end)

        RunService.Heartbeat:Connect(function()
            if RealChar:FindFirstChild('Animate') then
                RealChar.Animate:Destroy()
            end
            for _, v in ipairs(RealChar.Humanoid:GetPlayingAnimationTracks()) do
                v:Stop()
            end
        end)

        local UJ
        UJ = UIS.InputBegan:Connect(function(Input, gp)
            if Input.KeyCode == Enum.KeyCode.Space and not gp then
                task.spawn(function()
                    while UIS:IsKeyDown(Enum.KeyCode.Space) do
                        FakeCharacter.Humanoid.Jump = true
                        task.wait()
                    end
                end)
            end
        end)

        FakeCharacter:WaitForChild('Humanoid').Died:Once(function()
            Con1:Disconnect()
            UJ:Disconnect()
            RealChar.Humanoid.Health = 0
        end)

        RealChar:WaitForChild('Humanoid').Died:Once(function()
            Con1:Disconnect()
            FakeCharacter:Destroy()
        end)

        RealChar.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        workspace.CurrentCamera.CameraType = Enum.CameraType.Track
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)

    -- Get Motor6D from Torso to part
    local function getMotor(partName)
        local fakeModel = workspace:FindFirstChild(Player.Name .. "_Fake")
        if not fakeModel then return nil end
        local torso = fakeModel:FindFirstChild("Torso")
        local part = fakeModel:FindFirstChild(partName)
        if torso and part then
            return torso:FindFirstChild(partName)
        end
        return nil
    end

    return {
        MoveRotation = function(partName, angle)
            local motor = getMotor(partName)
            if motor then
                motor.CurrentAngle = angle
                Motors[partName] = angle
            end
        end,

        MoveCframePart = function(partName, cframe)
            local motor = getMotor(partName)
            if motor then
                local rx, ry, rz = cframe:ToOrientation()
                local angle = rx
                if partName == "Right Shoulder" or partName == "Right Hip" then
                    angle = -rx
                elseif partName == "Left Shoulder" or partName == "Left Hip" then
                    angle = rx
                elseif partName == "Neck" then
                    angle = -ry
                end
                motor.CurrentAngle = angle
                Motors[partName] = angle
            end
        end,

        TweenPart = function(partName, targetCFrame, time)
            local motor = getMotor(partName)
            if not motor then return end
            local startAngle = Motors[partName] or 0
            local rx, ry, rz = targetCFrame:ToOrientation()
            local targetAngle = rx
            if partName == "Right Shoulder" or partName == "Right Hip" then
                targetAngle = -rx
            elseif partName == "Left Shoulder" or partName == "Left Hip" then
                targetAngle = rx
            elseif partName == "Neck" then
                targetAngle = -ry
            end
            local startTime = tick()
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local elapsed = tick() - startTime
                local alpha = math.clamp(elapsed / time, 0, 1)
                local angle = startAngle + (targetAngle - startAngle) * alpha
                motor.CurrentAngle = angle
                Motors[partName] = angle
                if alpha >= 1 then conn:Disconnect() end
            end)
        end
    }
end






getgenv().returntable = returntable
getgenv().TeleportNetworkOwnerPart = TeleportNetworkOwnerPart
getgenv().IsRoUtils = true
getgenv().CreateFeConnection = CreateFeConnection
