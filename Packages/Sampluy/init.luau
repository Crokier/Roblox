--[[
   ToraIsMe | Inspired from here
   Crokyreo | Programming
   Gemini AI | Just help and fix
]]

local Services=setmetatable({},{__index=function(_,i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})

local Players=Services.Players
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local TweenService=Services.TweenService
local TeleportService=nil
local LocalPlayer=Players.LocalPlayer
local Mouse=nil

local OFFSET=UDim2.new(0,100,0,50)
local UIFolder="Sampluy"
local baseX,baseY=1024,768

local BUILDER_ICONS = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"

local TweenCache = {
	Tab = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Default = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Other = TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
}

local Theme = {
	Text = Color3.fromRGB(255,255,255),
	Element = Color3.fromRGB(0,0,0),
	SecondaryText = Color3.fromRGB(180,180,190),
	InputText = Color3.fromRGB(235,235,235),
	Round = Color3.fromRGB(40,40,40),
	DropdownSelected=Color3.fromRGB(40,40,40),
	DropdownUnselected=Color3.fromRGB(30,30,30)
}

local EnumCache = {
	ClickMethodTypes = {"Default","None","SingleClick","DoubleClick","MultiClick","AntiSpamClick","DebounceClick","1","2","3"}
}

local Library={
	Flags={},
	ActivePopup=nil,
	Notifications = nil
}

local Strs={}

function Strs.toNumber(v,maxFloat)
	local x=type(v)=="string" and tonumber(v) or v
	if not x or type(x)~="number" then return "nil" end
	if not maxFloat or type(maxFloat)~="number" or maxFloat<=0 then 
		maxFloat=3
	end
	local xFloor=math.floor(x)
	if x==xFloor then return tostring(xFloor) end
	local s=string.format(`%.{maxFloat}f`,x)
	s=string.gsub(s,"%.?0+$","")
	return s
end

function Strs.isOriginal(s)
	s=string.lower(tostring(s)) 
	for i,v in ipairs({"reset","default","original","origin"}) do if string.find(s,v) then return true end end
	return false
end

function Strs.trim(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

function Strs.isEmpty(s)
	if s ~= nil and type(s)=="string" then
		if string.len(s)==0 then return true end
		local v=string.match(s,"^%s*$")
		if v==nil then return false end
		return true
	end
	return true
end

local function callSafely(func,...)
	if func then 
		local success,result=pcall(func,...) 
		if not success then 
			warn("function failed with error:",result)
			return false 
		else 
			return result 
		end 
	end
end

-- Copy a string to clipboard. Returns whether a clipboard fn was available.
local function copyToClipboard(s)
	if not setclipboard then return false end
	return pcall(setclipboard, s)
end

local function requestSafely(options)
	local req=(syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
	if not req then return nil,"HTTP requests not supported" end
	local success,response=pcall(function() return req(options) end)
	if success and response then return response else return nil,"Connection Error" end
end

local function ensureFolder(folderPath)
	if isfolder and makefolder then
		if not callSafely(isfolder,folderPath) then
			callSafely(makefolder,folderPath)
		end
	end
end

local function rejoinGame()
	TeleportService=TeleportService or Services.TeleportService

	if #Players:GetPlayers() > 1 then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	else
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end
end

local function round(num, bracket)
	num = tonumber(num) or 0
	bracket = math.abs(tonumber(bracket) or 1)
	local v = math.floor(num / bracket + (math.sign(num) * 0.5)) * bracket
	if v < 0 and num % bracket == 0 then
		v = num
	end
	return v
end

local function missing(t,v,f)
	return (v~=nil and typeof(v)==t) and v or f
end

local function isUIOverlapping(ui1,ui2)
	local pos1,size1=ui1.AbsolutePosition,ui1.AbsoluteSize
	local pos2,size2=ui2.AbsolutePosition,ui2.AbsoluteSize

	local isNotOverlapping=
		(pos1.X+size1.X<pos2.X) or
		(pos2.X+size2.X<pos1.X) or
		(pos1.Y+size1.Y<pos2.Y) or
		(pos2.Y+size2.Y<pos1.Y)

	return not isNotOverlapping
end

local function create(className,properties)
	properties=typeof(properties)=="table" and properties or {}
	local obj=Instance.new(className)
	for property,value in next,properties do
		obj[property]=value
	end
	return obj
end

local function icon(className, name, size, filled, color)
	return create(className or "TextLabel", {
		BackgroundTransparency = 1,
		Text = name or "",
		FontFace = Font.new(BUILDER_ICONS, filled and Enum.FontWeight.Bold or Enum.FontWeight.Regular),
		TextColor3 = color or Theme.Text,
		TextScaled = true,
		Size = UDim2.fromOffset(size or 18, size or 18),
	})
end

local function fastWait(duration)
	if not duration then return RunService.RenderStepped:Wait() end
	local start=tick()
	while tick()-start<duration do RunService.RenderStepped:Wait() end
	return start-duration
end

local function getScreenType()
	local size = workspace.CurrentCamera.ViewportSize
	local width = size.X
	local height = size.Y

	if width >= 1920 and height >= 1080 then
		if width >= 3840 then
			return "4K"
		else
			return "1080p"
		end
	elseif width >= 1280 and height >= 720 then
		return "720p"
	elseif width>=1280 and height >= 500 then
		return "1280x500"
	else
		return tostring(width).."x"..tostring(height)
	end
end

local function connectDestroying(instance,saveName,func)
	local destroying,enabledChanged=nil,nil
	if instance and instance.Parent then
		destroying=instance.AncestryChanged:Connect(function(_,parent) if not parent then callSafely(func) end end)
		if instance.ClassName=="ScreenGui" then
			if not instance.Enabled and instance.Name~=saveName then 
				callSafely(func) 
			else
				enabledChanged=instance:GetPropertyChangedSignal("Enabled"):Connect(function()
					if instance and instance.Parent and not instance.Enabled and instance.Name~=saveName then 
						enabledChanged:Disconnect() 
						callSafely(func)
					end
				end)
			end
		end
	else
		callSafely(func)
	end
	return function()
		if destroying then destroying:Disconnect() end
		if enabledChanged then enabledChanged:Disconnect() end
	end
end

local function tween(instance,tweenInfo,properties)
	local newTween = TweenService:create(instance,tweenInfo,properties)
	newTween:Play()
	return newTween
end

local function resizeUIScale(ui,screenSize,x,y,callback)
	local scaleX=screenSize.X/x
	local scaleY=screenSize.Y/y
	local scale=math.min(scaleX,scaleY)

	local minAxis=math.min(screenSize.X,screenSize.Y)
	local isSmallScreen=minAxis<=500

	local uiScale=ui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Parent=ui

	local result,done=1,false
	if callback then
		local value=callSafely(callback,scale,minAxis,isSmallScreen)
		if value and type(value)=="number" then done=true if value>1 then result=value else done=false end end
	end
	if not done then if scale<1 then result=scale*1.5 elseif scale>1 then result=scale*1 else result=1 end end
	uiScale.Scale=result
end

local function getComponents(Window)
	local elements={}

	function elements:AddLabel(...)
		local args={...}
		local options={}
		for index,value in ipairs(args) do
			if value~=nil then
				local valueType=typeof(value)
				if index==1 and valueType=="table" then
					options=value
					break
				elseif index==1 and valueType=="string" then
					options.Text=value
				end
			end
		end
		options.Type="Label"
		options.Text=options.Text or options.Title or options.Name or options.Type

		local main=create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,24),
			BackgroundTransparency=1,
			Parent=Window.Container
		})

		local title=create("TextLabel",{
			Name="Title",
			ZIndex=2,
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Text=options.Text,
			TextColor3=Theme.SecondaryText,
			Font=Enum.Font.GothamBlack,
			TextSize=12,
			TextXAlignment=Enum.TextXAlignment.Center,
			Parent=main
		})

		function options:Set(text)
			title.Text=tostring(text or "")
		end

		function options:Get()
			return options.Value
		end

		if options.Visible~=nil then
			main.Visible=options.Visible and true or false
		end

		local originals={["TitleScaled"]="TextScaled",["TitleStrokeTransparency"]="TextStrokeTransparency",["TitleStrokeColor3"]="TextStrokeColor3",["TitleColor3"]="TextColor3",["TitleTransparency"]="TextTransparency",["TitleXAlignment"]="TextXAlignment",["TitleYAlignment"]="TextYAlignment"}

		for _,k in ipairs({"TextStrokeTransparency","TextStrokeColor3","TextScaled","TextTransparency","TextColor3","TextXAlignment","TextYAlignment","TextBounds","TextDirection","RichText","Font"}) do
			local v=options[k]
			if v~=nil then
				pcall(function() title[k]=v end)
			end
		end

		for k,i in pairs(originals) do
			local v=options[k]
			if v~=nil then
				pcall(function() title[i]=v end)
			end
		end

		options.Instance=main

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				local nv=v

				if i=="Visible" then
					nv=v and true or false
					main.Visible=nv
				elseif i=="Text" or i=="Title" then
					nv=v and tostring(v) or title.Text
					title.Text=nv
				elseif i=="Set" then
					return
				else
					local done=false
					for _,k in ipairs({"TextStrokeTransparency","TextStrokeColor3","TextScaled","TextTransparency","TextColor3","TextXAlignment","TextYAlignment","TextBounds","TextDirection","RichText","Font"}) do
						if i==k then
							done=true
							pcall(function() title[i]=v end)
							break
						end
					end
					if not done then
						local k=originals[i]
						if k~=nil then
							pcall(function() title[k]=v end)
						end
					end
				end

				options[i]=nv
			end
		})
	end

	function elements:AddButton(...)
		local args={...}
		local options={}
		for index,value in ipairs(args) do
			if value~=nil then
				local valueType=typeof(value)
				if index==1 and valueType=="table" then
					options=value
					break
				elseif index==1 and valueType=="string" then
					options.Text=value
				elseif index==2 and valueType=="function" then
					options.Callback=value
				end
			end
		end

		options.Type="Button"
		options.Text=options.Text or options.Title or options.Name or options.Type
		options.Callback=missing("function",options.Callback,function() end)
		options.MethodType=options.MethodType or "Default"
		options.ClickThreshold=options.ClickThreshold or 0.5
		options.ClickDuration=options.ClickDuration or 1
		options.MaxClick=options.MaxClick or 2
		options.ClickCount=0
		options.LastClickTime=0
		options.ClickWaiting=false

		local main=create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,30),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Parent=Window.Container
		})

		local title=create("TextLabel",{
			Name="Title",
			ZIndex=2,
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Text=options.Text,
			TextColor3=Theme.Text,
			Font=Enum.Font.GothamBlack,
			TextSize=12,
			Parent=main
		})

		local round=create("ImageLabel",{
			Name="Round",
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Image="rbxassetid://3570695787",
			ImageColor3=Theme.Round,
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Parent=main
		})

		function options:Set(text)
			options.Text=text
			title.Text=text
		end

		local inContact,clicking=false,false

		local inputBegan=main.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				clicking=true
				tween(round,TweenCache.Default,{ImageColor3=Color3.fromRGB(255,65,65)})
				local methodType=tostring(options.MethodType)
				if methodType=="DoubleClick" or methodType=="MultiClick" or methodType=="2" then
					local currentClickTime=os.clock()
					if (currentClickTime-options.LastClickTime)>options.ClickThreshold then
						options.ClickCount=0
					end
					options.ClickCount=options.ClickCount+1
					options.LastClickTime=currentClickTime
					if options.ClickCount>=options.MaxClick then
						options.ClickCount=0
						callSafely(options.Callback)
					end
				elseif methodType=="AntiSpamClick" or methodType=="DebounceClick" or methodType=="3" then
					if not options.ClickWaiting then
						options.ClickWaiting=true
						callSafely(options.Callback)
						task.wait(options.ClickDuration)
						options.ClickWaiting=false
					end
				else
					options.ClickWaiting=false
					callSafely(options.Callback)
				end
			end
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=true
				tween(round,TweenCache.Other,{ImageColor3=Color3.fromRGB(60,60,60)})
			end
		end)

		local inputEnded=main.InputEnded:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				clicking=false
				if inContact then
					tween(round,TweenCache.Default,{ImageColor3=Color3.fromRGB(60,60,60)})
				else
					tween(round,TweenCache.Default,{ImageColor3=Color3.fromRGB(40,40,40)})
				end
			end
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=false
				if not clicking then
					tween(round,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(40,40,40)})
				end
			end
		end)

		connectDestroying(Window.Gui,Window.SaveName,function()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
		end)

		if options.Visible~=nil then
			main.Visible=options.Visible and true or false
		end

		options.Instance=main

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" and i~="ClickWaiting" and i~="MethodType" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				elseif i=="MethodType" then
					if v~=nil then
						local methodType=tostring(v)
						if table.find(EnumCache.ClickMethodTypes, methodType) then
							options.MethodType=methodType

							if methodType=="AntiSpamClick" or methodType=="DebounceClick" or methodType=="3" then
								options.ClickWaiting=false
							end
						end
					end
				end
			end
		})
	end

	function elements:AddToggle(...)
		local args={...}
		local options={}
		for index,value in ipairs(args) do
			if value~=nil then
				local valueType=typeof(value)
				if index==1 and valueType=="table" then
					options=value
					break
				elseif index==1 and valueType=="string" then
					options.Text=value
				elseif index==2 and valueType=="boolean" then
					options.Value=value
				elseif index==2 or index==3 and valueType=="function" then
					options.Callback=value
				end
			end
		end
		options.Type="Toggle"
		options.Style=options.Style==nil and "1" or tostring(options.Style)
		options.Text=options.Text or options.Title or options.Name or options.Type
		options.Callback=missing("function",options.Callback,function() end)

		local inContact,title,tickboxOutline,changeFunc=false,nil,nil,nil

		local main=create("Frame",{
			Name=options.Type,
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Size=UDim2.new(1,0,0,30),
			Parent=Window.Container
		})

		if options.Style=="0" then
			title=create("TextLabel",{
				Name="Title",
				ZIndex=2,
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Text=options.Text,
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=12,
				Parent=main
			})

			local round=create("ImageLabel",{
				Name="Round",
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Image="rbxassetid://3570695787",
				ImageColor3=Color3.fromRGB(40,40,40),
				ScaleType=Enum.ScaleType.Slice,
				SliceCenter=Rect.new(100,100,100,100),
				SliceScale=0.02,
				Parent=main
			})

            local function changeState()
                value=value and true or false
				if options.Value~=value then
					options.Value=value
					if options.Flag then
						Library.Flags[options.Flag]=value
					end
					title.Text=options.Name .. ": " .. (value and "ON" or "OFF")
					tween(round,TweenCache.Default,{ImageColor3=value and Color3.fromRGB(60,200,60) or Color3.fromRGB(200,60,60)})
					callSafely(callback,value)
				end
            end
			
			function options:Set(value)
				changeState(value,options.Callback)
			end

			function options:Replace(value)
				changeState(value,nil)
			end
		elseif options.Style=="2" then
			title=create("TextLabel",{
				Name="Title",
				ZIndex=2,
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Text=" "..options.Text,
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=12,
				TextXAlignment=Enum.TextXAlignment.Left,
				Parent=main
			})

			local indicator=create("Frame",{
				Name="Indicator",
				Size=UDim2.new(0,38,0,18),
				Position=UDim2.new(1,-39,0.5,-9),
				BackgroundColor3=options.Value and Color3.fromRGB(60,200,60) or Color3.fromRGB(75,75,85),
				BorderSizePixel=0,
				Parent=main
			})

			local indicatorText=create("TextLabel",{
				Name="Title",
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				Text=options.Value and "ON" or "OFF",
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=9,
				Parent=indicator
			})

            
			local function changeState(value,callback)
				value=value and true or false
				if options.Value~=value then
					options.Value=value
					if options.Flag then
						Library.Flags[options.Flag]=value
					end
					local targetColor=value and Color3.fromRGB(60,200,60) or Color3.fromRGB(75,75,85)
					tween(indicator,TweenCache.Default,{BackgroundColor3=targetColor})
					indicatorText.Text=value and "ON" or "OFF"
					callSafely(callback,value)
				end
			end

			function options:Set(value)
				changeState(value,options.Callback)
			end

			function options:Replace(value)
				changeState(value,nil)
			end
		else
			title=create("TextLabel",{
				Name="Title",
				ZIndex=2,
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new(0.5,0,0.5,0),
				Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=1,
				BorderSizePixel=0,
				Text=" "..options.Text,
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,
				TextSize=12,
				TextXAlignment=Enum.TextXAlignment.Left,
				Parent=main
			})

			tickboxOutline=create("ImageLabel",{
				Position=UDim2.new(1,-6,0,4),
				Size=UDim2.new(-1,10,1,-10),
				SizeConstraint=Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency=1,
				Image="rbxassetid://3570695787",
				ImageColor3=options.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100),
				ScaleType=Enum.ScaleType.Slice,
				SliceCenter=Rect.new(100,100,100,100),
				SliceScale=0.02,
				Parent=main
			})

			local tickboxInner=create("ImageLabel",{
				Position=UDim2.new(0,2,0,2),
				Size=UDim2.new(1,-4,1,-4),
				BackgroundTransparency=1,
				Image="rbxassetid://3570695787",
				ImageColor3=options.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(20,20,20),
				ScaleType=Enum.ScaleType.Slice,
				SliceCenter=Rect.new(100,100,100,100),
				SliceScale=0.02,
				Parent=tickboxOutline
			})

			local checkmarkHolder=create("Frame",{
				Position=UDim2.new(0,4,0,4),
				Size=options.Value and UDim2.new(1,-8,1,-8) or UDim2.new(0,0,1,-8),
				BackgroundTransparency=1,
				ClipsDescendants=true,
				Parent=tickboxOutline
			})

			local checkmark=create("ImageLabel",{
				Size=UDim2.new(1,0,1,0),
				SizeConstraint=Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency=1,
				Image="rbxassetid://4919148038",
				ImageColor3=Color3.fromRGB(20,20,20),
				Parent=checkmarkHolder
			})

			local function changeState(value,callback)
				value=value and true or false
				if options.Value~=value then
					options.Value=value
					if options.Flag then
						Library.Flags[options.Flag]=value
					end
					checkmarkHolder:TweenSize(value and UDim2.new(1,-8,1,-8) or UDim2.new(0,0,1,-8),"Out","Quad",0.2,true)
					tween(tickboxInner,TweenCache.Default,{ImageColor3=value and Color3.fromRGB(255,255,255) or Color3.fromRGB(20,20,20)})
					tween(tickboxOutline, value and TweenCache.Default or TweenCache.Other,{ImageColor3=value and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)})
					if not value then
						tween(tickboxOutline,TweenInfo.new(inContact and 0.2 or 0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=inContact and Color3.fromRGB(140,140,140) or Color3.fromRGB(100,100,100)})
					end
					callSafely(callback,value)
				end
			end

			function options:Set(value)
				changeState(value,options.Callback)
			end

			function options:Replace(value)
				changeState(value,nil)
			end
		end

		if options.Flag then
			Library.Flags[options.Flag]=options
		end

		local inputBegan=main.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				options:Set(not options.Value)
			end
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=true
				if not options.Value and tickboxOutline~=nil then
					tween(tickboxOutline,TweenCache.Other,{ImageColor3=Color3.fromRGB(140,140,140)})
				end
			end
		end)

		local inputEnded=main.InputEnded:connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				if not options.Value and tickboxOutline~=nil then
					tween(tickboxOutline,TweenCache.Other,{ImageColor3=Color3.fromRGB(100,100,100)})
				end
			end
		end)

		connectDestroying(Window.Gui,Window.SaveName,function()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
			options:Set(false)
		end)

		if options.Visible~=nil then
			main.Visible=options.Visible and true or false
		end
		options.Instance=main

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				end
			end
		})
	end

	function elements:AddInput(options)
		options=missing("table",options,{})
		options.Type="Input"
		options.Title=options.Text or options.Title or options.Name or options.Type
		options.PlaceholderText=options.PlaceholderText or ""
		options.NoEnter=options.NoEnter or false
		options.Value=options.Value or ""
		options.Callback=missing("function",options.Callback,function() end)

		local main=create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,36),
			BackgroundColor3=Color3.fromRGB(45,45,52),
			BackgroundTransparency=0,
			BorderSizePixel=0,
			Parent=Window.Container
		})

		local title=create("TextLabel",{
			Name="Title",
			Parent=main,
			Size=UDim2.new(0.5,0,1,0),
			BackgroundTransparency=1,
			Text="   " .. options.Title,
			TextColor3=Color3.fromRGB(255,255,255),
			Font=Enum.Font.GothamBlack,
			TextSize=12,
			BorderSizePixel=0,
			TextXAlignment=Enum.TextXAlignment.Left
		})

		local inputFrame=create("Frame",{
			Name="InputFrame",
			Parent=main,
			Size=UDim2.new(0.5,-10,0,24),
			Position=UDim2.new(0.5,0,0.5,-12),
			BackgroundColor3=Color3.fromRGB(30,30,35),
			BorderSizePixel=0
		})

		local inputBox=create("TextBox",{
			Name="InputBox",
			Parent=inputFrame,
			Size=UDim2.new(1,-10,1,0),
			Position=UDim2.new(0,5,0,0),
			BackgroundTransparency=1,	
			PlaceholderText=options.PlaceholderText,
			Text=tostring(options.Value),
			TextColor3=Color3.fromRGB(200,200,200),
			Font=Enum.Font.GothamBlack,
			TextScaled=true,
			TextXAlignment=Enum.TextXAlignment.Left,
			ClearTextOnFocus=false
		})

		function options:Set(text)
			text=tostring(text)
			self.Value=text
			inputBox.Text=text
		end

		local focusLost=inputBox.FocusLost:Connect(function(enter)
			if not enter and not options.NoEnter then return end
			local inputText=inputBox.Text
			if options.RemoveTextAfterFocusLost or options.ClearOnFocus then inputBox.Text="" end
			callSafely(options.Callback,inputText)
		end)

		connectDestroying(Window.Gui,Window.SaveName,function()
			focusLost:Disconnect()
		end)

		if options.Visible~=nil then
			main.Visible=options.Visible and true or false
		end
		options:Set(options.Value)
		options.Instance=main

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Title" then
					title.Text=v
				elseif i=="Text" then
					inputBox.Text=v
				elseif i=="PlaceholderText" then
					inputBox.PlaceholderText=v
				end
			end
		})
	end

	function elements:AddSlider(...)
		local args={...}

		local options={}
		for index,value in ipairs(args) do
			if value~=nil then
				local valueType=typeof(value)
				if index==1 and valueType=="table" then
					options=value
					break
				elseif index==1 and valueType=="string" then
					options.Text=value
				elseif index==2 and valueType=="table" then
					options.Range=value
				elseif index==3 and valueType~="function" and valueType=="number" then
					options.Value=value
				elseif index==4 and valueType~="function" and valueType=="number" then
					options.Increment=value
				elseif index==3 or index==4 or index==5 and valueType=="function" then
					options.Callback=value
				end
			end
		end

		options.Type="Slider"
		options.Style = options.Style == nil and "1" or tostring(options.Style)
		options.Text=options.Text or options.Title or options.Name or options.Type
		options.Range=missing("table",options.Range,{0,100})

		if options.Range[1]==nil or type(options.Range[1])~="number" then
			options.Range[1]=0
		end
		if options.Range[2]==nil or type(options.Range[2])~="number" then
			options.Range[2]=100
		end
		if options.Min and type(options.Min)=="number" then
			options.Range[1]=options.Min
		end
		if options.Max and type(options.Max)=="number" then
			options.Range[2]=options.Max
		end

		options.Min=options.Range[1]
		options.Max=options.Range[2]

		options.Increment=missing("number",options.Increment,options.Min)
		options.Value=missing("number",options.Value,options.Min)
		options.FillColor3=options.FillColor3 or Color3.fromRGB(255,65,65)
		options.Callback=missing("function",options.Callback,function() end)
		options.SaveValue=options.Value

		local cleanFunc=nil
		local main,title,handle,fill,track=nil,nil,nil,nil,nil
		local sliding,inContact=false,false

		local dragStart,dragContinue,dragEnd,inputBegan,inputEnded,focusLost=nil,nil,nil,nil,nil,nil
		local uiDragDetector=create("UIDragDetector", {
			ResponseStyle=Enum.UIDragDetectorResponseStyle.CustomOffset,
			DragStyle=Enum.UIDragDetectorDragStyle.TranslateLine
		})

		local function updateSlider(position)
			local value = options.Min+((position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X)*(options.Max-options.Min)
			options:Set(value)
		end

		if options.Style=="0" then
			main=create("Frame",{
				Name=options.Type,
				Size=UDim2.new(1,0,0,45),
				BackgroundTransparency=1,
				Parent=Window.Container
			})

			title=create("TextLabel",{
				Name="Title",
				Size=UDim2.new(1,0,0,20),
				BackgroundTransparency=1,
				Text=options.Text .. ": " .. options.Value,
				TextColor3=Color3.fromRGB(255,255,255),
				Font=Enum.Font.GothamBlack,-- Updated Font
				TextSize=12,
				BorderSizePixel=0,
				Parent=main
			})

			track=create("Frame",{
				Name="Track",
				BackgroundColor3=Color3.fromRGB(30,30,30),
				BorderSizePixel=0,
				Size=UDim2.new(1,0,0,10),
				Position=UDim2.new(0,0,0,25),
				Parent=main,
			})

			fill=create("Frame",{
				Name="Fill",
				BackgroundColor3=Color3.fromRGB(60,60,60),
				Size=UDim2.new((options.Value-options.Min) / (options.Max-options.Min),0,1,0),
				BorderSizePixel=0,
				Parent=track
			})

			handle=create("ImageLabel",{
				Name="Handle",
				AnchorPoint=Vector2.new(0.5,0.5),
				Position=UDim2.new((options.Value - options.Min) / (options.Max - options.Min),0,0.5,0),
				SizeConstraint=Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency=1,
				Image="rbxassetid://3570695787",
				ImageColor3=Color3.fromRGB(60,60,60),
				ScaleType=Enum.ScaleType.Slice,
				SliceCenter=Rect.new(100,100,100,100),
				SliceScale=1,
				Parent=track
			})

			if options.Min>=0 then
				fill.Size=UDim2.new((options.Value-options.Min)/(options.Max-options.Min),0,1,0)
			else
				fill.Position=UDim2.new((0-options.Min)/(options.Max-options.Min),0,0,0)
				fill.Size=UDim2.new(options.Value/(options.Max-options.Min),0,1,0)
			end

			function options:Set(value)
				value=Round(value,self.Increment)
				value=math.clamp(value,self.Min,self.Max)
				self.Value=value
				handle:TweenPosition(UDim2.new((value-self.Min)/(self.Max-self.Min),0,0.5,0),"Out","Quad",0.1,true)
				if self.Min>=0 then
					fill:TweenSize(UDim2.new((value-self.Min)/(self.Max-self.Min),0,1,0),"Out","Quad",0.1,true)
				else
					fill:TweenPosition(UDim2.new((0-self.Min)/(self.Max-self.Min),0,0,0),"Out","Quad",0.1,true)
					fill:TweenSize(UDim2.new(value/(self.Max-self.Min),0,1,0),"Out","Quad",0.1,true)
				end
				local newValue=Strs.toNumber(value)
				title.Text=self.Text .. ": " .. newValue
				callSafely(self.Callback,tonumber(newValue) or value)
			end

			options:Set(options.Value)

			dragStart=uiDragDetector.DragStart:Connect(function(inputPosition)
				sliding=true
				tween(fill,TweenCache.Default,{BackgroundColor3 = options.FillColor3})
				tween(handle,TweenCache.Default,{Size = UDim2.new(2.5, 0, 2.5, 0), ImageColor3 = options.FillColor3})
				updateSlider(inputPosition)
			end)

			dragContinue=uiDragDetector.DragContinue:Connect(function(inputPosition)
				if sliding then
					updateSlider(inputPosition)
				end
			end)

			dragEnd=uiDragDetector.DragEnd:Connect(function(inputPosition)
				sliding=false
				tween(fill,TweenCache.Default,{BackgroundColor3=Color3.fromRGB(60,60,60)})
				tween(handle,TweenCache.Default,{Size=UDim2.new(0,0,0,0),ImageColor3=Color3.fromRGB(60,60,60)})
			end)

			inputBegan=main.InputBegan:connect(function(input)
				if input.UserInputType==Enum.UserInputType.MouseMovement then
					inContact=true
					if not sliding then
						tween(fill,TweenCache.Default,{BackgroundColor3=Color3.fromRGB(100,100,100)})
						tween(handle,TweenCache.Default,{Size=UDim2.new(1.8,0,1.8,0),ImageColor3=Color3.fromRGB(100,100,100)})
					end
				end
			end)

			inputEnded=main.InputEnded:connect(function(input)
				if input.UserInputType==Enum.UserInputType.MouseMovement then
					inContact=false
					if not sliding then
						tween(fill,TweenCache.Default,{BackgroundColor3=Color3.fromRGB(60,60,60)})
						tween(handle,TweenCache.Default,{Size=UDim2.new(0,0,0,0),ImageColor3=Color3.fromRGB(60,60,60)})
					end
				end
			end)

			cleanFunc=function()

			end
		else
	    main=create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,50),
			BackgroundTransparency=1,
			Parent=Window.Container
		})

		title=create("TextLabel",{
			Name="Title",
			Position=UDim2.new(0,0,0,4),
			Size=UDim2.new(1,0,0,20),
			BackgroundTransparency=1,
			Text=" " .. options.Text,
			TextSize=17,
			Font=Enum.Font.GothamBlack,
			TextColor3=Theme.Text,
			TextXAlignment=Enum.TextXAlignment.Left,
			Parent=main
		})

		track=create("ImageLabel",{
			Name="Track",
			Position=UDim2.new(0,10,0,34),
			Size=UDim2.new(1,-20,0,5),
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageColor3=Color3.fromRGB(30,30,30),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Parent=main
		})

		fill=create("ImageLabel",{
			Name="Fill",
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageColor3=Color3.fromRGB(60,60,60),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Parent=track
		})

		handle=create("ImageLabel",{
			Name="Handle",
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new((options.Value - options.Min) / (options.Max - options.Min),0,0.5,0),
			SizeConstraint=Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageColor3=Color3.fromRGB(60,60,60),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=1,
			Parent=track
		})

		local inputFrame=create("ImageLabel",{
			Name="InputFrame",
			Position=UDim2.new(1,-6,0,4),
			Size=UDim2.new(0,-60,0,18),
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageColor3=Color3.fromRGB(40,40,40),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Parent=main
		})

		local inputBox=create("TextBox",{
			Name="InputBox",
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			Text=tostring(options.Value),
			TextColor3=Theme.InputText,
			TextSize=15,
			TextWrapped=true,
			Font=Enum.Font.GothamBlack,
			Parent=inputFrame
		})

		if options.Min>=0 then
			fill.Size=UDim2.new((options.Value-options.Min)/(options.Max-options.Min),0,1,0)
		else
			fill.Position=UDim2.new((0-options.Min)/(options.Max-options.Min),0,0,0)
			fill.Size=UDim2.new(options.Value/(options.Max-options.Min),0,1,0)
		end


		if options.Visible~=nil then
			main.Visible=options.Visible and true or false
		end


		function options:Set(value)
			local min, max, increment, callback = options.Min or 0, options.Max or 100, options.Increment or 1, options.Callback
			value=round(value,increment)
			value=math.clamp(value,min,max)
			options.Value=value
			local ratio = (value-min)/(max-min)
			handle:TweenPosition(UDim2.new(ratio,0,0.5,0),"Out","Quad",0.1,true)
			if min>=0 then
				fill:TweenSize(UDim2.new(ratio,0,1,0),"Out","Quad",0.1,true)
			else
				fill:TweenPosition(UDim2.new((0-min)/(max-min),0,0,0),"Out","Quad",0.1,true)
				fill:TweenSize(UDim2.new(value/(max-min),0,1,0),"Out","Quad",0.1,true)
			end
			local newValue = Strs.toNumber(value) or tostring(value)
			inputBox.Text = newValue
			callSafely(callback, tonumber(newValue) or value)
		end

		dragStart=uiDragDetector.DragStart:Connect(function(inputPosition)
			sliding=true
			tween(fill,TweenCache.Default,{ImageColor3 = options.FillColor3})
			tween(handle,TweenCache.Default,{Size = UDim2.new(3.5, 0, 3.5, 0), ImageColor3 = options.FillColor3})
			updateSlider(inputPosition)
		end)

		dragContinue=uiDragDetector.DragContinue:Connect(function(inputPosition)
			if sliding then
				updateSlider(inputPosition)
			end
		end)

		dragEnd=uiDragDetector.DragEnd:Connect(function(inputPosition)
			sliding=false
			tween(fill,TweenCache.Default,{ImageColor3=Color3.fromRGB(60,60,60)})
			tween(handle,TweenCache.Default,{Size=UDim2.new(0,0,0,0),ImageColor3=Color3.fromRGB(60,60,60)})
		end)

		inputBegan=main.InputBegan:connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=true
				if not sliding then
					tween(fill,TweenCache.Default,{ImageColor3=Color3.fromRGB(100,100,100)})
					tween(handle,TweenCache.Default,{Size=UDim2.new(2.8,0,2.8,0),ImageColor3=Color3.fromRGB(100,100,100)})
				end
			end
		end)

		inputEnded=main.InputEnded:connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=false
				inputBox:ReleaseFocus()
				if not sliding then
					tween(fill,TweenCache.Default,{ImageColor3=Color3.fromRGB(60,60,60)})
					tween(handle,TweenCache.Default,{Size=UDim2.new(0,0,0,0),ImageColor3=Color3.fromRGB(60,60,60)})
				end
			end
		end)

		focusLost=inputBox.FocusLost:connect(function(enter)
			if not enter then return end
			local newValue,inputText=options.Value,inputBox.Text
			if Strs.isOriginal(inputText) then
				newValue=options.SaveValue
			else
				newValue=tonumber(inputBox.Text)
			end
			newValue=newValue or options.Value
			tween(handle,TweenCache.Default,{Size=UDim2.new(0,0,0,0),ImageColor3=Color3.fromRGB(60,60,60)})
			options:Set(newValue)
		end)

		cleanFunc=function()
			dragStart:Disconnect()
			dragContinue:Disconnect()
			dragEnd:Disconnect()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
			focusLost:Disconnect()
		end

		end

		uiDragDetector.BoundingUI=track
		uiDragDetector.Parent=main

		if options.Flag then
			Library.Flags[options.Flag]=options
		end

		connectDestroying(Window.Gui,Window.SaveName,function()
			dragStart:Disconnect()
			dragContinue:Disconnect()
			dragEnd:Disconnect()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
			if focusLost then focusLost:Disconnect() end
		end)

		options.Instance=main

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				elseif i=="Sliding" then
					return sliding
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" and i~="Range" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				elseif i=="Range" then
					options.Min=v[1] or options.Min
					options.Max=v[2] or options.Max
					options.Range={options.Min,options.Max}
				elseif i=="FillColor3" and sliding then
					tween(fill,TweenCache.Default,fill:IsA("ImageLabel") and {ImageColor3=v} or {BackgroundColor3=v})
					tween(handle,TweenCache.Default,{ImageColor3=v})
				end
			end
		})
	end

	function elements:AddSelector(options)
		options=missing("table",options,{})
		options.Type="Selector"
		options.Text=options.Text or options.Title or options.Name or nil
		if not options.Options or type(options.Options)~="table" or #options.Options<=0 then
			options.Options={"Option 1","Option 2","Option 3"}
		end
		options.NoCap=missing("boolean",options.NoCap,false)
		options.Index=table.find(options.Options,options.Value) or 1
		options.Value=missing("string",options.Value,options.Options[options.Index])
		options.Callback=missing("function",options.Callback,function() end)

		local main=create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,30),
			BackgroundTransparency=1,
			Parent=Window.Container
		})

		local nextFrame=create("Frame",{
			Name="Next",
			BackgroundTransparency=1,
			Size=UDim2.new(0.194,0,1,0),
			Position=UDim2.new(0.806,0,0,0),
			Parent=main
		})

		local nextIcon=create("ImageLabel",{
			Name="Icon",
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,-12,1,-12),
			BackgroundTransparency=1,
			Rotation=-0,
			Image="rbxassetid://4918373417",
			ImageColor3=Color3.fromRGB(255,255,255),
			ScaleType=Enum.ScaleType.Fit,
			Parent=nextFrame
		})

		local previousFrame=create("Frame",{
			Name="Previous",
			Size=UDim2.new(0.194,0,1,0),
			Position=UDim2.new(0,0,0,0),
			BackgroundTransparency=1,
			Parent=main
		})

		local previousIcon=create("ImageLabel",{
			Name="Icon",
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,-12,1,-12),
			BackgroundTransparency=1,
			Rotation=180,
			Image="rbxassetid://4918373417",
			ImageColor3=Color3.fromRGB(255,255,255),
			ScaleType=Enum.ScaleType.Fit,
			Parent=previousFrame
		})

		local information=create("TextLabel",{
			Name="Information",
			Position=UDim2.new(0,0,0,0),
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			Text=options.Text and tostring(options.Text)..": "..tostring(options.Value) or tostring(options.Value),
			TextColor3=Color3.fromRGB(180,180,190),
			Font=Enum.Font.GothamBlack,
			TextSize=12,
			Parent=main
		})

		function options:Set(value,index)
			self.Value=value
			information.Text=self.Text and tostring(self.Text)..": "..tostring(value) or tostring(value)
			if index and type(index)=="number" then self.Index=index else index=table.find(options.Options,value) or 1 end
			callSafely(self.Callback,value,index)
		end

		local nextBegan=nextFrame.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				local newIndex,newOptions=options.Index,options.Options
				if newIndex>=#newOptions then
					newIndex=options.NoCap and 1 or #newOptions
				else
					newIndex+=1
				end
				options.Index=newIndex
				options:Set(newOptions[newIndex],newIndex)
			end
		end)

		local previousBegan=previousFrame.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				local newIndex,newOptions=options.Index,options.Options
				if options.NoCap then
					if newIndex<=0 then newIndex=1 end
					newIndex=newIndex<=1 and #newOptions or newIndex-1
				else
					newIndex=newIndex<=0 and 1 or newIndex-1
					if newIndex<=0 then newIndex=1 end
				end
				options.Index=newIndex
				options:Set(newOptions[newIndex],newIndex)
			end
		end)

		connectDestroying(Window.Gui,Window.SaveName,function()
			nextBegan:Disconnect()
			previousBegan:Disconnect()
		end)

		if options.Visible~=nil then
			main.Visible=options.Visible and true or false
		end
		options.Instance=main

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				end
			end
		})
	end

	function elements:AddSelect(options)
		options=missing("table",options,{})
		options.Type="Select"
		options.Active=false
		options.Callback=missing("function",options.Callback,function() end)

		local text=options.Text or options.Title or options.Name

		local titleLabel=nil

		if text then
			titleLabel=getComponents(Window):AddLabel({Text=text})
		end

		local main=create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,30),
			BackgroundTransparency=1,
			Parent=Window.Container
		})

		local tickboxOutline=create("ImageLabel",{
			Position=UDim2.new(0,25,0,4),
			Size=UDim2.new(-1,10,1,-10),
			SizeConstraint=Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageColor3=options.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Parent=main
		})

		local tickboxInner=create("ImageLabel",{
			Position=UDim2.new(0,2,0,2),
			Size=UDim2.new(1,-4,1,-4),
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageColor3=options.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(20,20,20),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Parent=tickboxOutline
		})

		local checkmarkHolder=create("Frame",{
			Position=UDim2.new(0,4,0,4),
			Size=options.Value and UDim2.new(1,-8,1,-8) or UDim2.new(0,0,1,-8),
			BackgroundTransparency=1,
			ClipsDescendants=true,
			Parent=tickboxOutline
		})

		local checkmark=create("ImageLabel",{
			Size=UDim2.new(1,0,1,0),
			SizeConstraint=Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency=1,
			Image="rbxassetid://4919148038",
			ImageColor3=Color3.fromRGB(20,20,20),
			Parent=checkmarkHolder
		})

		local displayFrame=create("Frame",{
			Name="DisplayFrame",
			BackgroundColor3=Color3.fromRGB(200,200,200),
			BackgroundTransparency=0,
			BorderSizePixel=0,
			Position=UDim2.new(0.171,0,0.095,0),
			Size=UDim2.new(0.785,0,0.743,0),
			Parent=main
		})

		function options:Set(value)
			self.Value=value
			if type(value)=="table" then
				displayFrame.BackgroundColor3=value.Color or Color3.fromRGB(200,200,200)
			elseif typeof(value)=="Instance" and value:IsA("BasePart") then
				displayFrame.BackgroundColor3=value.Color
			end
			callSafely(self.Callback,value)
		end

		local inContact=false

		local setActive=function(active)
			options.Active=active
			checkmarkHolder:TweenSize(active and UDim2.new(1,-8,1,-8) or UDim2.new(0,0,1,-8),"Out","Quad",0.2,true)
			tween(tickboxInner,TweenCache.Default,{ImageColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(20,20,20)})
			tween(tickboxOutline,TweenInfo.new(active and 0.2 or 0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)})
			if not active then
				tween(tickboxOutline,TweenInfo.new(inContact and 0.2 or 0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=inContact and Color3.fromRGB(140,140,140) or Color3.fromRGB(100,100,100)})
			end
		end

		local selectClick=nil

		local inputBegan=tickboxOutline.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				if selectClick then selectClick:Disconnect() selectClick=nil end
				options.Active=options.Active and true or false
				local newActive=not options.Active
				setActive(newActive)
				if newActive then
					callSafely(options.Activated)
					fastWait(0.2)
					local mouse=LocalPlayer:GetMouse()
					selectClick=mouse.Button1Down:Connect(function()
						if options.Active then
							options.Active = false
							local Target=mouse.Target
							if (Target and Target.Parent) then 
								options:Set(Target)
							end
							if options.Active == false and selectClick then
								task.wait(0.1)
								options.Active = true
							end
						end
					end)
				else
					callSafely(options.Deactivated)
				end
			end
		end)

		connectDestroying(Window.Gui,Window.SaveName,function()
			if selectClick then selectClick:Disconnect() selectClick=nil end
			inputBegan:Disconnect()
		end)

		if options.Visible~=nil then
			local currentVisible=options.Visible and true or false
			if titleLabel then
				titleLabel.Visible=currentVisible
			end
			main.Visible=currentVisible
		end
		options.Instance=main

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" then
					options[i]=v
				end
				if i=="Visible" then
					if titleLabel then
						titleLabel.Visible=v
					end
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					if titleLabel then
						titleLabel:Set(v)
					end
				elseif i=="Active" and not v then
					if selectClick then selectClick:Disconnect() selectClick=nil end
				end
			end
		})
	end

	function elements:AddDropdown(options)
		options=options or {}
		options.Type="Dropdown"
		options.Name=options.Name or options.Type
		options.Text=options.Text or options.Title or options.Name
		options.MultipleOptions=options.MultipleOptions and true or false
		options.Callback=missing("function",options.Callback,function() end)
		options.Open=false
		options.SortOrder=options.SortOrder or "LayoutOrder"

		if not options.Options or type(options.Options)~="table" or #options.Options<=0 then
			options.Options={"Option 1","Option 2"}
		end

		if options.Option then
			if type(options.Option)=="string" then
				options.Option={options.Option}
			end
			if not options.MultipleOptions and type(options.Option)=="table" then
				options.Option={options.Option[1]}
			end
			if type(options.Option)~="table" then
				options.Option={}
			end
		else
			options.Option={}
		end

		local main=create("Frame", {
			BackgroundTransparency=1,
			Size=UDim2.new(1,0,0,52),
			Parent=Window.Container
		})

		local round=create("ImageLabel", {
			Position=UDim2.new(0, 6, 0, 4),
			Size=UDim2.new(1, -12, 1, -10),
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageColor3=Theme.Round,
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100, 100, 100, 100),
			SliceScale=0.02,
			Parent=main
		})

		local title=create("TextLabel", {
			Position=UDim2.new(0, 12, 0, 8),
			Size=UDim2.new(1, -24, 0, 14),
			BackgroundTransparency=1,
			Text=options.Text,
			TextSize=14,
			TextScaled=true,
			Font=Enum.Font.GothamBlack,
			TextColor3=Color3.fromRGB(140, 140, 140),
			TextXAlignment=Enum.TextXAlignment.Left,
			Parent=main
		})

		local selected=create("TextLabel", {
			Position=UDim2.new(0, 12, 0, 20),
			Size=UDim2.new(1, -24, 0, 24),
			BackgroundTransparency=1,
			Text=options.value,
			TextSize=18,
			Font=Enum.Font.GothamBlack,
			TextColor3=Color3.fromRGB(255, 255, 255),
			TextXAlignment=Enum.TextXAlignment.Left,
			Parent=main
		})

		create("ImageLabel", {
			Position=UDim2.new(1, -16, 0, 16),
			Size=UDim2.new(-1, 32, 1, -32),
			SizeConstraint=Enum.SizeConstraint.RelativeYY,
			Rotation=90,
			BackgroundTransparency=1,
			Image="rbxassetid://4918373417",
			ImageColor3=Color3.fromRGB(140, 140, 140),
			ScaleType=Enum.ScaleType.Fit,
			Parent=round
		})

		local mainHolder=create("ImageLabel",{
			Name="List",
			ZIndex=3,
			Size=UDim2.new(0,main.AbsoluteSize.X,0,0),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1,
			Image="rbxassetid://3570695787",
			ImageTransparency=1,
			ImageColor3=Color3.fromRGB(30,30,30),
			ScaleType=Enum.ScaleType.Slice,
			SliceCenter=Rect.new(100,100,100,100),
			SliceScale=0.02,
			Visible=false,
			Parent=Window.Gui
		})

		options.MainHolder=mainHolder

		local content=create("ScrollingFrame",{
			Name="Content",
			ZIndex=3,
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			BorderSizePixel=0,
			ScrollBarImageColor3=Color3.fromRGB(),
			ScrollBarThickness=0,
			ScrollingDirection=Enum.ScrollingDirection.Y,
			Parent=mainHolder
		})

		local layout=create("UIListLayout",{SortOrder=options.SortOrder, Parent=content})
		local optionLength=0

		options.DroptionButtons={}
		options.Actives={}
		options.IsEmpty=false

		if options.MultipleOptions then
			if #options.Option==1 then
				selected.Text=options.Option[1]
			elseif #options.Option==0 then
				selected.Text="None"
			else
				selected.Text="Various"
			end
		else
			selected.Text=options.Option[1] or "None"
		end
		options.IsEmpty=#options.Option<=0
		options.Instance=main

		local layoutChanged=layout.Changed:Connect(function()
			mainHolder.Size=UDim2.new(0,240,0,(optionLength>4 and (4*40) or layout.AbsoluteContentSize.Y)+12)
			content.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+12)
		end)

		function options:Add(newOption)
			if not newOption or typeof(newOption)~="string" then return end
			if options.Actives[newOption] ~= nil then return end
			options.Actives[newOption] = false
			optionLength=optionLength+1
			local droption=create("TextLabel",{
				Name=tostring(#options.DroptionButtons),
				ZIndex=3,
				Size=UDim2.new(1,0,0,40),
				BackgroundColor3=Theme.DropdownSelected,
				BorderSizePixel=0,
				Text="    " .. newOption,
				TextSize=14,
				TextTransparency=self.Open and 0 or 1,
				Font=Enum.Font.GothamBlack,
				TextColor3=Color3.fromRGB(255,255,255),
				TextXAlignment=Enum.TextXAlignment.Left,
				Parent=content
			})
			table.insert(options.DroptionButtons, droption)
			droption.LayoutOrder=#options.DroptionButtons
			if #options.Option>0 and table.find(options.Option,newOption)~=nil then
				droption.BackgroundColor3=Theme.DropdownUnselected
				options.Actives[newOption]=true
			end
			local inContact,clicking=false,false
			local visibleChanged=droption:GetPropertyChangedSignal("Visible"):Connect(function()
				if droption.Visible then
					local currentOption=Strs.trim(droption.Text)
					if #options.Option>0 and not table.find(options.Option,currentOption) then
						droption.BackgroundColor3=Theme.DropdownSelected
						options.Actives[currentOption] = false
					end
					if options.Actives[currentOption] == nil then
						options.Actives[currentOption] = false
					end
				end
			end)
			local inputeBegan=droption.InputBegan:Connect(function(input)
				if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
					clicking=true
					local currentOption=Strs.trim(droption.Text)
					if options.MultipleOptions then
						local foundIndex=table.find(options.Option,currentOption)
						if foundIndex then
							table.remove(options.Option,foundIndex)
							tween(droption,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundColor3=Theme.DropdownSelected})
							options.Actives[currentOption]=false
						else
							table.insert(options.Option,currentOption) 
							tween(droption,TweenInfo.new(0.3,Enum.EasingStyle.Exponential),{BackgroundColor3=Theme.DropdownUnselected})
							options.Actives[currentOption]=true
						end
						if #options.Option==1 then
							selected.Text=options.Option[1]
						elseif #options.Option==0 then
							selected.Text="None"
						else
							selected.Text="Various"
						end
						options.IsEmpty=#options.Option<=0
					else
						options.Actives[currentOption]=true
						table.clear(options.Option)
						table.insert(options.Option,currentOption)
						selected.Text=currentOption
						options.IsEmpty=#options.Option<=0
						options:Close()
					end
					callSafely(options.Callback,options.Option)
				end

				if input.UserInputType==Enum.UserInputType.MouseMovement then
					inContact=true
					if not clicking then
						tween(droption,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=Theme.DropdownUnselected})
					end
				end
			end)

			local inputEnded=droption.InputEnded:Connect(function(input)
				if input.UserInputType==Enum.UserInputType.MouseMovement then
					inContact=false
					if not clicking then
						local currentOption=Strs.trim(droption.Text)
						local isSelected=table.find(self.Option,currentOption)
						local targetColor=isSelected and Theme.DropdownUnselected or Theme.DropdownSelected
						tween(droption,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=targetColor})
					end
				end
			end)

			local cleanup=connectDestroying(Window.Gui,Window.SaveName,function()
				visibleChanged:Disconnect() 
				inputeBegan:Disconnect() 
				inputEnded:Disconnect() 
			end)

			connectDestroying(droption,nil,function()
				cleanup()

				local foundIndex = table.find(self.DroptionButtons, droption)
				if foundIndex then 
					table.remove(self.DroptionButtons, foundIndex) 
				end

				local oldListCount = #self.DroptionButtons

				if #self.DroptionButtons==oldListCount then
					for rank,otherDroption in ipairs(self.DroptionButtons) do
						if #self.DroptionButtons~=oldListCount then break end

						if otherDroption and otherDroption.Parent then
							otherDroption.LayoutOrder=rank
						end
					end
				end
			end)
		end

		function options:Set(option)
			if option==nil then option={} end
			local optionType=type(option)
			if optionType=="string" then
				option={option}
			elseif optionType~="table" then
				option={}
			end
			if not options.MultipleOptions then
				option={option[1]}
			end
			options.Option=option
			callSafely(options.Callback,option)
			if options.MultipleOptions then
				if #option==1 then
					selected.Text=tostring(option[1])
				elseif #options.Option==0 then
					selected.Text="None"
				else
					selected.Text="Various"
				end
			else
				selected.Text=tostring(option[1])
				options:Close()
				for _,droption in ipairs(content:GetChildren()) do
					if droption.ClassName=="TextLabel" then
						if not options.MultipleOptions then
							droption.BackgroundColor3=table.find(options.Option,droption.Name) ~= nil and Theme.DropdownUnselected or Theme.DropdownSelected
						else
							break
						end
					end
				end
			end
		end

		function options:Refresh()
			local currentOptions = options.Options
			local droptionButtons = options.DroptionButtons

			-- 1. Sembunyikan semua tombol yang ada
			for _, droption in ipairs(droptionButtons) do
				if droption and droption.Parent then
					droption.Visible = false
				end
			end

			-- 2. Tampilkan tombol sesuai opsi yang ada
			for index, option in ipairs(currentOptions) do
				local droption = droptionButtons[index]
				if droption and droption.Parent then
					droption.Name = option
					droption.Text = "    " .. tostring(option)
					droption.Visible = true
				end
			end

			-- 3. (FITUR BARU) Hapus opsi dari self.Option jika sudah tidak ada di currentOptions
			if options.Option and type(options.Option) == "table" then
				for index = #options.Option, 1, -1 do
					local option = options.Option[index]
					if option and not table.find(currentOptions, option) then
						table.remove(options.Option, index)
					end
				end
			end

			-- 4. Buat tombol baru jika currentOptions lebih banyak dari tombol yang tersedia
			if #currentOptions > #droptionButtons then
				for index = #droptionButtons + 1, #currentOptions do
					local option = currentOptions[index]
					options:Add(option)
				end
			end

			-- 5. Perbarui tampilan pilihan (Set value)
			if not options.Option or #options.Option == 0 then
				options:Set("None")
			else
				options:Set(options.Option)
			end
		end

		local inContact=false

		function options:Close()
			Library.ActivePopup=nil
			options.Open=false
			content.ScrollBarThickness=0
			local position=main.AbsolutePosition
			tween(round,TweenCache.Default,{ImageColor3=inContact and Color3.fromRGB(60,60,60) or Color3.fromRGB(40,40,40)})
			tween(mainHolder,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageTransparency=1,Position=UDim2.new(0,position.X-12,0,position.Y-10)})
			for _,label in next,content:GetChildren() do
				if label.ClassName=="TextLabel" then
					tween(label,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1,TextTransparency=1})
				end
			end
			fastWait(0.3)
			if not options.Open then
				options.MainHolder.Visible=false
			end
		end

		for _, option in ipairs(options.Options) do
			options:Add(option)
		end

		if options.Flag then
			Library.Flags[options.Flag]=options
		end

		local inputBegan=round.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				if Library.ActivePopup then
					Library.ActivePopup:Close()
				end
				local position=main.AbsolutePosition
				mainHolder.Position=UDim2.new(0,position.X-12,0,position.Y-10)
				options.Open=true
				mainHolder.Visible=true
				Library.ActivePopup=options
				content.ScrollBarThickness=6
				tween(mainHolder,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{ImageTransparency=0,Position=UDim2.new(0,position.X-12,0,position.Y-4)})
				tween(mainHolder,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0.1),{Position=UDim2.new(0,position.X-12,0,position.Y+1)})
				for _,label in ipairs(content:GetChildren()) do
					if label.ClassName=="TextLabel" then
						tween(label,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0,TextTransparency=0})
					end
				end
			end
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=true
				if not options.Open then
					tween(round,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(60,60,60)})
				end
			end
		end)

		local inputEnded=round.InputEnded:connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				inContact=false
				if not options.Open then
					tween(round,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{ImageColor3=Color3.fromRGB(40,40,40)})
				end
			end
		end)

		connectDestroying(Window.Gui,Window.SaveName,function()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
			layoutChanged:Disconnect()
			options:Set(nil)
		end)

		return setmetatable({},{
			__index=function(_,i)
				local DropdownReturns={
					["Visible"]=main.Visible,
					["Length"]=optionLength
				}
				if i=="DroptionButtons" then return nil end
				if DropdownReturns[i] then return DropdownReturns[i] end
				return options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" and i~="DroptionButtons" and i~="Option" and i~="IsEmpty" and i~="Actives" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Title" or i=="Text" then
					title.Text=v
				end
			end
		})
	end

	function elements:AddFolder(...)
		local args={...}
		local options={}
		for index,value in ipairs(args) do
			if value~=nil then
				local valueType=typeof(value)
				if index==1 and valueType=="table" then
					options=value
					break
				elseif index==1 and valueType=="string" then
					options.Text=value
				elseif index==2 and valueType=="boolean" then
					options.Open=value
				end
			end
		end
		options.Type="Folder"
		options.Text=options.Text or options.Title or options.Name or options.Type
		options.Open=options.Open or false

		local main=create("Frame",{
			Name=options.Type,
			Size=UDim2.new(1,0,0,0),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1,
			Parent=Window.Container
		})

		create("UIListLayout",{
			Parent=main,
			Padding=UDim.new(0,5),
			HorizontalAlignment=Enum.HorizontalAlignment.Center,
			SortOrder=Enum.SortOrder.LayoutOrder
		})

		local title=create("TextLabel",{
			Name="Title",
			Size=UDim2.new(1,0,0,28),
			BackgroundColor3=Theme.Round,
			Text=options.Text,
			TextColor3=Theme.Text,
			Font=Enum.Font.GothamBold,
			TextSize=12,
			BorderSizePixel=0,
			TextXAlignment=Enum.TextXAlignment.Center,
			Parent=main
		})

		local closeHolder=create("Frame",{
			Name="Close",
			Position=UDim2.new(1,0,0,0),
			Size=UDim2.new(-1,0,1,0),
			SizeConstraint=Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency=1,
			Parent=title
		})

		local close=create("ImageLabel",{
			Name="Icon",
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.new(0.5,0,0.5,0),
			Size=UDim2.new(1,-20,1,-20),
			BackgroundTransparency=1,
			Rotation=options.Open and 90 or 180,
			Image="rbxassetid://4918373417",
			ImageColor3=Color3.fromRGB(255,255,255),
			ScaleType=Enum.ScaleType.Fit,
			Parent=closeHolder
		})

		local childContainer=create("Frame",{
			Name="Container",
			Size=UDim2.new(1,0,0,0),
			AutomaticSize=Enum.AutomaticSize.Y,
			BackgroundTransparency=1,
			Visible=options.Open and true or false,
			Parent=main
		})

		local childLayout=create("UIListLayout",{
			Padding=UDim.new(0,5),
			HorizontalAlignment=Enum.HorizontalAlignment.Center,
			SortOrder=Enum.SortOrder.LayoutOrder,
			Parent=childContainer
		})

		create("UIPadding",{
			PaddingLeft=UDim.new(0,0),
			PaddingRight=UDim.new(0,0),
			Parent=childContainer,
		})

		if options.Visible~=nil then
			main.Visible=options.Visible and true or false
		end

		function options:Set(open)
			if open then open=true else open=false end
			self.Open=open
			tween(close,TweenCache.Default,{Rotation=open and 90 or 180})
			childContainer.Visible=open
		end

		if options.Flag then
			Library.Flags[options.Flag]=options
		end

		local inputBegan=closeHolder.InputBegan:connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				options:Set(not options.Open)
			end
		end)

		connectDestroying(Window.Gui,Window.SaveName,function()
			inputBegan:Disconnect()
			options:Set(false)
		end)

		options.Instance=main

		local newElements=getComponents({Gui=Window.Gui,SaveName=Window.SaveName,Container=childContainer})

		return setmetatable({},{
			__index=function(_,i)
				if i=="Visible" then 
					return main.Visible
				end
				return newElements[i] or options[i]
			end,
			__newindex=function(_,i,v)
				if i~="Set" then
					options[i]=v
				end
				if i=="Visible" then
					main.Visible=v
				elseif i=="Text" or i=="Title" then
					title.Text=v
				end
			end
		})
	end

	local ListOfElements={
		["Label"]=elements.AddLabel,
		["Button"]=elements.AddButton,
		["Toggle"]=elements.AddToggle,
		["Input"]=elements.AddInput,
		["Selector"]=elements.AddSelector,
		["Select"]=elements.AddSelect,
		["Folder"]=elements.AddFolder,
		["Dropdown"]=elements.AddDropdown
	}

	ListOfElements.Expand=ListOfElements.Folder
	ListOfElements.TextBox=ListOfElements.Input

	function elements:AddContext(options)
		options=typeof(options)=="table" and options or {}
		options.Type=missing("string",options.Type,"None")
		local func=ListOfElements[options.Type]
		if func then
			return func(self,options)
		end

		return options
	end

	return elements
end

function Library:SetAutoResizeGui(gui,data)
	if not data or type(data)~="table" then data={} end
	resizeUIScale(gui,workspace.CurrentCamera.ViewportSize,data.BaseX and data.BaseX or baseX,data.BaseY and data.BaseY or baseY,data.Callback)
	local connection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		resizeUIScale(gui,workspace.CurrentCamera.ViewportSize,data.BaseX or baseX,data.BaseY or baseY,data.Callback)
	end)
	return function()
		connection:Disconnect()
	end
end

function Library:MakeDraggable(topbar,frame)
	local dragging,dragInput,dragStart,startPos

	local inputBegan=topbar.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true
			dragStart=input.Position
			startPos=frame.Position

			local connection
			connection=input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging=false
					connection:Disconnect()
				end
			end)
		end
	end)

	local inputChanged2=topbar.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			dragInput=input
		end
	end)

	local inputChanged1=UserInputService.InputChanged:Connect(function(input)
		if input==dragInput and dragging then
			local delta=input.Position-dragStart
			frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		end
	end)

	return function()
		inputChanged1:Disconnect()
		inputChanged2:Disconnect()
		inputBegan:Disconnect()
	end
end

function Library:GetProtectGui(gui)
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	if get_hidden_gui then return get_hidden_gui() or Services.CoreGui end
	if gethui then return gethui() or Services.CoreGui end
	-- LocalPlayer:Kick("Error: protect_gui function not found")
	return Services.CoreGui
end

function Library:CreateKeySystem(keyInfo)
	keyInfo=missing("table",keyInfo,{})
	--[[
	    ================================================================
	    [ SCRIPT INFORMATION ]
	    Project: Custom Script
	    Author: OYB
	    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
	    
	    [ TERMS AND CONDITIONS ]
	    - You ARE allowed to use and modify this script for your own games.
	    - You ARE NOT allowed to re-upload,redistribute,or claim 
	      ownership of this script.
	    - Removing or altering these credits is strictly prohibited.
	    
	    Copyright (c) 2026 OYB. All rights reserved.
	    ================================================================
	]]
	local DefaultInfo={
		["Version"] = nil, -- The version of the gui style you want. (Number Only)

		Title = "Panel", -- The main title shown at the top of the GUI
		Description = "Key System", -- The text shown below the title
		UseNonce = true, -- To prevent replay attacks and request tampering, default: false
		FileName = "Mykey.txt", -- The name of the file where the valid key will be saved for auto-login
		FolderName = UIFolder, -- The name of the folder where the key is stored

		ServiceId = 0, -- Your PlatoBoost Service ID
		PlatoSecret = "", -- Your PlatoBoost Secret Key

		-- [2] Anti-Bypass / Global Secret Variable
		Secret = "1234", -- This makes the script ONLY run from the key script. Even if they copy the original obfuscated script to bypass the key, they won't be able to!
		UseCheckExpired = false, -- TBH
		CheckExpiredDuration= 1200, -- TBH


		-- [3] Scripts & Links
		ShowScript = false, -- If you don't want to use the script URL, you can set this to false to want to disable the script from running on the client.
		ScriptURL = "", -- The raw URL of your main script.

		-- [4] Social Media Settings (Set to true to show,false to hide)
		ShowDiscord = false,
		DiscordURL = "https://discord.gg/kT55J724BK",

		ShowInstagram = false,
		InstagramURL = "https://www.instagram.com/oyb0i/",

		ShowYoutube=false,
		YoutubeURL = "https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

		-- [5] GUI Management
		Name = "Key", -- Name of the main script's GUI to check if it's already executing
		OldName = "Key-Old" -- Name of the old GUI to destroy if it's already open
	}

	for k,v in pairs(DefaultInfo) do if keyInfo[k]==nil then keyInfo[k]=v end end

	if keyInfo.Name~=DefaultInfo.Name and keyInfo.OldName==DefaultInfo.OldName then
		keyInfo.OldName=keyInfo.Name.."-Old"
	end

	keyInfo.Type="KeySystem" keyInfo.Pass=false keyInfo.Rejected=false keyInfo.Closed=false keyInfo.Parent=true keyInfo.WaitForKey=function() end keyInfo.Destroy=function() keyInfo.Parent=nil end

	-------------------------------------------------------------------------------
	--! Library Json and Cryptography
	-------------------------------------------------------------------------------
	local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;
	J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}
	local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string,got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
	local lEncode,lDecode,lDigest=a3,aw,Z;

	-------------------------------------------------------------------------------
	--! CORE FUNCTIONS (REQUESTS & VERIFICATION)
	-------------------------------------------------------------------------------

	--! configuration
	local KeyOption={
		FileName=keyInfo.FileName,
		FolderName=keyInfo.FolderName,
		ServiceId=keyInfo.ServiceId, -- your service id,this is used to identify your service.
		PlatoSecret=keyInfo.PlatoSecret, -- make sure to obfuscate this if you want to ensure security.
		UseNonce=keyInfo.UseNonce, -- Hidden from Config to avoid user confusion,but active for security and use a nonce to prevent replay attacks and request tampering.
		KeyCode=keyInfo.Code or keyInfo.Secret,
		GuiName=keyInfo.Name,
		OldGuiName=keyInfo.OldName,
	}
	if not KeyOption.FolderName or type(KeyOption.FolderName)~="string" then KeyOption.FolderName=UIFolder end

	--! functions
	local fStringChar,fToString,fStringSub,fOsTime,fMathRandom,fMathFloor,fGetHwid=string.char,tostring,string.sub,os.time,math.random,math.floor,gethwid or function() return LocalPlayer.UserId end
	local requestSending,cachedLink,cachedTime=false,"",0
	local host="https://api.platoboost.com"
	local verifyAccept,maxVerifyAccept=0,30

	-- Check server connectivity
	local checkConnectivity=function()
		local response=requestSafely({Url=host .. "/public/connectivity",Method="GET"})
		if not response or (response.StatusCode ~= 200 and response.StatusCode ~= 429) then
			host="https://api.platoboost.net"
		end
	end 

	checkConnectivity()

	local generateNonce=function()
		local str="" for _=1,16 do str=str .. fStringChar(fMathFloor(fMathRandom()*(122-97+1))+97) end return str
	end

	-- Get player's key link
	local cacheLink=function()
		if cachedTime+(10*60)<fOsTime() then
			local response=requestSafely({
				Url=host.."/public/start",
				Method="POST",
				Body=lEncode({
					service=KeyOption.ServiceId,
					identifier=lDigest(fGetHwid())
				}),
				Headers={
					["Content-Type"]="application/json"
				}
			})
			local message=""
			if response.StatusCode==200 then
				local decoded=lDecode(response.Body)
				if decoded.success==true then
					cachedLink=decoded.data.url
					cachedTime=fOsTime()
					return true,cachedLink
				else
					return false,decoded.message
				end
			elseif response.StatusCode==429 then
				return false,"you are being rate limited,please wait 20 seconds and try again."
			end
			return false,"Failed to cache link."
		else
			return true,cachedLink
		end
	end

	-- Redeem player's key
	local redeemKey=function(key)
		if not KeyOption.ServiceId or type(KeyOption.ServiceId)~="number" or KeyOption.ServiceId<=0 then
			local isKey=key==KeyOption.KeyCode
			return isKey,not isKey and "key is invalid." or nil
		end

		local textNonce=generateNonce()
		local endpoint=host.."/public/redeem/".. fToString(KeyOption.ServiceId)

		local body={
			identifier=lDigest(fGetHwid()),
			key=key
		}

		if KeyOption.UseNonce then
			body.nonce=textNonce
		end

		local response=requestSafely({
			Url=endpoint,
			Method="POST",
			Body=lEncode(body),
			Headers={
				["Content-Type"]="application/json"
			}
		})

		if response.StatusCode==200 then
			local decoded=lDecode(response.Body)
			if decoded.success==true then
				if decoded.data.valid==true then
					if KeyOption.UseNonce then
						if decoded.data.hash==lDigest("true" .. "-" .. textNonce .. "-" .. KeyOption.PlatoSecret) then
							return true
						else
							return false,"failed to verify integrity."
						end    
					else
						return true
					end
				else
					return false,"key is invalid."
				end
			else
				if fStringSub(decoded.message,1,27)=="unique constraint violation" then
					return false,"you already have an active key, please wait for it to expire before redeeming it."
				else
					return false,decoded.message
				end
			end
		elseif response.StatusCode==429 then
			return false,"you are being rate limited, please wait 20 seconds and try again."
		else
			return false,"server returned an invalid status code, please try again later."
		end
	end

	-- Get status key
	local getKeyStatus=function(key)
		if not KeyOption.ServiceId or type(KeyOption.ServiceId)~="number" or KeyOption.ServiceId<=0 then
			local isKey=key==KeyOption.KeyCode
			return isKey,not isKey and "key is invalid." or nil
		end
		if requestSending then return false end
		requestSending=true

		-- https://api.platoboost.com/public/whitelist/24751?identifier=1&key=FREE_5b87660dfa621fb65ca16cb570788e1e
		local textNonce=generateNonce()
		local endpoint=host .. "/public/whitelist/" .. fToString(KeyOption.ServiceId) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key

		if KeyOption.UseNonce then
			endpoint=endpoint .. "&nonce=" .. textNonce
		end

		local response=requestSafely({
			Url=endpoint,
			Method="GET",
		})
		local message=""
		requestSending=false

		if response.StatusCode==200 then
			local decoded=lDecode(response.Body)
			if decoded.success==true then
				if decoded.data.valid==true then
					if KeyOption.UseNonce then
						if decoded.data.hash==lDigest("true" .. "-" .. textNonce .. "-" .. KeyOption.PlatoSecret) then
							return true
						else
							return false,"failed to verify integrity."
						end
					else
						return true;
					end
				else
					if fStringSub(key,1,4)=="KEY_" then
						return true
					else
						return false,"key is invalid."
					end
				end
			else
				return false,decoded.message
			end
		elseif response.StatusCode==429 then
			return false,"you are being rate limited, please wait 20 seconds and try again."
		else
			return false,"server returned an invalid status code, please try again later."
		end
	end

	local getFlag=function(name)
		local textNonce=generateNonce()
		local endpoint=host.."/public/flag/".. fToString(KeyOption.ServiceId) .."?name="..name

		if KeyOption.UseNonce then
			endpoint=endpoint .. "&nonce=" .. textNonce
		end

		local response=requestSafely({
			Url=endpoint,
			Method="GET",
		})
		local message=""

		if response.StatusCode==200 then
			local decoded=lDecode(response.Body)
			if decoded.success==true then
				if KeyOption.UseNonce then
					if decoded.data.hash==lDigest(fToString(decoded.data.value) .. "-" .. textNonce .. "-" .. KeyOption.PlatoSecret) then
						return decoded.data.value
					else
						return nil,"failed to verify integrity."
					end
				else
					return decoded.data.value;
				end
			else
				return nil,decoded.message
			end
		else
			return nil,"server returned an invalid status code,please try again later."
		end
	end

	local CheckExpiredThread = nil

	local handleCheckExpired=function(key)
		if keyInfo.UseCheckExpired then
			CheckExpiredThread = task.spawn(function()
				while keyInfo.UseCheckExpired and LocalPlayer.Parent ~= nil and keyInfo.Pass == true do
					task.wait(keyInfo.CheckExpiredDuration)
					local isValid, errorMessage = getKeyStatus(key)
					if not isValid then
						if errorMessage~="you are being rate limited, please wait 20 seconds and try again." and errorMessage~="server returned an invalid status code, please try again later." then
							rejoinGame()
							break
						end
					end
				end
			end)
		end
	end

	-------------------------------------------------------------------------------
	--! GUI & MAIN SCRIPT EXECUTION
	-------------------------------------------------------------------------------

	local scriptInfo={Enabled=keyInfo.ShowScript,Link=keyInfo.ScriptURL or keyInfo.ScriptLink}

	local function loadScript()
		-- Set secret global variable to bypass main script protection
		pcall(function() getgenv()[KeyOption.KeyCode]=true end)
		-- Execute main script
		if scriptInfo.Enabled and scriptInfo.Link then pcall(function() loadstring(game:HttpGet(scriptInfo.Link))() end) end
	end

	ensureFolder(KeyOption.FolderName.."/Key System")

	-- Auto Check Saved Key
	if isfile and callSafely(isfile,KeyOption.FolderName.."/Key System".."/"..KeyOption.FileName) and readfile then
		local savedKey=callSafely(readfile,KeyOption.FolderName.."/Key System".."/"..KeyOption.FileName)
		if not Strs.isEmpty(savedKey) then
			local success=redeemKey(savedKey)
			if success then
				if not keyInfo.Pass then 
					keyInfo.Pass=true
					keyInfo:Destroy()
					if scriptInfo.Enabled and scriptInfo.Link then
						fastWait(2)
					end
					handleCheckExpired(savedKey)
					loadScript()
					return keyInfo
				end
			end
		end
	end

	-- Initialize Key System GUI
	local screenGui=create("ScreenGui",{
		Name=KeyOption.GuiName,
		ResetOnSpawn=false
	})

	local mainFrame=create("Frame",{
		Size=UDim2.new(0,340,0,420),
		Position=UDim2.new(0.5,-170,0.5,-210),
		BackgroundColor3=Color3.fromRGB(25,26,31),
		Active=true,
		Parent=screenGui
	})

	create("UICorner",{CornerRadius=UDim.new(0,15),Parent=mainFrame})

	local mainStroke=create("UIStroke",{
		Thickness=2,
		Color=Color3.fromRGB(40,40,40),
		Parent=mainFrame
	})

	-- Close Button
	local closeButton=create("TextButton",{
		Name="Close",
		Size=UDim2.new(0,30,0,30),
		Position=UDim2.new(1,-35,0,10),
		BackgroundTransparency=1,
		Text="X",
		TextColor3=Color3.fromRGB(255,50,50),
		Font=Enum.Font.GothamBold,
		TextSize=18,
		ZIndex=10,
		Parent=mainFrame
	})

	local title=create("TextLabel",{
		Name="Title",
		Size=UDim2.new(1,0,0,50),
		BackgroundTransparency=1,
		BackgroundColor3=Color3.fromRGB(255,255,255),
		Text=keyInfo.Title,
		TextColor3=Color3.fromRGB(0,170,255),
		Font=Enum.Font.GothamBold,
		TextSize=16,
		Parent=mainFrame
	})

	create("UICorner",{CornerRadius=UDim.new(0,15),Parent=title})

	local description=create("TextLabel",{
		Name="Description",
		Size=UDim2.new(0.9,0,0,50),
		Position=UDim2.new(0.05,0,0,50),
		BackgroundTransparency=1,
		Text=keyInfo.Description,
		TextColor3=Color3.fromRGB(0,170,255),
		Font=Enum.Font.GothamBold,
		TextSize=14,
		TextWrapped=true,
		Parent=mainFrame
	})

	-- Rainbow Stroke Function
	local function addRainbowStroke(parent)
		local stroke=create("UIStroke",{
			Thickness=2,
			ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
			Parent=parent
		})
		task.spawn(function()
			while keyInfo.Parent do
				fastWait()
				local hue=tick() % 5 / 5
				stroke.Color=Color3.fromHSV(hue,1,1)
			end
		end)
	end

	local keyCache={}
	local Status=nil

	-- Dynamic Positioning for elements
	local currentYOffset=105

	-- Discord Button
	local discordInfo={Enabled=keyInfo.ShowDiscord,Link=keyInfo.DiscordURL or keyInfo.DiscordLink}
	if discordInfo.Enabled and discordInfo.Link then
		local discordButton=create("TextButton",{
			Name="Discord",
			Size=UDim2.new(0.85,0,0,35),
			Position=UDim2.new(0.075,0,0,currentYOffset),
			Text="      JOIN DISCORD",
			Font=Enum.Font.GothamBlack,
			TextSize=14,
			BackgroundColor3=Color3.fromRGB(88,101,242),
			TextColor3=Color3.new(1,1,1),
			Parent=mainFrame
		})
		create("UICorner",{Parent=discordButton})
		addRainbowStroke(discordButton)
		create("ImageLabel",{
			Name="Icon",
			Size=UDim2.new(0,20,0,20),
			Position=UDim2.new(0.1,0,0.5,-10),
			BackgroundTransparency=1,
			Image="rbxassetid://18505728201",
			Parent=discordButton
		})
		keyCache.DiscordActivated=discordButton.MouseButton1Click:Connect(function()
			copyToClipboard(discordInfo.Link)

			if Status then
				Status.Text="Discord Link Copied!"
				Status.TextColor3=Color3.fromRGB(88,101,242)
			end
			-- Auto-extract invite code from config URL
			local inviteCode=string.match(discordInfo.Link,"discord%.gg/([%w-]+)")
			requestSafely({Url="http://localhost:1111/discord?invite=" .. inviteCode,Method="GET"})
		end)
		currentYOffset=currentYOffset+45
	end

	-- Instagram Button
	local instagramInfo={Enabled=keyInfo.ShowInstagram,Link=keyInfo.InstagramURL or keyInfo.InstagramLink}
	if instagramInfo.Enabled and instagramInfo.Link then
		local instagramButton=create("TextButton",{
			Name="Instagram",
			Size=UDim2.new(0.85,0,0,35),
			Position=UDim2.new(0.075,0,0,currentYOffset),
			Text="      FOLLOW INSTAGRAM",
			Font=Enum.Font.GothamBlack,
			TextSize=14,
			BackgroundColor3=Color3.fromRGB(88,101,242),
			TextColor3=Color3.new(1,1,1),
			Parent=mainFrame
		})
		create("UICorner",{Parent=instagramButton})
		addRainbowStroke(instagramButton)
		create("ImageLabel",{
			Name="Icon",
			Size=UDim2.new(0,20,0,20),
			Position=UDim2.new(0.1,0,0.5,-10),
			BackgroundTransparency=1,
			Image="rbxassetid://18355586382",
			Parent=instagramButton
		})
		keyCache.InstagramActivated=instagramButton.MouseButton1Click:Connect(function()
			copyToClipboard(instagramInfo.Link)
			if Status then 
				Status.Text="Instagram Link Copied!"
				Status.TextColor3=Color3.fromRGB(225,48,108)
			end
		end)
		currentYOffset=currentYOffset+45
	end

	-- YouTube Button
	local youtubeInfo={Enabled=keyInfo.ShowYoutube,Link=keyInfo.YoutubeURL or keyInfo.YoutubeLink}
	if youtubeInfo.Enabled and youtubeInfo.Link then
		local youtubeButton=create("TextButton",{
			Name="Youtube",
			Size=UDim2.new(0.85,0,0,35),
			Position=UDim2.new(0.075,0,0,currentYOffset),
			Text="      SUBSCRIBE YOUTUBE",
			Font=Enum.Font.GothamBlack,
			TextSize=14,
			BackgroundColor3=Color3.fromRGB(88,101,242),
			TextColor3=Color3.new(1,1,1),
			Parent=mainFrame
		})
		create("UICorner",{Parent=youtubeButton})
		addRainbowStroke(youtubeButton)
		create("ImageLabel",{
			Name="Icon",
			Size=UDim2.new(0,20,0,20),
			Position=UDim2.new(0.1,0,0.5,-10),
			BackgroundTransparency=1,
			Image="rbxassetid://82532989017804",
			Parent=youtubeButton
		})
		keyCache.YoutubeActivated=youtubeButton.MouseButton1Click:Connect(function()
			copyToClipboard(youtubeInfo.Link)
			local Status=mainFrame:FindFirstChild("Status")
			if Status then
				Status.Text="YouTube Link Copied!"
				Status.TextColor3=Color3.fromRGB(255,0,0)
			end
		end)
		currentYOffset=currentYOffset + 45
	end

	-- Key Input Box
	local keyInput=create("TextBox",{
		Name="InputBox",
		Size=UDim2.new(0.85,0,0,40),
		Position=UDim2.new(0.075,0,0,currentYOffset+15),
		PlaceholderText="Enter Key...",
		Text="",
		Font=Enum.Font.SourceSansBold,
		TextSize=14,
		BackgroundColor3=Color3.fromRGB(25,25,25),
		TextColor3=Color3.new(1,1,1),
		Parent=mainFrame
	})
	create("UICorner",{Parent=keyInput})

	local verifyButton=create("TextButton",{
		Name="Verify",
		Size=UDim2.new(0.4,0,0,40),
		Position=UDim2.new(0.075,0,0,currentYOffset+65),
		Text="VERIFY",
		Font=Enum.Font.GothamBlack,
		TextSize=14,
		BackgroundColor3=Color3.fromRGB(0,120,255),
		TextColor3=Color3.new(1,1,1),
		Parent=mainFrame
	})
	create("UICorner",{Parent=verifyButton})

	local getKeyButton=create("TextButton",{
		Name="Get",
		Size=UDim2.new(0.4,0,0,40),
		Position=UDim2.new(0.525,0,0,currentYOffset+65),
		Text="GET KEY",
		Font=Enum.Font.GothamBlack,
		TextSize=14,
		BackgroundColor3=Color3.fromRGB(35,35,35),
		TextColor3=Color3.new(1,1,1),
		Parent=mainFrame,
	})
	create("UICorner",{Parent=getKeyButton})

	Status=create("TextLabel",{
		Name="Status",
		Size=UDim2.new(1,0,0,30),
		Position=UDim2.new(0,0,0,currentYOffset+115),
		BackgroundTransparency=1,
		Text="Waiting for input...",
		TextColor3=Color3.fromRGB(150,150,150),
		Font=Enum.Font.Gotham,
		TextSize=12,
		Parent=mainFrame,
	})

	-- Dynamically adjust main frame height based on active elements
	mainFrame.Size=UDim2.new(0,340,0,currentYOffset+160)

	local cleanDraggable=Library:MakeDraggable(mainFrame,mainFrame)

	local protectGui=Library:GetProtectGui(screenGui)

	for _,interface in ipairs(protectGui:GetChildren()) do
		if interface.Name==KeyOption.GuiName and interface~=screenGui then
			interface.Enabled=false
			interface.Name=KeyOption.OldGuiName
		end
	end

	screenGui.Parent=protectGui

	local cleanResize=Library:SetAutoResizeGui(screenGui,{BaseX=baseX,BaseY=baseY})

	local SaveStatus={TextColor3=Status.TextColor3,Text=Status.Text}
	local LastStatus=SaveStatus.Text

	local applyKey=function(key)
		if keyInfo.Pass==true or keyInfo.Rejected==true or keyInfo.Closed==true or not keyInfo.Parent then return end
		if Strs.isEmpty(key) then 
			LastStatus="Enter a key!"
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(255,50,50)
			fastWait(2)
			if Status.Text==LastStatus then
				Status.Text=SaveStatus.Text
				Status.TextColor3=SaveStatus.TextColor3
			end
			return 
		end
		Status.Text="Verifying..."
		fastWait(1)
		local success,message=redeemKey(key)
		if success then
			if not keyInfo.Pass then 
				keyInfo.Pass=true
				if writefile then callSafely(writefile,KeyOption.FolderName.."/Key System".."/"..KeyOption.FileName,key) end
				LastStatus="Success! Loading..."
				Status.Text=LastStatus
				Status.TextColor3=Color3.fromRGB(0,255,100)
				fastWait(2)
				keyInfo:Destroy()
				handleCheckExpired(key)
				loadScript()
			end
		else
			if verifyAccept>=maxVerifyAccept then 
				keyInfo.Rejected=true
				LastStatus="Now you are rejected for this"
				Status.Text=LastStatus
				Status.TextColor3=Color3.fromRGB(255,50,50)
				fastWait(2)
				keyInfo:Destroy()
				return
			end
			verifyAccept+=1
			LastStatus=message
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(255,50,50)
			fastWait(2)
		end
		if Status.Text==LastStatus then
			Status.Text=SaveStatus.Text
			Status.TextColor3=SaveStatus.TextColor3
		end
	end

	function keyInfo:WaitForKey()
		repeat fastWait() until keyInfo.Pass==true or keyInfo.Rejected==true or keyInfo.Closed==true
	end

	keyInfo.Parent=true

	local cleanDestroying=nil

	function keyInfo:Destroy()
		if not keyInfo.Parent then return end
		keyInfo.Parent=nil
		if cleanDestroying then cleanDestroying() end
		cleanResize()
		cleanDraggable()
		screenGui.Name=KeyOption.OldGuiName
		screenGui.Enabled=false
		local k,v=next(keyCache)
		while v do
			keyCache[k]=nil
			v:Disconnect()
			k,v=next(keyCache)
		end
	end

	keyInfo.Gui=screenGui

	-- Logic
	keyCache.CloseActivated=closeButton.Activated:Connect(function() 
		task.delay(3,function()
			if not keyInfo.Pass and CheckExpiredThread~=nil and coroutine.status(CheckExpiredThread) ~= "dead" then
				task.cancel(CheckExpiredThread)
			end
		end)
		keyInfo.Closed=true 
		keyInfo:Destroy() 
	end)
	keyCache.FocusLost=keyInput.FocusLost:Connect(function(enter)
		if not enter then return end
		applyKey(keyInput.Text)
	end)
	keyCache.VerifyActivated=verifyButton.Activated:Connect(function()
		applyKey(keyInput.Text)
	end)
	keyCache.GetKeyActivated=getKeyButton.Activated:Connect(function()
		Status.Text="Getting Link..."
		local success,response=cacheLink()
		if success then
			copyToClipboard(response)
			LastStatus="Link Copied!"
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(0,170,255)
			fastWait(2)
		else
			LastStatus="Error: ".. tostring(response)
			Status.Text=LastStatus
			Status.TextColor3=Color3.fromRGB(255,50,50)
			fastWait(2)
		end
		if Status.Text==LastStatus then
			Status.Text=SaveStatus.Text
			Status.TextColor3=SaveStatus.TextColor3
		end
	end)

	cleanDestroying=connectDestroying(screenGui,screenGui.Name,function()
		keyInfo:Destroy()
	end)

	return setmetatable({},{
		__index=function(this,key)
			local value=keyInfo[key]
			if value~=nil then return value end
			return nil
		end
	})
end

function Library:CreateWindow(config)
	if config and type(config)=="string" then
		config={Name=config}
	end
	config=typeof(config)=="table" and config or {}

	local Window={}
	if config.Name~=nil then
		Window.Name=config.Name.."_Sampluy"
	else
		Window.Name="Sampluy"
	end
	Window.OldName=config.Name.."-Old"
	Window.SaveName=Window.Name
	Window.Text=config.Text or config.Title or config.Name or "Panel"
	Window.MaxHeight=config.MaxHeight or 320
	Window.Size=config.Size or UDim2.new(0,230,0,40)
	Window.Open=config.Open or true
	Window.Destroying=config.Destroying or nil
	Window.Style = config.Style or "Crokyreo"
	Window.AutoMaxHeight = config.AutoMaxHeight or true
	Window.TabIcon = config.TabIcon or "controller"

	local gui=create("ScreenGui",{
		Name=Window.Name,
		ResetOnSpawn=false
	})

	local protectGui=Library:GetProtectGui(gui)

	for _,interface in ipairs(protectGui:GetChildren()) do
		if interface.Name==Window.Name and interface~=gui then
			interface.Enabled=false
			interface.Name=Window.OldName
		end
	end

	gui.Parent=protectGui

	local mainFrame=create("ImageLabel",{
		Name="Main",
		BackgroundTransparency=1,
		BorderSizePixel=0,
		Size=Window.Size,
		Position=UDim2.new(0,20,0,20),
		Image="rbxassetid://3570695787",
		ImageColor3=Color3.fromRGB(10,10,10),
		ScaleType=Enum.ScaleType.Slice,
		SliceCenter=Rect.new(100,100,100,100),
		SliceScale=0.04,
		ClipsDescendants=true,
		Parent=gui
	})

	for _,interface in ipairs(protectGui:GetChildren()) do
		if interface~=gui then
			for _,lastMainFrame in ipairs(interface:GetChildren()) do
				if lastMainFrame.ClassName=="ImageLabel" and lastMainFrame.Name=="Main" and isUIOverlapping(mainFrame,lastMainFrame) then
					lastMainFrame.Position=mainFrame.Position+OFFSET
				end
			end
		end
	end

	local titleBar=create("TextLabel",{
		Name="Title",
		Size=UDim2.new(1,0,0,40),
		BackgroundTransparency=1,
		BorderSizePixel=0,
		Text=Window.Text,
		TextColor3=Theme.Text,
		Font=Enum.Font.LuckiestGuy,
		TextSize=12,
		Parent=mainFrame
	})

	local closeHolder=create("Frame",{
		Name="Close",
		Position=UDim2.new(1,0,0,0),
		Size=UDim2.new(-1,0,1,0),
		SizeConstraint=Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency=1,
		Parent=titleBar
	})

	local close=create("ImageLabel",{
		Name="Icon",
		AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0.5,0,0.5,0),
		Size=UDim2.new(1,-Window.Size.Y.Offset-10,1,-Window.Size.Y.Offset-10),
		BackgroundTransparency=1,
		Rotation=Window.Open and 90 or 180,
		Image="rbxassetid://4918373417",
		ImageColor3=Color3.fromRGB(255,255,255),
		ScaleType=Enum.ScaleType.Fit,
		Parent=closeHolder
	})

	local scrollFrame=create("ScrollingFrame",{
		Size=UDim2.new(1,0,0,0),
		Position=UDim2.new(0,0,0,40),
		BackgroundTransparency=0,
		BackgroundColor3=Color3.fromRGB(20,20,20),
		BorderSizePixel=0,
		ScrollBarThickness=4,
		ScrollBarImageColor3=Color3.fromRGB(100,100,110),
		ClipsDescendants=true,
		CanvasSize=UDim2.new(0,0,0,0),
		Parent=mainFrame
	})

	local contentHolder=create("Frame",{
		AnchorPoint=Vector2.new(0.5,0),
		Size=UDim2.new(1,-16,0,0),
		Position=UDim2.new(0.5,0,0,0),
		AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundTransparency=1,
		Parent=scrollFrame
	})

	create("UIListLayout",{
		Parent=contentHolder,
		Padding=UDim.new(0,6),
		HorizontalAlignment=Enum.HorizontalAlignment.Center,
		SortOrder=Enum.SortOrder.LayoutOrder
	})

	local savedMaxHeight = Window.MaxHeight

	local function updateWindowSize(animated)
		local screenType = getScreenType()

		if Window.AutoMaxHeight or savedMaxHeight == 320 then
			if screenType == "720p" or screenType == "1280x500" then
				Window.MaxHeight = 450
			elseif screenType == "1080p" then
				Window.MaxHeight = 500
			elseif screenType == "4K" then
				Window.MaxHeight = 600
			else
				Window.MaxHeight = 320
			end
		end

		local contentHeight=contentHolder.AbsoluteSize.Y
		local targetMainSize,targetScrollSize

		if not Window.Open then
			targetMainSize=Window.Size
			targetScrollSize=UDim2.new(1,0,0,0)
		else
			local allowedContentHeight=math.min(contentHeight+6,Window.MaxHeight-Window.Size.Y.Offset)
			targetMainSize=UDim2.new(Window.Size.X.Scale,Window.Size.X.Offset,Window.Size.Y.Scale,Window.Size.Y.Offset+allowedContentHeight)
			targetScrollSize=UDim2.new(1,0,0,allowedContentHeight)
		end

		if animated then
			tween(mainFrame,TweenCache.Default,{Size=targetMainSize})
			tween(scrollFrame,TweenCache.Default,{Size=targetScrollSize})
		else
			mainFrame.Size=targetMainSize
			scrollFrame.Size=targetScrollSize
		end
	end

	local absoluteSizeChanged=contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		scrollFrame.CanvasSize=UDim2.new(0,0,0,contentHolder.AbsoluteSize.Y+6)
		updateWindowSize(true)
	end)

	local inputBegan=closeHolder.InputBegan:connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			Window.Open=not Window.Open
			tween(close,TweenCache.Default,{Rotation=Window.Open and 90 or 180})
			updateWindowSize(true)
		end
	end)

	local cleanDraggable=Library:MakeDraggable(titleBar,mainFrame)

	Window.Main=mainFrame
	Window.Container=contentHolder
	Window.Gui=gui
	Window.TabButtons={}
	Window.TabPages={contentHolder}
	Window.Parent=true

	function Window:Destroy()
		if not self.Parent then return end
		self.Parent=nil
		callSafely(self.Destroying)
		absoluteSizeChanged:Disconnect()
		inputBegan:Disconnect()
		cleanDraggable()
		self.Open=false
		if self.Gui.Parent then
			tween(close,TweenCache.Default,{Rotation=180})
			updateWindowSize(false)
			self.Gui.Enabled=false
			self.Gui.Name=self.OldName or self.GuiName.."-Old"
		end
	end

	connectDestroying(Window.Gui,Window.SaveName,function()
		Window:Destroy()
	end)

	function Window:CreateTab(options)
		options=missing("table",options,{})
		options.Icon=options.Icon or options.Image or ""
	end

	local baseComponents=getComponents(Window)
	for k,v in next,baseComponents do
		Window[k]=v
	end

	return Window
end

function Library:Notify(data)
	data = (data ~= nil and typeof(data) == "table") and data or {}
	local title, description, duration, icon = data.Title or data.Text, data.Description or data.Context, data.Duration or data.Cooldown or 25, data.Icon or data.Image or "rbxassetid://0"
	local protectGui = Library:GetProtectGui()
	local notificationGui = Library.Notifications
	if not notificationGui then
		for _,interface in ipairs(protectGui:GetChildren()) do
			if interface.Name=="ProtectNotification" and interface.ClassName == "ScreenGui" then
				if not notificationGui then
					for _,frame in ipairs(interface:GetChildren()) do
						if frame.Name == "Notifications" and frame.ClassName == "Frame" then
							local uiListLayout = frame:FindFirstChildOfClass("UIListLayout")
							local uiPadding = frame:FindFirstChildOfClass("UIPadding")
							if uiListLayout and uiPadding then
								notificationGui = interface
								break
							end
						end
					end
				end
				if notificationGui then
					break
				end
			end
		end
		Library.Notifications = notificationGui
	end
	local notificationFrame = nil
	if not notificationGui then
		notificationGui = create("ScreenGui", {
			Name = "ProtectNotification",
			ResetOnSpawn = false,
		})

		notificationFrame=create("Frame", {
			Name = "Notifications",
			Size=UDim2.new(0,320,1,0),
			Position=UDim2.new(1,-340,0,0),
			BackgroundTransparency=1,
			Parent=notificationGui
		})

		create("UIListLayout", {
			SortOrder=Enum.SortOrder.LayoutOrder,
			VerticalAlignment=Enum.VerticalAlignment.Bottom,
			Padding=UDim.new(0,10),
			Parent=notificationFrame
		})

		create("UIPadding", {
			PaddingBottom=UDim.new(0,20),
			Parent=notificationFrame
		})

		protectGui = Library:GetProtectGui(notificationGui)
		notificationGui.Parent = protectGui
	else
		notificationFrame=notificationGui:FindFirstChild("Notifications")
	end
	local lIIIll=Instance.new("Frame")
	lIIIll.Size=UDim2.new(1,0,0,80)
	lIIIll.BackgroundTransparency=1;
	lIIIll.Parent=notificationFrame;
	local IlllII=Instance.new("Frame")
	IlllII.Size=UDim2.new(1,0,1,0)
	IlllII.Position=UDim2.new(1.2,0,0,0)
	IlllII.BackgroundColor3=Color3.fromRGB(30,30,30)
	IlllII.BorderSizePixel=0;
	IlllII.Parent=lIIIll;
	local lIlIlI=Instance.new("UICorner")
	lIlIlI.CornerRadius=UDim.new(0,8)
	lIlIlI.Parent=IlllII;
	local IIlIIl=Instance.new("ImageLabel")
	IIlIIl.Size=UDim2.new(0,60,0,60)
	IIlIIl.Position=UDim2.new(0,10,0,10)
	IIlIIl.BackgroundTransparency=1;
	if icon ~= nil then
		local iconId = tonumber(icon)
		if iconId and iconId > 0 then 
			IIlIIl.Image="rbxassetid://"..iconId 
		elseif not iconId and typeof(icon) == "string" then
			IIlIIl.Image=icon
		end
	else
		IIlIIl.Image="rbxassetid://0"
	end
	IIlIIl.Parent=IlllII;
	local IIllll=Instance.new("TextLabel")
	IIllll.Size=UDim2.new(1,-110,0,20)
	IIllll.Position=UDim2.new(0,80,0,10)
	IIllll.BackgroundTransparency=1;
	IIllll.Text=title;
	IIllll.TextColor3=Color3.fromRGB(255,255,255)
	IIllll.TextSize=16;
	IIllll.Font=Enum.Font.GothamBold;
	IIllll.TextXAlignment=Enum.TextXAlignment.Left;
	IIllll.Parent=IlllII;
	local IlIIlI=Instance.new("TextLabel")
	IlIIlI.Size=UDim2.new(1,-90,0,40)
	IlIIlI.Position=UDim2.new(0,80,0,30)
	IlIIlI.BackgroundTransparency=1;
	IlIIlI.Text=description;
	IlIIlI.TextColor3=Color3.fromRGB(200,200,200)
	IlIIlI.TextSize=14;
	IlIIlI.Font=Enum.Font.Gotham;
	IlIIlI.TextXAlignment=Enum.TextXAlignment.Left;
	IlIIlI.TextWrapped=true;
	IlIIlI.Parent=IlllII;
	local lIlIll=Instance.new("TextButton")
	lIlIll.Size=UDim2.new(0,24,0,24)
	lIlIll.Position=UDim2.new(1,-30,0,8)
	lIlIll.BackgroundTransparency=1;
	lIlIll.Text="X";
	lIlIll.TextColor3=Color3.fromRGB(255,80,80)
	lIlIll.TextSize=18;
	lIlIll.Font=Enum.Font.GothamBold;
	lIlIll.Parent=IlllII;
	local IIIlll=TweenService:create(IlllII,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
	IIIlll:Play()
	local timeoutThread = nil
	local function OnFinished()
		lIlIll.Active=false;
		if timeoutThread and coroutine.status(timeoutThread)~="dead" then
			task.cancel(timeoutThread)
			timeoutThread = nil
		end
		local IIlIII=TweenService:create(IlllII,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(1.2,0,0,0)})
		IIlIII:Play()
		IIlIII.Completed:Wait()
		local lIllIl=TweenService:create(lIIIll,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,0)})
		lIllIl:Play()
		lIllIl.Completed:Wait()
		lIIIll:Destroy()
	end
	if duration>0 then
		task.delay(duration, OnFinished)
	end
	lIlIll.MouseButton1Click:Connect(OnFinished)
end

Services.UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		if Library.ActivePopup and Library.ActivePopup.MainHolder then
			if input.Position.X<Library.ActivePopup.MainHolder.AbsolutePosition.X or input.Position.Y<Library.ActivePopup.MainHolder.AbsolutePosition.Y then
				Library.ActivePopup:Close()
			end
		end
		if Library.ActivePopup and Library.ActivePopup.MainHolder  then
			if input.Position.X>Library.ActivePopup.MainHolder.AbsolutePosition.X+Library.ActivePopup.MainHolder.AbsoluteSize.X or input.Position.Y>Library.ActivePopup.MainHolder.AbsolutePosition.Y+Library.ActivePopup.MainHolder.AbsoluteSize.Y then
				Library.ActivePopup:Close()
			end
		end
	end
end)

return Library
