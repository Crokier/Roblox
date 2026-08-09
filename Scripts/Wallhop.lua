-- This script was inspired by GLITCH_KingGUEST666 on youtube

local UI=loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players,StarterGui,RunService,UserInputService=Services.Players,Services.StarterGui,Services.RunService,Services.UserInputService
local LocalPlayer=Players.LocalPlayer
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local AutoToggle=nil

local Enableds,Connections={Auto=false,Wallhop=false,InfiniteJump=false},{}

Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
end)

local function Notify(title,description,duration)
	if UI.Notify then
		UI.Notify({Title=title,Description=description,Duration=duration or 5})
	else
		StarterGui:SetCore("SendNotification",{Title=title,Text=description,Duration=duration or 5})
	end
end

local SelectedBrickColor,AutoEnabled=nil,false
local raycastParams=RaycastParams.new()
raycastParams.FilterType=Enum.RaycastFilterType.Exclude

local function Clean()
	for key,enabled in pairs(Enableds) do
		Enableds[key]=false
	end
	local key,connection=next(Connections)
	while connection do
		Connections[key]=nil
		connection:Disconnect()
		key,connection=next(Connections)
	end
end

local function GetWallRaycastResult()
	local character=LocalPlayer.Character
	if not character then return nil end
	local humanoidRootPart=character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return nil end
	raycastParams.FilterDescendantsInstances={character}
	local detectionDistance=2
	local closestHit=nil
	local minDistance=detectionDistance+1
	local hrpCF=humanoidRootPart.CFrame
	for i=0,7 do
		local angle=math.rad(i*45)
		local direction=(hrpCF*CFrame.Angles(0,angle,0)).LookVector
		local ray=workspace:Raycast(humanoidRootPart.Position,direction*detectionDistance,raycastParams)
		if ray and ray.Instance and ray.Distance<minDistance then
			minDistance=ray.Distance
			closestHit=ray
		end
	end
	local blockCastSize=Vector3.new(1.5,1,0.5)
	local blockCastOffset=CFrame.new(0,-1,-0.5)
	local blockCastOriginCF=hrpCF*blockCastOffset
	local blockCastDirection=hrpCF.LookVector
	local blockCastDistance=1.5
	local blockResult=workspace:Blockcast(blockCastOriginCF,blockCastSize,blockCastDirection*blockCastDistance,raycastParams)
	if blockResult and blockResult.Instance and blockResult.Distance<minDistance then
		minDistance=blockResult.Distance
		closestHit=blockResult
	end
	return closestHit
end

local function ExecuteWallJump(wallRayResult,jumpType)
	if jumpType~="Button" and not Enableds.InfiniteJump then return end

	local character=LocalPlayer.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	local rootPart=character and character:FindFirstChild("HumanoidRootPart")
	local camera=workspace.CurrentCamera

	if not (humanoid and rootPart and camera and humanoid:GetState()~=Enum.HumanoidStateType.Dead and wallRayResult) then
		return
	end

	if jumpType~="Button" then
		Enableds.InfiniteJump=false
	end

	local maxInfluenceAngleRight=math.rad(20)
	local maxInfluenceAngleLeft=math.rad(-100)

	local wallNormal=wallRayResult.Normal
	local baseDirectionAwayFromWall=Vector3.new(wallNormal.X,0,wallNormal.Z).Unit
	if baseDirectionAwayFromWall.Magnitude<0.1 then
		local dirToHit=(wallRayResult.Position-rootPart.Position)*Vector3.new(1,0,1)
		baseDirectionAwayFromWall=-dirToHit.Unit
		if baseDirectionAwayFromWall.Magnitude<0.1 then
			baseDirectionAwayFromWall=-rootPart.CFrame.LookVector * Vector3.new(1,0,1)
			if baseDirectionAwayFromWall.Magnitude>0.1 then baseDirectionAwayFromWall=baseDirectionAwayFromWall.Unit end
			if baseDirectionAwayFromWall.Magnitude<0.1 then baseDirectionAwayFromWall=Vector3.new(0,0,1) end
		end
	end
	baseDirectionAwayFromWall=Vector3.new(baseDirectionAwayFromWall.X,0,baseDirectionAwayFromWall.Z).Unit
	if baseDirectionAwayFromWall.Magnitude < 0.1 then baseDirectionAwayFromWall=Vector3.new(0,0,1) end

	local cameraLook=camera.CFrame.LookVector
	local horizontalCameraLook=Vector3.new(cameraLook.X,0,cameraLook.Z).Unit
	if horizontalCameraLook.Magnitude<0.1 then horizontalCameraLook=baseDirectionAwayFromWall end

	local dot=math.clamp(baseDirectionAwayFromWall:Dot(horizontalCameraLook),-1,1)
	local angleBetween=math.acos(dot)
	local cross=baseDirectionAwayFromWall:Cross(horizontalCameraLook)
	local rotationSign=-math.sign(cross.Y)
	if rotationSign==0 then angleBetween=0 end

	local actualInfluenceAngle
	if rotationSign==1 then
		actualInfluenceAngle=math.min(angleBetween,maxInfluenceAngleRight)
	elseif rotationSign==-1 then
		actualInfluenceAngle=math.min(angleBetween,maxInfluenceAngleLeft)
	else
		actualInfluenceAngle=0
	end

	local adjustmentRotation=CFrame.Angles(0,actualInfluenceAngle * rotationSign,0)
	local initialTargetLookDirection=adjustmentRotation * baseDirectionAwayFromWall

	rootPart.CFrame=CFrame.lookAt(rootPart.Position,rootPart.Position + initialTargetLookDirection)

	RunService.Heartbeat:Wait()

	local didJump=false
	if humanoid and humanoid:GetState()~=Enum.HumanoidStateType.Dead then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		didJump=true
		rootPart.CFrame=rootPart.CFrame*CFrame.Angles(0,-1,0)
		task.wait(0.15)
		rootPart.CFrame=rootPart.CFrame*CFrame.Angles(0,1,0)
	end

	if didJump then
		local directionTowardsWall=-baseDirectionAwayFromWall
		task.wait(0.05)
		rootPart.CFrame=CFrame.lookAt(rootPart.Position,rootPart.Position+directionTowardsWall)
	end

	if jumpType~="Button" then
		task.wait(0.1)
		Enableds.InfiniteJump=true
	end
end

local function PerformFaceWallJump()
	local wallRayResult=GetWallRaycastResult()
	if wallRayResult then
		ExecuteWallJump(wallRayResult,"Button")
	end
end

Connections.JumpLooped=RunService.Heartbeat:Connect(function(deltaTime)
	if not (Enableds.Wallhop and Enableds.Auto and SelectedBrickColor) then return end
	
	if not (Character and Character.Parent) then return end
	
	local humanoid=Character:FindFirstChildOfClass("Humanoid")
	if not (humanoid and humanoid:GetState()~=Enum.HumanoidStateType.Dead) then return end

	local wallRayResult=GetWallRaycastResult()
	if wallRayResult then
		local hitPart=wallRayResult.Instance
		if hitPart~=nil and hitPart:IsA("BasePart") and hitPart.BrickColor==SelectedBrickColor then
			ExecuteWallJump(wallRayResult,"Auto")
		end
	end
end)

Connections.JumpRequest=UserInputService.JumpRequest:Connect(function()
	if not Enableds.Wallhop then return end
	local wallRayResult=GetWallRaycastResult()
	if wallRayResult then
		ExecuteWallJump(wallRayResult,"Manual")
	end
end)

local Window=UI:CreateWindow({
	Name="Wallhop",
	Destroying=Clean
})

Window:AddToggle({
	Text="Active",
	Value=false,
	Callback=function(Value) 
		Enableds.Wallhop=Value 
	end
})

AutoToggle=Window:AddToggle({
	Text="Auto",
	Value=false,Callback=function(value)
		if not SelectedBrickColor then 
			AutoToggle:Replace(false)
			Enableds.Auto=false 
			Notify("Wall Hop","Auto requires color selection!") 
			Notify("Info","Please press select button.") 
			return 
		end 
		Enableds.Auto=value 
	end
})

Window:AddSelect({
	Text="Color Target",
	Callback=function(Target) 
		SelectedBrickColor=Target.BrickColor 
	end
})

Window:AddButton({
	Text="Jump",
	Callback=PerformFaceWallJump
})

Window:AddButton({
	Text="Destroy",
	MethodType="DoubleClick",
	Callback=function()
		Window:Destroy() 
		Clean() 
	end
})

Window:AddLabel({
	Text="YouTube: GLITCH_KingGUEST666",
	TextColor3=Color3.fromRGB(255, 255, 255),
	TextScaled=true
})

Window:AddLabel({
	Text="YouTube: Crokyreo",
	TextColor3=Color3.fromRGB(255, 255, 255)
})

Window:AddLabel({
	Text="Date: 06-10-2026",
	TextColor3=Color3.fromRGB(255, 255, 255)
})
