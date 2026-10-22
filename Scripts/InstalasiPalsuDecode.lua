local function Parse(Value,Type,DefaultValue)
	if Type=='string' then
		return tostring(Value)
	elseif Type=='EnumItem' then
		local enumPath=string.split(tostring(Value), '.')
		if #enumPath>=3 then
			if Enum[enumPath[2]] then
				return Enum[enumPath[2]][enumPath[3]]
			end
			return enumPath[3]
		end
		return Value
	elseif Type=='number' then
		return tonumber(Value)
	elseif Type=='boolean' then
		local result=tostring(Value)
		if result=='true' then return true end
		if result=='false' then return false end
	elseif type(Value)=='table' then
		if Type=='Vector3' then
			return Vector3.new(Value[1] or DefaultValue.X,Value[2] or DefaultValue.Y,Value[3] or DefaultValue.Z)
		elseif Type=='Color3' then
			return Color3.fromRGB(Value[1] or DefaultValue.R,Value[2] or DefaultValue.G,Value[3] or DefaultValue.B)
		elseif Type=='NumberRange' or Type=='FloatRange' then
			return NumberRange.new(Value[1] or DefaultValue.Min,Value[2] or DefaultValue.Max)
		elseif Type=='UDim' then
			return UDim.new(Value[1] or DefaultValue.Scale, Value[2] or DefaultValue.Offset)
		elseif Type=='UDim2' then
			return UDim2.new(Value[1] or DefaultValue.X.Scale, Value[2] or DefaultValue.X.Offset, Value[3] or DefaultValue.Y.Scale, Value[4] or DefaultValue.Y.Offset)
		elseif Type=='BrickColor' then
			return BrickColor.new(Value[1] or DefaultValue.r*255,Value[2] or DefaultValue.g*255,Value[3] or DefaultValue.b*255)
		elseif #Value>0 and type(Value[1])=='table' then
			local defaultKeypoints=DefaultValue.Keypoints
			local keypoints={}
			for i,k in ipairs(Value) do
				local timeValue=k[1]
				local dataValue=k[2]
				if type(dataValue)=='table' then
					local col=Color3.fromRGB(dataValue[1], dataValue[2], dataValue[3])
					table.insert(keypoints, ColorSequenceKeypoint.new(timeValue, col))
				else
					local envelope=k[3] or 0
					table.insert(keypoints, NumberSequenceKeypoint.new(timeValue, dataValue, envelope))
				end
			end
			if #keypoints>0 then
				return typeof(keypoints[1].Value)=='Color3' and ColorSequence.new(keypoints) or NumberSequence.new(keypoints)
			end
		end
	end
	
	warn("Fail for",Type)
end

local function BuildDecode(tableOrString,targetParent)
	local dataTable={}
	if type(tableOrString)~='table' then
		if type(tableOrString)~='string' or #tableOrString==0 then
			warn('[Decoder Error]: tableOrString is empty or not a string!')
			return nil
		end
		local formattedString=tableOrString
		if not string.find(tableOrString, '^%s*return') and not string.find(tableOrString,'local V={',1,true) then
			formattedString='return ' .. tableOrString
		elseif  not string.find(tableOrString, '^%s*return') and string.find(tableOrString,'local V={',1,true) then
			formattedString='return V'
		end

		local loaderFunction,syntaxError=loadstring(formattedString)

		if not loaderFunction then
			warn('[Decoder Error] Syntax Error for string table: ' .. tostring(syntaxError))
			return nil
		end
		
		local successExecute=false
		successExecute, dataTable=pcall(loaderFunction)

		if not successExecute or type(dataTable) ~= 'table' then
			warn('[Decoder Error] Failed to execute the script, or the final result is not in the form of a table.: ' .. tostring(dataTable))
			return nil
		end
	else
		dataTable=tableOrString
	end
	local instancesByVariable={}
	local pendingObjectReferences={}

	local function createInstancesPass(dataList, currentParent)
		for _,data in ipairs(dataList) do
			if data.ClassName=='Coding' then continue end

			local ok,newInstance=pcall(function()
				return Instance.new(data.ClassName)
			end)

			if not ok or not newInstance then continue end
			if data.Name then newInstance.Name=data.Name end
			newInstance.Parent=currentParent
			
			if data.Id and data.Id~='nil' and data.Id~='' then
				instancesByVariable[tostring(data.Id)]=newInstance
			end
			if data.Properties then
				for propertyName,propertyValue in next,data.Properties do
					print(propertyName,propertyValue,typeof(propertyName),typeof(propertyValue))
					if propertyValue~=nil then
						local propertyDefultValue=newInstance[propertyName]
						local propertyType=typeof(propertyDefultValue or 'nil')
						local isObjectRef=type(propertyValue)=='string' and propertyValue:match('v%d+')
						if isObjectRef then
							table.insert(pendingObjectReferences,{Instance=newInstance,PropertyName=propertyName,Id=tostring(propertyValue)})
						else
							newInstance[propertyName]=Parse(propertyValue,propertyType,propertyDefultValue)
							--pcall(function()  return nil end)
						end
					end
				end
			end

			if data.Children and #data.Children>0 then
				createInstancesPass(data.Children, newInstance)
			end

			if currentParent and not data.Properties['Parent'] then
				newInstance.Parent=currentParent
			end
		end
	end
	createInstancesPass(dataTable, targetParent)
	for _, ref in ipairs(pendingObjectReferences) do
		local targetInst=instancesByVariable[ref.TargetVariable]
		if targetInst then
			pcall(function()
				ref.Instance[ref.PropertyName]=targetInst
			end)
		end
	end
	return instancesByVariable
end

local TargetModule=require(script:WaitForChild('Terrain'))
BuildDecode(TargetModule,workspace)
