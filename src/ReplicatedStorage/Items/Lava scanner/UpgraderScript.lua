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
					if Tag.Value >= 2 then
						ItemLib.Error(script.Parent.Upgrader)
						return
					end
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
	
	spawn(function()
		script.Parent.Upgrader.BodyPosition.Position = script.Parent.Des2.Position
		script.Parent.Upgrader.Position = script.Parent.Des2.Position
		while true do
			if not script.Parent then
				break
			end
			for i = 1,35 do
				if not script.Parent then
					break
				end
				script.Parent.Upgrader.BodyPosition.Position = script.Parent.Upgrader.BodyPosition.Position - (script.Parent.Upgrader.BodyPosition.Position - script.Parent.Des2.Position)/20
				wait()
			end
			for i = 1,35 do
				if not script.Parent then
					break
				end
				script.Parent.Upgrader.BodyPosition.Position = script.Parent.Upgrader.BodyPosition.Position - (script.Parent.Upgrader.BodyPosition.Position - script.Parent.Des1.Position)/20
				wait()
			end
		end
	end)
end

if Server then
	script.Upgrade.OnServerEvent:Connect(function(Player,Ore)
		if Ore.Parent ~= Tycoon.Ores then
			return
		end
		local Tag = ItemLib.GetTag(Ore,script.Parent.Name)
		if Tag then
			if Tag.Value >= 2 then
				return
			end
			ItemLib.UpdateTag(Ore,script.Parent.Name,Tag.Value + 1)
		else
			Tag = ItemLib.CreateTag(Ore,script.Parent.Name)
			ItemLib.UpdateTag(Ore,script.Parent.Name,1)
		end
		Ore.Cash.Value = (Ore.Cash.Value * 2.8)
	end)
	script.Parent.Upgrader.Anchored = false
	script.Parent.Upgrader:SetNetworkOwner(Owner.Value)
end

return module