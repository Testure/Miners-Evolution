local module = {}

local Client = game:FindService("NetworkClient")
local Server = game:FindService("NetworkServer")
local Tycoon = script.Parent.Parent.Parent
local Owner = Tycoon.Owner

if Server then
	local DB = false
	local Part = script.Parent.SwordGiver
	local Weapon = "Illumina"

	Part.Touched:Connect(function(Hit)
		local Human = Hit.Parent:FindFirstChild("Humanoid")
		local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
		if Human and Player then
			if not DB then
				DB = true
				local Clone = game.Lighting:FindFirstChild(Weapon):Clone()
				Clone.Parent = Player.Backpack
				delay(1,function()
					DB = false
				end)
			end
		end
	end)
	
	local Ti = TweenInfo.new(
		1.5,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut,
		-1,
		true,
		0
	)
	
	local Tween = game.TweenService:Create(Part,Ti,{Position = Vector3.new(Part.Position.X,Part.Position.Y + 1,Part.Position.Z)})
	Tween:Play()
end

return module