local UI = loadstring(game:HttpGet("http://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services=setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local Players=Services.Players
local RunService=Services.RunService
local UserInputService=Services.UserInputService
local VirtualInputManager=Services.VirtualInputManager

local LocalPlayer=Players.LocalPlayer
local PlayerGui=LocalPlayer:FindFirstChildOfClass("PlayerGui")

local Enableds={["Raycast"]=false}

local RaycastInfo={
  Distance=50, -- Jarak jangkauan raycast
  Speed=14, -- Kecepatan interpolasi sudut (makin tinggi makin responsif & mulus)
  UseSweep=true, -- Set 'true' agar sinar mengayun memindai area terus-menerus tanpa celah
  SweepSpeed = 2.5, -- Kecepatan ayunan radar
  SweepRange=25 -- Jangkauan ayunan derajat (+25° ke kanan, -25° ke kiri)
}

local Window=UI:CreateWindow({
	Name="Raycaster",
	Destroying=function()
		task.cancel(ClickThread)
		for key, enabled in pairs(Enableds) do
			Enableds[key]=false
		end
	end
})

-- ==================== KONFIGURASI ====================
local DISTANCE = 50             
local SMOOTH_SPEED = 14         
local USE_CONTINUOUS_SWEEP = true

-- Konfigurasi Ayunan Radar (Derajat mendaki menggunakan Gelombang Sinus)
local SWEEP_SPEED = 2.5         
local SWEEP_RANGE = 25          

-- Sudut Dasar Sinar (Dibuat lebih rapat agar menutup celah/gap)
local baseTargetAngles = {
	["Front"]         = 0,
	["Left Front"]    = 30,
	["Right Front"]   = -30,
	["Left Mid"]      = 60,
	["Right Mid"]     = -60,
	["Left"]          = 90,
	["Right"]         = -90,
}

-- Tracking State
local currentAngles = {}
for name in pairs(baseTargetAngles) do
	currentAngles[name] = 0
end

local visualParts = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- Helper function untuk menggambar sinar visual
local function drawVisualRay(name, origin, directionVector, color)
	local visualPart = visualParts[name]
	
	if not visualPart or not visualPart:IsDescendantOf(workspace) then
		visualPart = Instance.new("Part")
		visualPart.Name = "RayVisual_" .. name
		visualPart.Material = Enum.Material.Neon
		visualPart.Anchored = true
		visualPart.CanCollide = false
		visualPart.CanQuery = false
		visualPart.CanTouch = false
		visualPart.Parent = workspace
		visualParts[name] = visualPart
	end
	
	local length = directionVector.Magnitude
	if length < 0.001 then length = 0.001 end
	
	local midPoint = origin + (directionVector / 2)
	visualPart.Color = color
	visualPart.Size = Vector3.new(0.12, 0.12, length)
	visualPart.CFrame = CFrame.lookAt(midPoint, origin + directionVector)
end

-- Core Function dengan Interpolasi Derajat Mulus
local function castSmoothDirectionalRays(character, distance, dt)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return {} end

	local origin = rootPart.Position
	local baseCFrame = rootPart.CFrame
	raycastParams.FilterDescendantsInstances = {character}

	local results = {}

	-- Hitung offset ayunan derajat halus menggunakan Gelombang Sinus (Sine Wave)
	local sweepOffset = 0
	if USE_CONTINUOUS_SWEEP then
		sweepOffset = math.sin(os.clock() * SWEEP_SPEED) * SWEEP_RANGE
	end

	for name, baseAngle in pairs(baseTargetAngles) do
		-- Sudut target aktual + ayunan pemindai
		local targetAngle = baseAngle + sweepOffset

		-- Formula Derajat Mendaki Halus (Eksponensial Lerp berdasarkan Delta Time)
		local lerpFactor = 1 - math.exp(-SMOOTH_SPEED * dt)
		currentAngles[name] = currentAngles[name] + (targetAngle - currentAngles[name]) * lerpFactor
		
		-- Rotasi CFrame berdasarkan derajat saat ini
		local angleRotation = CFrame.Angles(0, math.rad(currentAngles[name]), 0)
		local directionVector = (baseCFrame * angleRotation).LookVector * distance
		
		-- Raycast
		local raycastResult = workspace:Raycast(origin, directionVector, raycastParams)
		results[name] = raycastResult
		
		-- Tentukan Warna & Panjang Sinar
		local visualDirection = directionVector
		local rayColor = Color3.fromRGB(255, 0, 0) -- Merah saat tidak kena objek

		if raycastResult then
			visualDirection = raycastResult.Position - origin
			rayColor = Color3.fromRGB(0, 255, 0) -- Hijau saat mengenai halangan
		end
		
		drawVisualRay(name, origin, visualDirection, rayColor)
	end

	return results
end

-- Cleanup saat karakter respawn/mati
LocalPlayer.CharacterRemoving:Connect(function()
	for _, part in pairs(visualParts) do
		if part then part:Destroy() end
	end
	table.clear(visualParts)
end)

-- Main Loop dengan Delta Time (dt)
task.spawn(function()
	while true do
		local dt = task.wait() -- Mengambil nilai selisih waktu antar frame untuk kehalusan ekstra
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				castSmoothDirectionalRays(character, DISTANCE, dt)
			end
		end
	end
end)
