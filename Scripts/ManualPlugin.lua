script:Destroy()

--[[
• Tutorial
1. Select the script below, then copy script.
2. View > Command Bar > 'Run a command' > Paste script.
3. Done!
]]

-----// Set \\-----
--[Set Thumbnail Camera Model]--
warn("Set Thumbnail Camera Model")
local Offset=CFrame.new(0,0,-2)
local thumbnailModel=game.Workspace.Inits.ThumbnailModel
local thumbnailPart=game.Workspace.Inits.ThumbnailPart
for i,v in pairs(thumbnailModel:GetDescendants()) do if v:IsA("Camera") and v~=game.Workspace.Camera then v:Destroy() end end
local part=thumbnailPart
local camera=game.Workspace.Camera
camera.CameraSubject=part
camera.CameraType=Enum.CameraType.Fixed
camera.CoordinateFrame=part.CFrame*Offset
camera.Focus=part.CFrame
local a=camera:Clone()
a.Parent=thumbnailModel
a.Name="ThumbnailCamera"
part.Parent=a

--// Part \\--
--[Set Weld]--
warn("Set Part Weld")
local hinge=nil
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") and v.Name=="Hinge" then hinge=v break end end
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("ManualWeld") then v:Destroy() end end
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do
	if v:IsA("BasePart") and v.Name~=hinge.Name then
		local newWeld=Instance.new("WeldConstraint")
		newWeld.Part0=v
		newWeld.Part1=hinge
		newWeld.Parent=v
	end
end

--[Set All Surface Part | Set Surface]--
warn("Set All Part Surface")
local SurfaceType=Enum.SurfaceType.Studs
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do 
	if v:IsA("Part") or v:IsA("WedgePart") then 
		v.Material=Enum.Material.Plastic
		v.BackSurface=SurfaceType
		v.BottomSurface=SurfaceType
		v.FrontSurface=SurfaceType
		v.LeftSurface=SurfaceType
		v.RightSurface=SurfaceType
		v.TopSurface=SurfaceType
	end
end

--[Set Up Down Other Surface Part | Set Surface]--
warn("Set Up Down Other Surface Part")
local UpSurfaceType=Enum.SurfaceType.Studs
local DownSurfaceType=Enum.SurfaceType.Inlet
local SurfaceType=Enum.SurfaceType.Smooth
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do
	if v:IsA("Part") then
		local orientation=v.Orientation
		v.Material=Enum.Material.Plastic
		if v.Shape==Enum.PartType.Block then
			v.BackSurface=SurfaceType
			v.BottomSurface=DownSurfaceType
			v.FrontSurface=SurfaceType
			v.LeftSurface=SurfaceType
			v.RightSurface=SurfaceType
			v.TopSurface=UpSurfaceType
		elseif v.Shape==Enum.PartType.Wedge then
			if orientation==Vector3.new(0,0,0) or orientation==Vector3.new(0,-90,0) or orientation==Vector3.new(0,90,0) or orientation==Vector3.new(0,180,0) then
				v.BackSurface=SurfaceType
				v.BottomSurface=DownSurfaceType
				v.FrontSurface=UpSurfaceType
				v.LeftSurface=SurfaceType
				v.RightSurface=SurfaceType
				v.TopSurface=SurfaceType
			elseif orientation==Vector3.new(90,0,0) or orientation==Vector3.new(90,-90,0) or orientation==Vector3.new(90,90,0) or orientation==Vector3.new(90,180,0) then
				v.BackSurface=DownSurfaceType
				v.BottomSurface=SurfaceType
				v.FrontSurface=UpSurfaceType
				v.LeftSurface=SurfaceType 
				v.RightSurface=SurfaceType
				v.TopSurface=SurfaceType
			elseif orientation==Vector3.new(0,0,180) or orientation==Vector3.new(0,-90,180) or orientation==Vector3.new(0,90,180) or orientation==Vector3.new(0,180,180) then
				v.BackSurface=SurfaceType
				v.BottomSurface=DownSurfaceType
				v.FrontSurface=SurfaceType
				v.LeftSurface=SurfaceType
				v.RightSurface=SurfaceType
				v.TopSurface=UpSurfaceType
			end
		end
	elseif v:IsA("WedgePart") then
		local orientation=v.Orientation
		v.Material=Enum.Material.Plastic
		if orientation==Vector3.new(0,0,0) or orientation==Vector3.new(0,-90,0) or orientation==Vector3.new(0,90,0) or orientation==Vector3.new(0,180,0) then
			v.BackSurface=SurfaceType
			v.BottomSurface=DownSurfaceType
			v.FrontSurface=UpSurfaceType
			v.LeftSurface=SurfaceType
			v.RightSurface=SurfaceType
			v.TopSurface=SurfaceType
		elseif orientation==Vector3.new(90,0,0) or orientation==Vector3.new(90,-90,0) or orientation==Vector3.new(90,90,0) or orientation==Vector3.new(90,180,0) then
			v.BackSurface=DownSurfaceType
			v.BottomSurface=SurfaceType
			v.FrontSurface=UpSurfaceType
			v.LeftSurface=SurfaceType 
			v.RightSurface=SurfaceType
			v.TopSurface=SurfaceType
		elseif orientation==Vector3.new(0,0,180) or orientation==Vector3.new(0,-90,180) or orientation==Vector3.new(0,90,180) or orientation==Vector3.new(0,180,180) then
			v.BackSurface=SurfaceType
			v.BottomSurface=DownSurfaceType
			v.FrontSurface=SurfaceType
			v.LeftSurface=SurfaceType
			v.RightSurface=SurfaceType
			v.TopSurface=UpSurfaceType
		end
	end
end

--[Set Part CanCollide and Part Material and Part CastShadow and Part CanTouch and Part CanQuery | Anti Lag 2]--
warn("Set Part Material and Part CanCollide and Part CastShadow and Part CanTouch and Part CanQuery")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do
	if v:IsA("BasePart") then
		v.Material=Enum.Material.Plastic
		v.CanCollide=false
		v.CastShadow=false
		v.CanTouch=false
		v.CanQuery=false
	end
end

--[Set Part CanTouch and Part CanQuery | Anti Lag 3]--
warn("Set Part CanTouch and Part CanQuery")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do
	if v:IsA("BasePart") then
		v.CanTouch=false
		v.CanQuery=false
	end
end

--[Set Part CastShadow and Part Anchored and Part CanCollide and Check Transparency and Union UsePartColor and Set Invisible Part and Part Locked and Part CastShadow | Anti Lag 4]--
warn("Set Part CastShadow and Part Anchored and Part CanCollide and Check Transparency and Union UsePartColor and Set Invisible Part and Part Locked and Part CastShadow")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do 
	if v:IsA("UnionOperation") then 
		v.UsePartColor=true 
	elseif v:IsA("BasePart") then 
		if v.Transparency~=1 then
			v.CastShadow=false v.Anchored=true v.CanCollide=true
		else
			v.Anchored=true v.CastShadow=false v.CanCollide=false v.Color=Color3.fromRGB(255,255,255) v.Material=Enum.Material.Plastic
		end
		v.Locked=false
		v.CastShadow=false
	end 
end

--[Set Invisible Part]--
warn("Set Invisible Part")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") and v.Transparency==1 then v.Anchored=true v.CastShadow=false v.CanCollide=false v.Color=Color3.fromRGB(255,255,255) v.Material=Enum.Material.Plastic end end

--[Set Normal Part Name]--
warn("Set Normal Name")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Name="Part" elseif v:IsA("UnionOperation") then v.Name="Union" end end

--[Set Part Name By Shape Type]--
warn("Set Name By Shape Type")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do
	if v:IsA("Part") then
		if v.Shape==Enum.PartType.Block then
			v.Name="Cube"
		elseif v.Shape==Enum.PartType.Wedge then
			v.Name="Wedge"
		elseif v.Shape==Enum.PartType.CornerWedge then
			v.Name="CornerWedge"
		elseif v.Shape==Enum.PartType.Ball then
			v.Name="Sphere"
		elseif v.Shape==Enum.PartType.Cylinder then
			v.Name="Cylinder"
		else
			v.Name="Part"
		end
	elseif v:IsA("WedgePart") then
		v.Name="Wedge"
	elseif v:IsA("TrussPart") then
		v.Name="Truss"
	elseif v:IsA("CornerWedgePart") then
		v.Name="CornerWedge"
	elseif v:IsA("MeshPart") or v:IsA("SpecialMesh") then 
		v.Name="Mesh" 
	elseif v:IsA("UnionOperation") then 
		v.Name="Union" 
	end 
end

--[Set Part Glass | Set Glass]--
warn("Set Part Glass")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do 
	if v:IsA("BasePart") and v.Name=="Glass" then  
		v.Reflectance=0.75
		v.Transparency=0.45
		v.Material=Enum.Material.Plastic
		v.CanCollide=true
		v.Color=Color3.fromRGB(255,255,255)
		v.Locked=false
		v.CastShadow=false
		v.CanQuery=false
		v.CanTouch=false
	end 
end

--[Set Part Material and Part Color]--
warn("Set Part Material and Part Color")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Material=Enum.Material.Plastic v.Color=Color3.fromRGB(255,255,255) end end

--[Set Part Material and Part BrickColor]--
warn("Set Part Material and Part BrickColor")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Material=Enum.Material.Plastic v.BrickColor=BrickColor.new("White") end end

--[Set Part Material]--
warn("Set Part Material")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Material=Enum.Material.Plastic end end

--[Set Part Color]--
warn("Set Part Color")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Color=Color3.fromRGB(255,255,255) end end

--[Set Part BrickColor]--
warn("Set Part BrickColor")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.BrickColor=BrickColor.new("White") end end

--[Set Part Transparency and Part Anchored]--
warn("Set Part Transparency and Part Anchored")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 v.Anchored=true end end

--[Set Part Anchored]--
warn("Set Part Anchored")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Anchored=true end end

--[Set Part Transparency]--
warn("Set Part Transparency")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 end end

--[Set Part Locked]--
warn("Set Part Locked")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Locked=true end end

--[Set Part CastShadow]--
warn("Set Part CastShadow")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.CastShadow=false end end

--[Set Union UsePartColor]--
warn("Set Union UsePartColor")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("UnionOperation") then v.UsePartColor=true end end

--[Set Model ScaleTo]--
warn("Set Model ScaleTo")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Model") then v:ScaleTo(1) end end

--[Set Part Size and Part Rotation]--
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Size=Vector3.new(3,3,0.5) v.Rotation=Vector3.new(0,180,0) end end

--[Set Part Size]--
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("BasePart") then v.Size=Vector3.new(3,3,0.5) end end





--// Instance \\--
--[Set Instance Name]--
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Decal") then v.Name="eye" end end

--[Set Instance Name If Check]--
for i,v in pairs(game.Workspace.Inits.Model:GetChildren()) do if v:IsA("Model") and v:GetChildren()<=1 then for j,k in pairs(v:GetChildren()) do if k:IsA("Decal") then k.Name="eye" end end end end





--// Sound \\--
--[Set Sound Id By Name]--
warn("Set Sound Id By Name")
local sounds={
	["CloseSound"]="rbxassetid://0",
	["OpenSound"]="rbxassetid://0"
}
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Sound") then local soundId=sounds[v.Name] if soundId then v.SoundId=soundId end end end

--[Set Sound Volume and Sound Playing and Sound PlayOnRemove]--
warn("Set Sound Volume and Sound Playing and Sound PlayOnRemove")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Sound") then v.Playing=false v.PlayOnRemove=false v.Volume=0.2 end end

--[Set Sound Playing and Sound PlayOnRemove]--
warn("Set Sound Playing and Sound PlayOnRemove")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Sound") then v.Playing=false v.PlayOnRemove=false end end

--[Set Sound Playing and Sound PlayOnRemove]--
warn("Set Sound PlayOnRemove")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Sound") then v.PlayOnRemove=false end end

--[Set Sound Volume]--
warn("Set Sound Volume")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Sound") then v.Volume=0.2 end end

--// Decal \\--
warn("Set Decal Face")
for i,v in pairs(game.Workspace.Inits:GetDescendants()) do if v:IsA("Decal") then v.Face=Enum.NormalId.Front end end










-----// Fixed \\-----
--[Fixed Part Position]--
warn("Set Fixed Part Position")
local defaultPart=game.Workspace.Inits.DefaultPart
local newModel=Instance.new("Model")
newModel.Name="InsertModel"
newModel.Parent=game.Workspace.Finishs
local oldPosition=nil

local fixedModel=game.Workspace.Inits.FixedModel

for i,v in pairs(fixedModel:GetDescendants()) do
	if v:IsA("BasePart") and v.Name~=defaultPart.Name then
		if oldPosition==nil then oldPosition=defaultPart.Position+Vector3.new(3.5,0,0) end
		v.Position=oldPosition
		oldPosition=v.Position+Vector3.new(3.5,0,0)
		v.Parent=newModel
		game:GetService("RunService").Heartbeat:Wait()
	end
end

--[Fixed Gui]--
warn("Set Fixed Part Position")
for i,v in pairs(game.StarterGui:GetDescendants()) do
	if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("ImageLabel") then
		v.AnchorPoint=Vector2.new(0.5,0.5)
		v.Size=UDim2.new(1,0,1,0)
		v.Position=UDim2.new(0.5,0,0.5,0)
	end
end

--[Moving Instance]--
warn("Moving Instance")
local model=Instance.new("Model")
model.Name="MoveModel"
model.Parent=game.Workspace.Detects
local names={"Tree","Flower","House","Shop","Grass","Rock","Npc","Plant","Car","Money"}
for i,v in pairs(game.Workspace.Inits:GetChildren()) do
	if v:IsA("Model") or v:IsA("Folder") then
		local newName
		for j,k in pairs(names) do
			if string.find(string.lower(v.Name),string.lower(k)) then
				newName=k
				break
			end
		end
		if newName then
			local newModel=model:FindFirstChild(tostring(newName).."s")
			if not newModel then
				newModel=Instance.new("Model")
				newModel.Name=tostring(newName).."s"
				newModel.Parent=model
			end
			v.Parent=newModel
		end
	end
end
if #model:GetChildren()<1 then
	model:Destroy()
end










-----// Clean \\-----
--[Insert Audio Loaded or NotLoaded | Check Sound If Loaded or NotLoaded]--
warn("Insert Audio Loaded or NotLoaded")
local newModel=Instance.new("Model",workspace.Inits)
newModel.Name="AudioModel"

local newModelLoaded=Instance.new("Model",newModel)
newModelLoaded.Name="Loaded"

local newModelNotLoaded=Instance.new("Model",newModel)
newModelNotLoaded.Name="NotLoaded"

for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Sound") then
		if v.IsLoaded==true then
			v.Parent=newModelLoaded
		else
			v.Parent=newModelNotLoaded
		end
	end
end

for i,v in pairs(newModel:GetDescendants()) do
	if v:IsA("Sound") then
		v.Playing=false
		v.PlayOnRemove=false
	end
end

--[Check Sound Id If Duplicate Sound and Clean Sound]--
warn("Check Sound Id If Duplicate Sound and Clean Sound")
local SoundId=833871080
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Sound") then
		v.PlayOnRemove=false
		if string.find(tostring(v.SoundId),tostring(SoundId)) then
			print(i.." | Where: "..v:GetFullName());
			local d=game.Workspace:FindFirstChild("Detects")
			if d~=nil then v.Parent=d; else v:Destroy(); end
		end
	end
end

--[Clean Script and Weld and Value and Effect]--
warn("Clean Script and Weld and Value and Effect")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("ManualWeld") or v.ClassName=="Vector2Value" or v:IsA("Vector3Value") or v.ClassName=="Vector4Value" or v:IsA("CFrameValue") or v:IsA("BrickColorValue") or v:IsA("Color3Value") or v:IsA("BoolValue") or v:IsA("RayValue") or v:IsA("NumberValue") or v.ClassName=="FloatValue" or v:IsA("IntValue") or v:IsA("Beam") or v:IsA("Trail") or v:IsA("ParticleEmitter") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Script]--
warn("Clean Script")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Image]--
warn("Clean Image")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Decal") or v:IsA("Texture") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Sound]--
warn("Clean Sound")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Sound") then
		v.PlayOnRemove=false
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Interaction]--
warn("Clean Interaction")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("ClickDetector") or v:IsA("ProximityPrompt") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Event]--
warn("Clean Event")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("BindableFunction") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Weld]--
warn("Clean Weld")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("ManualWeld") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Value]--
warn("Clean Value")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v.ClassName=="Vector2Value" or v:IsA("Vector3Value") or v.ClassName=="Vector4Value" or v:IsA("CFrameValue") or v:IsA("BrickColorValue") or v:IsA("Color3Value") or v:IsA("BoolValue") or v:IsA("RayValue") or v:IsA("NumberValue") or v.ClassName=="FloatValue" or v:IsA("IntValue") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Clean Effect]--
warn("Clean Effect")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do
	if v:IsA("Beam") or v:IsA("Trail") or v:IsA("ParticleEmitter") then
		print(i.." | Where: "..v:GetFullName());
		local d=game.Workspace:FindFirstChild("Detects")
		if d~=nil then v.Parent=d; else v:Destroy(); end
	end
end

--[Check Creator Instance]--
warn("Check Creator Instance")
for i,v in pairs(game.Workspace.Cleans:GetDescendants()) do 
	local creator=(v:FindFirstChild("Creator") and v.Creator:IsA("StringValue") and v.Creator.Value) or v:GetAttribute("Creator")
	if creator~=nil then
		print("Name: "..v.Name.." | Creator: "..creator)
	end
end

--[To Fix UI Stroke]--
for _, child in game:GetService("StarterGui"):GetDescendants() do 
	if not child:IsA("UIStroke") or not child.Parent:IsA("GuiObject") then 
		continue 
	end 
	if child.Parent.AbsoluteSize.Magnitude == 0 then 
		continue 
	end 
	local frame = child.Parent 
	local shortestSize = math.min(frame.AbsoluteSize.X,frame.AbsoluteSize.Y)
	local pixelStroke = child.Thickness 
	local newSize = pixelStroke/shortestSize 
	child.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize 
	child.Thickness = newSize 
end
