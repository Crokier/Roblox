local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players=Services.Players
local CollectionService=Services.CollectionService

type InstanceStatus="__inflight__"|"__dead__"

export type AttributeValue=
	string
| boolean
| number
| UDim
| UDim2
| BrickColor
| Color3
| Vector2
| Vector3
| CFrame
| NumberSequence
| ColorSequence
| NumberRange
| Rect
| Font

export type PropertyValue=
	AttributeValue 
| Instance 
| Ray
| {}
| unknown

local EmptyFunction=function() end

local function ObserveChild(instance:Instance,callback:(child:Instance)->(()->()),noInitial:boolean?):()->()
	local childAddedConnection:RBXScriptConnection
	local childRemovedConnection:RBXScriptConnection
	local childCache:{[Instance]:()->()}={}

	local function OnChildAdded(child:Instance?)
		task.defer(function()
			if childAddedConnection.Connected and child and child.Parent then
				local cleanup=callback(child)
				if type(cleanup)~="function" then return end
				if childAddedConnection.Connected and child and child.Parent then
					childCache[child]=cleanup
				else
					task.spawn(cleanup)
				end
			end
		end)
	end

	local function OnChildRemoved(child:Instance)
		local cleanup=childCache[child]
		childCache[child]=nil
		if type(cleanup)~="function" then return end
		task.spawn(cleanup)
	end

	-- Listen for changes:
	childAddedConnection=instance.ChildAdded:Connect(OnChildAdded)
	childRemovedConnection=instance.ChildRemoved:Connect(OnChildRemoved)

	-- Initial:
	task.defer(function()
		if not childAddedConnection.Connected or noInitial then return end
		local children=instance:GetChildren()
		for i,child in ipairs(children) do
			OnChildAdded(child)
		end
	end)

	-- Cleanup:
	return function()
		childAddedConnection:Disconnect()
		childRemovedConnection:Disconnect()
		local child=next(childCache)
		while child do
			OnChildRemoved(child)
			child=next(childCache)
		end
	end
end

local function ObserveDescendant(instance:Instance,callback:(descendant:Instance)->(()->()),noInitial:boolean?):()->()
	local descendantAddedConnection:RBXScriptConnection
	local descendantRemovedConnection:RBXScriptConnection
	local descendantCache:{[Instance]:()->()}={}

	local function OnDescendantAdded(descendant:Instance?)
		task.defer(function()
			if descendantAddedConnection.Connected and descendant and descendant.Parent then
				local cleanup=callback(descendant)
				if type(cleanup)~="function" then return end
				if descendantAddedConnection.Connected and descendant and descendant.Parent then
					descendantCache[descendant]=cleanup
				else
					task.spawn(cleanup)
				end
			end
		end)
	end

	local function OnDescendantRemoving(descendant:Instance)
		local cleanup=descendantCache[descendant]
		descendantCache[descendant]=nil
		if type(cleanup)~="function" then return end
		task.spawn(cleanup)
	end

	-- Listen for changes:
	descendantAddedConnection=instance.DescendantAdded:Connect(OnDescendantAdded)
	descendantRemovedConnection=instance.DescendantRemoving:Connect(OnDescendantRemoving)

	-- Initial:
	task.defer(function()
		if not descendantAddedConnection.Connected or noInitial then return end
		local descendants=instance:GetDescendants()
		for i,descendant in ipairs(descendants) do
			OnDescendantAdded(descendant)
		end
	end)

	-- Cleanup:
	return function()
		descendantAddedConnection:Disconnect()
		descendantRemovedConnection:Disconnect()
		local descendant=next(descendantCache)
		while descendant do
			OnDescendantRemoving(descendant)
			descendant=next(descendantCache)
		end
	end
end

local function ObservePlayer(callback:(player:Player)->(()->()),noInitial:boolean?):()->()
	local playerAddedConnection:RBXScriptConnection
	local playerRemovedConnection:RBXScriptConnection
	local playerCache:{[Instance]:()->()}={}

	local function OnPlayerAdded(player:Player?)
		task.defer(function()
			if playerAddedConnection.Connected and player and player.Parent then
				local cleanup=callback(player)
				if type(cleanup)~="function" then return end
				if playerAddedConnection.Connected and player and player.Parent then
					playerCache[player]=cleanup
				else
					task.spawn(cleanup)
				end
			end
		end)
	end

	local function OnPlayerRemoving(player:Player)
		local cleanup=playerCache[player]
		playerCache[player]=nil
		if type(cleanup)~="function" then return end
		task.spawn(cleanup)
	end

	-- Listen for changes:
	playerAddedConnection=Players.PlayerAdded:Connect(OnPlayerAdded)
	playerRemovedConnection=Players.PlayerRemoving:Connect(OnPlayerRemoving)

	-- Initial:
	task.defer(function()
		if not playerAddedConnection.Connected or noInitial then return end
		local plrs=Players:GetPlayers()
		for i,player in ipairs(plrs) do
			OnPlayerAdded(player)
		end
	end)

	-- Cleanup:
	return function()
		playerAddedConnection:Disconnect()
		playerRemovedConnection:Disconnect()
		local player=next(playerCache)
		while player do
			OnPlayerRemoving(player::Player)
			player=next(playerCache)
		end
	end
end

local function ObserveCharacter(player:Player,callback:(character:Model)->(()->()),noInitial:boolean?):()->()
	local cleanup:(()->())?=nil
	local characterAddedConnection:RBXScriptConnection
	local ancestryChangedConnection:RBXScriptConnection
	local playerAncestryChangedConnection:RBXScriptConnection
	local done=false

	local function OnCharacterAdded(character:Model?)
		if characterAddedConnection.Connected and character and character.Parent then 
			local characterCleanup:(()->())?=nil
			task.defer(function()
				if characterAddedConnection.Connected and character and character.Parent then 
					local clean=callback(character)
					if type(clean)=="function" then
						if characterAddedConnection.Connected and character and character.Parent then
							characterCleanup=clean
							cleanup=clean
						else
							task.spawn(clean)
						end
					end
				end
			end)
			if ancestryChangedConnection then
				ancestryChangedConnection:Disconnect()
			end
			ancestryChangedConnection=character.AncestryChanged:Connect(function(_,parent)
				if not parent and ancestryChangedConnection.Connected then
					ancestryChangedConnection:Disconnect()
					if not characterCleanup then return end
					task.spawn(characterCleanup)
					if cleanup==characterCleanup then
						cleanup=nil
					end
					characterCleanup=nil
				end
			end)
		end
	end

	local function OnPlayerRemoved()
		if done then return end
		done=true

		characterAddedConnection:Disconnect()
		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
		end
		if playerAncestryChangedConnection then
			playerAncestryChangedConnection:Disconnect()
		end
		if cleanup~=nil then
			task.spawn(cleanup)
			cleanup=nil
		end
	end

	-- Listen for changes:
	characterAddedConnection=player.CharacterAdded:Connect(OnCharacterAdded)
	playerAncestryChangedConnection=player.AncestryChanged:Connect(function(_,parent)
		if not parent then OnPlayerRemoved() end
	end)

	-- Initial:
	task.defer(function()
		if not characterAddedConnection.Connected or noInitial then return end
		OnCharacterAdded(player.Character)
	end)

	-- Cleanup:
	return function()
		OnPlayerRemoved()
	end
end

local function ObserveProperty(instance:Instance,property:string,callback:(value:PropertyValue)->()->(),noInitial:boolean?):()->()
	local cleanup:(()->())?=nil
	local propertyChangedConnection:RBXScriptConnection
	local changedId=0

	local function OnPropertyChanged()
		if cleanup~=nil then
			task.spawn(cleanup)
			cleanup=nil
		end
		changedId+=1
		local id=changedId
		local value=(instance::any)[property]
		task.spawn(function()
			local clean=callback(value)
			if type(clean)=="function" then
				if id==changedId and propertyChangedConnection.Connected then
					cleanup=clean
				else
					task.spawn(clean)
				end
			end
		end)
	end

	-- Listen for changes:
	propertyChangedConnection=instance:GetPropertyChangedSignal(property):Connect(OnPropertyChanged)

	-- Initial:
	task.defer(function()
		if not propertyChangedConnection.Connected or noInitial then return end
		OnPropertyChanged()
	end)

	-- Cleanup:
	return function()
		propertyChangedConnection:Disconnect()
		if cleanup~=nil then
			task.spawn(cleanup)
			cleanup=nil
		end
	end
end

local function ObserveTag(tag:string,callback:(instance:Instance)->(()->()),ancestors:{Instance}?,noInitial:boolean?):()->()
	local instances:{[Instance]:InstanceStatus|()->()}={}
	local ancestryCache:{[Instance]:RBXScriptConnection}={}
	local instanceAddedConnection:RBXScriptConnection
	local instanceRemovedConnection:RBXScriptConnection

	local function IsGoodAncestor(instance:Instance)
		if not ancestors then return true end
		for i,ancestor in ancestors do
			if instance:IsDescendantOf(ancestor) then
				return true
			end
		end
		return false
	end

	local function AttemptStartup(instance:Instance)
		instances[instance]="__inflight__"
		task.defer(function()
			if instances[instance]~="__inflight__" then return end
			local cleanup=callback(instance)
			if type(cleanup)~="function" then return end
			if instances[instance]~="__inflight__" then
				task.spawn(cleanup)
			else
				instances[instance]=cleanup
			end
		end)
	end

	local function AttemptCleanup(instance:Instance)
		local cleanup=instances[instance]
		instances[instance]="__dead__"
		if typeof(cleanup)=="function" then
			task.spawn(cleanup)
		end
	end

	local function OnAncestryChanged(instance:Instance)
		if IsGoodAncestor(instance) then
			if instances[instance]=="__dead__" then
				AttemptStartup(instance)
			end
		else
			AttemptCleanup(instance)
		end
	end

	local function OnInstanceAdded(instance:Instance)
		task.defer(function()
			if instanceAddedConnection.Connected and instance.Parent and not instances[instance] then 
				instances[instance]="__dead__"
				ancestryCache[instance]=instance.AncestryChanged:Connect(function()
					OnAncestryChanged(instance)
				end)
				OnAncestryChanged(instance)
			end
		end)
	end

	local function OnInstanceRemoved(instance:Instance)
		AttemptCleanup(instance)
		local ancestry=ancestryCache[instance]
		if ancestry then
			ancestry:Disconnect()
			ancestryCache[instance]=nil
		end
		instances[instance]=nil
	end

	-- Listen for changes:
	instanceAddedConnection=CollectionService:GetInstanceAddedSignal(tag):Connect(OnInstanceAdded)
	instanceRemovedConnection=CollectionService:GetInstanceRemovedSignal(tag):Connect(OnInstanceRemoved)

	-- Initial:
	task.defer(function()
		if not instanceAddedConnection.Connected or noInitial then return end
		local tagged=CollectionService:GetTagged(tag)
		for i,instance in ipairs(tagged) do
			task.defer(OnInstanceAdded,instance)
		end
	end)

	-- Cleanup:
	return function()
		instanceAddedConnection:Disconnect()
		instanceRemovedConnection:Disconnect()
		local instance=next(instances)
		while instance do
			OnInstanceRemoved(instance)
			instance=next(instances)
		end
	end
end

local function ObserveAttribute(instance:Instance,name:string,callback:(value:AttributeValue)->(()->()),noInitial:boolean?):()->()
	local cleanup:(()->())?=nil
	local attributeChangedConnection:RBXScriptConnection
	local changedId=0

	local function OnAttributeChanged()
		if cleanup~=nil then
			task.spawn(cleanup)
			cleanup=nil
		end
		changedId+=1
		local id=changedId
		local value:AttributeValue=instance:GetAttribute(name)
		if value~=nil then
			task.spawn(function()
				local clean=callback(value)
				if type(clean)=="function" then
					if id==changedId and attributeChangedConnection.Connected then
						cleanup=clean
					else
						task.spawn(clean)
					end
				end
			end)
		end
	end

	-- Listen for changes:
	attributeChangedConnection=instance:GetAttributeChangedSignal(name):Connect(OnAttributeChanged)

	-- Initial:
	task.defer(function()
		if not attributeChangedConnection.Connected or noInitial then return end
		OnAttributeChanged()
	end)

	-- Cleanup:
	return function()
		attributeChangedConnection:Disconnect()
		if cleanup~=nil then
			task.spawn(cleanup)
			cleanup=nil
		end
	end
end

local function ObserveClamp(x:any,min:any,max:any,uses:any)
	if not x then return min end
	if type(x)=="string" then x=tonumber(x) end
	if type(x)~="number" then return min end
	if not min then min=0 end
	if type(min)=="string" then 
		min=tonumber(min)
	end
	if type(min)~="number" then min=0 end
	if not max then max=math.huge end
	if type(max)=="string" then 
		if max=="inf" or max=="huge" then max=math.huge else max=tonumber(max) end
	end
	if type(max)~="number" then max=math.huge end
	if x>=max then return max end
	if uses~=nil and type(uses)=="table" then
		local useNegative=uses[1] or uses["Negative"]
		if useNegative and x<=0 then return min end
		local useNaN=uses[2] or uses["NaN"]
		if useNaN and x~=x then return min end
		local useFloor=uses[3] or uses["Floor"]
		if useFloor and math.floor(x)~=x then return math.clamp(math.floor(x),min,max) end
	else
		if x<=0 or x~=x or math.floor(x)~=x then return min end
	end
	return x
end

local function ObserveDead(character:Instance,callback:()->()->(),useValue:boolean?)
	if not (character~=nil and character.Parent~=nil) then callback("Removed") return EmptyFunction end

	local dead=false

	local function OnDead()
		if dead then return end
		dead=true

		callback()
	end

	local cleanupHumanoid:()->()?=nil
	local humanoid:Humanoid?=character:FindFirstChildOfClass("Humanoid")
	if humanoid~=nil then
		if humanoid.Health<=0 or humanoid.MaxHealth<=0 then
			OnDead()
		else
			-- Detect health <= 0
			local healthConnection:RBXScriptConnection
			healthConnection=humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health<=0 and healthConnection.Connected then
					healthConnection:Disconnect()
					OnDead()
				end
			end)

			-- Detect MaxHealth <= 0
			local maxHealthConnection:RBXScriptConnection
			maxHealthConnection=humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
				if humanoid.MaxHealth<=0 and maxHealthConnection.Connected then
					maxHealthConnection:Disconnect()
					OnDead()
				end
			end)

			cleanupHumanoid=function()
				if healthConnection.Connected then healthConnection:Disconnect() end
				if maxHealthConnection.Connected then maxHealthConnection:Disconnect() end
			end
		end
	end

	local healthConnection:RBXScriptConnection
	if useValue then
		local health:number?=character:GetAttribute("Health")
		if health~=nil and health<=0 then
			OnDead()
		else
			healthConnection=character:GetAttributeChangedSignal("Health"):Connect(function()
				local health:number?=character:GetAttribute("Health")
				if health~=nil and health<=0 and healthConnection.Connected then
					healthConnection:Disconnect()
					OnDead()
				end
			end)
		end
	end

	-- Detect character parent == nil
	local ancestryChangedConnection:RBXScriptConnection
	ancestryChangedConnection=character.AncestryChanged:Connect(function(_,parent)
		if not parent and ancestryChangedConnection.Connected then
			ancestryChangedConnection:Disconnect()
			OnDead()
		end
	end)

	return function()
		if ancestryChangedConnection.Connected then ancestryChangedConnection:Disconnect() end
		if cleanupHumanoid then cleanupHumanoid() cleanupHumanoid=nil end
		if healthConnection and healthConnection.Connected then healthConnection:Disconnect() end
	end
end

local Observe={}

Observe.ObserveChild=ObserveChild
Observe.ObserveDescendant=ObserveDescendant
Observe.ObservePlayer=ObservePlayer
Observe.ObserveCharacter=ObserveCharacter
Observe.ObserveProperty=ObserveProperty
Observe.ObserveTag=ObserveTag
Observe.ObserveAttribute=ObserveAttribute
Observe.ObserveClamp=ObserveClamp
Observe.ObserveDead=ObserveDead

return Observe
