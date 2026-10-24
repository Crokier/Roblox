local function Parse(Value,Type,DefaultValue)
	DefaultValue=DefaultValue or {}

	if Value==nil or Value=="" or Value=='""' then
		return DefaultValue
	end

	if Type=='string' then
		return tostring(Value)
	elseif Type=='EnumItem' then
		local enumPath=string.split(tostring(Value),'.')
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
		local result=tostring(Value):lower()
		if result=='true' or result=='yes' or result=='on' or result=='active' or result=='granted' then return true end
		if result=='false' or result=='no' or result=='off' or result=='inactive' or result=='unactive' or result=='denied' then return false end
		return DefaultValue
	elseif Type=='Vector2' then
		if type(Value)=="table" then
			return Vector2.new(Value[1] or (DefaultValue.X or 0),Value[2] or DefaultValue.Y)
		end
		return DefaultValue
	elseif Type=='Vector3' then
		if type(Value)=="table" then
			return Vector3.new(Value[1] or (DefaultValue.X or 0),Value[2] or (DefaultValue.Y or 0),Value[3] or (DefaultValue.Z or 0))
		end
		return DefaultValue
	elseif Type=='Color3' then
		if type(Value)=="table" then
			return Color3.fromRGB(Value[1] or math.round((DefaultValue.R or 1)*255),Value[2] or math.round((DefaultValue.G or 1),Value[3] or math.round((DefaultValue.B or 1)*255)))
		end
		return DefaultValue
	elseif Type=='BrickColor' then
		if type(Value)=="table" then
			return BrickColor.new(Value[1] or math.round((DefaultValue.r or 1) * 255),Value[2] or math.round((DefaultValue.g or 1),Value[3] or math.round((DefaultValue.b or 1)*255)))
		end
		return DefaultValue
	elseif Type=='CFrame' then
		if type(Value)=="table" then
			if #Value<=3 then
				return CFrame.new(Value[1] or (DefaultValue.X or 0),Value[2] or (DefaultValue.Y or 0),Value[3] or (DefaultValue.Z or 0))
			else
				return CFrame.new(unpack(Value))
			end
		end
		return DefaultValue
	elseif Type=='UDim' then
		if type(Value)=="table" then
			return UDim.new(Value[1] or (DefaultValue.Scale or 0),Value[2] or (DefaultValue.Offset or 0))
		end
		return DefaultValue

	elseif Type=='UDim2' then
		if type(Value)=="table" then
			return UDim2.new(Value[1] or (DefaultValue.X.Scale or 0),Value[2] or (DefaultValue.X.Offset or 0),Value[3] or  (DefaultValue.Y.Scale or 0),Value[4] or (DefaultValue.Y.Offset or 0))
		end
		return DefaultValue
	elseif Type=='NumberRange' or Type=='FloatRange' then
		if type(Value)=="table" then
			return NumberRange.new(Value[1] or (DefaultValue.Min or 0),Value[2] or (DefaultValue.Max or 0))
		end
		return DefaultValue
	elseif Type=='Font' then
		if type(Value)=="string" then
			local family=string.match(Value,'Family="([^"]+)"') or (DefaultValue and DefaultValue.Family or "rbxasset://fonts/families/LegacyArial.json")
			local weightStr=string.match(Value,'Weight=([%w_]+)') or "Regular"
			local styleStr=string.match(Value,'Style=([%w_]+)') or "Normal"

			local weight=Enum.FontWeight[weightStr] or Enum.FontWeight.Regular
			local style=Enum.FontStyle[styleStr] or Enum.FontStyle.Normal

			return Font.new(family,weight,style)
		elseif type(Value)=="table" then
			local family=Value.Family or Value[1] or (DefaultValue and DefaultValue.Family or "rbxasset://fonts/families/LegacyArial.json")
			local weight=Value.Weight or Enum.FontWeight.Regular
			local style=Value.Style or Enum.FontStyle.Normal

			if type(weight)=="string" then weight=Enum.FontWeight[weight] or Enum.FontWeight.Regular end
			if type(style)=="string" then style=Enum.FontStyle[style] or Enum.FontStyle.Normal end

			return Font.new(family,weight,style)
		end
		return DefaultValue or Font.new("rbxasset://fonts/families/LegacyArial.json")
	elseif Type=='Content' then
		if type(Value)=="string" and Value ~= "" then
			return Content.fromUri(Value)
		end
		return DefaultValue or Content.fromUri("")
	elseif Type=='ColorSequence' then
		if type(Value)=="table" then
			if #Value==3 and type(Value[1])=="number" then
				local color=Color3.fromRGB(Value[1],Value[2],Value[3])
				return ColorSequence.new(color)
			end
			local keypoints={}
			for _,k in ipairs(Value) do
				if type(k)=="table" then
					local timeValue=k[1]
					local r,g,b=k[2],k[3],k[4]
					if type(k[2])=="table" then
						r,g,b=k[2][1],k[2][2],k[2][3]
					end
					local color=Color3.fromRGB(r or 255,g or 255,b or 255)
					table.insert(keypoints,ColorSequenceKeypoint.new(timeValue,color))
				end
			end
			if #keypoints >= 2 then
				return ColorSequence.new(keypoints)
			end
		end
		return DefaultValue
	elseif Type=='NumberSequence' or Type=='FloatSequence' then
		if type(Value)=="table" then
			if #Value==1 and type(Value[1])=="number" then
				return NumberSequence.new(Value[1])
			end
			local keypoints={}
			for _,k in ipairs(Value) do
				if type(k)=="table" then
					table.insert(keypoints,NumberSequenceKeypoint.new(k[1],k[2],(k[3] or 0)))
				end
			end
			if #keypoints >= 2 then
				return NumberSequence.new(keypoints)
			end
		end
		return DefaultValue
	end

	warn("Failed to Parse for",Type)
	return DefaultValue
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
        for i,data in ipairs(dataList) do
            if data.ClassName=='Coding' then continue end
			if i%20==0 then task.wait() end
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
			    local j=0
                for propertyName,propertyValue in next,data.Properties do
					j=(j+1)%20
					if j==0 then task.wait() end
                    if propertyValue~=nil then
                        local propertyDefultValue=newInstance[propertyName]
                        local propertyType=typeof(propertyDefultValue or 'nil')
                        local isObjectRef=type(propertyValue)=='string' and propertyValue:match('v%d+')
                        if isObjectRef then
                            table.insert(pendingObjectReferences,{Instance=newInstance,PropertyName=propertyName,Id=tostring(propertyValue)})
						else
							local success=pcall(function()  newInstance[propertyName]=Parse(propertyValue,propertyType,propertyDefultValue) return nil end)
							if not success then
								warn('Failed to Parse '..propertyName..' of '..data.ClassName..' to '..tostring(propertyValue))
							end
                        end
                    end
                end
            end

            if data.Children and #data.Children>0 then
                createInstancesPass(data.Children, newInstance)
            end

            if currentParent then
                newInstance.Parent=currentParent
            end
        end
    end
    createInstancesPass(dataTable, targetParent)
    for j, ref in ipairs(pendingObjectReferences) do
		if j%20==0 then task.wait() end
        local targetInst=instancesByVariable[ref.Id]
        if targetInst then
            pcall(function()
                ref.Instance[ref.PropertyName]=targetInst
            end)
        end
    end
    return instancesByVariable
end

local TargetModule=require(workspace:FindFirstChildOfClass('Terrain'):FindFirstChild('Instal'))
BuildDecode(TargetModule,workspace)
