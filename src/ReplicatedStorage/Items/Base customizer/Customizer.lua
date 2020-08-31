local module = {}

local Client = game:FindService("NetworkClient")
local Server = game:FindService("NetworkServer")
local Tycoon = script.Parent.Parent.Parent
local Owner = Tycoon.Owner

if Client then
	for _,v in pairs(script.Parent.ColorButtons:GetChildren()) do
		v.Click.MouseHoverEnter:Connect(function()
			script.SelectionBox.Adornee = v
		end)
		v.Click.MouseHoverLeave:Connect(function()
			script.SelectionBox.Adornee = nil
		end)
		v.Click.MouseClick:Connect(function()
			script.Click:Play()
			script.Change:FireServer(v)
		end)
	end
	for _,v in pairs(script.Parent.MaterialButtons:GetChildren()) do
		v.Click.MouseHoverEnter:Connect(function()
			script.SelectionBox.Adornee = v
		end)
		v.Click.MouseHoverLeave:Connect(function()
			script.SelectionBox.Adornee = nil
		end)
		v.Click.MouseClick:Connect(function()
			script.Click:Play()
			script.Change:FireServer(v)
		end)
	end
end

if Server then
	script.Parent.Rep.Material = Tycoon.Base.Material
	script.Parent.Rep.BrickColor = Tycoon.Base.BrickColor
	script.Change.OnServerEvent:Connect(function(Player,Part)
		if Part.Parent == script.Parent.MaterialButtons then
			script.Parent.Rep.Material = Part.Material
			Tycoon.Base.Material = Part.Material
		elseif Part.Parent == script.Parent.ColorButtons then
			script.Parent.Rep.BrickColor = Part.BrickColor
			Tycoon.Base.BrickColor = Part.BrickColor
		end
	end)
end

return module