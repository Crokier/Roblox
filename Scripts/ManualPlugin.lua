-- To Fix UI Stroke
for _, child in game:GetService("StarterGui"):GetDescendants() do 
	if not child:IsA("UIStroke") or not child.Parent:IsA("GuiObject") then 
		continue 
	end 
	if child.Parent.AbsoluteSize.Magnitude == 0 then 
		continue 
	end 
	local frame = child.Parent 
	local shortestSize = math.min(frame.AbsoluteSize.X,frame.AbsoluteSize.Y)
	local pixelStroke = child.Thickness 
	local newSize = pixelStroke/shortestSize 
	child.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize 
	child.Thickness = newSize 
end
