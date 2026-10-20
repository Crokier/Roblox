-- WaitFor
-- Stephen Leitnick and Crokyreo
-- January 17,2022

-- Use Promise in https://github.com/evaera/roblox-lua-promise
-- This module have WaitFor.QueryDescendants by Crokyreo

local RunService=game:GetService("RunService")

local Promise=require(script.Parent.Promise)

local DEFAULT_TIMEOUT=60
local DEFAULT_LENGTH=1

--[=[
	@class WaitFor
	Utility class for awaiting the existence of instances.

	By default,all promises timeout after 60 seconds,unless the `timeout`
	argument is specified.

	:::note
	Promises will be rejected if the parent (or any ancestor) is unparented
	from the game.
	:::

	:::caution Set name before parent
	When waiting for instances based on name (e.g. `WaitFor.Child`),the `WaitFor`
	system is listening to events to capture these instances being added. This
	means that the name must be set _before_ being parented into the object.
	:::
]=]
local WaitFor={}

--[=[
	@within WaitFor
	@prop Error {Unparented:string,ParentChanged:string}
]=]
WaitFor.Error={
	Unparented="Unparented",
	ParentChanged="ParentChanged",
}

local function PromiseWatchAncestry(instance:Instance,promise)
	return Promise.race({
		promise,
		Promise.fromEvent(instance.AncestryChanged,function(_,newParent)
			return newParent==nil
		end):andThen(function()
			return Promise.reject(WaitFor.Error.Unparented)
		end),
	})
end

--[=[
	@return Promise<Instance>
	Waits for a specific number of descendants matching a selector to exist within a given parent. 
	Resolves early with the current descendants if the timeout is reached or if the `match` function returns false.

	```lua
	-- Example:Wait for up to 10 seconds until there are 5 descendants matching the "Part" selector
	WaitFor.QueryDescendants(workspace.Map,"#Part > ScreenGui",5,10):andThen(function(descendants)
		print("Found",#descendants,"matching descendants!")
	end):catch(warn)
	```
]=]
function WaitFor.QueryDescendants(instance:Instance,selector:string,length:number?,timeOut:number?)
	length=(length==nil or typeof(length)~="number") and DEFAULT_LENGTH or length
	timeOut=(timeOut==nil or typeof(timeOut)~="number") and DEFAULT_TIMEOUT or timeOut
	
	local fullName=instance:GetFullName()
	
	local descendants=instance:QueryDescendants(selector)
	if #descendants>=length then
		return Promise.resolve(descendants)
	end

	local queryPromise=Promise.fromEvent(instance.DescendantAdded, function()
		descendants=instance:QueryDescendants(selector)
		return #descendants>=length
	end):andThen(function()
		return instance:QueryDescendants(selector)
	end)

	local ancestryPromise=Promise.fromEvent(instance.AncestryChanged, function(_, parent)
		return parent==nil
	end):andThen(function()
		return Promise.reject(debug.traceback(WaitFor.Error.Unparented))
	end)

	local timeoutPromise=Promise.delay(timeOut):andThen(function()
		warn(debug.traceback(string.format("Infinite yield possible on 'WaitFor.QueryDescendants(%s, \"%s\", %s)'",fullName,selector,length)))
		return instance:QueryDescendants(selector)
	end)

	return Promise.race({
		queryPromise,
		ancestryPromise,
		timeoutPromise,
	})
end

--[=[
	@return Promise<Instance>
	Wait for a child to exist within a given parent based on the child name.

	```lua
	WaitFor.Child(parent,"SomeObject"):andThen(function(someObject)
		print(someObject,"now exists")
	end):catch(warn)
	```
]=]
function WaitFor.Child(instance:Instance,childName:string,timeout:number?)
	local isTable
	local child=instance:FindFirstChild(childName)
	if child then
		return Promise.resolve(child)
	end
	return PromiseWatchAncestry(
		instance,
		Promise.fromEvent(instance.ChildAdded,function(c)
			return c.Name==childName
		end):timeout(timeout or DEFAULT_TIMEOUT)
	)
end

--[=[
	@return Promise<{Instance}>
	Wait for all children to exist within the given parent.

	```lua
	WaitFor.Children(parent,{"SomeObject01","SomeObject02"}):andThen(function(children)
		local someObject01,someObject02=table.unpack(children)
	end)
	```

	:::note
	Once all children are found,a second check is made to ensure that all children
	are still directly parented to the given `parent` (since one child's parent
	might have changed before another child was found). A rejected promise with the
	`WaitFor.Error.ParentChanged` error will be thrown if any parents of the children
	no longer match the given `parent`.
	:::
]=]
function WaitFor.Children(instance:Instance,childrenNames:{string},timeout:number?)
	local all=table.create(#childrenNames)
	for i,childName in ipairs(childrenNames) do
		all[i]=WaitFor.Child(instance,childName,timeout)
	end
	return Promise.all(all):andThen(function(children)
		-- Check that all are still parented
		for _,child in ipairs(children) do
			if child.Parent~=instance then
				return Promise.reject(WaitFor.Error.ParentChanged)
			end
		end
		return children
	end)
end

--[=[
	@return Promise<Instance>
	Wait for a descendant to exist within a given parent. This is similar to
	`WaitFor.Child`,except it looks for all descendants instead of immediate
	children.

	```lua
	WaitFor.Descendant(parent,"SomeDescendant"):andThen(function(someDescendant)
		print("SomeDescendant now exists")
	end)
	```
]=]
function WaitFor.Descendant(instance:Instance,descendantName:string,timeout:number?)
	local descendant=instance:FindFirstChild(descendantName,true)
	if descendant then
		return Promise.resolve(descendant)
	end
	return PromiseWatchAncestry(
		instance,
		Promise.fromEvent(instance.DescendantAdded,function(d)
			return d.Name==descendantName
		end):timeout(timeout or DEFAULT_TIMEOUT)
	)
end

--[=[
	@return Promise<{Instance}>
	Wait for all descendants to exist within a given parent.

	```lua
	WaitFor.Descendants(parent,{"SomeDescendant01","SomeDescendant02"}):andThen(function(descendants)
		local someDescendant01,someDescendant02=table.unpack(descendants)
	end)
	```

	:::note
	Once all descendants are found,a second check is made to ensure that none of the
	instances have moved outside of the parent (since one instance might change before
	another instance is found). A rejected promise with the `WaitFor.Error.ParentChanged`
	error will be thrown if any of the instances are no longer descendants of the given
	`parent`.
	:::
]=]
function WaitFor.Descendants(instance:Instance,descendantNames:{string},timeout:number?)
	local all=table.create(#descendantNames)
	for i,descendantName in ipairs(descendantNames) do
		all[i]=WaitFor.Descendant(instance,descendantName,timeout)
	end
	return Promise.all(all):andThen(function(descendants)
		-- Check that all are still parented
		for _,descendant in ipairs(descendants) do
			if not descendant:IsDescendantOf(instance) then
				return Promise.reject(WaitFor.Error.ParentChanged)
			end
		end
		return descendants
	end)
end

--[=[
	@return Promise<Instance>
	Wait for the PrimaryPart of a model to exist.

	```lua
	WaitFor.PrimaryPart(model):andThen(function(primaryPart)
		print(primaryPart==model.PrimaryPart)
	end)
	```
]=]
function WaitFor.PrimaryPart(model:Model,timeout:number?)
	local primary=model.PrimaryPart
	if primary then
		return Promise.resolve(primary)
	end
	return PromiseWatchAncestry(
		model,
		Promise.fromEvent(model:GetPropertyChangedSignal("PrimaryPart"),function()
			primary=model.PrimaryPart
			return primary~=nil
		end):andThen(function() return primary end):timeout(timeout or DEFAULT_TIMEOUT)
	)
end

--[=[
	@return Promise<Instance>
	Wait for the Value of an ObjectValue to exist.

	```lua
	WaitFor.ObjectValue(someObjectValue):andThen(function(value)
		print("someObjectValue's value is",value)
	end)
	```
]=]
function WaitFor.ObjectValue(objectValue:ObjectValue,timeout:number?)
	local value=objectValue.Value
	if value then
		return Promise.resolve(value)
	end
	return PromiseWatchAncestry(
		objectValue,
		Promise.fromEvent(objectValue.Changed,function(v)
			value=v
			return value~=nil
		end):andThen(function()return value end):timeout(timeout or DEFAULT_TIMEOUT)
	)
end

--[=[
	@return Promise<T>
	Wait for the given predicate function to return a non-nil value of
	of type `T`. The predicate is fired every RunService Heartbeat step.

	```lua
	-- Example,waiting for some property to be set:
	WaitFor.Custom(function() return vectorForce.Attachment0 end):andThen(function(a0)
		print(a0)
	end)
	```
]=]
function WaitFor.Custom<T>(predicate:() -> T?,timeout:number?)
	local value=predicate()
	if value~=nil then
		return Promise.resolve(value)
	end
	return Promise.new(function(resolve,_reject,onCancel)
		local heartbeat
		local function OnDone()
			heartbeat:Disconnect()
		end
		local function Update()
			local v=predicate()
			if v~=nil then
				OnDone()
				resolve(v)
			end
		end
		heartbeat=RunService.Heartbeat:Connect(Update)
		onCancel(OnDone)
	end):timeout(timeout or DEFAULT_TIMEOUT)
end

return WaitFor
