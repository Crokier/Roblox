-- Example: "Check1" -> 1
local s = "Check1"
local tier = tonumber(s:match("%d+") or "")
print(tier) -- Output: 1

-- Example: "1. A\n2. D" -> {{["Tier"] = "1", ["Letter"] = "A"}, {["Tier"] = "2", ["Letter"] = "D"}}
local s = "1. A\n2. D"
local list = {}
for tier, letter in string.gmatch(s, "(%d+)%.%s*(%a+)") do
    print("Tier:", tier, "| Letter:", letter) -- Output: Tier: 1 | Letter: A
end

-- Example: "STOCK: 1.5K" -> "1.5K"
local s = "STOCK: 1.5K"
local text = string.gsub(text, "STOCK:%s*", "")
print(text) -- Output: "1.5K"

-- Example: "2.5x" -> "2.5"
local s = "2.5x"
local multiple = string.match(text, "[%d%.]+")
print(multiple) -- Output: "2.5"

task.wait(7)

local Strs=nil

if script.Parent.Name=="Strs" then
	Strs=require(script.Parent)
else
	Strs=require(game:GetService("ReplicatedStorage").Packages.Strs)
end

-- Example: 0/0 -> "NaN"
local nan=Strs.ToNaN(0/0)
print(`Strs.ToNaN: {nan}`)

-- Example: math.huge -> "∞"
local inf=Strs.ToInf(math.huge)
print(`Strs.ToInf: {inf}`)

local progress,maxProgress=5,300

local percentaseDefault=Strs.ToPersentase(progress,maxProgress,2)
print(`Strs.ToPersentase Default: {percentaseDefault}`)

local percentaseReverse=Strs.ToPersentase(progress,maxProgress,2,true)
print(`Strs.ToPersentase Reverse: {percentaseReverse}`)

local money=12500000
local formatNumber=Strs.FormatNumber(money)
print(`Strs.FormatTime: {formatNumber}`)

local duration=1350
local formatTime=Strs.FormatTime(duration)
print(`Strs.FormatTime: {formatTime}`)

-- Example: nil or "\n" or " " or "" -> true
local isEmpty=Strs.IsEmpty(nil or "\n" or " " or "")
print(`Strs.IsEmpty: {isEmpty}`)

local List={
	"Apple",
	"Watermelon",
	"Mango",
	"Flower"
}

local isString=Strs.IsStrings("Avocado",List)
print(`Strs.IsStrings: {isString}`)
