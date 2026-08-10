local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local MarketplaceService = Services.MarketplaceService
local placeId = game.PlaceId
local info = MarketplaceService:GetProductInfoAsync(placeId)

local function InspectInfo(info)
	UI:Notify({
		Title = "Info",
		Description = info.Name,
		Icon = info.IconImageAssetId,
		Duration = -1
	})
	local s = ""
	for k,v in pairs(info) do
		if k == "Creator" and typeof(v) == "table" then
			s = s .. "CreatorType" .. " = " .. tostring(v.CreatorType) .. "\n"
			s = s .. "CreatorTargetId" .. " = " .. tostring(v.CreatorTargetId) .. "\n"
			s = s .. "CreatorName" .. " = " .. tostring(v.Name) .. "\n"
			s = s .. "CreatorId" .. " = " .. tostring(v.Id) .. "\n"
		else
			s = s .. k .. " = " .. tostring(v) .. "\n"
		end
	end
	warn(s)
end

if info then
	InspectInfo(info)
	if info.TargetId and info.TargetId > 0 then
		task.wait(2)
		local newInfo = MarketplaceService:GetProductInfoAsync(info.TargetId)
		InspectInfo(newInfo)
	end
end
