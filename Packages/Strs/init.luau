local InfNumber=math.huge

local Strs={
	['Icons']={
		['Robux']=utf8.char(0xE002),
		['Premium']=utf8.char(0xE001),
		['Verified']=utf8.char(0xE000),
	},
	['Suffixes'] = {' ','K','M','B','T','Qd','Qn','Sx','Sp','Oc','No','De','UDe','DDe','TDe','QdDe','QnDe','SxDe','SpDe','OcDe','NoDe','Vg','UVg','DVg','TVg'},
	['BoolData']={["yes"]=true,["no"]=false,["true"]=true,["false"]=false,["active"]=true,["unactive"]=false,["start"]=true,["stop"]=false},
	['BuilderIcons'] = 'rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json'
}

-- Basic Function --
-- Example: '0/0' > 'NaN' | '1' > ''
function Strs.ToNaN(x:number,s:string?)
	return x~=x and "NaN" or s
end

-- Example: '-inf' > '∞' | 'inf' > '∞'
function Strs.ToInf(x:number,s:string?)
	return (x>=InfNumber or x<=-InfNumber) and '∞' or s
end

function Strs.GetLines(s:string):()->(string)
	local lastBreak=0
	local function NextLine()
		if lastBreak==#s then return nil end
		local line,nextBreak=nil,string.find(s,"\n",lastBreak+1)	
		if nextBreak then
			line=s:sub(lastBreak+1,nextBreak-1)
			lastBreak=nextBreak
		else
			line=s:sub(lastBreak+1,#s)
			lastBreak=#s
		end
		return line
	end
	return NextLine
end

function Strs.IsStrings(s1,s2)
	for i,v in ipairs(s2) do if s1==v then return true end end return false
end

-- Example: 'reset' > true | '1' > false
function Strs.IsOriginal(s:string):boolean
	s=string.lower(s) 
	for i,v in ipairs({"reset","default","original","origin"}) do if string.find(s,v) then return true end end
	return false
end

-- Example: '  ' > true | nil > true | not string type > true
function Strs.IsEmpty(s:any):boolean
	if s~=nil and type(s)=="string" then
		if string.len(s)==0 then return true end
		local v=string.match(s,"^%s*$")
		if v==nil then return false end
		return true
	end
	return true
end

-- Example: '    upper      ' > 'upper'
function Strs.Trim(s:string):string
	if s==nil or type(s)~="string" then return "" end
	return string.gsub(s, "^%s*(.-)%s*$", "%1") or string.match(s,"^%s*(.-)%s*$") or ""
end

-- Example: 67.2345 > 67.23% | inf > ∞%
function Strs.ToPersentase(x:number,max:number?,maxFloat:number?,reverse:boolean?):string
	if x==nil or type(x)~="number" or x==0 then return "0%" end
	if (x>=InfNumber or x<=-InfNumber) then return "∞%" end
	maxFloat=if type(maxFloat)=="number" and maxFloat>0 then maxFloat else 2
	local percentage=math.floor(x)*100
	if not reverse then
		if max then percentage=math.floor(x/max)*100 end
	else
		if max then
			percentage=(1/max)*x
			if percentage>=1 then 
				return "100%"
			else
				percentage=percentage*100
			end
		end
	end
	local s=string.format(`%.{maxFloat}f`,percentage)
	s=s.."%"
	if max and x>=max then s="100%" end
	return s
end

function Strs.ToBoolean(s:string)
	return Strs.BoolData[string.lower(s)]
end

-- Deprecated
-- Example: '    upper      ' > 'upper' > "UPPER"
function Strs.Normalize(s:string):string
	if true then error("Strs.Normalize is deprecated, use Strs.Trim instead") end
	if s==nil or type(s)~="string" then return "" end
	local ns = string.match(s,"^%s*(.-)%s*$")
	return string.upper(ns) or ""
end

-- Format Number Function --
function Strs.TryNumber(s,defautValue,originalValue)
	if s==nil then return nil end
	if not (type(s)=="string" or type(s)=="number") then return nil end
	local numberInput = tonumber(s)
	if numberInput then return numberInput end
	local ls=string.lower(s)
	if ls=="reset" or ls=="default" or ls=="original" or ls=="origin" then return tonumber(originalValue) or tonumber(defautValue) end
	if ls=="inf" or ls=="huge" or "infinite" then return math.huge end
	if ls=="-inf" or ls=="-huge" or "-infinite" then return -math.huge end
	return tonumber(defautValue)
end

function Strs.ToNumber(v,maxFloat)
	local x=type(v)=="string" and tonumber(v) or v
	if x == nil or type(x)~="number" then return "nil" end
	if maxFloat == nil or type(maxFloat)~="number" or maxFloat<=0 then 
		maxFloat=3
	end
	local xFloor=math.floor(x)
	if x==xFloor then return tostring(xFloor) end
	local s=string.format(`%.{maxFloat}f`,x)
	s=string.gsub(s,"%.?0+$","")
	return s
end

function Strs.FormatNumber(x:number):string?
	if x==nil then return nil end
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	local isNegative=x<=0
	x=math.abs(x)
	local s=tostring(x)
	for i=1,#Strs.Suffixes do
		if x<10^(i*3) then
			local v=x/(10^((i-1)*3)/100)
			local result=tostring(math.floor(v)/100)..Strs.Suffixes[i]
			return isNegative and '-'..result or result
		end
	end
	return isNegative and '-'..s or s
end

-- Format Time Function --
function Strs.FormatTime(x:number):string
	local checkString=Strs.ToInf(x) or Strs.ToNaN(x)
	if checkString then return checkString end
	x=math.floor(x)
	local seconds=x%60
	local minutes=math.floor(x/60)%60
	local hours=math.floor(x/60^2)
	local days=math.floor(x/86400)
	if x<60 then
		return string.format('%02i',seconds)
	elseif x < 3600 then
		return string.format('%02i:%02i',minutes,seconds)
	elseif x < 86400 then
		return string.format('%02i:%02i:%02i',hours,minutes,seconds)
	else
		return string.format('%02i:%02i:%02i:%02i',days,hours,minutes,seconds)
	end
end

function Strs.ToMS(x:number):string
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	x=math.floor(x)
	local seconds=x%60
	local minutes=math.floor(x/60)%60
	return string.format('%02i:%02i',minutes,seconds)
end

function Strs.ToHMS(x:number):string
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	x=math.floor(x)
	local seconds=x%60
	local minutes=math.floor(x/60)%60
	local hours=math.floor(x/60^2)
	return string.format('%02i:%02i:%02i',hours,minutes,seconds)
end

function Strs.ToDHMS(x:number):string
	local check=Strs.ToInf(x) or Strs.ToNaN(x)
	if check then return check end
	x=math.floor(x)
	local seconds=x%60
	local minutes=math.floor(x/60)%60
	local hours=math.floor(x/60^2)
	local days=math.floor(x/86400)
	return  string.format('%02i:%02i:%02i:%02i',days,hours,minutes,seconds)
end

-- Random Function --
function Strs.Random()
	local length=math.random(10,20)
	local array={}
	for i=1,length do
		array[i]=string.char(math.random(32,126))
	end
	return table.concat(array)
end

return Strs
