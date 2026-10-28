-- Instal Decode V11
local UseMeshPart=true

local function Parse(Value,Type,DefaultValue)
	DefaultValue=DefaultValue or {}
	if Value==nil or Value=='' or Value=='""' then
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
		local valueText=tostring(Value):lower()
		if valueText=='true' or valueText=='yes' or valueText=='on' or valueText=='active' or valueText=='granted' then return true end
		if valueText=='false' or valueText=='no' or valueText=='off' or valueText=='inactive' or valueText=='unactive' or valueText=='denied' then return false end
	elseif Type=='Vector2' then
		if type(Value)=='table' then
			return Vector2.new(Value[1] or (DefaultValue.X or 0),Value[2] or DefaultValue.Y)
		end
	elseif Type=='Vector3' then
		if type(Value)=='table' then
			return Vector3.new(Value[1] or (DefaultValue.X or 0),Value[2] or (DefaultValue.Y or 0),Value[3] or (DefaultValue.Z or 0))
		end
	elseif Type=='Color3' then
		if type(Value)=='table' then
			local dr,dg,db=math.round((DefaultValue.R or 1)*255),math.round((DefaultValue.G or 1)*255),math.round((DefaultValue.B or 1)*255)
			return Color3.fromRGB(Value[1] or dr,Value[2] or dg,Value[3] or db)
		end
	elseif Type=='BrickColor' then
		if type(Value)=='table' then
			local dr,dg,db=math.round((DefaultValue.r or 1)*255),math.round((DefaultValue.g or 1)*255),math.round((DefaultValue.b or 1)*255)
			return BrickColor.new(Value[1] or dr,Value[2] or dg,Value[3] or db)
		end
	elseif Type=='CFrame' then
		if type(Value)=='table' then
			if #Value<=3 then
				return CFrame.new(Value[1] or (DefaultValue.X or 0),Value[2] or (DefaultValue.Y or 0),Value[3] or (DefaultValue.Z or 0))
			else
				return CFrame.new(unpack(Value))
			end
		end
	elseif Type=='UDim' then
		if type(Value)=='table' then
			return UDim.new(Value[1] or (DefaultValue.Scale or 0),Value[2] or (DefaultValue.Offset or 0))
		end
	elseif Type=='UDim2' then
		if type(Value)=='table' then
			return UDim2.new(Value[1] or (DefaultValue.X.Scale or 0),Value[2] or (DefaultValue.X.Offset or 0),Value[3] or  (DefaultValue.Y.Scale or 0),Value[4] or (DefaultValue.Y.Offset or 0))
		end
	elseif Type=='NumberRange' or Type=='FloatRange' then
		if type(Value)=='table' then
			return NumberRange.new(Value[1] or (DefaultValue.Min or 0),Value[2] or (DefaultValue.Max or 0))
		end
	elseif Type=='Rect'then
		if type(Value)=='table' then
			return Rect.new(Value[1] or DefaultValue.Min.X,Value[2] or DefaultValue.Min.Y,Value[3] or DefaultValue.Max.X, Value[4] or DefaultValue.Max.Y)
		end
	elseif Type=='Font' then
		if type(Value)=='string' then
			local valueText=tostring(Value)
			local family=string.match(valueText,'Family="([^"]+)"') or (DefaultValue and DefaultValue.Family or 'rbxasset://fonts/families/LegacyArial.json')
			local weightStr=string.match(valueText,'Weight=([%w_]+)') or 'Regular'
			local styleStr=string.match(valueText,'Style=([%w_]+)') or 'Normal'
			local weight=Enum.FontWeight[weightStr] or Enum.FontWeight.Regular
			local style=Enum.FontStyle[styleStr] or Enum.FontStyle.Normal
			return Font.new(family,weight,style)
		elseif type(Value)=='table' then
			local family=Value.Family or Value[1] or (DefaultValue.Family or 'rbxasset://fonts/families/LegacyArial.json')
			local weight=Value.Weight or Value[2] or (DefaultValue.Weight or Enum.FontWeight.Regular)
			local style=Value.Style or Value[3] or (DefaultValue.Style or Enum.FontStyle.Normal) 
			local bold=Value.Bold or Value[4] or (DefaultValue.Bold or false) 
			if type(weight)=='string' then weight=Enum.FontWeight[weight] or Enum.FontWeight.Regular end
			if type(style)=='string' then style=Enum.FontStyle[style] or Enum.FontStyle.Normal end
			local font=Font.new(family,weight,style)
			font.Bold=bold
			return font
		end
	elseif Type=='Content' then
		if type(Value)=='string' and Value ~= '' then
			return Content.fromUri(Value)
		end
	elseif Type=='ColorSequence' then
		if type(Value)=='table' then
			if #Value==3 and type(Value[1])=='number' then
				local color=Color3.fromRGB(Value[1],Value[2],Value[3])
				return ColorSequence.new(color)
			end
			local keypoints={}
			for _,k in ipairs(Value) do
				if type(k)=='table' then
					local timeValue=k[1]
					local r,g,b=k[2],k[3],k[4]
					if type(k[2])=='table' then
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
	elseif Type=='NumberSequence' or Type=='FloatSequence' then
		if type(Value)=='table' then
			if #Value==1 and type(Value[1])=='number' then
				return NumberSequence.new(Value[1])
			end
			local keypoints={}
			for _,k in ipairs(Value) do
				if k~=nil and type(k)=='table' then
					table.insert(keypoints,NumberSequenceKeypoint.new(k[1],k[2],(k[3] or 0)))
				end
			end
			if #keypoints>=2 then
				return NumberSequence.new(keypoints)
			end
		end
	elseif Type=='PhysicalProperties' then
		if type(Value)=='table' then
			return PhysicalProperties.new(
				Value[1] or (DefaultValue.Density or 0),
				Value[2] or (DefaultValue.Friction or 0),
				Value[3] or (DefaultValue.Elasticity or 0),
				Value[4] or (DefaultValue.FrictionWeight or 0),
				Value[5] or (DefaultValue.ElasticityWeight or 0)
			)
		end
	else
		warn('Unknown type to Parse for',Type)
	end
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

	local ValueSurfaces={'BackSurface','BottomSurface','FrontSurface','LeftSurface','RightSurface','TopSurface'}

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

			local isPart=newInstance:IsA('BasePart')

			data.Id=tostring(data.Id or 'nil')

			if data.Id and data.Id~='nil' and data.Id~='' then
				instancesByVariable[data.Id]=newInstance
			end

			if data.Properties then
				local j=0
				for propertyName,propertyValue in next,data.Properties do
					if propertyValue~=nil then
						j=(j+1)%20
						if j==0 then task.wait() end
						if isPart and propertyName=='SurfaceType' then
							local changed=true
							if typeof(propertyValue)=='EnumItem' then
								for _,propertyKey in ipairs(ValueSurfaces) do
									pcall(function() newInstance[propertyKey]=propertyValue end)
								end
							elseif type(propertyValue)=='table' then
								for x=1,#ValueSurfaces do
									local propertyKey=ValueSurfaces[x]
									pcall(function() newInstance[propertyKey]=propertyValue[x] or (newInstance[propertyKey] or 0) end)
								end
							else
								changed=false
							end
							if changed then
								continue
							end
						end
						local propertyDefultValue=newInstance[propertyName]
						local propertyType=typeof(propertyDefultValue or 'nil')
						local isObjectRef=type(propertyValue)=='string' and propertyValue:match('v%d+')
						if isObjectRef then
							table.insert(pendingObjectReferences,{Instance=newInstance,PropertyName=propertyName,Id=tostring(propertyValue)})
						else
							local success,message=pcall(function()  newInstance[propertyName]=Parse(propertyValue,propertyType,propertyDefultValue) return nil end)
							if not success then
								warn('Failed to Parse '..propertyName..' of '..data.ClassName..' to '..tostring(propertyValue)..'from '..propertyType,message)
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

	for _, ref in ipairs(pendingObjectReferences) do
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
local result=BuildDecode(TargetModule,workspace)
warn('Decode Complete')

local function MeshPartDecode(instance)
	local AssetService=game:GetService("AssetService")
	local specialMeshs=instance:QueryDescendants("SpecialMesh")
	local meshChanged=false
	for i,specialMesh in ipairs(specialMeshs) do
		if i%20 then task.wait() end
		local part=specialMesh.Parent
		local model=part.Parent
		local meshPart=nil
		local success=pcall(function()
			meshPart=AssetService:CreateMeshPartAsync(specialMesh.MeshContent)
		end)
		if success and meshPart then
			meshChanged=true
			meshPart.Parent=model
			meshPart.TextureContent=specialMesh.TextureContent
			meshPart.Size=part.Size
			meshPart.CFrame=part.CFrame
			local surfaceAppearanceFolder=part:QueryDescendants('Folder#SurfaceAppearance')[1]
			if surfaceAppearanceFolder then
				local length=#surfaceAppearanceFolder:GetChildren()
				local surfaceAppearance=Instance.new("SurfaceAppearance")
				surfaceAppearance.Parent=meshPart
				local emissiveTint=surfaceAppearanceFolder:FindFirstChild("EmissiveTint")
				local metalnessMap=surfaceAppearanceFolder:FindFirstChild("MetalnessMap")
				local roughnessMap=surfaceAppearanceFolder:FindFirstChild("RoughnessMap")
				local emissiveStrength=surfaceAppearanceFolder:FindFirstChild("EmissiveStrength")
				local emissiveMask=surfaceAppearanceFolder:FindFirstChild("EmissiveMaskContent") or surfaceAppearanceFolder:FindFirstChild("EmissiveMask")
				local colorMap=surfaceAppearanceFolder:FindFirstChild("ColorMap")
				local normalMap=surfaceAppearanceFolder:FindFirstChild("NormalMap")
				local color=surfaceAppearanceFolder:FindFirstChild("Color")
				local count=0
				if color then
					surfaceAppearance.Color=color.Value
					count+=1
				end
				if colorMap then
					surfaceAppearance.ColorMapContent=Content.fromUri(colorMap.Value)
					count+=1
				end
				if emissiveTint then
					surfaceAppearance.EmissiveTint=emissiveTint.Value
					count+=1
				end
				if metalnessMap then
					surfaceAppearance.MetalnessMapContent=Content.fromUri(metalnessMap.Value)
					count+=1
				end
				if roughnessMap then
					surfaceAppearance.RoughnessMapContent=Content.fromUri(roughnessMap.Value)
					count+=1
				end
				if normalMap then
					surfaceAppearance.NormalMapContent=Content.fromUri(normalMap.Value)
					count+=1
				end
				if emissiveStrength then
					surfaceAppearance.EmissiveStrength=emissiveStrength.Value
					count+=1
				end
				if emissiveMask then
					surfaceAppearance.EmissiveMaskContent=Content.fromUri(emissiveMask.Value)
					count+=1
				end
				for _,obj in ipairs(part:GetChildren()) do
					if obj:IsA("Bone") or obj:IsA("Texture") or obj:IsA("Decal") then
						obj.Parent=meshPart
						count+=1
						length+=1
					end
				end
				if count>=length then
					part:Destroy()
				end
			end
		end
	end
	if meshChanged then
		warn('MeshPart Decode Complete')
	else
		warn('MeshPart Decode Failed')
	end
end

if UseMeshPart then
	MeshPartDecode(result['1'])
end
