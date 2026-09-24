local Tabler={}

function Tabler.GetProperties(t:{[any]:any}):(any,any,number)
	local i=0
	local function NextProperty() i=i+1 if t[i] then return t[i],t[t[i]],i end end
	return NextProperty
end

function Tabler.IsAlive(t:{[any]:any}):boolean
	return if t and type(t)=="table" and getmetatable(t) then true else false
end

function Tabler.NextValue(t:{any},i:number):(number,any)
	if i>=#t then i=1 else i=i+1 end if not t[i] then i=i+1 end if not t[i] then i=1 end return i,t[i]
end

function Tabler.PreviousValue(t:{any},i:number):(number,any)
	if i==0 or i==1 then i=#t else i=i-1 end if not t[i] then i=i-1 end if not t[i] then i=#t end return i,t[i]
end

function Tabler.DeepCopy(t:{[any]:any}):{[any]:any} 
	local copyTable={}
	for k,v in t do
		if v~=nil and type(v)=="table" then
			copyTable[k]=Tabler.DeepCopy(v)
		else
			copyTable[k]=v
		end
	end
	return copyTable
end

function Tabler.DeepFreeze(t:{[any]:any}):{[any]:any} 
	table.freeze(t)
	for _,v in pairs(t) do
		if v~=nil and type(v)=="table" then
			Tabler.DeepFreeze(v)
		end
	end
	return t
end

function Tabler.IndexOf(t:{[any]:any},value:any):(number,...any)
	local i=0
	for k,v in pairs(t) do i=i+1 if v==value then return i,k,v end end 
	return -1
end

function Tabler.RandomByRarity(t:{{["Weight"]:number,["Reward"]:{}}},getWeight:(reward:any)->(number)?)
	if not getWeight or type(getWeight)~="function" then
		getWeight=function(v,k)
			return v.Weight
		end
	end
	local totalWeight=0
	for k,v in pairs(t) do
		totalWeight=totalWeight+v.Weight
	end
	local firstValue=t[1]
	local randomWeight=rng:NextNumber(0,totalWeight)
	local cumulative=0
	for k,v in pairs(t) do
		local weight=getWeight(v,k)
		if not weight then weight=v.Weight end
		cumulative+=weight
		if randomWeight<=cumulative then
			return v
		end
	end
	return firstValue
end

function Tabler.RandomNoSame(t:{any},length:number?,match:(value:any,index:number)->(boolean)?):{any}
	if type(length)~="number" or length<=0 then length=0 end
	if type(match)~="function" then match=function(v,k) return true end end
	local values=nil
	if #t~=0 then
		local list={}
		for i,v in ipairs(t) do
			local can=match(v,i)
			if can then
				table.insert(list,v)
			end
		end
		values={}
		if not length or length<=0 or length>=#list then length=#list end
		local index,limit=1,#list;
		while #list>0 do
			if #list>=5 then
				task.wait()
			end
			index=1
			if #list>1 then
				index=math.random(1,#list)
			end
			local value=table.remove(list,index)
			table.insert(values,value)
			if length~=limit then
				if #values>=length then
					break
				end
			end
		end
	end
	return values
end

-- Author: @Sleitnick
local success,tableUtil=pcall(function()
	if game:GetService("RunService"):IsStudio() then return nil end
	local func=loadstring(game:HttpGet('https://raw.githubusercontent.com/Sleitnick/RbxUtil/refs/heads/main/modules/table-util/init.luau'))
	if func then return func() end return nil
end)

if success and tableUtil then
	for k,v in pairs(tableUtil) do if Tabler[k]==nil then Tabler[k]=v end end
end

return Tabler
