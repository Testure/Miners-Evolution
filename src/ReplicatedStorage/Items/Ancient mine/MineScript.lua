local module = {}

local Client = game:FindService("NetworkClient")
local Server = game:FindService("NetworkServer")
local Tycoon = script.Parent.Parent.Parent
local Owner = Tycoon.Owner
local Producing = Tycoon.Producing
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

-- Globals
-- This should be what is mostly edited
local CoolDown = 2.5 -- Interval in seconds between drops
local Size = Vector3.new(1,1,1) -- Size of the drops
local Material = Enum.Material.Slate -- Material of the drops
local Color = BrickColor.new("Medium stone grey").Color -- Color of the drops
local OreValue = MoneyLib.STV("25K") -- Value of the drops

-- Server Code
-- Edit the code only if you know what you're doing
if Server then
	local Lib = require(game.ReplicatedStorage.OreLib)
	
	local function SpawnOre()
		if not script.Parent then
			return
		end
		local Part,Cash = Lib.NewOre(script.Parent,script.Parent.Name)
		Cash.Value = OreValue
		Part.Size = Size
		Part.Material = Material
		Part.Color = Color
		Part.CFrame = script.Parent.Dropper.CFrame - Vector3.new(0,1,0)
	end
	
	while wait(CoolDown) do
		if not script.Parent then
			break
		end
		if Producing.Value and Owner.Value then
			SpawnOre()
		end
	end
end

return module