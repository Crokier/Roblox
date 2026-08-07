local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players,RunService,TweenService=Services.Players,Services.RunService,nil
local LocalPlayer=RunService:IsClient() and Players.LocalPlayer or nil

local PartProperties={"Name","Anchored","Locked","CanCollide","Transparency","Color","Material","Reflectance","CFrame","BackSurface","BottomSurface","FrontSurface","LeftSurface","RightSurface","TopSurface","Size"}
local AddNumberCallback,SpentNumberCallback=function(a,b) return a+b end,function(a,b) return a-b end

local function InvalidArgumentInstance(v,i,s)
	assert(typeof(v)=="Instance",`Invalid argument #{i} (Instance expected, got {typeof(v)}) to Instancer.{s}`)
end

local function InvalidArgumentFunction(v,i,s)
	assert(type(v)=="function",`Invalid argument #{i} (function expected, got {typeof(v)}) to Instancer.{s}`)
end

local function InvalidArgumentNumber(v,i,s)
	assert(type(v)=="number",`Invalid argument #{i} (number expected, got {typeof(v)}) to Instancer.{s}`)
end

local function InvalidArgumentString(v,i,s)
	assert(type(v)=="string",`Invalid argument #{i} (string expected, got {typeof(v)}) to Instancer.{s}`)
end

local function InvalidArgumentTable(v,i,s)
	assert(type(v)=="table",`Invalid argument #{i} (table expected, got {typeof(v)}) to Instancer.{s}`)
end

local Instancer={}

-- Check Function --
function Instancer.IsAlive(instance)
	if instance and instance.Parent then return true else return false end
end

function Instancer.IsCharacter(instance)
	return instance~=nil and instance.Parent~=nil and instance.ClassName=="Model" and instance:FindFirstChildOfClass("Humanoid")
end

function Instancer.IsDied(instance)
	if instance~=nil and instance.Parent~=nil then
		local humanoid=instance:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health>0 and humanoid.MaxHealth>0 then
			return false
		end
		return false
	end
	return true
end

function Instancer.IsNPC(instance)
	return instance and instance:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(instance)
end

function Instancer.IsAs(instance,classNames)
	for i,v in ipairs(classNames) do if Instancer.IsAlive(instance) and instance:IsA(v) then return true end end return false
end

function Instancer.GetPlot(path,player,match)
	local plots=Instancer.FindByPath(workspace,path)
	if not plots then return nil end

	local userId,userName=player.UserId,player.Name

	if not match or typeof(match)~="function" then
		match=function(plot)
			local plotName=plot.Name
			if plot:IsA("Folder") or plot:IsA("Model") then
				local attributes=plot:GetAttributes()
				if next(attributes) then 
					for attributeName,attributeValue in pairs(attributes) do
						if attributeValue==nil then continue end

						local lowerAttributeName = string.lower(attributeName)
						if lowerAttributeName=="owner" or lowerAttributeName == "ownerid" or lowerAttributeName=="owneruserid" or lowerAttributeName=="playerid" or lowerAttributeName=="playeruserid" and tonumber(attributeValue) and tostring(attributeValue)==tostring(userId) then
							return true
						end
						if lowerAttributeName=="owner" or lowerAttributeName == "ownername" and tostring(attributeValue)==tostring(userName) then
							return true
						end
					end
				end
				if plotName==userName or string.find(plotName,userName) then
					return true
				end
				if plotName==userId or string.find(plotName,userId) then
					return true
				end
			end
		end
	end

	for _,plot in ipairs(plots:GetChildren()) do
		if not Instancer.IsAlive(plot) then continue end

		local access=match(plot)
		if access then return plot end
	end

	return nil
end

-- Attribute Function --
function Instancer.AddAttribute(instance,attribute,value,callback)
	InvalidArgumentInstance(instance,1)
	InvalidArgumentString(attribute,2)
	InvalidArgumentNumber(value,3)
	callback=type(callback)=="function" and callback or AddNumberCallback
	local current=instance:GetAttribute(attribute)
	if type(current)=="number" then
		local amount=callback(current,value)
		instance:SetAttribute(attribute,amount)
	else
		instance:SetAttribute(attribute,value)
	end
end

function Instancer.SpentAttribute(instance,attribute,value,callback)
	InvalidArgumentInstance(instance,1)
	InvalidArgumentString(attribute,2)
	InvalidArgumentNumber(value,3)
	callback=type(callback)=="function" and callback or SpentNumberCallback
	local current=instance:GetAttribute(attribute)
	if type(current)=="number" then
		local amount=callback(current,value)
		instance:SetAttribute(attribute,amount)
	else
		instance:SetAttribute(attribute,value)
	end
end

-- Child Function --
function Instancer.FindOrCreateChild(instance,name,className,data)
	InvalidArgumentInstance(instance,1,"FindOrCreateChild")
	InvalidArgumentString(name,2,"FindOrCreateChild")
	InvalidArgumentString(className,3,"FindOrCreateChild")
	data=type(data)=="table" and data or {}
	local c=nil
	for i,v in ipairs(instance:GetChildren()) do if v~=nil and v.Parent~=nil and v.Name==name and v:IsA(className) then c=v break end end
	if not c then
		c=Instance.new(className)
		c.Name=name
		local parent=instance
		for k,v in pairs(data) do
			if type(k)=="string" then
				if k=="Parent" then
					parent=v
				else
					pcall(function() c[k]=v end)
				end
			end
		end
		c.Parent=parent
	end
	return c
end

-- Wait For --
function Instancer.WaitForChildOfClass(instance, className, timeout)
	timeout = typeof(timeout) == "number" and timeout or 5

	local existingChild = instance:FindFirstChildOfClass(className)
	if existingChild then return existingChild end
	
	local currentThread = coroutine.running()
	local connection = nil
	local timeoutThread = nil

	connection = instance.ChildAdded:Connect(function(child)
		if child:IsA(className) then
			if connection then connection:Disconnect() connection = nil end
			if timeoutThread and coroutine.status(timeoutThread) ~= "dead" then task.cancel(timeoutThread) timeoutThread = nil end
			task.spawn(currentThread, child)
		end
	end)

	timeoutThread = task.delay(timeout, function()
		if connection and connection.Connected then
			connection:Disconnect()
			connection= nil
			warn(string.format("Infinite yield possible on 'Instancer.WaitForChildOfClass(%s, \"%s\")'", instance:GetFullName(), className))
			task.spawn(currentThread, nil)
			currentThread = nil
		end
	end)

	return coroutine.yield()
end

-- Yield For
function Instancer.YieldForChild(instance,match,callback)
	if not callback or typeof(callback) ~= "function" then
		callback = function() return false end
	end

	local yieldThread = coroutine.running()
	local connection = nil
	local done = false

	local function OnChildAdded(child)
		if child and child.Parent then
			local success = match(child)
			if success and not done then
				done = true
				connection:Disconnect()
				if coroutine.status(yieldThread) == "suspended" then
					task.spawn(yieldThread, child)
				end
			end
		end
	end

	connection = instance.ChildAdded:Connect(OnChildAdded)

	task.defer(function()
		if not connection.Connected or done then return end
		while connection.Connected and not done do
			task.wait(1)
			local children = instance:GetChildren()
			for _, child in ipairs(children) do
				task.wait()
				if done then break end
				OnChildAdded(child)
			end
			if not done then
				local success = callback()
				if success and not done then
					done = true
					connection:Disconnect()
					if coroutine.status(yieldThread) == "suspended" then
						task.spawn(yieldThread, nil)
					end
					break
				end
			end
		end
	end)

	return coroutine.yield()
end

-- Other Function --
function Instancer.SetCollisionGroup(instance,collisionGroup)
	InvalidArgumentInstance(instance,1)
	InvalidArgumentString(collisionGroup,2)
	local descendants=instance:GetDescendants()
	for i,v in ipairs(descendants) do  if v:IsA("BasePart") then v.CollisionGroup=collisionGroup end end
end

function Instancer.CreatePart(partInfo)
	local data=type(partInfo)=="table" and partInfo or {}
	local part=Instance.new("Part")
	part.Name=data.Name or part.ClassName
	part.Shape=data.Shape or Enum.PartType.Ball
	if data.Radius then
		part.Size=Vector3.new(data.Radius,data.Radius,data.Radius)
	else
		part.Size=data.Size or Vector3.new(1,1,1)
	end
	part.Position=data.Position or Vector3.new(0,0,0)
	part.Anchored=data.Anchored or true
	part.CanCollide=data.CanCollide or false
	part.CanQuery=data.CanQuery or true
	part.CanTouch=data.CanTouch or true
	part.Transparency=data.Transparency or 1
	part.Material=data.Material or Enum.Material.Neon
	part.Color=data.Color or Color3.fromRGB(255,255,255)
	if typeof(data.CFrame)=="CFrame" then
		part.CFrame=data.CFrame
	end
	part.Parent=data.Parent or workspace
	return part
end


-- Deprecated
function Instancer.FindByPath(instance,path,match)
	if true then error("Instancer.FindByPath is deprecated, use Instance:QueryDescendants instead") end

	local array,totalArray={},0

	local pathType=type(path)
	if pathType=="string" then
		for part in string.gmatch(path,"[^%.]+") do
			table.insert(array,part)
		end
	elseif pathType=="table" then
		array=path
	elseif pathType=="number" then
		totalArray=path
	else
		error(`Invalid argument #2 (string or number or table expected, got {typeof(path)}) to Instancer.FindByPath`)
		return nil
	end

	if pathType=="number" and (not match or type(match) ~= "function") then
		error(`Invalid argument #3 (function expected, got {typeof(match)}) to Instancer.FindByPath`)
	end

	if #array>1 then 
		local function SearchInstance(current,index)
			if not Instancer.IsAlive(current) then return nil end

			if pathType=="number" then
				if index>totalArray then
					return current
				end

				for _,child in ipairs(current:GetChildren()) do
					if Instancer.IsAlive(child) then
						local newIndex=index+1
						local access=match(child,index,newIndex)
						if access then
							local result=SearchInstance(child,newIndex)

							if result then
								return result
							end
						end
					end
				end
			else
				if index>#array then
					return current
				end

				local targetName=array[index]

				for _,child in ipairs(current:GetChildren()) do
					if Instancer.IsAlive(child) and child.Name==targetName then
						local result=SearchInstance(child,index+1)

						if result then
							return result
						end
					end
				end
			end

			return nil
		end

		return SearchInstance(instance,1)
	else
		for _,child in ipairs(instance:GetChildren()) do
			if Instancer.IsAlive(child) then
				local access=false
				if pathType=="number" then
					access=match(child,1,1)
				else
					access=child.Name==path[1]
				end
				if access then
					return child
				end
			end
		end
	end

	return nil
end

function Instancer.CreateVariable(instance,variables,name)
	InvalidArgumentInstance(instance,1,"CreateVariable")
	InvalidArgumentTable(variables,2,"CreateVariable")

	local currentName=type(name)=="string" and name or instance.Name

	-- Remove symbols
	local nameWithoutSymbols=""
	for v in string.gmatch(currentName,"[%w_]") do nameWithoutSymbols=nameWithoutSymbols..v end

	-- Check for string
	local baseName=""
	if #nameWithoutSymbols==0 then
		baseName=instance.ClassName
	elseif string.find(string.sub(nameWithoutSymbols,1,1),"%d") then
		baseName="_"..nameWithoutSymbols
	else
		baseName=nameWithoutSymbols
	end

	-- Check for original name
	local isOriginal=true
	for i,v in pairs(variables) do if v==baseName then isOriginal=false break end end
	if isOriginal then variables[instance]=baseName return end

	-- Check for duplicate name
	local count=1
	local isDuplicate=false
	while true do
		isDuplicate=false
		local mainBaseName=baseName.."_"..tostring(count)
		for i,v in pairs(variables) do if v==mainBaseName then isDuplicate=true break end end
		count=count+1
		if not isDuplicate then variables[instance]=mainBaseName return end
		task.wait()
	end
end

function Instancer.ConvertMeshPartToSpecialMesh(instance)
	if instance and instance.Parent and instance:IsA("MeshPart") then
		local meshId,textureId=instance.MeshId,instance.TextureID
		local part=Instance.new("Part")
		for i,v in ipairs(PartProperties) do if pcall(function() return part[v] end) then part[v]=instance[v] end end
		local specialMesh=Instance.new("SpecialMesh")
		specialMesh.Name="SpecialMesh"
		specialMesh.MeshType=Enum.MeshType.FileMesh
		specialMesh.MeshId=meshId
		specialMesh.TextureId=textureId
		specialMesh.Scale=(1/instance.MeshSize)*instance.ExtentsSize
		specialMesh.Parent=part
		part.Parent=instance.Parent
		local t={}
		for j,k in ipairs(instance:GetDescendants()) do if not k:IsA("SurfaceAppearance") then k.Parent=part else table.insert(t,k) end end
		if next(t) then for i,v in ipairs(t) do if not v:IsA("SurfaceAppearance") then v.Parent=part table.remove(t,i) end end end
		if next(t) then for i,v in ipairs(t) do v:Destroy() end end
		instance:Destroy()
	end
end

function Instancer.GetInstanceProperty(instance,properties,func)
	InvalidArgumentInstance(instance,1,"GetInstanceProperty")
	InvalidArgumentTable(properties,2,"GetInstanceProperty")
	InvalidArgumentFunction(func,1,"GetInstanceProperty")
	for i,v in ipairs(properties) do 
		local success=pcall(function() return instance[v] end)
		if success then
			pcall(func,typeof(instance[v]),instance[v],v,i)
		end 
	end 
end

function Instancer.GetAncestorsAndSelf(instance)
	InvalidArgumentInstance(instance,1,"GetAncestorsAndSelf")
	local current=nil
	local function NextParent()
		if current==nil then current=instance else current=current.Parent end return current
	end
	return NextParent
end

function Instancer.CopyInstance(className,instance,properties)
	InvalidArgumentString(className,1,"CopyInstance")
	InvalidArgumentInstance(instance,2,"CopyInstance")
	InvalidArgumentTable(properties,3,"CopyInstance")
	local newInstance=Instance.new(className)  
	local i=1  
	for j,k in pairs(properties) do  
		local v=properties[i] 
		if v then 
			i=i+1 
			local success=pcall(function() return newInstance[v] end)
			if success then  
				newInstance[v]=instance[v] 
			end 
		end 
	end 
	return newInstance
end

function Instancer.TeleportModel(mode, character, target, duration)
	local hrp = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")

	local m = tostring(mode):lower()

	if m == "1" or m == "cframe" then
		hrp.CFrame = target.CFrame
	elseif m == "2" or m == "pivotto" then
		character:PivotTo(target.CFrame)
	elseif m == "3" or m == "moveto" then
		character:MoveTo(target.Position)
	elseif m == "4" or m == "position" then
		hrp.Position = target.Position
	elseif m == "5" or m == "setprimarypartcframe" then
		character:SetPrimaryPartCFrame(target.CFrame)
	elseif m == "6" or m == "cframenew" then
		hrp.CFrame = CFrame.new(target.Position)
	elseif m == "7" or m == "primarypart" then
		character.PrimaryPart.CFrame = target.CFrame
	elseif m == "8" or m == "offset" then
		hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
	elseif m == "9" or m == "translateby" then
		character:TranslateBy(target.Position - hrp.Position)
	elseif m == "10" or m == "tween" then
		TweenService = TweenService or Services.TweenService
		local tween = TweenService:Create(hrp, TweenInfo.new(duration or 0.01), {CFrame = target.CFrame})
		tween:Play()
	else
		character:PivotTo(target.CFrame)
	end
end

function Instancer.CopyInstanceWith(list,objectClasses,object,match)
	InvalidArgumentTable(list,1,"CopyInstanceWith")
	InvalidArgumentTable(objectClasses,2,"CopyInstanceWith")
	InvalidArgumentFunction(match,4,"CopyInstanceWith")
	local parent=typeof(object)=="Instance" and object or nil
	local func=type(object)=="function" and object or nil
	if func~=nil or parent~=nil then else return end
	for j,k in ipairs(list) do 
		if k and k.Parent then 
			for i,v in ipairs(k:GetDescendants()) do 
				if v and v.Parent and match(v) then
					local className=v.ClassName
					if func~=nil then
						func(v)
					elseif parent~=nil then
						local nv=Instancer.CopyInstance(className,v,objectClasses[className]) 
						nv.Parent=parent 
						RunService.Stepped:Wait() 
					end
				end 
			end 
		end
	end
end

function Instancer.SetChildrenParent(instance,parent)
	InvalidArgumentInstance(instance,1,"SetChildrenParent")
	for i,v in ipairs(instance:GetChildren()) do v.Parent=parent  end
end

function Instancer.GetChildrenWhichIsA(instance,className)
	InvalidArgumentInstance(instance,1,"GetChildrenWhichIsA")
	InvalidArgumentString(className,2,"GetChildrenWhichIsA")
	local list={}
	for i,v in ipairs(instance:GetChildren()) do if v:IsA(className) then table.insert(list,v) end end
	return list
end

function Instancer.GetDescendantsWhichIsA(instance,className)
	InvalidArgumentInstance(instance,1,"GetDescendantsWhichIsA")
	InvalidArgumentString(className,2,"GetDescendantsWhichIsA")
	local list={}
	for i,v in ipairs(instance:GetDescendants()) do if v:IsA(className) then table.insert(list,v) end end
	return list
end

function Instancer.SetPartAnchoredChildren(v,anchored)
	if Instancer.IsAlive(v) then for i,v in ipairs(v:GetChildren()) do if Instancer.IsAlive(v) and v.ClassName=="Part" or v.ClassName=="MeshPart" then v.Anchored=anchored end end end
end

function Instancer.GetCharacterInfo(instance,data)
	local characterInfo={}

	if Instancer.IsCharacter(instance) then 
		local noParts,callback=data and data.NoParts,data and data.Callback

		local headPart=instance:FindFirstChild("Head") 
		if Instancer.IsAlive(headPart) and headPart:IsA("BasePart") then 
			characterInfo.Head=headPart
			if callback and type(callback)=="function" then pcall(callback,"Head",headPart) end
		end 

		local rootPart=instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("Torso") or instance:FindFirstChild("UpperTorso") or instance.PrimaryPart 
		if Instancer.IsAlive(rootPart) then 
			characterInfo.HumanoidRootPart=rootPart 
			if callback and type(callback)=="function" then pcall(callback,"HumanoidRootPart",rootPart) end
		end

		local humanoid=instance:FindFirstChildOfClass("Humanoid") :: Humanoid
		if Instancer.IsAlive(humanoid) then 
			characterInfo.Humanoid=humanoid
			characterInfo.RigType=humanoid.RigType
			if callback and type(callback)=="function" then pcall(callback,"Humanoid",humanoid) end
		end 

		if not noParts then
			characterInfo.Parts={}
			for i,v in ipairs(instance:GetChildren()) do if v:IsA('BasePart') then table.insert(characterInfo.Parts,v) end end
			if #characterInfo.Parts>=2 then
				characterInfo.RandomPart=characterInfo.Parts[math.random(1,#characterInfo.Parts)]
			else
				characterInfo.RandomPart=characterInfo.HumanoidRootPart
			end
			if callback and type(callback)=="function" then pcall(callback,"RandomPart",characterInfo.RandomPart) end
		end
	end

	return characterInfo
end

-- Raycast Function --
function Instancer.GetHitRaycast(instance, raycastInfo, match)
	local part = nil

	if instance:IsA("Model") then
		part = instance.PrimaryPart or instance:FindFirstChild("HumanoidRooPart")
		if not part then
			for _, child in ipairs(instance:GetChildren()) do
				if child ~= nil and child.Parent ~= nil and child:IsA("BasePart") then
					part = child
					break
				end
			end
		end
	elseif instance:IsA("BasePart") then
		part = instance
	end

	if not part then return nil, nil end

	raycastInfo = raycastInfo or {}

	-- Set up Raycast: Start point at the instance, direction downwards for 100 studs
	local rayOrigin = part.Position
	local rayDirection = raycastInfo.Direction or Vector3.new(0, -100, 0)

	-- Ignore the instance so the raycast does not hit itself.
	if not raycastInfo.RaycastParams then
		raycastInfo.RaycastParams = RaycastParams.new()
		raycastInfo.RaycastParams.FilterDescendantsInstances = {instance}
		raycastInfo.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end
	local raycastParams = raycastInfo.RaycastParams

	-- Perform Raycast
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		local hit = raycastResult.Instance
		if hit then 
			local current, last = hit, nil

			while current ~= workspace and not match(current, last) do
				last = current
				current = current.Parent
				task.wait()
			end

			return current, last
		end
	end

	return nil, nil
end

-- Player Function --
function Instancer.GetPlayer(object)
	if not object then return nil end
	local objectType,playerList=typeof(object),{}
	if objectType=="Instance" then
		if not (object ~= nil and object.Parent ~= nil) then return nil end
		if object.ClassName=="Player" and object:IsDescendantOf(Players) then return object end
		local isModel=object.ClassName=="Model"
		local playerList=Players:GetPlayers()
		for index=#playerList,1,-1 do
			local player=playerList[index]
			if not (player~=nil and player.Parent~=nil) then continue end
			local character=player.Character
			if not (character~=nil and character.Parent~=nil) then continue end
			if isModel and character==object then return player end
			if not isModel and (object ~= nil and object.Parent ~= nil) and object:IsDescendantOf(character) then return player end
		end
	elseif objectType=="string" or objectType=="number" then
		local inputNumber=tonumber(object)
		if inputNumber then
			local playerList=Players:GetPlayers()
			for index=#playerList,1,-1 do
				local player=playerList[index]
				if player~=nil and player.Parent~=nil and player.UserId==inputNumber then 
					return player 
				end 
			end
		else
			local s=tostring(object) or ""
			local ls=string.lower(s)
			if ls=="!me" then
				if (LocalPlayer~=nil and LocalPlayer.Parent~=nil) then return LocalPlayer end
			elseif ls=="!random" then
				local matches={}
				if RunService:IsClient() then
					local playerList=Players:GetPlayers()
					for index=#playerList,1,-1 do
						local player=playerList[index]
						if (player~=nil and player.Parent~=nil) and (LocalPlayer~=nil and LocalPlayer.Parent~=nil) and player~=LocalPlayer or player.UserId~=LocalPlayer.UserId then 
							table.insert(matches,player)
						end 
					end
				else
					local playerList=Players:GetPlayers()
					for index=#playerList,1,-1 do
						local player=playerList[index]
						if (player~=nil and player.Parent~=nil) then
							table.insert(matches,player)
						end
					end
				end
				if #matches>=2 then return matches[math.random(1,#matches)] end
			else
				for mode=1,4 do
					local playerList=Players:GetPlayers()
					for index=#playerList,1,-1 do
						local player=playerList[index]
						if not (player~=nil and player.Parent~=nil) then continue end
						local key="" if mode==1 then key=player.Name elseif mode==2 then key=player.DisplayName elseif mode==3 then key=string.lower(player.Name) else key=string.lower(player.DisplayName) end
						if string.find(key,s) then return player end
					end
				end
			end
		end
	end
	return nil
end

return Instancer
