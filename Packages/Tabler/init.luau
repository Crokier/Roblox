local Tabler={
	WeightEmptyFunction=function(v,k) return v.Weight end,
	MatchEmptyFunction=function(...) return true end,
	rng=Random.new()
}

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

function Tabler.Reconcile(target:{[any]:any},template:{[any]:any}):{[any]:any} 
	for k,v in pairs(template) do
		if type(k)=="string" then
			if target[k]==nil then
				if type(v)=="table" then
					target[k]=Tabler.DeepCopy(v)
				else
					target[k]=v
				end
			elseif type(target[k])=="table" and type(v)=="table" then
				Tabler.Reconcile(target[k],v)
			end
		end
	end
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

function Tabler.RandomByRarity(t:{{["Weight"]:number,["Reward"]:{[any]:any},[string]:any}},callback:(t:{{["Weight"]:number,["Reward"]:{[any]:any},[string]:any}},index:number)->(number)?,rng:any?):(any,any)
	if callback==nil or type(callback)~="function" then callback=Tabler.WeightEmptyFunction end
	if rng==nil then rng=Tabler.rng end
	local totalWeight=0
	for k,v in pairs(t) do
		totalWeight=totalWeight+v.Weight
	end
	local randomWeight=rng:NextNumber(0,totalWeight)
	local cumulative=0
	for k,v in pairs(t) do
		local weight=callback(v,k)
		if not weight then weight=v.Weight end
		cumulative+=weight
		if randomWeight<=cumulative then
			return v,k
		end
	end
	return t[1],1
end

function Tabler.RandomNoSame(t:{any},length:number?,match:(value:any,index:number)->(boolean)?,rng:any?):{any}
	if length==nil or type(length)~="number" or length<=0 then length=0 end
	if match==nil or type(match)~="function" then match=Tabler.MatchEmptyFunction end
	if rng==nil then rng=Tabler.rng end
	local values=nil
	if #t>0 then
		local list={}
		for i,v in ipairs(t) do
			local can=match(v,i)
			if can then
				table.insert(list,v)
			end
		end
		values={}
		if not length or length<=0 or length>=#list then length=#list end
		local index,limit,waitingIndex=1,#list,0
		while #list>0 do
			waitingIndex=(waitingIndex+1)%5
			if #list>=5 or waitingIndex==0 then
				task.wait()
			end
			index=1
			if #list>1 then
				index=rng:NextInteger(1,#list)
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

function Tabler.Generate(match:()->(boolean),randomizer:()->(string),target:{[string]:{any}})
	local key=nil
	while match() do
		key=randomizer()
		if target[key]==nil then
			break
		end
		task.wait()
	end
	return key
end

return Tabler
