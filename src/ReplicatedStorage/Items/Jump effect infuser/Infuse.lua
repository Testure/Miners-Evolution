local module = {}

local Client = game:FindService("NetworkClient")
local Server = game:FindService("NetworkServer")
local Tycoon = script.Parent.Parent.Parent
local Owner = Tycoon.Owner

if Server then
	local DB = false
	script.Parent.Pad.Touched:Connect(function(Hit)
		if not DB then
			local Human = Hit.Parent:FindFirstChild("Humanoid")
			if Human and not Hit.Parent:FindFirstChild("Infused") then
				DB = true
				local Tag = Instance.new("StringValue")
				Tag.Parent = Hit.Parent
				Tag.Name = "Infused"
				Tag.Value = "Jump"
				Human.JumpPower = Human.JumpPower + 14
				script.Parent.Pad.Sound:Play()
				script.Parent.Pad.Boom.Enabled = true
				wait(.1)
				script.Parent.Pad.Boom.Enabled = false
				wait(.9)
				DB = false
			end
		end
	end)
end

return module