local Motors = {
	["Left Hip"] = 5,
	["Neck"] = 5,
	["Left Shoulder"] = 5,
	["Right Hip"] = 5,
	["Right Shoulder"] = 5
}

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
Player.Character.Archivable = true
local OAN = Player.Character.Animate:Clone()
local OCF = Player.Character.PrimaryPart.CFrame
local FakeCharacter = game:GetObjects("rbxassetid://10117001961")[1]
FakeCharacter.Name = Player.Name .. "_Fake"
OAN.Parent = FakeCharacter

Player.Character:BreakJoints()
Player.Character=nil

local function MotorAngle(RealChar)
	if RealChar:FindFirstChild("Torso") then
		for MotorName, Motor6DAngle in pairs(Motors) do
			if RealChar:FindFirstChild("Torso"):FindFirstChild(MotorName) then
				RealChar:FindFirstChild("Torso"):FindFirstChild(MotorName).CurrentAngle = Motor6DAngle
			end
		end
	end
end

local function SetAngles(FakeCharacter)
	if FakeCharacter:FindFirstChild("Torso") then
		for MotorName, Motor6DAngle in pairs(Motors) do
			if FakeCharacter:FindFirstChild("Torso"):FindFirstChild(MotorName) then
				local Motor = FakeCharacter:FindFirstChild("Torso"):FindFirstChild(MotorName) 
				local rx, ry, rz = Motor.Part1.CFrame:ToObjectSpace(FakeCharacter:FindFirstChild("Torso").CFrame):ToOrientation()
				--Motors[MotorName] = rx
				if Motor.Name == "Right Shoulder" then
					Motors[MotorName] = -rx
				end
				if Motor.Name == "Left Shoulder" then
					Motors[MotorName] = rx
				end
				if Motor.Name == "Right Hip" then
					Motors[MotorName] = -rx
				end
				if Motor.Name == "Left Hip" then
					Motors[MotorName] = rx
				end
				if Motor.Name == "Neck" then
					Motors[MotorName] = -ry
				end
			end
		end
	end
end

local function BaseCol(RealChar)
	for i, Part in ipairs(RealChar:GetChildren()) do
		if Part:IsA("BasePart")then
			Part.CanCollide = false
		end
	end
end

Player.CharacterAdded:Once(function(NewChar)
    FakeCharacter:PivotTo(OCF)
	FakeCharacter.Parent = workspace
	Player.Character = nil
	Player.Character = FakeCharacter
	workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
	workspace.CurrentCamera.CameraSubject = FakeCharacter.PrimaryPart
	local RealChar = NewChar
	RealChar.Archivable = true

	local Con1
	Con1 = RunService.Heartbeat:Connect(function()
		SetAngles(FakeCharacter)
		MotorAngle(RealChar)
		RealChar.Torso.CFrame = FakeCharacter.Torso.CFrame
	end)

	task.spawn(function()
		for i, LS in ipairs(FakeCharacter:GetChildren()) do
			if LS:IsA("LocalScript") then
				LS.Enabled = false
				task.wait(0.2)
				LS.Enabled = true
			end
		end
		for i, Part in ipairs(FakeCharacter:GetDescendants()) do
			if Part:IsA("BasePart")then
				Part.Transparency = 1
			end
		end

		for i, Decal in ipairs(FakeCharacter:GetDescendants()) do
			if Decal:IsA("Decal")then
				Decal.Transparency = 1
			end
		end
	end)

	RealChar:WaitForChild("Humanoid").StateChanged:Connect(function()
		BaseCol(RealChar)
	end)

	RunService.Heartbeat:Connect(function()
		if RealChar:FindFirstChild("Animate") then
			RealChar:FindFirstChild("Animate"):Destroy()
		end
		for i,v in ipairs(RealChar.Humanoid:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end)
	local UJ 
	UJ = UIS.InputBegan:Connect(function(Input,gp)
		if Input.KeyCode == Enum.KeyCode.Space and not gp then
			task.spawn(function()
				while UIS:IsKeyDown(Enum.KeyCode.Space) do
					FakeCharacter.Humanoid.Jump = true
					task.wait()
				end
			end)
		end
	end)

	FakeCharacter:WaitForChild("Humanoid").Died:Once(function()
		Con1:Disconnect()
		UJ:Disconnect()
		RealChar.Humanoid.Health = 0
	end)
	RealChar:WaitForChild("Humanoid").Died:Once(function()
		Con1:Disconnect()
		FakeCharacter:Destroy()
	end)
	RealChar:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end)
