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
	local childCache:{[Instance]:()->()}={}
	
	local function OnChildRemoved(child:Instance)
		local childInfo=childCache[child]
		if childInfo==nil then return end
		childCache[child]=nil
		childInfo.AncestryChanged:Disconnect()
		local cleanup=childInfo.Cleanup
		if cleanup==nil or type(cleanup)~="function" then return end
		task.spawn(cleanup,child)
	end

	local function OnChildAdded(child:Instance?)
		if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
			local cleanup=callback(child)
			if cleanup~=nil and type(cleanup)=="function" then
				if childAddedConnection.Connected and child~=nil and child.Parent~=nil then
					local childInfo={["Cleanup"]=cleanup}
					childInfo.AncestryChanged=child.AncestryChanged:Connect(function(_,parent)
						if not (parent~=nil and child:IsDescendantOf(instance)) then
							OnChildRemoved(child)
						end
					end)
					childCache[child]=childInfo
				else
					task.spawn(cleanup,child)
				end
			end
		end
	end

	-- Listen for changes:
	childAddedConnection=instance.ChildAdded:Connect(OnChildAdded)
	
	-- Initial:
	task.defer(function()
		if not childAddedConnection.Connected or noInitial then return end
		local children=instance:GetChildren()
		for i,child in ipairs(children) do
			if not childAddedConnection.Connected then break end
			task.defer(OnChildAdded,child)
		end
	end)

	-- Cleanup:
	return function()
		childAddedConnection:Disconnect()
		local child=next(childCache)
		while child do
			OnChildRemoved(child)
			child=next(childCache)
		end
	end
end

local function ObserveDescendant(instance:Instance,callback:(descendant:Instance)->(()->()),noInitial:boolean?):()->()
	local descendantAddedConnection:RBXScriptConnection
	local descendantCache:{[Instance]:()->()}={}
	
	local function OnDescendantRemoving(descendant:Instance)
		local descendantInfo=descendantCache[descendant]
		if descendantInfo==nil then return end
		descendantCache[descendant]=nil
		descendantInfo.AncestryChanged:Disconnect()
		local cleanup=descendantInfo.Cleanup
		if cleanup==nil or type(cleanup)~="function" then return end
		task.spawn(cleanup,descendant)
	end

	local function OnDescendantAdded(descendant:Instance?)
		if descendantAddedConnection.Connected and descendant~=nil and descendant.Parent~=nil then
			local cleanup=callback(descendant)
			if cleanup~=nil and type(cleanup)=="function" then
				if descendantAddedConnection.Connected and descendant~=nil and descendant.Parent~=nil then
					local descendantInfo={["Cleanup"]=cleanup}
					descendantInfo.AncestryChanged=descendant.AncestryChanged:Connect(function(_,parent)
						if not (parent~=nil and descendant:IsDescendantOf(instance)) then
							OnDescendantRemoving(descendant)
						end
					end)
					descendantCache[descendant]=descendantInfo
				else
					task.spawn(cleanup,descendant)
				end
			end
		end
	end

	-- Listen for changes:
	descendantAddedConnection=instance.DescendantAdded:Connect(OnDescendantAdded)
	
	-- Initial:
	task.defer(function()
		if not descendantAddedConnection.Connected or noInitial then return end
		local descendants=instance:GetDescendants()
		for i,descendant in ipairs(descendants) do
			if not descendantAddedConnection.Connected then break end
			task.defer(OnDescendantAdded,descendant)
		end
	end)

	-- Cleanup:
	return function()
		descendantAddedConnection:Disconnect()
		local descendant=next(descendantCache)
		while descendant do
			OnDescendantRemoving(descendant)
			descendant=next(descendantCache)
		end
	end
end

local function ObservePlayer(callback:(player:Player)->(()->()),noInitial:boolean?):()->()
	local playerAddedConnection:RBXScriptConnection
	local playerCache:{[Player]:()->()}={}

	local function OnPlayerRemoved(player:Player)
		local playerInfo=playerCache[player]
		if playerInfo==nil then return end
		playerCache[player]=nil
		playerInfo.AncestryChanged:Disconnect()
		local cleanup=playerInfo.Cleanup
		if cleanup==nil or type(cleanup)~="function" then return end
		task.spawn(cleanup,player)
	end

	local function OnPlayerAdded(player:Player?)
		if playerAddedConnection.Connected and player~=nil and player.Parent~=nil then
			local cleanup=callback(player)
			if cleanup~=nil and type(cleanup)=="function" then 
				if playerAddedConnection.Connected and player~=nil and player.Parent~=nil then
					local playerInfo={["Cleanup"]=cleanup}
					playerInfo.AncestryChanged=player.AncestryChanged:Connect(function(_,parent)
						if not (parent~=nil and player:IsDescendantOf(Players)) then
							OnPlayerRemoved(player)
						end
					end)
					playerCache[player]=playerInfo
				else
					task.spawn(cleanup,player)
				end
			end
		end
	end

	-- Listen for changes:
	playerAddedConnection=Players.PlayerAdded:Connect(OnPlayerAdded)

	-- Initial:
	task.defer(function()
		if not playerAddedConnection.Connected or noInitial then return end
		local plrs=Players:GetPlayers()
		for i,player in ipairs(plrs) do
			if not playerAddedConnection.Connected then break end
			task.defer(OnPlayerAdded,player)
		end
	end)

	-- Cleanup:
	return function()
		playerAddedConnection:Disconnect()
		local player=next(playerCache)
		while player do
			OnPlayerAdded(player)
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

local function ObserveAllProperty(instance:Instance,properties:{string},callback:(name:string,property:PropertyValue)->()->(),noInitial:boolean?):()->()
	local propertyCleans={}
	local propertyDebounces={}
	for _, property in ipairs(properties) do
		if propertyDebounces[property] then continue end
		propertyDebounces[property]=true
		
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
				local clean=callback(property,value)
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
		table.insert(propertyCleans,function()
			propertyDebounces[property]=false
			propertyChangedConnection:Disconnect()
			if cleanup~=nil then
				task.spawn(cleanup)
				cleanup=nil
			end
		end)
	end
	return function()
		while #propertyCleans>0 do
			local cleanup=table.remove(propertyCleans)
			task.spawn(cleanup)
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

	local function OnInstanceAdded(instance:Instance?)
		task.defer(function()
			if instanceAddedConnection.Connected and instance~=nil and instance.Parent~=nil and not instances[instance] then 
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
			if not instanceAddedConnection.Connected then break end
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

local function ObserveAllTag(tags:{string},callback:(tag:string,instance:Instance)->(()->()),ancestors:{Instance}?,noInitial:boolean?):()->()
	local tagCleans={}
	local tagDebounces={}
	for _, tag in ipairs(tags) do
		if tagDebounces[tag] then continue end
		tagDebounces[tag]=true

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
				local cleanup=callback(tag,instance)
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

		local function OnInstanceAdded(instance:Instance?)
			task.defer(function()
				if instanceAddedConnection.Connected and instance~=nil and instance.Parent~=nil and not instances[instance] then 
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
				if not instanceAddedConnection.Connected then break end
				task.defer(OnInstanceAdded,instance)
			end
		end)

		-- Cleanup:
		table.insert(tagCleans,function()
			tagDebounces[tag]=false
			instanceAddedConnection:Disconnect()
			instanceRemovedConnection:Disconnect()
			local instance=next(instances)
			while instance do
				OnInstanceRemoved(instance)
				instance=next(instances)
			end
		end)
	end
	return function()
		while #tagCleans>0 do
			local cleanup=table.remove(tagCleans)
			task.spawn(cleanup)
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

local function ObserveAllAttribute(instance:Instance,names:{string},callback:(name:string,value:AttributeValue)->(()->()),noInitial:boolean?):()->()
	local attributeCleans={}
	local attributeDebounces={}
	for _, name in ipairs(names) do
		if attributeDebounces[name] then continue end
		attributeDebounces[name]=true

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
					local clean=callback(name,value)
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
		table.insert(attributeCleans,function()
			attributeDebounces[name]=false
			attributeChangedConnection:Disconnect()
			if cleanup~=nil then
				task.spawn(cleanup)
				cleanup=nil
			end
		end)
	end
	return function()
		while #attributeCleans>0 do
			local cleanup=table.remove(attributeCleans)
			task.spawn(cleanup)
		end
	end
end

local function ObserveDead(instance:Instance,callback:()->()->(),useValue:boolean?)
	if not (instance~=nil and instance.Parent~=nil) then callback() return EmptyFunction end

	local dead=false

	local function OnDead()
		if dead then return end
		dead=true
		callback()
	end

	local cleanupHumanoid:()->()?=nil
	local humanoid:Humanoid?=instance:FindFirstChildOfClass("Humanoid")
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
		local health:number?=instance:GetAttribute("Health")
		if health~=nil and health<=0 then
			OnDead()
		else
			healthConnection=instance:GetAttributeChangedSignal("Health"):Connect(function()
				local health:number?=instance:GetAttribute("Health")
				if health~=nil and health<=0 and healthConnection.Connected then
					healthConnection:Disconnect()
					OnDead()
				end
			end)
		end
	end

	-- Detect character parent == nil
	local ancestryChangedConnection:RBXScriptConnection
	ancestryChangedConnection=instance.AncestryChanged:Connect(function(_,parent)
		if not parent and ancestryChangedConnection.Connected then
			ancestryChangedConnection:Disconnect()
			OnDead()
		end
	end)

	return function()
		ancestryChangedConnection:Disconnect()
		if cleanupHumanoid then cleanupHumanoid() cleanupHumanoid=nil end
		if healthConnection then healthConnection:Disconnect() end
	end
end

local Observe={}

Observe.ObserveChild=ObserveChild
Observe.ObserveDescendant=ObserveDescendant
Observe.ObservePlayer=ObservePlayer
Observe.ObserveCharacter=ObserveCharacter
Observe.ObserveProperty=ObserveProperty
Observe.ObserveAllProperty=ObserveAllProperty
Observe.ObserveTag=ObserveTag
Observe.ObserveAllTag=ObserveAllTag
Observe.ObserveAttribute=ObserveAttribute
Observe.ObserveAllAttribute=ObserveAllAttribute
Observe.ObserveDead=ObserveDead

return Observe
