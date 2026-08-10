local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Crokier/Roblox/main/Packages/Sampluy/init.luau"))()

local Services = setmetatable({}, {__index = function(_, i) return cloneref and cloneref(game:GetService(i)) or game:GetService(i) end})
local MarketplaceService = Services.MarketplaceService
local placeId = game.PlaceId
local info = MarketplaceService:GetProductInfoAsync(placeId)

if info then
	UI:Notify({
		Title = "Info",
		Description = info.Name,
		Icon = info.IconImageAssetId
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
