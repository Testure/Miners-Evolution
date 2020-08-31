local module = {}

local Client = game:FindService("NetworkClient")
local Server = game:FindService("NetworkServer")
local Tycoon = script.Parent.Parent.Parent
local Owner = Tycoon.Owner
local ItemLib = require(game.ReplicatedStorage.ItemLib)
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

if Client then
	script.Parent.Upgrader.Touched:Connect(function(Hit)
		if Hit.Parent and Hit:IsDescendantOf(Tycoon) then
			if Hit.Parent == Tycoon.Ores then
				local Tag = ItemLib.GetTag(Hit,script.Parent.Name)
				if Tag then
					if Tag.Value >= 25 then
						ItemLib.Error(script.Parent.Upgrader)
						return
					end
				end
				if Hit.Cash.Value > MoneyLib.STV("500B") then
					ItemLib.Error(script.Parent.Upgrader)
					return
				end
				script.Upgrade:FireServer(Hit)
			end
		end
	end)
	
	for _,v in pairs(script.Parent:GetChildren()) do
		if v.Name == "Conveyor" then
			v.Velocity = v.CFrame.LookVector * v.Speed.Value
			v.Speed.Changed:Connect(function()
				v.Velocity = v.CFrame.LookVector * v.Speed.Value
			end)
		end
	end
end

if Server then
	script.Upgrade.OnServerEvent:Connect(function(Player,Ore)
		if Ore.Parent ~= Tycoon.Ores then
			return
		end
		local Tag = ItemLib.GetTag(Ore,script.Parent.Name)
		if Ore.Cash.Value > MoneyLib.STV("500B") then
			return
		end
		if Tag then
			if Tag.Value >= 25 then
				return
			end
			ItemLib.UpdateTag(Ore,script.Parent.Name,Tag.Value + 1)
		else
			Tag = ItemLib.CreateTag(Ore,script.Parent.Name)
			ItemLib.UpdateTag(Ore,script.Parent.Name,1)
		end
		Ore.Cash.Value = (Ore.Cash.Value + MoneyLib.STV("500M"))
		if Ore:FindFirstChild("Flaming") and Ore.Flaming.Heat.Value < 20 then
			ItemLib.FreezeOre(Ore,Ore.Flaming.Heat.Value)
		end
	end)
end

return module