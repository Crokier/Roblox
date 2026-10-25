--                         This was made by Crokyreo 
-- Instal V80 04-05-2024

local PLUGIN_NAME='Instal'
local MAX_CAP=math.huge

local Missing=function(t,v,f) return type(v)==t and v or f end
setclipboard,cloneref=Missing('function',setclipboard,function(text) warn(text) end),Missing('function',cloneref,function(v) return v end)

local Services=setmetatable({},{__index=function(self,i) local service=cloneref and cloneref(game:GetService(i)) or game:GetService(i) self[service]=service return service end})
local Workspace,Players,UserInputService,RunService,ReplicatedFirst,ReplicatedStorage,SoundService,Lighting,Teams,InsertService,StarterGui,StarterPack,HttpService=Services.Workspace,Services.Players,Services.UserInputService,Services.RunService,Services.ReplicatedFirst,Services.ReplicatedStorage,Services.SoundService,Services.Lighting,Services.Teams,Services.InsertService,Services.StarterGui,Services.StarterPack,Services.HttpService
local Window=nil

local LocalPlayer=Players.LocalPlayer

local Tabler=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Tabler/init.luau'))()
local Instancer=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Instancer/init.luau'))()
local Strs=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Strs/init.luau'))()
local UI=loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau'))()

task.delay(5,function()
	if LocalPlayer.AccountAge>=1000 then
		UI:Notify({
			Title=''..PLUGIN_NAME..' Warning ',
			Description='This script is dangerous! Please make alt account only!',
			Duration=10,
			Icon = 'rbxassetid://9072920609',
		})
	end
end)

local PlayerGui=LocalPlayer:FindFirstChildOfClass('PlayerGui')

local Values={
	['Inf']=math.huge,
	['DefaultCFrame']=CFrame.new(),
	['FolderName']='Instal',
	['SaveDebounce']=false,['TargetDebounce']=false,['RecordDebounce']=false,['Debounce']=false,
	['BuildingIndex']=0,['TotalBuilding']=0,
	['GrabType']='None',
	['LastStatus']='',
	['BuildingTarget']=nil,['InstalTarget']=nil,['GuiTarget']=nil,['ToolTarget']=nil,['GrabberModel']=nil,
	['Destroyed']=false,
	['MaxSound']=200,
	['MaxIcon']=100,
	['NoName']=false,
	['FileName']='',
	['CanAutoSaveFile']=false,
	['RecordAnimType']='Auto',['FPSType']='12 FPS',['AnimationName']='',['AnimationPriority']='Idle',['PlayAnimationCache']={},
	['UseMyself']=false,
	['CanShutdown']=false,
	['CanWrapText']=true,
}

local Templates={
	['SurfaceAppearance']=Instance.new('SurfaceAppearance')
}

local Interfaces={
	['TopSelect']=nil,
	['StatusLabel']=nil,
	['LoaderLabel']=nil,
	['ResetButton']=nil,
	['DestroyButton']=nil,
	['AddButton']=nil,
	['nitializeButton']=nil,
	['InstalButton']=nil,
	['TextBox']=nil,
	['StopButton']=nil,
	['GrabTypeSelector']=nil,
	['AnimationTitle']=nil,
	['AnimationSelector']=nil,
	['FPSTitle']=nil,
	['FPSSelector']=nil,
	['SoundSlider']=nil,
	['AnimationPriorityTitle']=nil,
	['AnimationPrioritySelector']=nil,
	['UseNameToggle']=nil,
	['UseMyselfToggle']=nil,
	['CanShutdownToggle']=nil,
	['CanWrapText']=false

}

local Utility={}
Utility={
	-- Instancer --
	IsAs=Instancer.IsAs,
	CopyInstanceWith=Instancer.CopyInstanceWith,
	CopyInstance=Instancer.CopyInstance,
	GetInstanceProperty=Instancer.GetInstanceProperty,
	CreateVariable=function(instance,options)
		if options.Duplicated==nil then
			options.Duplicated={}
		end
		if options.Variables==nil then
			options.Variables={}
		end
		local currentName=instance.Name
		-- Remove symbols
		local nameWithoutSymbols=''
		for v in string.gmatch(currentName,'[%w_]') do 
			nameWithoutSymbols=nameWithoutSymbols .. v 
		end
		-- Check for string
		local baseName=''
		if #nameWithoutSymbols=='0' then
			baseName=instance.ClassName
		elseif string.find(string.sub(nameWithoutSymbols,1,1),'%d') then
			baseName='_' .. nameWithoutSymbols
		else
			baseName=nameWithoutSymbols
		end
		
		if not options.Duplicated[baseName] then
			options.Duplicated[baseName]=1
			options.Variables[instance]=baseName
			return
		end
		options.Duplicated[baseName]+=1
		local count=options.Duplicated[baseName]
		local mainBaseName=baseName .. '_' .. tostring(count)
		options.Variables[instance]=mainBaseName
	end,
	ConvertMeshPartToSpecialMesh=Instancer.ConvertMeshPartToSpecialMesh,
	SetChildrenParent=Instancer.SetChildrenParent,
	GetAncestorsAndSelf=Instancer.GetAncestorsAndSelf,
	Create=Instancer.Create,
	-- Strs --
	IsEmpty=Strs.IsEmpty,
	IsStrings=Strs.IsStrings,
	GetLines=Strs.GetLines,
	ToPersentase=Strs.ToPersentase,
	ToNumber=Strs.ToNumber,
	Trim=Strs.Trim,
	FastFind=function(s,pattern)
		return string.find(s,pattern,1,true)
	end,
	-- Tabler --
	GetProperties=Tabler.GetProperties,
	Foreach=function(t,func)
		while #t>0 do
			local v=table.remove(t)
			func(v)
		end
	end,
	IsEnums=function(enum1,enum2)
		for i,v in ipairs(enum2) do if enum1==v then return true end end return false
	end
}

local Cacheds={}
local Outliner=Instance.new('SelectionBox') Outliner.Name='Selection' Outliner.Color3=Color3.fromRGB(25,153,255) Outliner.LineThickness=0.1 Outliner.SurfaceColor3=Color3.fromRGB(255,255,255) Outliner.SurfaceTransparency=1 Outliner.Transparency=0 Outliner.Adornee=nil Outliner.Visible=false

local GlobalData={
	['Locals']={
		['Instance']={
			['Prefix']='e',
			['Value']='Instance.new'
		},
		['Color3']={
			['Prefix']='frRGB',
			['Value']='Color3.fromRGB'
		},
		['Vector2']={
			['Prefix']='V2',
			['Value']='Vector2.new'
		},
		['Vector3']={ 
			['Prefix']='V3',
			['Value']='Vector3.new'
		},
		['Vector4']={ 
			['Prefix']='V4',
			['Value']='Vector4.new'
		},
		['CFrame']={
			['Prefix']='CF',
			['Value']='CFrame.new'
		},
		['UDim2']={
			['Prefix']='UD2',
			['Value']='UDim2.new'
		},
		['UDim']={
			['Prefix']='UD',
			['Value']='UDim.new'
		},
		['BrickColor']={
			['Prefix']='BC',
			['Value']='BrickColor.new'
		},
		['Rect2D']={
			['Prefix']='R2D',
			['Value']='Rect.new'
		},
		['Font']={
			['Prefix']={
				'Fnt',
				'FfrId',
				'FfrName'
			},
			['Value']={
				'Font.new',
				'Font.fromId',
				'Font.fromName',
			},
			['Length']=3
		},
		['NumberRange']={
			['Prefix']='NR',
			['Value']='NumberRange.new'
		},
		['FloatRange']={
			['Prefix']='FR',
			['Value']='FloatRange.new'
		},
		['PhysicalProperties']={
			['Prefix']='PhyProp',
			['Value']='PhysicalProperties.new'
		},
		['ColorSequence']={
			['Prefix']='CSeq',
			['Value']='ColorSequence.new'
		},
		['NumberSequence']={
			['Prefix']='NSeq',
			['Value']='NumberSequence.new'
		},
		['FloatSequence']={
			['Prefix']='FSeq',
			['Value']='FloatSequence.new'
		},
		['ColorSequenceKeypoint']={
			['Prefix']='CSeqKey',
			['Value']='ColorSequenceKeypoint.new'
		},
		['NumberSequenceKeypoint']={
			['Prefix']='NSeqKey',
			['Value']='NumberSequenceKeypoint.new'
		},
		['FloatSequenceKeypoint']={
			['Prefix']='FSeqKey',
			['Value']='FloatSequenceKeypoint.new'
		}
	},
	['Fonts']={
		Akronim=12187368317,
		AreYouSerious=12187363616,
		Audiowide=12187360881,
		Barlow=12187372847,
		Barrio=12187371991,
		Blaka=12187365104,
		BungeeInline=12187370000,
		BungeeShade=12187367666,
		CaesarDressing=12187368843,
		Cairo=12187377099,
		Caveat=12187369802,
		Codystar=12187363887,
		Damion=12187607722,
		DancingScript=8764312106,
		Eater=12187372382,
		FasterOne=12187370928,
		FingerPaint=12187375716,
		FiraSans=12187374954,
		Frijole=12187375194,
		FuzzyBubbles=11322590111,
		GreatVibes=12187375958,
		Hind=12187361116,
		HindSiliguri=12187361378,
		IBMPlexSansJP=12187364147,
		Inter=12187365364,
		IrishGrover=12187376910,
		Italianno=12187374273,
		Kanit=12187373592,
		Kings=12187371622,
		LaBelleAurore=12187607116,
		Lato=11598289817,
		LibreBaskerville=12187365769,
		Lobster=8836875837,
		Lora=12187366657,
		MPLUSRounded1c=12188570269,
		Marhey=12187364648,
		Monofett=12187606783,
		Monoton=12187374098,
		Montserrat=11702779517,
		Mukta=12187365559,
		Mulish=12187372629,
		NanumGothic=12187361718,
		Nosifer=12187377325,
		NothingYouCouldDo=12187367901,
		NotoSans=12187370747,
		NotoSansHK=12187362892,
		NotoSerifHK=12187366846,
		NotoSerifJP=12187369639,
		NotoSerifSC=12187376739,
		NotoSerifTC=12187368093,
		NunitoSans=12187363368,
		OpenSans=11598121416,
		PTSans=12187606934,
		PTSerif=12187606624,
		Pacifico=12187367362,
		Parisienne=12187361943,
		PlayfairDisplay=12187374765,
		Poppins=11702779409,
		Prompt=12187607287,
		Quicksand=12187371324,
		Rajdhani=12187375422,
		Raleway=11702779240,
		RobotoSlab=12187368625,
		Rubik=12187365977,
		RubikBurned=12187363148,
		RubikIso=12187362120,
		RubikMarkerHatch=12187367066,
		RubikMaze=12187366475,
		RubikWetPaint=12187369046,
		Rye=12187372175,
		SedgwickAveDisplay=12187376357,
		ShadowsIntoLight=12187607493,
		Silkscreen=12187371840,
		Sono=12187374537,
		SonoMonospace=12187362578,
		Tajawal=12187377588,
		Tangerine=12187376545,
		Teko=12187376174,
		UnicaOne=12187364842,
		WorkSans=12187373327,
		Yellowtail=12187373881
	},
	['Explorers']={
		['Event']={Workspace,ReplicatedStorage,ReplicatedFirst},
		['Lighting']={Lighting},
		['GuiColor']={PlayerGui,ReplicatedStorage},
		['Effect']={Workspace,ReplicatedStorage},
		['Name']={Workspace,ReplicatedStorage,Players,Teams,ReplicatedFirst,StarterPack},
		['Icon']={Workspace,ReplicatedStorage,PlayerGui,Teams,ReplicatedFirst}
	},
	['Types']={
		['GrabTypes']={'None','Building','Gui','Lighting','Sound','Tool','Icon','GuiIcon','MouseIcon','Animation','Team','Event','Texture','Decal','Beam','Trail','Name','GuiColor','PartColor','Settings'},
		['BannedGrabTypes']={'None','Animation'},
		['RecordAnimTypes']={'Auto','Motor6D','Bone'},
		['FPSTypes']={'12 FPS','24 FPS','30 FPS','60 FPS','120 FPS','240 FPS','Unlimited'},
		['NumericTypes']={'1','2','3','4','5','6','7','8','9','0'},
		['PacketClasses']={'RemoteEvent','RemoteFunction','BindableEvent','BindableFunction','UnreliableRemoteEvent'},
		['LightingClasses']={'Sky','BloomEffect','ColorCorrectionEffect','SunRaysEffect','Atmosphere','BlurEffect'},
		['UIClasses']={'BackgroundColor3','ImageColor3','BorderColor3','Color','Color3','Value','BrickColor'},
		['ColorProperties']={'BackgroundColor3','ImageColor3','BorderColor3','Color','Color3','Value','BrickColor'},
		['IconProperties']={'Texture','Icon','TextureId','Image','HoverImage'},
		['TextProperties']={'Name','Value','Message','Text','Print','DisplayName'},
		['AnimationPriority']={}
	},
	['Propertys']={},
	['FPSRates']={
		['12 FPS']=1/12,
		['24 FPS']=1/24,
		['30 FPS']=1/30,
		['60 FPS']=1/60,
		['120 FPS']=1/120,
		['240 FPS']=1/240,
	}
}

GlobalData.Propertys.Constraint=[[
Attachment
	bool Archivable
	string Name
	Object Parent
	bool Visible
	Vector3 Position
	Vector3 Orientation
SpringConstraint
	bool Archivable
	string Name
	Object Parent
	number Coils
	BrickColor Color
	number Radius
	number Thickness
	bool Visible
	bool Enabled
	Object Attachment0
	Object Attachment1
	number Damping
	number FreeLength
	bool LimitsEnabled
	number MaxLength
	number MaxLength
	number MaxForce
	number Stiffness
Weld
	bool Archivable
	string Name
	Object Parent
	CFrame C0
	CFrame C1
	Object Part0
	Object Part1
	bool Enabled
WeldConstraint
	bool Archivable
	string Name
	Object Parent
	Object Part0
	Object Part1
	bool Enabled
]]

GlobalData.Propertys.Gui=[[
ScreenGui
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ LayerCollector ]
	bool Enabled
	ZIndexBehavior ZIndexBehavior
-	[ ScreenGui ]
	int DisplayOrder
	bool ResetOnSpawn
BillboardGui
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ LayerCollector ]
	bool Enabled
	ZIndexBehavior ZIndexBehavior
-	[ BillboardGui ]
	bool Active
	Object Adornee
	bool AlwaysOnTop
	Vector3 ExtentsOffset
	Vector3 ExtentsOffsetWorldSpace
	float LightInfluence
	float MaxDistance
	Object PlayerToHideFrom
	UDim2 Size
	Vector2 SizeOffset
	Vector3 StudsOffset
	Vector3 StudsOffsetWorldSpace
Frame
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	EnumItem BorderMode
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ Frame ]
	FrameStyle Style
ImageButton
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	EnumItem BorderMode
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ GuiButton ]
	bool AutoButtonColor
	bool Modal
	bool Selected
	ButtonStyle Style
-	[ ImageButton ]
	Content Image
	Color3 ImageColor3
	Vector2 ImageRectOffset
	Vector2 ImageRectSize
	float ImageTransparency
	ScaleType ScaleType
	Rect2D SliceCenter
	float SliceScale
	UDim2 TileSize
ImageLabel
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	EnumItem BorderMode
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ ImageLabel ]
	Content Image
	Color3 ImageColor3
	Vector2 ImageRectOffset
	Vector2 ImageRectSize
	float ImageTransparency
	ScaleType ScaleType
	Rect2D SliceCenter
	float SliceScale
	UDim2 TileSize
ScrollingFrame
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	EnumItem BorderMode
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ ScrollingFrame ]
	EnumItem AutomaticCanvasSize
	Content BottomImage
	Vector2 CanvasPosition
	UDim2 CanvasSize
	EnumItem ElasticBehavior
	EnumItem HorizontalScrollBarInset
	Content MidImage
	Color3 ScrollBarImageColor3
	number ScrollBarImageTransparency
	int ScrollBarThickness
	EnumItem ScrollingDirection
	bool ScrollingEnabled
	Content TopImage
	EnumItem VerticalScrollBarInset
	EnumItem VerticalScrollBarPosition
SurfaceGui
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ LayerCollector ]
	bool Enabled
	ZIndexBehavior ZIndexBehavior
-	[ SurfaceGui ]
	bool Active
	Object Adornee
	bool AlwaysOnTop
	Vector2 CanvasSize
	NormalId Face
	float LightInfluence
	float ToolPunchThroughDistance
	float ZOffset
TextBox
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	EnumItem BorderMode
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ TextBox ]
	bool ClearTextOnFocus
	Font FontFace
	float LineHeight
	bool MultiLine
	Color3 PlaceholderColor3
	string PlaceholderText
	bool ShowNativeInput
	string Text
	Color3 TextColor3
	bool TextScaled
	float TextSize
	Color3 TextStrokeColor3
	float TextStrokeTransparency
	float TextTransparency
	bool TextWrapped
	TextXAlignment TextXAlignment
	TextYAlignment TextYAlignment
TextButton
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	EnumItem BorderMode
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ GuiButton ]
	bool AutoButtonColor
	bool Modal
	bool Selected
	ButtonStyle Style
-	[ TextButton ]
	Font FontFace
	float LineHeight
	string Text
	Color3 TextColor3
	bool TextScaled
	float TextSize
	Color3 TextStrokeColor3
	float TextStrokeTransparency
	float TextTransparency
	bool TextWrapped
	TextXAlignment TextXAlignment
	TextYAlignment TextYAlignment
TextLabel
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ GuiObject ]
	bool Active
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	float BackgroundTransparency
	Color3 BorderColor3
	EnumItem BorderMode
	int BorderSizePixel
	bool ClipsDescendants
	bool Draggable
	int LayoutOrder
	Object NextSelectionDown
	Object NextSelectionLeft
	Object NextSelectionRight
	Object NextSelectionUp
	UDim2 Position
	float Rotation
	bool Selectable
	Object SelectionImageObject
	UDim2 Size
	SizeConstraint SizeConstraint
	bool Visible
	int ZIndex
	bool ClipsDescendants
-	[ TextLabel ]
	Font FontFace
	float LineHeight
	string Text
	Color3 TextColor3
	bool TextScaled
	float TextSize
	Color3 TextStrokeColor3
	float TextStrokeTransparency
	float TextTransparency
	bool TextWrapped
	TextXAlignment TextXAlignment
	TextYAlignment TextYAlignment
UIAspectRatioConstraint
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIAspectRatioConstraint ]
	float AspectRatio
	AspectType AspectType
	DominantAxis DominantAxis
UIGridLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UIGridLayout ]
	UDim2 CellPadding
	UDim2 CellSize
	int FillDirectionMaxCells
	StartCorner StartCorner
UIListLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UIListLayout ]
	UDim Padding
UIPadding
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIPadding ]
	UDim PaddingBottom
	UDim PaddingLeft
	UDim PaddingRight
	UDim PaddingTop
UIPageLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UIPageLayout ]
	bool Animated
	bool Circular
	EasingDirection EasingDirection
	EasingStyle EasingStyle
	bool GamepadInputEnabled
	UDim Padding
	bool ScrollWheelInputEnabled
	bool TouchInputEnabled
	float TweenTime
UIScale
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIScale ]
	float Scale
UISizeConstraint
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UISizeConstraint ]
	Vector2 MaxSize
	Vector2 MinSize
UITableLayout
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGridStyleLayout ]
	FillDirection FillDirection
	HorizontalAlignment HorizontalAlignment
	SortOrder SortOrder
	VerticalAlignment VerticalAlignment
-	[ UITableLayout ]
	bool FillEmptySpaceColumns
	bool FillEmptySpaceRows
	TableMajorAxis MajorAxis
	UDim2 Padding
UITextSizeConstraint
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UITextSizeConstraint ]
	int MaxTextSize
	int MinTextSize
ViewportFrame
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ ViewportFrame ]
	Color3 Ambient
	Color3 LightColor
	Vector3 LightDirection
	Object SelectionImageObject
	float BackgroundTransparency
	Vector2 AnchorPoint
	Color3 BackgroundColor3
	int BorderSizePixel
	Color3 BorderColor3
	Object CurrentCamera
	int LayoutOrder
	UDim2 Position
	int Rotation
	bool Visible
	int ZIndex
	bool ClipsDescendants
	Color3 ImageColor3
	float ImageTransparency
UIGradient
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIGradient ]
	ColorSequence Color
	Vector2 Offset
	int Rotation
	NumberSequence Transparency
UICorner
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UICorner ]
	UDim CornerRadius
UIStroke
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIStroke ]
	ApplyStrokeMode ApplyStrokeMode
	Color3 Color
	LineJoinMode LineJoinMode
	number Thickness
	number Transparency
	number ZIndex
	bool Enabled
UIShadow
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ UIShadow ]
	UDim BlurRadius
	Color3 Color
	UDim2 Offset
	UDim2 Spread
	number Transparency
	number ZIndex
]]

GlobalData.Propertys.Building=[[
SpecialMesh
	bool Archivable
	string Name
	Object Parent
	string MeshId
	MeshType MeshType
	string TextureId
	Vector3 Scale
	Vector3 Offset
	Color3 VertexColor
WedgePart
	bool Archivable
	string Name
	Object Parent
	BrickColor BrickColor
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
	SurfaceType BackSurface
	SurfaceType BottomSurface
	SurfaceType FrontSurface
	SurfaceType LeftSurface
	SurfaceType RightSurface
	SurfaceType TopSurface
CornerWedgePart
	bool Archivable
	string Name
	Object Parent
	BrickColor BrickColor
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
	SurfaceType BackSurface
	SurfaceType BottomSurface
	SurfaceType FrontSurface
	SurfaceType LeftSurface
	SurfaceType RightSurface
	SurfaceType TopSurface
TrussPart
	bool Archivable
	string Name
	Object Parent
	BrickColor BrickColor
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
	Style Style
	SurfaceType BackSurface
	SurfaceType BottomSurface
	SurfaceType FrontSurface
	SurfaceType LeftSurface
	SurfaceType RightSurface
	SurfaceType TopSurface
Part
	bool Archivable
	string Name
	Object Parent
	Color3 Color
	Material Material
	number Reflectance
	number Transparency
	Vector3 Size
	Vector3 Position
	Vector3 Rotation
	bool CanCollide
	bool Anchored
	PhysicalProperties CustomPhysicalProperties
	PartType Shape
	SurfaceType BackSurface
	SurfaceType BottomSurface
	SurfaceType FrontSurface
	SurfaceType LeftSurface
	SurfaceType RightSurface
	SurfaceType TopSurface
MeshPart
	bool Archivable
	string Name
	Object Parent
	SurfaceType BackSurface
	SurfaceType BottomSurface
	SurfaceType FrontSurface
	SurfaceType LeftSurface
	SurfaceType RightSurface
	SurfaceType TopSurface
]]

GlobalData.Propertys.Animation=[[
Motor6D
	bool Archivable
	string Name
	Object Parent
	Object Part0
	Object Part1
	CFrame Transform
Bone
	bool Archivable
	string Name
	Object Parent
	CFrame Transform
	CFrame CFrame
KeyframeSequence
	bool Archivable
	string Name
	Object Parent
Keyframe
	bool Archivable
	string Name
	Object Parent
	float Time
Pose
	bool Archivable
	string Name
	Object Parent
	CFrame CFrame
	EnumItem EasingStyle
	EnumItem EasingDirection
Animator
	bool Archivable
	string Name
	Object Parent
AnimationController
	bool Archivable
	string Name
	Object Parent
Humanoid
	bool Archivable
	string Name
	Object Parent
]]

GlobalData.Propertys.Value=[[
BoolValue
	bool Archivable
	string Name
	Object Parent
	bool Value
StringValue
	bool Archivable
	string Name
	Object Parent
	string Value
NumberValue
	bool Archivable
	string Name
	Object Parent
	number Value
FloatValue
	bool Archivable
	string Name
	Object Parent
	float Value
IntValue
	bool Archivable
	string Name
	Object Parent
	int Value
ObjectValue
	bool Archivable
	string Name
	Object Parent
	Object Value
Vector2Value
	bool Archivable
	string Name
	Object Parent
	Vector2 Value
Vector3Value
	bool Archivable
	string Name
	Object Parent
	Vector3 Value
Vector4Value
	bool Archivable
	string Name
	Object Parent
	Vector4 Value
CFrameValue
	bool Archivable
	string Name
	Object Parent
	CFrame Value
Color3Value
	bool Archivable
	string Name
	Object Parent
	Color3 Value
BrickColorValue
	bool Archivable
	string Name
	Object Parent
	BrickColor Value
]]

GlobalData.Propertys.Signal=[[
BindableEvent
	bool Archivable
	string Name
	Object Parent
BindableFunction
	bool Archivable
	string Name
	Object Parent
RemoteEvent
	bool Archivable
	string Name
	Object Parent
UnreliableRemoteEvent
	bool Archivable
	string Name
	Object Parent
RemoteFunction
	bool Archivable
	string Name
	Object Parent
]]

local REFERENCE_PROPERTY=[[
Configuration
	bool Archivable
	string Name
	Object Parent
Folder
	bool Archivable
	string Name
	Object Parent
Model
	bool Archivable
	string Name
	Object Parent
	Object PrimaryPart
Tool
	bool Archivable
	string Name
	Object Parent
	string ToolTip
	string TextureId
	Object PrimaryPart
	bool CanBeDropped
	bool ManualActivationOnly
	bool RequiresHandle
	bool Enabled
Beam
	bool Archivable
	string Name
	Object Parent
	ColorSequence Color
	bool Enabled
	number LightEmission
	number LightInfluence
	string Texture
	number TextureLength
	TextureMode TextureMode
	number TextureSpeed
	NumberSequence Transparency
	number ZOffset
	number CurveSize0
	number CurveSize1
	bool FaceCamera
	number Segments
	number Width0
	number Width1
Trail
	bool Archivable
	string Name
	Object Parent
	ColorSequence Color
	bool FaceCamera
	number LightEmission
	number LightInfluence
	string Texture
	number TextureLength
	TextureMode TextureMode
	NumberSequence Transparency
	bool Enabled
	number Lifetime
	number MaxLength
	number MinLength
	number WidthScale
ParticleEmitter
	bool Archivable
	string Name
	Object Parent
	ColorSequence Color
	number LightEmission
	number LightInfluence
	EnumItem Orientation
	NumberSequence Size
	NumberSequence Squash
	string Texture
	NumberSequence Transparency
	number ZOffset
	Vector3 Acceleration
	EnumItem EmissionDirection
	bool Enabled
	NumberRange Lifetime
	NumberRange Rotation
	NumberRange RotSpeed
	NumberRange Speed
	number Rate
	Vector2 SpreadAngle
	number Rate
	EnumItem Shape
	number ShapePartial
	EnumItem ShapeInOut
	EnumItem ShapeStyle
	EnumItem FlipbookLayout
	bool FlipbookBlendFrames
	number FlipbookFramerate
	EnumItem FlipbookMode
	number FlipbookSizeX
	number FlipbookSizeY
	EnumItem FlipbookLayout
	bool FlipbookStartRandom
	Vector3 Acceleration
	number TimeScale
	number VelocityInheritance
	number WindAffectsDrag
Team
	bool Archivable
	string Name
	Object Parent
	BrickColor TeamColor
SurfaceAppearance
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ SurfaceAppearance ]
	string AlphaMode
	Color3 Color
	Content ColorMapContent
	Content MetalnessMapContent
	Content NormalMapContent
	Content EmissiveMaskContent
	number EmissiveStrength
	Color3 EmissiveTint
Texture
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ Texture ]
	Color3 Color3
	number OffsetStudsU
	number OffsetStudsV
	number StudsPerTileU
	number StudsPerTileV
	string Texture
	number Transparency
	number ZIndex
	NormalId Face
Decal
-	[ Instance ]
	bool Archivable
	string Name
	Object Parent
-	[ Decal ]
	NormalId Face
	Color3 Color3
	string Texture
AudioPlayer
	bool Archivable
	string Name
	Object Parent
	string Asset
	bool AutoLoad
	bool AutoPlay
	bool Looping
	number Volume
Sound
	bool Archivable
	string Name
	Object Parent
	string SoundId
	bool Looped
	bool Playing
	number Volume
	number RollOffMaxDistance
	number RollOffMinDistance
	RollOffMode RollOffMode
	bool PlaybackRegionsEnabled
	number PlaybackSpeed
	number TimePosition
Sky
	bool Archivable
	string Name
	Object Parent
	bool CelestialBodiesShown
	number MoonAngularSize
	string MoonTextureId
	string SkyboxBk
	string SkyboxDn
	string SkyboxFt
	string SkyboxLf
	string SkyboxRt
	string SkyboxUp
	number StarCount
	number SunAngularSize
	string SunTextureId
ColorCorrectionEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Brightness
	number Contrast
	number Saturation
	Color3 TintColor
BlurEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Size
SunRaysEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Intensity
	number Spread
DepthOfFieldEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number FarIntensity
	number FocusDistance
	number InFocusRadius
	number NearIntensity
BloomEffect
	bool Archivable
	string Name
	Object Parent
	bool Enabled
	number Intensity
	number Size
	number Threshold
Atmosphere
	bool Archivable
	string Name
	Object Parent
	number Density
	number Offset
	Color3 Color
	Color3 Decay
	number Glare
]] .. GlobalData.Propertys.Building .. GlobalData.Propertys.Gui .. GlobalData.Propertys.Constraint .. GlobalData.Propertys.Animation .. GlobalData.Propertys.Value .. GlobalData.Propertys.Signal

local SafeData={}
do
	SafeData['bool']=function(value) return tostring(value) end
	SafeData['boolean']=SafeData['bool']
	SafeData['float']=function(value) return Utility.ToNumber(value,2) end
	SafeData['int']=function(value) return tostring(math.floor(value)) end
	SafeData['number']=function(value) return Utility.ToNumber(value,3) end
	SafeData['string']=function(value) 
		value=Utility.Trim(value)
		local result="\'"..value:gsub("[\"\\]","\\%1"):gsub("\n","\\\\n").."\'"
		return result
	end

	SafeData['EnumItem']=SafeData['bool']
	SafeData['TextureMode']=SafeData['bool']
	SafeData['LineJoinMode']=SafeData['bool']
	SafeData['ApplyStrokeMode']=SafeData['bool']
	SafeData['Style']=SafeData['bool']
	SafeData['MeshType']=SafeData['bool']
	SafeData['Material']=SafeData['bool']
	SafeData['PartType']=SafeData['bool']
	SafeData['RollOffMode']=SafeData['bool']
	SafeData['AspectType']=SafeData['bool']
	SafeData['ButtonStyle']=SafeData['bool']
	SafeData['DominantAxis']=SafeData['bool']
	SafeData['EasingDirection']=SafeData['bool']
	SafeData['EasingStyle']=SafeData['bool']
	SafeData['FillDirection']=SafeData['bool']
	SafeData['Font']=function(value) return ("Fnt('%s',%s,%s)"):format(value.Family,tostring(value.Weight),tostring(value.Style)) end
	SafeData['FrameStyle']=SafeData['bool']
	SafeData['HorizontalAlignment']=SafeData['bool']
	SafeData['NormalId']=SafeData['bool']
	SafeData['ScaleType']=SafeData['bool']
	SafeData['ScrollBarInset']=SafeData['bool']
	SafeData['SizeConstraint']=SafeData['bool']
	SafeData['SortOrder']=SafeData['bool']
	SafeData['StartCorner']=SafeData['bool']
	SafeData['TableMajorAxis']=SafeData['bool']
	SafeData['TextXAlignment']=SafeData['bool']
	SafeData['TextYAlignment']=SafeData['bool']
	SafeData['VerticalAlignment']=SafeData['bool']
	SafeData['VerticalScrollBarPosition']=SafeData['bool']
	SafeData['ZIndexBehavior']=SafeData['bool']
	SafeData['InlineAlignment']=SafeData['bool']

	SafeData['Object']=function(value)
		local hierarchy=''
		local previousObjectUsedBrackets=true

		for object in Utility.GetAncestorsAndSelf(value) do
			local objectName=object.Name
			local safeName=''
			local shouldUseBrackets=false
			local currentHierarchy=''

			if Strs.IsEmpty(objectName) then
				shouldUseBrackets=true
			else
				if objectName:match('[%a_ ]+')~=objectName then
					shouldUseBrackets=true
				end
			end

			if shouldUseBrackets then
				safeName=objectName:gsub("[\"\\]","\\%1"):gsub("\n","\\\\n")
			end

			if object==game and previousObjectUsedBrackets then
				hierarchy='game'..hierarchy
				break
			elseif object==game and not previousObjectUsedBrackets then
				if hierarchy=='StarterGui' then
					currentHierarchy='game.StarterGui'
				elseif hierarchy=='PlayerGui' then
					currentHierarchy='game.StarterGui'
				elseif hierarchy=='workspace' then
					currentHierarchy='workspace'
				else
					currentHierarchy=hierarchy
				end
				hierarchy=currentHierarchy
				break
			elseif shouldUseBrackets and previousObjectUsedBrackets then
				previousObjectUsedBrackets=true
				hierarchy="[\""..safeName.."\"]"..hierarchy
			elseif shouldUseBrackets and not previousObjectUsedBrackets then
				previousObjectUsedBrackets=true
				hierarchy="[\""..safeName.."\"]".."."..hierarchy
			elseif (not shouldUseBrackets) and previousObjectUsedBrackets then
				previousObjectUsedBrackets=false
				hierarchy=objectName..hierarchy
			elseif (not shouldUseBrackets) and (not previousObjectUsedBrackets) then
				previousObjectUsedBrackets=false
				if object==StarterGui or hierarchy=='StarterGui' then
					currentHierarchy='game.StarterGui'
				elseif object==PlayerGui or hierarchy=='PlayerGui' then
					currentHierarchy='game.StarterGui'
				elseif object==workspace or hierarchy=='workspace' then
					currentHierarchy='workspace'
				else
					currentHierarchy=objectName..'.'..hierarchy
				end
				hierarchy=currentHierarchy
			end
		end

		return hierarchy
	end

	SafeData['Content']=function(value)
		return value.Uri
	end
	SafeData['PhysicalProperties']=function(value)
		return ('PhyProp(%s,%s,%s,%s,%s)'):format(Utility.ToNumber(value.Density,3),Utility.ToNumber(value.Friction,3),Utility.ToNumber(value.Elasticity,3),Utility.ToNumber(value.FrictionWeight,3),Utility.ToNumber(value.ElasticityWeight,3))
	end
	SafeData['Rect2D']=function(value)
		return 'R2D('..tostring(value):gsub('\n',''):gsub(' ','')..')'
	end
	SafeData['BrickColor']=function(value)
		return ('BC(%i,%i,%i)'):format(value.r*255,value.g*255,value.b*255);
	end
	SafeData['Color3']=function(value)
		return ('frRGB(%i,%i,%i)'):format(value.R*255,value.G*255,value.B*255);
	end
	SafeData['UDim']=function(value)
		local t={}
		for i,v in ipairs({value.Scale,value.Offset})  do
			t[i]=Utility.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'UD('..s..')'
	end
	SafeData['UDim2']=function(value)
		local t={}
		for i,v in ipairs({value.X.Scale,value.X.Offset,value.Y.Scale,value.Y.Offset}) do
			t[i]=Utility.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'UD2('..s..')'
	end
	SafeData['Vector2']=function(value)
		local t={}
		for i,v in ipairs({value.X,value.Y})  do
			t[i]=Utility.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'V2('..s..')'
	end
	SafeData['Vector3']=function(value)
		local t={}
		for i,v in ipairs({value.X,value.Y,value.Z})  do
			t[i]=Utility.ToNumber(v,3)
		end
		local s=table.concat(t,',')
		return 'V3('..s..')'
	end
	SafeData['Vector4']=function(value)
		local list={value.X,value.Y,value.Z,value.W or value.A}
		local results={}
		for i,v in ipairs(list)  do
			results[i]=Utility.ToNumber(v,3)
		end
		local s=table.concat(results,',')
		return 'V4('..s..')'
	end
	SafeData['CFrame']=function(value)
		local list=string.split(tostring(value):gsub('\n',''):gsub(' ',''),',')
		local results={}
		for i,v in ipairs(list)  do
			results[i]=Utility.ToNumber(v,3)
		end
		local s=table.concat(results,',')
		return 'CF('..s..')'
	end

	SafeData['NumberRange']=function(value)
		return ('NR(%s,%s)'):format(Utility.ToNumber(value.Min),Utility.ToNumber(value.Max))
	end
	SafeData['FloatRange']=function(value)
		return ('FR(%s,%s)'):format(Utility.ToNumber(value.Min),Utility.ToNumber(value.Max))
	end

	SafeData['ColorSequenceKeypoint']=function(value)
		return ('CSeqKey(%s,%s)'):format(Utility.ToNumber(value.Time),SafeData['Color3'](value.Value));
	end
	SafeData['NumberSequenceKeypoint']=function(value)
		return ('NSeqKey(%s,%s)'):format(Utility.ToNumber(value.Time),Utility.ToNumber(value.Value))
	end
	SafeData['FloatSequenceKeypoint']=function(value)
		return ('FSeqKey(%s,%s)'):format(Utility.ToNumber(value.Time),Utility.ToNumber(value.Value))
	end

	SafeData['ColorSequence']=function(value)
		local t={}
		for i,v in ipairs(value.Keypoints) do t[i]=SafeData['ColorSequenceKeypoint'](v)..(i<=#value.Keypoints-1 and ',' or '') end
		local s=''
		for i,v in ipairs(t) do s=s..v end
		return ('CSeq({%s})'):format(s)
	end
	SafeData['NumberSequence']=function(value)
		local t={}
		for i,v in ipairs(value.Keypoints) do t[i]=SafeData['NumberSequenceKeypoint'](v)..(i<=#value.Keypoints-1 and ',' or '') end
		local s=''
		for i,v in ipairs(t) do s=s..v end
		return ('NSeq({%s})'):format(s)
	end
	SafeData['FloatSequence']=function(value)
		local t={}
		for i,v in ipairs(value.Keypoints) do  t[i]=SafeData['FloatSequenceKeypoint'](v)..(i<=#value.Keypoints-1 and ',' or '') end
		local s=''
		for i,v in ipairs(t) do s=s..v end
		return ('FSeq({%s})'):format(s)
	end
end

local RegisteredClasses,ObjectClasses={},{}
local GrabTypeCache,BuildingCache,GuiCache,ToolCache,MouseIconCache,InstalCache,FileCache={},{},{},{},{},{},{}

Utility.CreateClasses=function(properties)
	local className,templateObject,classList,registeredList=nil,nil,{},{}
	for line in Utility.GetLines(properties) do
		if line:sub(1,1)~='-' then
			if line:sub(1,1)=='	' then
				if templateObject then
					local space=line:find(' ')
					if not tonumber(space) then return end
					local dataType=line:sub(2,space-1)
					local propertyName=line:sub(space+1,#line)
					local propertyValue,propertyType=nil,nil
					local success,err=pcall(function() propertyValue=templateObject[propertyName] end) 
					if not success then
						--warn('['..PLUGIN_NAME..'] Unknown property '..className..'.'..propertyName..' will be ignored.')
						continue
					end
					propertyType=typeof(propertyValue)
					if propertyType=='EnumItem' then
						dataType=propertyType
					end
					if SafeData[dataType]==nil then
						--warn('['..PLUGIN_NAME..'] Unhandled data type '..dataType..' '..className..'.'..propertyName..' will be ignored.')
						continue
					end
					classList[className][propertyName]={
						DataType=dataType,
						DefaultValue=propertyValue
					}
					table.insert(classList[className],propertyName)
				end
			else
				if templateObject then templateObject:Destroy() templateObject=nil end
				className=line
				if not pcall(function() Instance.new(className):Destroy() end) then
					--warn('['..PLUGIN_NAME..'] Unknown class '..line..'  will be ignored.')
					continue
				end
				if classList[className] then
					--warn('['..PLUGIN_NAME..'] '..className..'class is already registered.')
					continue
				end
				table.insert(registeredList,className)
				templateObject=Instance.new(className)
				classList[className]={}
			end
		end
	end
	if templateObject then templateObject:Destroy() templateObject=nil end
	className=nil
	return classList,registeredList
end

ObjectClasses,RegisteredClasses=Utility.CreateClasses(REFERENCE_PROPERTY)

REFERENCE_PROPERTY=nil
GUI_PROPERTY=nil

table.insert(GlobalData.Types.AnimationPriority,'Auto')
for _,v in pairs(Enum.AnimationPriority:GetEnumItems()) do
	if not table.find(GlobalData.Types.AnimationPriority,v.Name) then
		table.insert(GlobalData.Types.AnimationPriority,v.Name)
	end
end

-- by cybercrazyyy and Gemini AI
local RecordAnimation={}

function RecordAnimation.new(model,options)
	options=options or {}
	
	local recordAnimationType=options.RecordAnimationType or "Motor6D"
	local animationName=options.Name
	
	local Container=model:FindFirstChild('AnimSaves')
	if not Container then
		Container=Instance.new('ObjectValue')
		Container.Name='AnimSaves'
		Container.Parent=model
	end

	local baseParts=model:QueryDescendants('BasePart')
	local isSinglePart=#baseParts==1

	local rootPart=model:FindFirstChild('HumanoidRootPart')
	local torso=model:FindFirstChild('LowerTorso') or model:FindFirstChild('Torso')

	local PrimaryPart=isSinglePart and baseParts[1] or rootPart or torso or model.PrimaryPart or baseParts[1]
	local KeyframeSequence=Instance.new('KeyframeSequence')
	
	if not animationName or animationName=='' then animationName='Record' end
	KeyframeSequence.Name=animationName..'_'..tostring(os.time())
	
	local Time=0
	local Init=PrimaryPart and CFrame.new(PrimaryPart.Position) or CFrame.new()

	local function GenerateKeyframe()
		local Keyframe=Instance.new("Keyframe")

		if recordAnimationType == "Bone" or isSinglePart then
			if PrimaryPart then
				local RootPose = Instance.new("Pose")
				RootPose.Name = PrimaryPart.Name
				RootPose.CFrame = Init:ToObjectSpace(PrimaryPart.CFrame)
				Keyframe:AddPose(RootPose)
				
				local function AddBonePoses(parentObj, parentPose)
					for _, child in ipairs(parentObj:GetChildren()) do
						if child:IsA("Bone") then
							local Pose = Instance.new("Pose")
							Pose.Name = child.Name
							Pose.CFrame = child.Transform
							parentPose:AddSubPose(Pose)
							AddBonePoses(child, Pose)
						end
					end
				end

				for _, part in ipairs(baseParts) do
					for _, child in ipairs(part:GetChildren()) do
						if child:IsA("Bone") then
							local Pose = Instance.new("Pose")
							Pose.Name = child.Name
							Pose.CFrame = child.Transform
							RootPose:AddSubPose(Pose)
							AddBonePoses(child, Pose)
						end
					end
				end
			end
		else
			if not rootPart and not torso then
				warn("Character does not have HumanoidRootPart, LowerTorso, or Torso for Motor6D mode.")
				return Keyframe
			end

			local ActiveRoot = rootPart or torso
			local ActiveTorso = torso or rootPart

			local PartsAdded = {
				[ActiveRoot] = true,
				[ActiveTorso] = true
			}

			local function AddPoses(Part: BasePart, ParentPose)
				for _, Joint in pairs(Part:GetJoints()) do
					if Joint:IsA("AnimationConstraint") or Joint:IsA('Motor6D') then
						local ConnectedPart = nil
						if Joint.Part0 == Part then
							ConnectedPart = Joint.Part1
						elseif Joint.Part1 == Part then
							ConnectedPart = Joint.Part0
						end
						if ConnectedPart then
							if not PartsAdded[ConnectedPart] then
								PartsAdded[ConnectedPart] = true
								local Pose = Instance.new("Pose")
								Pose.CFrame = Joint.Transform
								Pose.Name = ConnectedPart.Name
								ParentPose:AddSubPose(Pose)
								AddPoses(ConnectedPart, Pose)
							end
						end
					end
				end
			end

			local RootPose = Instance.new("Pose")
			RootPose.Name = ActiveRoot.Name
			RootPose.CFrame = Init:ToObjectSpace(ActiveRoot.CFrame)
			Keyframe:AddPose(RootPose)

			if ActiveTorso ~= ActiveRoot then
				local TorsoPose = Instance.new("Pose")
				TorsoPose.Name = ActiveTorso.Name
				TorsoPose.CFrame = Init:ToObjectSpace(ActiveTorso.CFrame)
				RootPose:AddSubPose(TorsoPose)
				AddPoses(ActiveTorso, TorsoPose)
			else
				AddPoses(ActiveRoot, RootPose)
			end
		end

		return Keyframe
	end

	local Connection=RunService.Heartbeat:Connect(function(deltaTime)
		Time+=deltaTime
		local Keyframe=GenerateKeyframe()
		Keyframe.Time=Time
		KeyframeSequence:AddKeyframe(Keyframe)
	end)

	return {
		Stop=function(_)
			Connection:Disconnect()
			KeyframeSequence.Parent=Container
			return KeyframeSequence
		end
	}
end

local Module={Parent=false}

function Module:SetStatus(mode,...)
	if mode==1 or mode==0 then
		local message,cooldown=...
		if not message or type(message)~='string' then return end
		Values.LastStatus=message
		Interfaces.StatusLabel:Set(message)
		if mode==0 then return end
		if cooldown then task.wait(tonumber(cooldown) or 2) end
		if message==Values.LastStatus then
			Interfaces.StatusLabel:Set('Status')
		end
	elseif mode==2 then
		local v,max=...
		if v==-1 then
			Interfaces.LoaderLabel.Text=tostring(max)..'/'..tostring(max)..' 100%'
		elseif v==-2 then
			Interfaces.LoaderLabel.Text='(0/0) 0%'
		else
			local persentase=Utility.ToPersentase(v,max,2,true)
			Interfaces.LoaderLabel.Text=tostring(v)..'/'..tostring(max)..' '..persentase
		end
	end
end

function Module:SetUpdate(mode,...)
	if mode==1 then
		table.clear(GrabTypeCache)
		table.clear(BuildingCache)
		table.clear(GuiCache)
		table.clear(ToolCache)
		table.clear(MouseIconCache)
		table.clear(InstalCache)
		Values.GrabType=GlobalData.Types.GrabTypes[1]
		for _, key in ipairs({'BuildingTarget','InstalTarget','GuiTarget','ToolTarget'}) do
			Values[key]=nil
		end
		Values.RecordAnimType=GlobalData.Types.RecordAnimTypes[1]
		Values.RecordDebounce=false
		if Cacheds.PlayerGuiAdded then Cacheds.PlayerGuiAdded:Disconnect() Cacheds.PlayerGuiAdded=nil end
		Interfaces.GrabTypeSelector:Set(Values.GrabType)
		if Values.GrabberModel then Values.GrabberModel:Destroy() Values.GrabberModel=nil end
		if Window.Parent then
			Interfaces.StatusLabel:Set('Status')
			Interfaces.LoaderLabel:Set('(0/0) 0%')
		end
		self:SetUpdate(2)
		self:SetUpdate(3)
	elseif mode==2 then
		local target=...
		if Outliner.Parent then
			local isTarget=target~=nil
			Outliner.Adornee=target
			Outliner.Visible=isTarget 
		end
	elseif mode==3 then
		local lastGrabType=Values.GrabType
		local isAnimation,isBuilding,isSettings=lastGrabType=='Animation',lastGrabType=='Building' or lastGrabType=='Animation',lastGrabType=='Settings'
		Interfaces.SoundSlider.Visible=lastGrabType=='Sound' or isSettings
		Interfaces.FileNameTextBox.Visible=isSettings
		Interfaces.AutoSaveFileToggle.Visible=isSettings
		Interfaces.UseNameToggle.Visible=isSettings
		Interfaces.InitializeButton.Visible=lastGrabType=='None'
		Interfaces.InstalButton.Visible=lastGrabType=='None'
		Interfaces.UseMyselfToggle.Visible=isSettings or isBuilding
		Interfaces.CanShutdownToggle.Visible=isSettings
		Interfaces.CanWrapTextToggle.Visible=isSettings
		for i,v in ipairs({Interfaces.DestroyButton,Interfaces.ResetButton}) do v.Visible=lastGrabType=='None' end
		Interfaces.TopSelect.Visible=isBuilding
		self:SetUpdate(isBuilding and 2 or 0)
		if Cacheds.PlayerGuiAdded then Cacheds.PlayerGuiAdded:Disconnect() Cacheds.PlayerGuiAdded=nil end
		Interfaces.TextBox.Visible=isBuilding
		Interfaces.TextBox.Title=isBuilding and 'Building Index (0-'.. tostring(Values.BuildingIndex)..')' or ''
		Interfaces.AddButton.Visible=lastGrabType~='None' and lastGrabType~='Settings' and lastGrabType~='Animation'
		if lastGrabType=='Gui' then
			local originText,lastText="Use dex/explorer and Add StringValue and named 'Instal' to any ScreenGui in PlayerGui",''
			Interfaces.MainLabel.Text=originText
			Cacheds.PlayerGuiAdded=PlayerGui.DescendantAdded:Connect(function(child)
				if child and child.Parent and child:IsA('StringValue') and child.Name=='Instal' then
					local isGui,gui=false,child.Parent
					if gui then isGui=gui:IsA('ScreenGui') if isGui then Values.GuiTarget=gui child:Destroy() end end
					lastText=isGui and 'Successfully' or 'An Error Occured'
					Interfaces.MainLabel.Text=lastText
					task.wait(1)
					if Interfaces.MainLabel.Text==lastText then
						Interfaces.MainLabel.Text=originText
					end
				end
			end)
		else
			Interfaces.MainLabel.Text=''
		end
		Interfaces.MainLabel.TextScaled=lastGrabType=='Gui'
		Interfaces.MainLabel.Visible=lastGrabType=='Gui'
		Interfaces.StopButton.Visible=isBuilding
		Interfaces.FPSTitle.Visible=isSettings
		Interfaces.FPSSelector.Visible=isSettings
		for i,v in ipairs({Interfaces.RecordButton,Interfaces.PlayButton}) do 
			if Values.GrabType~=lastGrabType then break end
			v.Visible=isAnimation
		end
		for i,v in ipairs({Interfaces.AnimationTextBox,Interfaces.AnimationPriorityTitle,Interfaces.AnimationPrioritySelector,Interfaces.AnimationTitle,Interfaces.AnimationSelector}) do
			if Values.GrabType~=lastGrabType then break end
			v.Visible=lastGrabType=='Animation' or isSettings
		end
	end
end

function Module:GetGrabData(mode)
	mode=tostring(mode)
	Interfaces.StatusLabel:Set(mode)
	task.wait(1)
	local newModel=Instance.new('Model') newModel.Name=mode
	local objectLength,textValue,textLength,maxText,textRemoved,needle,needles,list,actives,explorers=0,'',0,100,true,nil,GlobalData.Explorers[mode] or {},{},{},{}
	if mode=='Texture' or mode=='Effect' or mode=='Decal' or mode=='Trail' or mode=='Beam' then
		explorers=GlobalData.Explorers['Effect']
	elseif mode=='Team' then
		explorers={Teams}
	elseif mode=='Sound' then
		explorers={Workspace,ReplicatedStorage,SoundService,LocalPlayer,LocalPlayer.Character}
	end
	if mode=='GuiIcon' or mode=='Icon' then
		textValue=textValue..'\n do \n local icons={'
	end
	local OnImageIdCallback=function(propertyType,propertyValue)
		if propertyType~='string' then return end 
		RunService.Stepped:Wait()
		local k=propertyValue
		if actives[k] then return end
		actives[k]=true 
		Interfaces.StatusLabel:Set(mode..': '..tostring(k))
		textValue=textValue.."'"..k.."',"
		objectLength=objectLength+1
		if textLength>=Values.MaxSound then textValue=textValue..'\n' end 
		textLength=(textLength+1)%Values.MaxSound 
	end
	local IsCopyInstance=function(v)
		RunService.Stepped:Wait()
		local name,className,k=v.Name,v.ClassName,nil
		if className=='Team' and mode=='Team' then 
			k=name..'_'..tostring(v.TeamColor)
		elseif className=='Decal' and mode=='Decal' then
			k=v.Texture 
		elseif className=='Trail' and mode=='Trail' then
			k=v.Texture 
		elseif className=='Beam' and mode=='Beam' then
			k=v.Texture 
		elseif className=='Texture' and mode=='Texture' then
			k=v.Texture
		elseif Utility.IsAs(v,GlobalData.Types.PacketClasses) and mode=='Event' then
			k=name..'_'..className
		end 
		if k~=nil and actives[k]==nil then
			actives[k]=true 
			Interfaces.StatusLabel:Set(mode..': '..name)
			return true
		end
		return false
	end
	if mode=='Sound' then
		textValue='\n local SoundIds={' 
		for _, explorer in ipairs(explorers) do if explorer and explorer.Parent then for _, child in ipairs(explorer:GetDescendants()) do if child and child.Parent then local name,className,key=child.Name,child.ClassName,nil if className=='Sound' then key=child.SoundId elseif className=='AudioPlayer' then key=child.Asset end if key~=nil and actives[key]==nil then actives[key]=true RunService.Stepped:Wait() Interfaces.StatusLabel:Set(mode..': '..name..' '..key) textValue=textValue.."{'"..name.."'"..",".."'"..key.."'}," textLength=(textLength+1)%maxText if textLength==0 then textValue=textValue.."\n" end table.insert(list,{name,key,child,className}) end end end end end
		textValue=textValue.."}\n" 
		textValue=textValue.. [[for i,v in ipairs(SoundIds) do local nv=e('Sound') nv.Name=v[1] nv.SoundId=v[2] nv.Parent=%s end]] .."\n" 
		if #list>=Values.MaxSound then
			textRemoved=false
		else
			textValue='' for i,v in ipairs(list) do RunService.Stepped:Wait() Interfaces.StatusLabel:Set(mode..': '..v[2]) local newValue=Utility.CopyInstance(v[4],v[3],ObjectClasses[v[4]]) newValue.Parent=newModel end
		end
		table.clear(list)
	elseif mode=='Lighting' then
		Utility.Create('Model',{
			Name='Lighting',
			Parent=newModel
		},{
			Utility.Create('NumberValue',{
				Name='Brightness',
				Value=Lighting.Brightness
			}),
			Utility.Create('Color3Value',{
				Name='Ambient',
				Value=Lighting.Ambient
			}),
			Utility.Create('Color3Value',{
				Name='ColorShift_Bottom',
				Value=Lighting.ColorShift_Bottom
			}),
			Utility.Create('Color3Value',{
				Name='ColorShift_Top',
				Value=Lighting.ColorShift_Top
			}),
			Utility.Create('Color3Value',{
				Name='OutdoorAmbient',
				Value=Lighting.OutdoorAmbient
			}),
			Utility.Create('NumberValue',{
				Name='EnvironmentDiffuseScale',
				Value=Lighting.EnvironmentDiffuseScale
			}),
			Utility.Create('NumberValue',{
				Name='EnvironmentSpecularScale',
				Value=Lighting.EnvironmentSpecularScale
			}),
			Utility.Create('BoolValue',{
				Name='GlobalShadows',
				Value=Lighting.GlobalShadows
			}),
			Utility.Create('BoolValue',{
				Name='ShadowSoftness',
				Value=Lighting.ShadowSoftness
			}),
			Utility.Create('NumberValue',{
				Name='ClockTime',
				Value=Lighting.ClockTime
			}),
			Utility.Create('NumberValue',{
				Name='GeographicLatitude',
				Value=Lighting.GeographicLatitude
			}),
			Utility.Create('NumberValue',{
				Name='ExposureCompensation',
				Value=Lighting.ExposureCompensation
			})
		})
		Utility.CopyInstanceWith(explorers,ObjectClasses,newModel,function(v) if Utility.IsAs(v,GlobalData.Types.LightingClasses) then Interfaces.StatusLabel:Set(mode..': '..v.Name) return true end return false end)
	elseif mode=='Event' then
		Utility.CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Team' then
		Utility.CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Texture' then
		Utility.CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Decal' then
		Utility.CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Trail' then
		Utility.CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='Beam' then
		Utility.CopyInstanceWith(explorers,ObjectClasses,newModel,IsCopyInstance)
	elseif mode=='GuiColor' then
		for j,k in ipairs(explorers) do for i,v in ipairs(k:GetDescendants()) do if Utility.IsAs(v,GlobalData.Types.UIClasses) then Utility.GetInstanceProperty(v,GlobalData.Types.ColorProperties,function(dataType,propertyValue) if dataType=='Color3' or dataType=='BrickColor' then needle=dataType..'_'..tostring(propertyValue) if not actives[needle] then actives[needle]=true Interfaces.StatusLabel:Set(mode..': '..tostring(propertyValue)) if dataType=='BrickColor' then textValue=textValue..tostring(propertyValue)..',' else textValue=textValue..SafeData['Color3'](propertyValue)..',' end if textLength>=maxText then textValue=textValue..'\n' end textLength=(textLength+1)%maxText RunService.Stepped:Wait() end end end) end end end
	elseif mode=='PartColor' then
		for i,v in ipairs(Workspace:GetDescendants()) do if v:IsA('BasePart') then Utility.GetInstanceProperty(v,GlobalData.Types.ColorProperties,function(dataType,propertyValue) if dataType=='Color3' or dataType=='BrickColor' then needle=dataType..'_'..tostring(propertyValue) if not actives[needle] then actives[needle]=true Interfaces.StatusLabel:Set(mode..': '..tostring(propertyValue)) if dataType=='BrickColor' then textValue=textValue..tostring(propertyValue)..',' else textValue=textValue..SafeData['Color3'](propertyValue)..',' end if textLength>=maxText then textValue=textValue..'\n' end textLength=(textLength+1)%maxText RunService.Stepped:Wait() end end end) end end
	elseif mode=='Name'  then
		for j,k in ipairs(explorers) do for i,v in ipairs(k:GetDescendants()) do Utility.GetInstanceProperty(v,GlobalData.Types.TextProperties,function(dataType,propertyValue,propertyName) if dataType=='string' then local nameFilter='' for v in propertyValue:gmatch("[%w]") do if not Utility.IsStrings(v,GlobalData.Types.NumericTypes) then nameFilter=nameFilter..v end end if #nameFilter<=0 or v:IsA(nameFilter) then return end local newInstance=Instance.new(v.ClassName) local instanceValue=nil pcall(function() instanceValue=newInstance[propertyName] end) if instanceValue and instanceValue==nameFilter then newInstance:Destroy() return end if not actives[nameFilter] then actives[nameFilter]=true Interfaces.StatusLabel:Set(mode..': '..nameFilter) textValue=textValue..nameFilter..',' if textLength>=maxText then textValue=textValue..'\n' end textLength=(textLength+1)%maxText RunService.Stepped:Wait() end end end) end end
	elseif mode=='MouseIcon' then
		if next(MouseIconCache) then for v,k in pairs(MouseIconCache) do Interfaces.StatusLabel:Set(mode..': '..v) textValue=textValue..v..',' if textLength>=maxText then textValue=textValue..'\n' end textLength=(textLength+1)%maxText RunService.Stepped:Wait() end end
	elseif mode=='Icon' then
		for j,k in ipairs(explorers) do for i,v in ipairs(k:GetDescendants()) do Utility.GetInstanceProperty(v,GlobalData.Types.IconProperties,OnImageIdCallback) end end
	elseif mode=='GuiIcon' then
		for i,v in ipairs(PlayerGui:GetDescendants()) do Utility.GetInstanceProperty(v,GlobalData.Types.IconProperties,OnImageIdCallback) end
	elseif mode=='Tool' then
		Values.ToolTarget=nil if not next(ToolCache) then for i, v in ipairs(ReplicatedStorage:GetDescendants()) do if v and v.Parent and v:IsA('Tool') then RunService.Stepped:Wait() Interfaces.StatusLabel:Set(mode) table.insert(ToolCache,v:Clone()) end end end
	elseif mode=='Gui' then
		Values.GuiTarget=nil local k,v=next(GuiCache) while k and v do RunService.Stepped:Wait() GuiCache[k]=nil local cv=k:Clone() if cv and cv.Parent==nil then Interfaces.StatusLabel:Set(mode..': '..cv.Name) cv.Parent=newModel end k,v=next(GuiCache) end
	elseif mode=='Building' then
		Values.BuildingTarget=nil local k,v=next(BuildingCache) while k and v do RunService.Stepped:Wait() BuildingCache[k]=nil local cv=k:Clone() if cv and cv.Parent==nil then Interfaces.StatusLabel:Set(mode..': '..cv.Name) cv.Parent=newModel end k,v=next(BuildingCache) end
	else
		return false,nil
	end
	if mode=='GuiIcon' or mode=='Icon' then
		textValue=textValue..'}\n'
		local columns=math.ceil(math.sqrt(objectLength))
		local rows=math.ceil(objectLength/columns);
		local newTextBonus="local i,size,origin,color1,color2,folder,len,columns,rows=1,Vector3.new(4,1,4),Vector3.new(0,0.5,0),BrickColor.new('Black'),BrickColor.new('White'),V['1'] or V['2'],"..tostring(objectLength)..","..tostring(columns)..","..tostring(rows).." "
		local newTextValue=[[for x=1,columns do for z=1,rows do if i<=len then local image=icons[i] local p=Instance.new('Part') p:SetAttribute('Tier',i) p.Name=image p.Size=size p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth  p.Position=Vector3.new(origin.X+((x-1)*size.X),origin.Y,origin.Z+((z-1)*size.Z)) p.BrickColor=(x+z)%2==0 and color1 or color2 p.Material=Enum.Material.SmoothPlastic p.Parent=folder local sg=Instance.new('SurfaceGui') sg.Face=Enum.NormalId.Top sg.LightInfluence=1 sg.Parent=p local label=Instance.new('ImageLabel') label.Size=UDim2.new(1,0,1,0) label.Position=UDim2.new(0,0,0,0) label.BackgroundTransparency=1 label.Image=image label.Parent=sg i=i+1 end task.wait() end task.wait() end]]
		textValue=textValue..newTextBonus..'\n'
		textValue=textValue..newTextValue..'\n end'
	elseif #textValue>0 and mode~='Sound' then
		local newTextValue='local '..mode..'=[['..textValue..']]'
		textValue=newTextValue..'\n'
	end
	local isModel,modelChildren=false,newModel:GetChildren()
	if #textValue>0 then
		if #textValue>=2000 then Interfaces.StatusLabel:Set(mode..' string is too long! and '..tostring(#textValue)) task.wait(1) end 
		if textRemoved then newModel:SetAttribute('Coding',true) end 
		InstalCache[mode]={textValue}
	elseif #textValue<=0 and not next(modelChildren) then
		self:SetStatus(0,mode..' Has Empty') newModel:Destroy() newModel=nil task.wait(1)
	else
		isModel=true
	end
	textValue='' textLength=0 needle=nil actives,explorers,needles={},{},{}
	return isModel,newModel
end

function Module:Initialize()
	if Values.Debounce then return end
	Values.Debounce=true
	Interfaces.StatusLabel:Set('Initialize')
	task.wait(1)
	self:SetUpdate(2)
	if Values.GrabberModel then Values.GrabberModel:Destroy() Values.GrabberModel=nil end
	local newInstance=Instance.new('Model')
	newInstance.Name='InstalModel'
	if next(GrabTypeCache) then
		for k,v in pairs(GrabTypeCache) do 
			RunService.Stepped:Wait() 
			local isGroup,newGroup=self:GetGrabData(k) 
			if newGroup then
				newGroup.Parent=newInstance 
				if isGroup then
					InstalCache[k]=newGroup:GetChildren() 
				end
			end
		end
	elseif Values.GrabType then
		local lastGrabType=Values.GrabType 
		local isGroup,newGroup=self:GetGrabData(lastGrabType) 
		if newGroup then
			newGroup.Parent=newInstance
			if isGroup then
				InstalCache[lastGrabType]=newGroup:GetChildren() 
			end
		end
	end
	if next(InstalCache) then
		local length=#newInstance:GetDescendants()+1
		if length>=MAX_CAP then Values.LastStatus=tostring(length)..'Object is Dangerous!' else Values.LastStatus='Grab '..tostring(length)..' Object' end
		Interfaces.StatusLabel:Set(Values.LastStatus)
		task.wait(1)
		Values.GrabberModel=newInstance
		Values.InstalTarget=newInstance
		self:SetStatus(0,'Successfully')
	else
		self:SetStatus(0,'An Error Occured')
	end
	task.wait(1)
	self:SetStatus(0,'Status')
	Values.Debounce=false
end

function Module:Scan(instance,func,data)
	if data==nil then 
		data={Count=0,Max=#instance:GetDescendants()} 
	end
	if data.Count%20==0 then RunService.Stepped:Wait() end
	local currentChildren=instance:GetChildren()
	Utility.Foreach(currentChildren,function(v)
		if data.Count%20==0 then RunService.Stepped:Wait() end
		local info=ObjectClasses[v.ClassName]
		if info==nil then
			data.Max-=1
			for _,k in ipairs(v:GetChildren()) do k.Parent=v.Parent table.insert(currentChildren,1,k) end
			v:Destroy()
			return
		else
			data.Count+=1
		end
		func(data.Count,v,data.Max)
		local children=v:GetChildren()
		if #children>0 then
			self:Scan(v,func,data)
			table.clear(children)
		end
	end)
	func(data.Count,nil,data.Max)
end

function Module:Starting(instance,func)
	self:Scan(instance,func)
	local progress,maxProgress=0,0
	local packList={instance:FindFirstChild('Building'),instance:FindFirstChild('Tool'),instance:FindFirstChild('Gui')}
	for _,model in ipairs(packList) do 
		if model then 
			local i=0
			Utility.Foreach(model:GetDescendants(),function(v) 
				if v:IsA('MeshPart') then 
					maxProgress+=1 
					progress+=1
					i=(i+1)%30
					if i==0 then RunService.Stepped:Wait() end
					Utility.ConvertMeshPartToSpecialMesh(v,{
						['DefaultSurfaceAppearance']=Templates.SurfaceAppearance,
						['SafeData']=SafeData
					})
					func(progress,v,maxProgress) 
				end 
			end) 
		end 
	end
	maxProgress+=#instance:GetDescendants()
	progress=maxProgress
	func(progress,nil,maxProgress) 
end

function Module:Create(instance,options,func)
	Utility.Foreach(instance:GetChildren(),function(v)
		if options.Count%20==0 then RunService.Stepped:Wait() end
		if ObjectClasses[v.ClassName] then 
			options.Count+=1
			Utility.CreateVariable(v,options)
			options.Objectives[options.Variables[v]]=v
			options.AdvencedVariables[v]=string.format("%s[\'%s\']","V",options.Count)
			table.insert(options.Selections,v)
		else
			options.Max-=1
		end
		func(options.Count,v,options.Max)
		local children=v:GetChildren()
		if #children>0 then
			self:Create(v,options,func)
			table.clear(children)
		end
	end)
	func(options.Count,nil,options.Max)
end

function Module:Creating(instance,visualInstance,data,func)
	local descendants=instance:GetDescendants()
	local options={
		Count=0,
		Duplicated={},
		Max=#descendants,
		Variables={},
		AdvencedVariables={},
		Objectives={},
		Selections={},
		Properties={}
	}
	for mode,list in pairs(data) do for j,k in ipairs(list) do if type(k)=='string' then options.Max+=1 end end end
	self:Create(instance,options,func)
	table.clear(descendants)
	for mode,list in pairs(data) do
		for i,k in ipairs(list) do
			if k==nil or type(k)~='string' then continue end
			options.Count+=1
			if i%30 then RunService.Stepped:Wait() end
			local v=visualInstance:FindFirstChild(mode)
			if v then
				local coding=v:GetAttribute('Coding')
				local variable=options.AdvencedVariables[v]
				if variable then
					if coding~=nil and coding==true then
						options.AdvencedVariables[v]=nil
						local instanceIndex=table.find(options.Selections,v)
						if instanceIndex then table.remove(options.Selections,instanceIndex) end
						local otherVariable=options.Variables[v]
						if otherVariable then
							options.Variables[v]=nil
							options.Objectives[otherVariable]=nil
						end
						options.Count-=1
						table.insert(options.Selections,k)
						v:Destroy()
					else
						table.insert(options.Selections,string.format(k,variable))
					end
				end
			end
			func(options.Count,k,options.Max)
		end
		table.clear(list)
	end
	func(options.Count,nil,options.Max)
	return options.Selections,options.Variables,options.Objectives,options.AdvencedVariables,options.Properties
end

function Module:Serialize(Value,Type,DefaultValue)
	if Value==nil then return 'nil' end

	-- String
	if Type=='string' then
		return "\'".. Utility.Trim(Value):gsub("[\"\\]","\\%1"):gsub("\n","\\\\n").."\'"

		-- number
	elseif Utility.IsStrings(Type,{'number','float','int','short','double'}) then
		if Value~=Value then return '0/0' end
		if Value==math.huge then return 'math.huge' end
		if Value==-math.huge then return '-math.huge' end
		return Utility.ToNumber(Value)
	elseif Type=='boolean' or type(Value)=='boolean' then
		return Value and 'true' or 'false'
	elseif Type=='BrickColor' then
		local r,g,b=math.round(Value.r*255),math.round(Value.g*255),math.round(Value.b*255)
		local dr,dg,db=math.round(DefaultValue.r*255),math.round(DefaultValue.g*255),math.round(DefaultValue.b*255)
		if b==db then
			if g==dg then
				return string.format('{%d}',r)
			end
			return string.format('{%d,%d}',r,g)
		end
		return string.format('{%d,%d,%d}',r,g,b)
	elseif Type=='Color3' then
		local r,g,b=math.round(Value.R*255),math.round(Value.G*255),math.round(Value.B*255)
		local dr,dg,db=math.round(DefaultValue.R*255),math.round(DefaultValue.G*255),math.round(DefaultValue.B*255)
		if b==db then
			if g==dg then
				return string.format('{%d}',r)
			end
			return string.format('{%d,%d}',r,g)
		end
		return string.format('{%d,%d,%d}',r,g,b)
	elseif Type=='Vector2' then
		local x,y=Value.X,Value.Y
		local dx,dy=DefaultValue.X,DefaultValue.Y
		if y==dy then
			return string.format('{%s}',Utility.ToNumber(x))
		end
		return string.format('{%s,%s}',Utility.ToNumber(x),Utility.ToNumber(y))
	elseif Type=='Vector3' then
		local x,y,z=Value.X,Value.Y,Value.Z
		local dx,dy,dz=DefaultValue.X,DefaultValue.Y,DefaultValue.Z
		if z==dz then
			if y==dy then
				return string.format('{%s}',Utility.ToNumber(x))
			end
			return string.format('{%s,%s}',Utility.ToNumber(x),Utility.ToNumber(y))
		end
		return string.format('{%s,%s,%s}',Utility.ToNumber(x),Utility.ToNumber(y),Utility.ToNumber(z))
	elseif Type=='CFrame' then
		local comp={Value:GetComponents()}
		local defComp=DefaultValue and {DefaultValue:GetComponents()} or nil
		local isIdentityRotation=comp[4]==1 and comp[5]==0 and comp[6]==0 and comp[7]==0 and comp[8]==1 and comp[9]==0 and comp[10]==0 and comp[11]==0 and comp[12]==1
		if isIdentityRotation then
			local x,y,z=comp[1],comp[2],comp[3]
			if defComp then
				local dx,dy,dz=defComp[1],defComp[2],defComp[3]
				if z==dz then
					if y==dy then
						return string.format('{%s}',Utility.ToNumber(x))
					end
					return string.format('{%s,%s}',Utility.ToNumber(x),Utility.ToNumber(y))
				end
			end
			return string.format('{%s,%s,%s}',Utility.ToNumber(x),Utility.ToNumber(y),Utility.ToNumber(z))
		end
		local formatText="{"
		for i,v in ipairs(comp) do
			formatText=formatText..Utility.ToNumber(v)..(i<=#comp and ',' or '')
		end
		formatText=formatText..'}'
		return formatText
	elseif Type=='UDim' then
		local scale,offset=Value.Scale,Value.Offset
		local dScale,dOffset=DefaultValue.Scale,DefaultValue.Offset
		if offset==dOffset then
			return string.format('{%s}',Utility.ToNumber(scale))
		end
		return string.format('{%s,%s}',Utility.ToNumber(scale),Utility.ToNumber(offset))
	elseif Type=='UDim2' then
		local xScale,xOffset,yScale,yOffset=Value.X.Scale,Value.X.Offset,Value.Y.Scale,Value.Y.Offset
		local dxScale,dxOffset,dyScale,dyOffset=DefaultValue.X.Scale,DefaultValue.X.Offset,DefaultValue.Y.Scale,DefaultValue.Y.Offset
		if yOffset==dyOffset then
			if yScale==dyScale then
				if xOffset==dxOffset then
					return string.format('{%s}',Utility.ToNumber(xScale))
				end
				return string.format('{%s,%s}',Utility.ToNumber(xScale),Utility.ToNumber(xOffset))
			end
			return string.format('{%s,%s,%s}',Utility.ToNumber(xScale),Utility.ToNumber(xOffset),Utility.ToNumber(yScale))
		end
		return string.format('{%s,%s,%s,%s}',Utility.ToNumber(xScale),Utility.ToNumber(xOffset),Utility.ToNumber(yScale),Utility.ToNumber(yOffset))
	elseif Type=='ColorSequence' then
		local text='{'
		local keypoints=Value.Keypoints
		for i,k in ipairs(keypoints) do
			local color=k.Value
			local r,g,b=math.round(color.R*255),math.round(color.G*255),math.round(color.B*255)
			text=text..string.format('{%s,{%d,%d,%d}}',Utility.ToNumber(k.Time),r,g,b)..(i<#keypoints and ',' or '')
		end
		text=text..'}'
		return text
	elseif Type=='NumberSequence' or Type=='FloatSequence' then
		local text='{'
		local keypoints=Value.Keypoints
		for i,k in ipairs(keypoints) do text=text..string.format('{%s,%s,%s}',Utility.ToNumber(k.Time),Utility.ToNumber(k.Value),Utility.ToNumber(k.Envelope or 0))..(i<#keypoints and ',' or '') end
		text=text..'}'
		return text
	elseif Type=='NumberRange' or Type=='FloatRange' then
		if Value.Max==DefaultValue.Max then
			return string.format('{%s}',Utility.ToNumber(Value.Min))
		else
			return string.format('{%s,%s}',Utility.ToNumber(Value.Min),Utility.ToNumber(Value.Max))
		end
	elseif typeof(Value)=='EnumItem' or Type=='EnumItem' or string.find(Type,'Enum') then
		return tostring(Value)
	elseif Type=='Font' or typeof(Value)=='Font' then
		local family=Value.Family
		local weight=tostring(Value.Weight) 
		local style=tostring(Value.Style)
		weight=string.gsub(weight, "Enum%.FontWeight%.", "")
		style=string.gsub(style, "Enum%.FontStyle%.", "")
		if DefaultValue and typeof(DefaultValue) == "Font" then
			if Value.Family == DefaultValue.Family and Value.Weight == DefaultValue.Weight and Value.Style == DefaultValue.Style then
				return nil
			end
		end
		return string.format('Font{Family=%q,Weight=%s,Style=%s}', family, weight, style)
	elseif Type=='Content' or typeof(Value)=='Content' then
		local uri=typeof(Value)=="Content" and Value.Uri or tostring(Value)

		if DefaultValue then
			local defaultUri = typeof(DefaultValue) == "Content" and DefaultValue.Uri or tostring(DefaultValue)
			if uri == defaultUri then
				return nil
			end
		end

		return string.format('%q', Utility.Trim(uri):gsub("[\"\\]", "\\%1"))
	elseif Type=='PhysicalProperties' or typeof(Value)=='PhysicalProperties' then
		local Value:PhysicalProperties,DefaultValue:PhysicalProperties=Value,DefaultValue
		if Value.Density==DefaultValue.Density and Value.Friction==DefaultValue.Friction and Value.Elasticity==DefaultValue.Elasticity and Value.FrictionWeight==DefaultValue.FrictionWeight and Value.ElasticityWeight==DefaultValue.ElasticityWeight then
			return nil
		end
		if Value.ElasticityWeight==DefaultValue.ElasticityWeight then
			if Value.FrictionWeight==DefaultValue.FrictionWeight then
				if Value.Elasticity==DefaultValue.Elasticity then
					if Value.Friction==DefaultValue.Friction then
						return string.format('{%s}',Utility.ToNumber(Value.Density))
					end
					return string.format('{%s,%s}',Utility.ToNumber(Value.Density),Utility.ToNumber(Value.Friction))
				end
				return string.format('{%s,%s,%s}',Utility.ToNumber(Value.Density),Utility.ToNumber(Value.Friction),Utility.ToNumber(Value.Elasticity))
			end
			return string.format('{%s,%s,%s,%s}',Utility.ToNumber(Value.Density),Utility.ToNumber(Value.Friction),Utility.ToNumber(Value.Elasticity),Utility.ToNumber(Value.FrictionWeight))
		end
		return string.format('{%s,%s,%s,%s,%s}',Utility.ToNumber(Value.Density),Utility.ToNumber(Value.Friction),Utility.ToNumber(Value.Elasticity),Utility.ToNumber(Value.FrictionWeight),Utility.ToNumber(Value.ElasticityWeight))
	elseif Type=='SurfaceType' then
		for _,key in ipairs(Enum.SurfaceType:GetEnumItems()) do
			if Value.BackSurface.Name==key.Name and Value.BottomSurface.Name==key.Name and Value.FrontSurface.Name==key.Name and Value.LeftSurface.Name==key.Name and Value.RightSurface.Name==key.Name and Value.TopSurface.Name==key.Name then return string.format('Enum.SurfaceType.%s',key.Name) end
		end
		if Value.BackSurface==DefaultValue.BackSurface and Value.BottomSurface==DefaultValue.BottomSurface and Value.FrontSurface==DefaultValue.FrontSurface and Value.LeftSurface==DefaultValue.LeftSurface and Value.RightSurface==DefaultValue.RightSurface and Value.TopSurface==DefaultValue.TopSurface then return nil end
		return string.format('{%s,%s,%s,%s,%s,%s}',tostring(Value.BackSurface),tostring(Value.BottomSurface),tostring(Value.FrontSurface),tostring(Value.LeftSurface),tostring(Value.RightSurface),tostring(Value.TopSurface))
	else
		return string.format('%q',tostring(Value))
	end
end

function Module:BuildEncode(v,variables,targets,objectives,data,depth,func)
	if data.Duplicated[v] then return end
	data.Duplicated[v]=true

	data.Count+=1
	if data.Count % 20 == 0 then 
		RunService.Stepped:Wait() 
	end

	local canWrapText=data.CanWrapText
	local indent=string.rep("\t", depth)
	local innerIndent=string.rep("\t", depth + 1)
	local className,variable=v.ClassName,variables[v] or ''
	local isPart=v:IsA('BasePart')
	
	if func then
		func(data.Count,v,data.Max)
	end

	local bufferList={
		'{',
		canWrapText and '\n' or '',
		(canWrapText and innerIndent or '')..'ClassName='..SafeData.string(className)..',Id='..string.format('%s',tostring(variable:match('%d+') or '')),
		canWrapText and ',\n' or ','
	}
	
	local DefaultSurfaces=nil

	local properties,isPropertyChanged,actives,needle={},false,{},nil
	for propertyName,property,propertyIndex in Utility.GetProperties(ObjectClasses[className]) do
		if propertyIndex%20==0 then RunService.Stepped:Wait() end
		local propertyDefaultValue,propertyType,propertyValue=property.DefaultValue,property.DataType,v[propertyName]
		if propertyValue==propertyDefaultValue then continue end
		if propertyType=='Object' and propertyName=='Parent' then continue end
		needle=propertyType..'_'..propertyName 
		if actives[needle] then continue end actives[needle]=true
		if propertyType=='Object' then
			local objectTarget=variables and variables[propertyValue] or (targets and targets[propertyValue] and objectives[targets[propertyValue]])
			if objectTarget then
				table.insert(properties,tostring(propertyName)..'='..string.format('%s',tostring(objectTarget:match('%d+') or '')))
			end
		else
			if isPart and propertyType=='SurfaceType' or typeof(propertyValue)=='EnumItem' then 
				if Utility.IsStrings(propertyName,{'BackSurface','BottomSurface','FrontSurface','LeftSurface','RightSurface','TopSurface'}) then 
					if DefaultSurfaces==nil then DefaultSurfaces={} end
					DefaultSurfaces[propertyName]=propertyDefaultValue
					continue
				end 
			end
			local serializeValue=self:Serialize(propertyValue,propertyType,propertyDefaultValue)
			if serializeValue~=nil then
				table.insert(properties,tostring(propertyName)..'='..serializeValue)
			end
		end
		isPropertyChanged=true
	end
	
	if isPart and DefaultSurfaces then
		local ValueSurfaces={
			BackSurface=v.BackSurface,
			BottomSurface=v.BottomSurface,
			FrontSurface=v.FrontSurface,
			LeftSurface=v.LeftSurface,
			RightSurface=v.RightSurface,
			TopSurface=v.TopSurface
		}
		local serializeValue=self:Serialize(ValueSurfaces,'SurfaceType',DefaultSurfaces)
		if serializeValue~=nil then
			table.insert(properties,'SurfaceType='..serializeValue)
			isPropertyChanged=true
		end
	end
	
	local children=v:GetChildren()
	local childrenLen=#children

	if isPropertyChanged then
		table.insert(bufferList, canWrapText and innerIndent or '')
		table.insert(bufferList, 'Properties={'..table.concat(properties,',')..'}')
	end

	if childrenLen>0 then
		table.insert(bufferList, canWrapText and ',\n' or ',')
	else
		table.insert(bufferList, canWrapText and '\n' or '')
	end

	if childrenLen>0 then
		table.insert(bufferList, canWrapText and innerIndent..'Children={' or 'Children={')
		if canWrapText then
			table.insert(bufferList, '\n')
		end

		for i,child in ipairs(children) do
			local result=self:BuildEncode(child,variables,targets,objectives,data,depth+2,func)
			if canWrapText then
				table.insert(bufferList, innerIndent..'\t'..result)
			else
				table.insert(bufferList, result)
			end
			if i<childrenLen then 
				table.insert(bufferList, ',') 
			end
			if canWrapText then 
				table.insert(bufferList, '\n') 
			end
		end

		if canWrapText then
			table.insert(bufferList, innerIndent..'}\n')
		else
			table.insert(bufferList, '}')
		end

		table.clear(children)
	end

	table.insert(bufferList, canWrapText and indent..'}' or '}')

	actives={} 
	needle=nil 
	table.clear(properties)

	return table.concat(bufferList)
end

function Module:Process(selections,variables,objectives,targets,visual,func)
	local canWrapText=Values.CanWrapText
	local maxProgress=#selections

	local bufferList = {}
	table.insert(bufferList, 'local V={')
	if canWrapText then
		table.insert(bufferList, '\n')
	end

	local codings={}
	for _,value in ipairs(selections) do 
		if type(value)=='string' then 
			table.insert(codings,value) 
		end 
	end
	table.clear(selections)

	local data={Duplicated={},Count=0,Max=maxProgress,CanWrapText=canWrapText}
	local rootModel = visual:FindFirstChildOfClass('Model') or visual:FindFirstChildOfClass('Folder')

	if rootModel then
		local itemStr=self:BuildEncode(rootModel,variables,targets,objectives,data,1,func)
		if canWrapText then
			table.insert(bufferList, '\t'..itemStr..'\n')
		else
			table.insert(bufferList, itemStr)
		end
	end

	local codingsLen=#codings
	if codingsLen>0 then
		table.insert(bufferList, '{')
		for i,coding in ipairs(codings) do
			data.Count+=1
			if data.Count%20==0 then RunService.Stepped:Wait() end
			table.insert(buffer, "{ClassName='Coding',Properties={Value="..tostring(coding).."}}")
			if i<codingsLen then 
				table.insert(buffer, ',') 
			end
			if func then
				func(data.Count,coding,data.Max)
			end
		end
		table.insert(bufferList, '}')
		table.clear(codings)
	end

	if canWrapText then
		table.insert(bufferList, '}\nreturn V')
	else
		table.insert(bufferList, '} return V')
	end

	return table.concat(bufferList)
end

function Module:Convert(data,target)
	local lastTime=tick()

	local visualInstance=Instance.new('Model')
	visualInstance.Name='Visual'
	target.Parent=visualInstance

	Interfaces.StatusLabel:Set('Starting Object')
	self:Starting(target,function(i,v,length) Interfaces.StatusLabel:Set('Starting Object') self:SetStatus(2,i,length) end)
	task.wait(1)

	local length=#target:GetDescendants()+1
	if length>=MAX_CAP then Values.LastStatus=tostring(length)..' Object is Dangerous!' else Values.LastStatus='Grab '..tostring(length)..' Object' end
	Interfaces.StatusLabel:Set(Values.LastStatus)
	task.wait(1)

	Interfaces.StatusLabel:Set('Create Object')
	local selections,variables,objectives,advencedVariables=self:Creating(visualInstance,target,data,function(i,v,length) Interfaces.StatusLabel:Set('Create Object') self:SetStatus(2,i,length) end)
	task.wait(1)

	Interfaces.StatusLabel:Set('Process Object')
	local text=self:Process(selections,advencedVariables,objectives,variables,visualInstance,function(i,v,length) Interfaces.StatusLabel:Set('Process Object') self:SetStatus(2,i,length) end)
	task.wait(1)

	target.Parent=nil
	visualInstance:Destroy()
	Interfaces.StatusLabel:Set('Complete')
	task.wait(0.5)
	Interfaces.StatusLabel:Set('Text Length: '..tostring(#text))
	task.wait(1)
	return text
end

function Module:Instal()
	Interfaces.StatusLabel:Set('Instal' )
	self:SetUpdate(2) 
	task.wait(1)
	if not next(InstalCache) or not Values.InstalTarget then self:SetStatus(1,'Target Has Empty',2) return end
	if Values.Debounce then return end
	Values.Debounce=true
	local success,text=pcall(function() return self:Convert(InstalCache,Values.InstalTarget) end)
	if Values.Destroyed then return end
	if success and type(text)=='string' then
		setclipboard(text)
		Interfaces.StatusLabel:Set('Save To File!')
		local fileInfo={
			FileId=os.date('%Y%m%d%H%M%S',os.time()),
			Value=text
		}
		table.insert(FileCache,fileInfo)
		local canShutdown,canAutoSafeFile=Values.CanShutdown,Values.CanAutoSaveFile
		if canShutdown then
			canAutoSafeFile=true
		end
		if canAutoSafeFile then
			Module:SaveToFile()
		end
		if canShutdown then
			Interfaces.AutoSaveFileToggle:Replace(false)
			Module:Destroy()
			Players.LocalPlayer:Kick('Instal Complete')
			game:Shutdown()
			return
		end
	else
		Interfaces.StatusLabel:Set('An Error Occured')
		warn('['..PLUGIN_NAME..']',text)
	end
	task.wait(10)
	Interfaces.StatusLabel:Set('Status')
	Interfaces.LoaderLabel.Text='(0/0) 0%'
	if Values.GrabberModel then Values.GrabberModel:Destroy() Values.GrabberModel=nil end
	table.clear(InstalCache)
	self:SetUpdate(1)
	task.wait(1)
	Values.Debounce=false
end

function Module:Add()
	local lastGrabType=Values.GrabType
	if Utility.IsStrings(lastGrabType,GlobalData.Types.BannedGrabTypes) then 
		self:SetStatus(1,'This type not allowed',2) 
		return 
	end
	if lastGrabType=='Building' then
		local lastPlayerCharacter=LocalPlayer.Character
		local lastTarget=Values.BuildingTarget
		if Values.UseMyself then lastTarget=lastPlayerCharacter end
		if not lastTarget then self:SetStatus(1,lastGrabType..' Target Has Empty',2) return end
		if BuildingCache[lastTarget] then 
			self:SetStatus(1,lastTarget==lastPlayerCharacter and 'Myself Already Added' or 'Building Already Added',2)
			if Values.UseMyself and lastTarget==lastPlayerCharacter and Interfaces.UseMyselfToggle then
				Interfaces.UseMyselfToggle:Set(false)
			end
			return 
		end
		BuildingCache[lastTarget]=true
		Values.BuildingTarget=nil
		if not GrabTypeCache[lastGrabType] then GrabTypeCache[lastGrabType]=true end
	elseif lastGrabType=='MouseIcon' then
		local newMouse=LocalPlayer:GetMouse()
		local mouseIconTarget=newMouse.Icon
		if not mouseIconTarget or #tostring(mouseIconTarget)==0 then self:SetStatus(1,'MouseIcon Target Has Empty',2) return end
		if MouseIconCache[mouseIconTarget] then 
			self:SetStatus(1,'MouseIcon Already Added',2) 
			return 
		end
		MouseIconCache[mouseIconTarget]=true
		if not GrabTypeCache[lastGrabType] then GrabTypeCache[lastGrabType]=true end
	elseif lastGrabType=='Tool' then
		local newCharacter=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local isTool=false
		for i,v in ipairs(newCharacter:GetChildren()) do if v:IsA('Tool') then isTool=true table.insert(ToolCache,v:Clone()) end end
		if not isTool then self:SetStatus(1,'Tool Target Has Empty',2) return end
		if not GrabTypeCache[lastGrabType] then GrabTypeCache[lastGrabType]=true end
	elseif lastGrabType=='Gui' then
		local lastGuiTarget=Values.GuiTarget
		if not lastGuiTarget then self:SetStatus(1,'Gui Target Has Empty',2) return end
		if GuiCache[lastGuiTarget] then self:SetStatus(1,'Gui Already Added',2) return end
		GuiCache[lastGuiTarget]=true 
		Values.GuiTarget=nil
		if not GrabTypeCache[lastGrabType] then GrabTypeCache[lastGrabType]=true end
	else
		if GrabTypeCache[lastGrabType] then self:SetStatus(1,'Already Added',2) return end GrabTypeCache[lastGrabType]=true
	end
	self:SetStatus(1,'Successfully',2)
end

function Module:Reset()
	self:SetUpdate(1)
end

function Module:Destroy()
	if Values.Destroyed then return end
	Values.Destroyed=true
	Window:Destroy()
	Outliner:Destroy()
	self:SetUpdate(1)
	local k,v=next(Cacheds)
	while v do
		Cacheds[k]=nil
		v:Disconnect()
		k,v=next(Cacheds)
	end
	Values.PlayAnimationCache={}
end

function Module:Play()
	if Values.GrabType~='Animation' then return end
	local useMyself=Values.UseMyself
	local model=useMyself and LocalPlayer.Character or Values.BuildingTarget
	if not (model and model.Parent) then self:SetStatus(1,useMyself and 'No Myself Target' or 'No Building Target', 2) return end
	local animators:{Animator}=model:QueryDescendants('Animator')
	if #animators<=0 then self:SetStatus(1,'No Animator',2) return end
	local animationName=Values.AnimationName
	for _,animator in ipairs(animators) do
		local animation=nil
		for _,v in ipairs(animator.Parent.Parent:QueryDescendants('Animation')) do if v.Parent and v.Name==animationName and v.AnimationId~='' then animation=v break end end
		local animSaves=model:FindFirstChild('AnimSaves')
		local sequence=animSaves and animSaves:FindFirstChild(animationName)
		local animationToLoad=animation
		if not animationToLoad and sequence and sequence:IsA('KeyframeSequence') then
			local cache=Values.PlayAnimationCache
			if cache==nil then
				cache={}
				Values.PlayAnimationCache=cache
			end
			animationToLoad=cache[sequence]
			if not animationToLoad then
				local provider=Services.KeyframeSequenceProvider
				if not provider then continue end
				local success,animationId=pcall(function()
					return provider:RegisterKeyframeSequence(sequence)
				end)
				if not success or not animationId then
					self:SetStatus(1,'Animation Preview Failed',2)
					continue
				end
				local previewAnimation=Instance.new('Animation')
				previewAnimation.Name=animationName
				previewAnimation.AnimationId=animationId
				cache[sequence]=previewAnimation
				animationToLoad=previewAnimation
			end
			Values.PlayAnimationCache=cache
		end
		if not animationToLoad then self:SetStatus(1,sequence and 'Animation Id Missing' or 'Animation not found',2) continue end
		local animationTrack=nil
		local success,existingTrack=pcall(function() return animator:GetTrackByAnimationId(animationToLoad.AnimationId) end)
		if success then animationTrack=existingTrack end
		if not animationTrack then
			local loadSuccess,result=pcall(function() return animator:LoadAnimation(animationToLoad) end)
			if not loadSuccess or not result then self:SetStatus(1,'Animation Load Failed',2) continue end
			animationTrack=result
		end
		animationTrack.Looped=true
		local priorityName=Values.AnimationPriority
		local priority=Enum.AnimationPriority.Idle
		if priorityName~='' and priorityName~='Auto' then
			local selectedPriority=Enum.AnimationPriority[priorityName]
			if selectedPriority then
				priority=selectedPriority
			else
				self:SetStatus(1,'Invalid Animation Priority',2)
			end
		end
		animationTrack.Priority=priority
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do 
			if track~=animationTrack or track.IsPlaying then track:Stop(0.1) end 
		end
		animationTrack:Play(0.1,1,1) if animationTrack.Length>0 then animationTrack.TimePosition=0 end
	end
	self:SetStatus(1,'Play Complete',2)
end

function Module:Stop()
	if Values.GrabType~='Building' and Values.GrabType~='Animation' then return end
	local useMyself=Values.UseMyself
	local model=useMyself and LocalPlayer.Character or Values.BuildingTarget
	if not (model and model.Parent) then self:SetStatus(1,useMyself and 'No Myself Target' or 'No Building Target', 2) return end
	local animators=model:QueryDescendants('Animator')
	if #animators<=0 then self:SetStatus(1,'No Animator',2) return end
	for i,k in ipairs(animators) do local playingTracks=k:GetPlayingAnimationTracks() for j,v in ipairs(playingTracks) do v.TimePosition=0 v:Stop() end end
	self:SetStatus(1,'Stop Complete',2)
end

function Module:Record()
	if Values.GrabType~='Animation' then return end
	
	local useMyself=Values.UseMyself
	local target=useMyself and LocalPlayer.Character or Values.BuildingTarget
	if not (target and target.Parent) then self:SetStatus(1,useMyself and 'No Myself Target' or 'No Building Target', 2) return end
	
	local recordAnimationType,fpsMode,animationName=Values.RecordAnimType,Values.FPSType,Values.AnimationName
	local animators=target:QueryDescendants('Animator')
	if #animators<=0 then self:SetStatus(1,'No Animator',2) return end
	
	local function recordAnimation(animator)
		local model=animator.Parent.Parent

		local playingTracks:{AnimationTrack}=animator:GetPlayingAnimationTracks()
		local oldTrack=playingTracks[1]
		if #playingTracks<=0 then return end

		local length=oldTrack.Length
		if length<=0 then return end

		local sources={}
		if recordAnimationType=='Auto' then
			local bones,motors=model:QueryDescendants('Bone'),model:QueryDescendants('Motor6D')
			if #motors>0 then
				sources=motors
				recordAnimationType='Motor6D'
			elseif #bones>0 then
				sources=bones
				recordAnimationType='Bone'
			end
		else
			sources=recordAnimationType=='Bone' and model:QueryDescendants('Bone') or model:QueryDescendants('Motor6D')
		end
		if #sources<=0 then return end
		table.clear(sources)
		oldTrack.TimePosition=0
		local Recording=RecordAnimation.new(model,{
			Name=animationName,
			RecordAnimationType=recordAnimationType,
		})
		task.wait(length)
		Recording:Stop()
	end
	
	for _,animator in ipairs(animators)  do
		task.defer(recordAnimation,animator)
	end
	
	self:SetStatus(1,'Look at the dex',2)
end

function Module:SaveToFile()
	if isfile and writefile and isfolder and makefolder then
		if not Values.SaveDebounce then
			Values.SaveDebounce=true
			if #FileCache>0 then
				if not isfolder(Values.FolderName) then
					makefolder(Values.FolderName)
					task.wait(1)
				end
				Utility.Foreach(FileCache,function(info)
					local fileId=#Values.FileName>0 and Values.FileName..'_'..info.FileId or info.FileId
					local path=Values.FolderName..'/'..fileId..'.txt'
					writefile(path,info.Value)
					print('File Path:'..path)
					task.wait()
				end)
				Module:SetStatus(1,'Save Completed',2)
			end
			Values.SaveDebounce=false
		end
	end
end

local function OnCharacterToolAdded(character)
	if Cacheds.CharacterToolAdded then Cacheds.CharacterToolAdded:Disconnect() Cacheds.CharacterToolAdded=nil end
	if Cacheds.CharacterRemoved then Cacheds.CharacterRemoved:Disconnect() Cacheds.CharacterRemoved=nil end
	Cacheds.CharacterRemoved=character.AncestryChanged:Connect(function(_,parent) if not parent then if BuildingCache[character]~=nil then BuildingCache[character]=nil end end end)
	Cacheds.CharacterToolAdded=character.ChildAdded:Connect(function(child) if child:IsA('Tool') then Values.ToolTarget=child end end)
end

OnCharacterToolAdded(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
Cacheds.CharacterAdded=LocalPlayer.CharacterAdded:Connect(OnCharacterToolAdded)

Window=UI:CreateWindow({
	Name='Instal',
	ConfigInfo={Enabled=true,Path='Crokyreo/Instal/configs.json'},
	Destroying=function()
		Module:Destroy() 
	end
})

Outliner.Parent=Window.Gui

Window:AddButton({
	Text='Save to File',
	MethodType='DoubleClick',
	Callback=function()
		Module:SaveToFile()
	end
})
Interfaces.StatusLabel=Window:AddLabel({
	Text='Status',
	TextColor3=Color3.fromRGB(255,255,255),
	TextXAlignment=Enum.TextXAlignment.Center,
	Wrap=true
})
Interfaces.LoaderLabel=Window:AddLabel({
	Text='(0/0) 0%',
	TextColor3=Color3.fromRGB(255,255,255)
})
Interfaces.GrabTypeSelector=Window:AddSelector({
	Options=GlobalData.Types.GrabTypes,
	Value=GlobalData.Types.GrabTypes[1],
	NoCap=true,
	Flag='grab_type',
	Callback=function(value,key) 
		Values.GrabType=value 
		Module:SetUpdate(3) 
	end
})
Interfaces.FileNameTextBox=Window:AddInput({
	Text='File Name (Optional)',
	Visible=false,
	Callback=function(text)
		Values.FileName=text
	end
})
Interfaces.AutoSaveFileToggle=Window:AddToggle({
	Text='Can Auto Save File',
	Visible=false,
	Value=false,
	Callback=function(text)
		Values.CanAutoSaveFile=text
	end
})
Interfaces.UseNameToggle=Window:AddToggle({
	Text='No Name',
	Value=false,
	Visible=false,
	Callback=function(value) 
		Values.NoName=value
	end
})
Interfaces.UseMyselfToggle=Window:AddToggle({
	Text='Use Myself',
	Value=false,
	Visible=false,
	Callback=function(value) 
		Values.UseMyself=value
	end
})
Interfaces.CanShutdownToggle=Window:AddToggle({
	Text='Can Shutdown',
	Value=false,
	Visible=false,
	Callback=function(value) 
		Values.CanShutdown=value
	end
})
Interfaces.CanWrapTextToggle=Window:AddToggle({
	Text='Can Wrap Text',
	Value=Values.CanWrapText,
	Visible=false,
	Flag='wrap_text_enabled',
	Callback=function(value) 
		Values.CanWrapText=value
	end
})
Interfaces.TopSelect=Window:AddSelect({
	Text='None',
	Visible=false,
	Callback=function(target) 
		if Utility.IsStrings(Values.GrabType,{'Building','Animation'}) then 
			if not Values.TargetDebounce then
				Values.TargetDebounce=true
				if target then
					Values.BuildingIndex=0
					local current=target
					while current and current.Parent and current.Parent~=workspace do
						current=current.Parent
						Values.BuildingIndex=Values.BuildingIndex+1 
						if Values.TotalBuilding>0 and Values.BuildingIndex>=Values.TotalBuilding then
							target=current
							break
						end
					end
					if Window.Parent then
						Interfaces.TextBox.Title='Building Index (0-'.. tostring(Values.BuildingIndex)..')'
						Interfaces.TopSelect.Text=target.Name..' | '..target.ClassName..' | '..tostring(#target:GetChildren())
					end
					Module:SetUpdate(2,target)
					Values.BuildingTarget=target
				else
					Values.BuildingIndex=0
					if Window.Parent then
						Interfaces.TextBox.Title='Building Index (0-'.. tostring(Values.BuildingIndex)..')'
						Interfaces.TopSelect.Text='None'
					end
					Module:SetUpdate(2)
					Values.BuildingTarget=nil
				end
				task.wait(1)
				Values.TargetDebounce=false
			end
		end
	end,
	Deactivated=function() Module:SetUpdate(2) Module:SetStatus(1,Interfaces.StatusLabel.Text) end
})
Interfaces.MainLabel=Window:AddLabel({
	Text='',
	Visible=false,
	TextScaled=true
})
Interfaces.TextBox=Window:AddInput({
	Text='None',
	Visible=false,
	Callback=function(text)
		if Interfaces.TextBox==nil then return end
		local amount=tonumber(text)
		if amount then
			if Utility.IsStrings(Values.GrabType,{'Building','Animation'}) then 
				Values.TotalBuilding=math.max(amount,0)
				Interfaces.TextBox.Text=tostring(Values.TotalBuilding)
			end
		else
			local lastTextBox='Please enter the number'
			Interfaces.TextBox.Text=lastTextBox
			task.wait(1)
			if Interfaces.TextBox.Text==lastTextBox then
				Interfaces.TextBox.Text=''
			end
		end
	end
})
Interfaces.AnimationTextBox=Window:AddInput({
	Text='Animation Name',
	Visible=false,
	Callback=function(text)
		Values.AnimationName=text
		if Values.AnimationPriority=='Auto' then
			if Utility.FastFind(text,'Idle') then
				Interfaces.AnimationPrioritySelector:Set('Idle')
				return
			end
			for _,pattern in ipairs({'Run','Climb','Walk','Swim','Move'}) do 
				if Values.AnimationPriority~='Auto' then break end
				if Utility.FastFind(text,pattern) then
					Interfaces.AnimationPrioritySelector:Set('Movement')
					return
				end
			end
			for _,pattern in ipairs({'Carry','Steal','Attack'}) do 
				if Values.AnimationPriority~='Auto' then break end
				if Utility.FastFind(text,pattern) then
					Interfaces.AnimationPrioritySelector:Set('Action')
					return
				end
			end
		end
	end
})
Interfaces.AnimationTitle=Window:AddLabel({
	Text='Animation Rig Type',
	Visible=false,
	TextScaled=true
})
Interfaces.AnimationSelector=Window:AddSelector({
	Options=GlobalData.Types.RecordAnimTypes,
	Value=Values.RecordAnimType,
	NoCap=true,
	Visible=false,
	Flag='record_animation_type',
	Callback=function(value,key) 
		Values.RecordAnimType=value 
	end
})
Interfaces.FPSTitle=Window:AddLabel({
	Text='FPS',
	Visible=false,
	TextScaled=true
})
Interfaces.FPSSelector=Window:AddSelector({
	Options=GlobalData.Types.FPSTypes,
	Value=Values.FPSType,
	NoCap=true,
	Visible=false,
	Flag='frame_per_second_type',
	Callback=function(value,key) 
		Values.FPSType=value 
	end
})
Interfaces.RecordButton=Window:AddButton({
	Text='Record',
	Visible=false,
	MethodType='DoubleClick',
	Callback=function() 
		Module:Record() 
	end
})
Interfaces.AnimationPriorityTitle=Window:AddLabel({
	Text='Animation Priority',
	Visible=false,
	TextScaled=true
})
Interfaces.AnimationPrioritySelector=Window:AddSelector({
	Options=GlobalData.Types.AnimationPriority,
	Value='Auto',
	NoCap=true,
	Visible=false,
	Flag='animation_priority_type',
	Callback=function(value)
		Values.AnimationPriority=value
	end
})
Interfaces.PlayButton=Window:AddButton({
	Text='Play',
	Visible=false,
	MethodType='DoubleClick',
	Callback=function() 
		Module:Play() 
	end
})
Interfaces.StopButton=Window:AddButton({
	Text='Stop',
	Visible=false,
	MethodType='DoubleClick',
	Callback=function() 
		Module:Stop() 
	end
})
Interfaces.SoundSlider=Window:AddSlider({
	Text='Max Sound',
	Range={0,1000},
	Value=Values.MaxSound,
	Increment=1,
	Visible=false,
	Callback=function(amount)
		if Values.GrabType=='Sound' then 
			Values.MaxSound=math.max(amount,0)
		end
	end
})
Interfaces.AddButton=Window:AddButton({
	Text='Add',
	Visible=false,
	MethodType='DoubleClick',
	Callback=function() 
		Module:Add() 
	end
})
Interfaces.InitializeButton=Window:AddButton({
	Text='Initialize',
	MethodType='DoubleClick',
	Callback=function() 
		Module:Initialize() 
	end
})
Interfaces.InstalButton=Window:AddButton({
	Text='Instal',
	MethodType='DoubleClick',
	Callback=function() 
		Module:Instal() 
	end
})
Interfaces.ResetButton=Window:AddButton({
	Text='Reset',
	MethodType='DoubleClick',
	Callback=function() 
		Module:Reset() 
	end
})
Interfaces.DestroyButton=Window:AddButton({
	Text='Destroy',
	MethodType='DoubleClick',
	Callback=function() 
		Module:Destroy() 
	end
})

Module.Parent=true

Window:AddLinkButton({Text='Donate 💖',Link='https://link-target.net/6690566/TlR2vuR2JR4F'})
Window:AddLabel({Text='YouTube: Crokyreo',TextColor3=Color3.fromRGB(255,255,255)})
Window:LoadConfig()

queueteleport=Missing('function',queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport), function() end)

Cacheds.OnTeleport=Players.LocalPlayer.OnTeleport:Connect(function(State)
	if not Values.TeleportDone and queueteleport then
		Values.TeleportDone=true
		Module:Destroy()
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Crokier/Roblox/main/Scripts/InstalasiPalsu.lua'))()")
	end
end)
