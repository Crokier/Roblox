local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Enableds,Connections={["Raycast"]=false,["UsePart"]=false,["UseTarget"]=false},{}
local RaycastInfo={
	["Distance"]=50, 
	["Speed"]=14, 
	["UseSweep"]=true,
	["SweepSpeed"]=2.5, 
	["SweepRange"]=25,
	["TargetAngles"]={},
	["CurrentAngles"]={},
	["RaycastParams"]=RaycastParams.new(),
	["DeltaTime"]=0,
	["Color2"]=Color3.fromRGB(0,255,0),
	["Color1"]=Color3.fromRGB(255,0,0),
	["Target"]=nil
}

RaycastInfo.RaycastParams.FilterType=Enum.RaycastFilterType.Exclude

local BaseTargetAngles = {
	["Front"]         = 0,
	["LeftFront"]     = 30,
	["RightFront"]    = -30,
	["LeftFrontMid"]       = 60,
	["RightFrontMid"]      = -60,
	["Left"]          = 90,
	["Right"]         = -90,
}

local VisualToggles = {}
local VisualParts = {}

local CurrentAngles = {}
for name in pairs(BaseTargetAngles) do
	CurrentAngles[name] = 0
end

RaycastInfo.TargetAngles=BaseTargetAngles
RaycastInfo.CurrentAngles=CurrentAngles

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function DrawPart(name, origin, direction, color)
	local visualPart = VisualParts[name]

	if not visualPart or not visualPart:IsDescendantOf(workspace) then
		local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end
		visualPart = cloneref and cloneref(rootPart:Clone()) or rootPart:Clone()
		visualPart.Name = "RayVisual_" .. name
		visualPart.Transparency = 0.5
		visualPart.Material = Enum.Material.Neon
		visualPart.Anchored = true
		visualPart.CanCollide = false
		visualPart.CanQuery = false
		visualPart.CanTouch = false
		visualPart.Parent = Character
		VisualParts[name] = visualPart
	end
	
    visualPart.Transparency = 0.5
	
	local length = direction.Magnitude
	if length < 0.001 then length = 0.001 end

	local midPoint = origin + (direction / 2)
	visualPart.Color = color or Color3.fromRGB(255, 255, 255)
	visualPart.Size = Vector3.new(0.12, 0.12, length)
	visualPart.CFrame = CFrame.lookAt(midPoint, origin + direction)
end

local function Downcast(origin, height, params, total)
	-- Set up Raycast: Start point at the instance, direction downwards for 100 studs
	local direction = Vector3.new(0, -height, 0)
	
	-- Perform Raycast
	local raycastResult = workspace:Raycast(origin, direction, params)

	if raycastResult then
		local hit = raycastResult.Instance
		if hit then 
			local results = {IncludeInstances= {}, ExcludeInstances = {}, Index = 0}

			if total == nil then results.IncludeInstances = hit:GetChildren() return results end
			
			local current, last = hit, nil
			
			current=current.Parent
			
			while current ~= workspace do
				results.Index=results.Index+1 

				if total ~= nil and total>0 and results.Index>=total then
					break
				end
				
				last = current
				current = current.Parent
				task.wait()
			end
			
			results.IncludeInstances = current:GetChildren()
			results.ExcludeInstances = last:GetChildren()
			return results
		end
	end

	return nil
end

local function IsCaughtcast(plrModel, npcModel, raycastInfo)
	if not (plrModel and npcModel) then return false end

	local rootRoot = plrModel.PrimaryPart or plrModel:FindFirstChild("HumanoidRootPart")
	local npcHead = npcModel:FindFirstChild("Head")

	if not (rootRoot and npcHead) then return false end
	local maxDistance = raycastInfo.MaxDistance or 1000

	local npcLookVector = npcHead.CFrame.LookVector * maxDistance
	local toPlayerVector = (rootRoot.Position - npcHead.Position)
	local distance = toPlayerVector.Magnitude
	local directionToPlayer = toPlayerVector.Unit

	local dotProduct = npcLookVector:Dot(directionToPlayer)
	local maxAngle = raycastInfo.MaxAngle or 0

	if dotProduct >= maxAngle and  distance <= maxDistance then
		if not raycastInfo.RaycastParams then
			raycastInfo.RaycastParams = RaycastParams.new()
			raycastInfo.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		end

		local raycastResult = workspace:Raycast(npcHead.Position, directionToPlayer * maxDistance, raycastInfo.RaycastParams)

		if raycastResult then
			local hit = raycastResult.Instance
			if hit then
				return hit:IsDescendantOf(plrModel)
			end
		end

		return true
	end

	return false
end

local function Directionalcast(origin, baseCFrame, info)
	info = info or {}
	
	local raycastParams = info.RaycastParams

	local results = {}

	-- Hitung offset ayunan derajat halus menggunakan Gelombang Sinus (Sine Wave)
	local sweepOffset = 0
	if info.UseSweep~=nil and info.UseSweep==true then
		sweepOffset = math.sin(os.clock() * (info.SweepSpeed or 2.5)) * (info.SweepRange or 25)
	end

	local caught = false
	
	for name, baseAngle in pairs(info.TargetAngles) do
		-- Sudut target aktual + ayunan pemindai
		local targetAngle = baseAngle + sweepOffset

		-- Formula Derajat Mendaki Halus (Eksponensial Lerp berdasarkan Delta Time)
		local lerpFactor = 1 - math.exp(-(info.Speed or 14) * info.DeltaTime)
		info.CurrentAngles[name] = info.CurrentAngles[name] + (targetAngle - info.CurrentAngles[name] or 0) * lerpFactor

		-- Rotasi CFrame berdasarkan derajat saat ini
		local angleRotation = CFrame.Angles(0, math.rad(info.CurrentAngles[name]), 0)
		local directionVector = (baseCFrame * angleRotation).LookVector * info.Distance

		-- Perform Raycast
		local raycastResult = workspace:Raycast(origin, directionVector, raycastParams)
		
		local result = {
			["Direction"] = directionVector,
			["Dectected"] = false
		}
		
		if raycastResult then
			result = {
				["Distance"] = raycastResult.Distance,
				["Position"] = raycastResult.Position,
				["Normal"] = raycastResult.Normal,
				["Material"] = raycastResult.Material,
				["Instance"] = raycastResult.Instance,
				["Direction"] = raycastResult.Position - origin,
				["Dectected"] = true
			}
			caught = true 
		end

		results[name] = result
	end
	
	return results, caught
end

local Window=UI:CreateWindow({
	Name="Raycaster",
	Destroying=function()
		for key, enabled in pairs(Enableds) do
			Enableds[key]=false
		end
		for key, connection in pairs(Connections) do
			if connection then
				connection:Disconnect()
			end
		end
	end
})

VisualToggles["Caught"] = Window:AddToggle({
	Text="Caught",
	Value=false,
	Callback=function() end
})

local InfoFolder=Window:AddFolder({
	Text="Info",
	Open=false,
})

for name in pairs(BaseTargetAngles) do
	VisualToggles[name] = InfoFolder:AddToggle({
		Text=name,
		Value=false,
		Callback=function() end
	})
end

local RaycastFolder = Window:AddFolder({
	Text = "Raycast",
	Open=false,
})

local BodyType=""

RaycastFolder:AddDropdown({
	Text="Body Type",
	Options={"RootPart","Head"},
	Option="RootPart",
	MultipleOptions=false,
	Callback=function(option)
		BodyType=option[1]
	end
})

RaycastFolder:AddSlider({
	Text="Distance",
	Range={50,1000},
	Value=50,
	Increment=1,
	Flag="distance",
	Callback=function(value)
		RaycastInfo.Distance=value
	end
})

RaycastFolder:AddSlider({
	Text="Speed",
	Range={1,100},
	Value=14,
	Increment=1,
	Flag="speed",
	Callback=function(value)
		RaycastInfo.Speed=value
	end
})

local SweepSpeedSlider,SweepRangeSlider=nil,nil

RaycastFolder:AddToggle({
	Text="Use Sweep",
	Value=true,
	Flag="sweep_enabled",
	Callback=function(value)
		RaycastInfo.UseSweep=value
		SweepSpeedSlider.Visible=value
		SweepRangeSlider.Visible=value
	end
})

SweepSpeedSlider=RaycastFolder:AddSlider({
	Text="Sweep Speed",
	Range={1,25},
	Value=2.5,
	Increment=1,
	Flag="sweep_speed",
	Callback=function(value)
		RaycastInfo.SweepSpeed=value
	end
})

SweepRangeSlider=RaycastFolder:AddSlider({
	Text="Sweep Range",
	Range={1,100},
	Value=25,
	Increment=1,
	Flag="sweep_range",
	Callback=function(value)
		RaycastInfo.SweepRange=value
	end
})

RaycastFolder:AddSelect({
	Text = "Target",
	Callback = function(target)
		local instance = target
		while instance ~= workspace do
			if instance and instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") then
				break
			end
			instance = instance.Parent
			task.wait()
		end
		if instance and instance:IsA("Model") and instance:FindFirstChildOfClass("Humanoid") then
			RaycastInfo.Target=instance
		end
	end
})

RaycastFolder:AddToggle({
	Text="Use Target",
	Value=false,
	Flag="target_enabled",
	Callback=function(value)
		Enableds.UseTarget=value
	end
})

local UsePartOrUIButton=nil
UsePartOrUIButton=RaycastFolder:AddButton({
	Text="Use Visual Part",
	MethodType="DoubleClick",
	Callback=function()
		Enableds.UsePart=not Enableds.UsePart
	    local lastUsePart=Enableds.UsePart
		UsePartOrUIButton:Set(lastUsePart and "Use Visual UI" or "Use Visual Part")
		if not lastUsePart then 
		   for _, part in pairs(VisualParts) do
			  if lastUsePart~=Enableds.UsePart then break end
			  part.Transparency = lastUsePart and 0.5 or 1
		   end
	   end
   end
})

Window:AddToggle({
	Text="Raycast",
	Value=false,
	Flag="raycast_enabled",
	Callback=function(value)
		Enableds.Raycast=value
		if not Enableds.Raycast then return end
		task.spawn(function()
			while Enableds.Raycast do
				local deltaTime = task.wait() -- Mengambil nilai selisih waktu antar frame untuk kehalusan ekstra
				local bodyPart = nil
				local model = nil
				if Enableds.UseTarget then
					model = RaycastInfo.Target
				else
					model = Character
				end
				if not (model and model.Parent) then continue end
				if not BodyType or BodyType=="" or BodyType=="RootPart" then
					bodyPart=model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
				elseif BodyType=="Head" then
					bodyPart=model:FindFirstChild("Head")
				end
				RaycastInfo.RaycastParams.FilterDescendantsInstances={model}
				RaycastInfo.DeltaTime=deltaTime
				local origin=bodyPart.Position
				local results,caught=Directionalcast(origin,bodyPart.CFrame,RaycastInfo)
				VisualToggles["Caught"]:Replace(caught)
				
				for name, result in pairs(results) do
					local detected = result.Detected
					result.Color = detected and RaycastInfo.Color2 or RaycastInfo.Color1
					if Enableds.UsePart and caught then
		               DrawPart(name, origin, result.Direction, result.Color)
					end
					local toggle=VisualToggles[name]
					if toggle then
						toggle:Replace(detected)
					end
				end
			end
		end)
	end
})

Window:AddLabel({
	Text="YouTube: Crokyreo",
	TextColor3=Color3.fromRGB(255,255,255)
})
