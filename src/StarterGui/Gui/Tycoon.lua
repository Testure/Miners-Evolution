local module = {}

function module.GetTycoon(Player)
	Player = Player or game.Players.LocalPlayer
	return Player.ActiveTycoon.Value
end

function module.init(Modules)
	local Connections = {}
	
	local function Hook()
		for i,v in pairs(Connections) do
			v:Disconnect()
			table.remove(Connections,i)
		end
		local Tycoon = module.GetTycoon()
		if Tycoon then
			local Owner = Tycoon.Owner.Value
			if Owner then
				local Money = Owner:FindFirstChild("Money")
				local Research = Owner.Values:FindFirstChild("Research")
				local Angelite = Owner.Values:FindFirstChild("Angelite")
				local Income = Owner:FindFirstChild("AverageIncome")
				local Shards = game.Players.LocalPlayer.Values:FindFirstChild("Shards")
				local Ores = Tycoon.Ores
				
				if Money then
					table.insert(Connections,Money.Changed:Connect(function()
						script.Parent.Money.Value = Money.Value
					end))
					script.Parent.Money.Value = Money.Value
				end
				if Angelite then
					table.insert(Connections,Angelite.Changed:Connect(function()
						script.Parent.Angelite.Value = Angelite.Value
					end))
					script.Parent.Angelite.Value = Angelite.Value
				end
				if Research then
					table.insert(Connections,Research.Changed:Connect(function()
						script.Parent.Research.Value = Research.Value
					end))
					script.Parent.Research.Value = Research.Value
				end
				if Income then
					table.insert(Connections,Income.Changed:Connect(function()
						script.Parent.Change.Value = Income.Value
					end))
					script.Parent.Change.Value = Income.Value
				end
				if Shards then
					table.insert(Connections,Shards.Changed:Connect(function()
						script.Parent.Shards.Value = Shards.Value
					end))
					script.Parent.Shards.Value = Shards.Value
				end
				if Ores then
					table.insert(Connections,Ores.ChildAdded:Connect(function()
						script.Parent.HUDLeft.MenuButton.OreLimit.Visible = (#Ores:GetChildren() >= 1)
						script.Parent.HUDLeft.MenuButton.OreLimit.Text.Text = tostring(#Ores:GetChildren()).." / "..tostring(Owner.OreLimit.Value)
						local Progress = #Ores:GetChildren()/Owner.OreLimit.Value
						if Progress >= 0.7 then
							script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(255,84,84)
						elseif Progress >= 0.4 then
							script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(255,255,84)
						else
							script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(0,255,134)
						end
						script.Parent.HUDLeft.MenuButton.OreLimit.Progress.Size = UDim2.new(math.clamp(Progress,0,1),0,1,0)
					end))
					table.insert(Connections,Ores.ChildRemoved:Connect(function()
						script.Parent.HUDLeft.MenuButton.OreLimit.Visible = (#Ores:GetChildren() >= 1)
						script.Parent.HUDLeft.MenuButton.OreLimit.Text.Text = tostring(#Ores:GetChildren()).." / "..tostring(Owner.OreLimit.Value)
						local Progress = #Ores:GetChildren()/Owner.OreLimit.Value
						if Progress >= 0.7 then
							script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(255,84,84)
						elseif Progress >= 0.4 then
							script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(255,255,84)
						else
							script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(0,255,134)
						end
						script.Parent.HUDLeft.MenuButton.OreLimit.Progress.Size = UDim2.new(math.clamp(Progress,0,1),0,1,0)
					end))
					script.Parent.HUDLeft.MenuButton.OreLimit.Visible = (#Ores:GetChildren() >= 1)
					script.Parent.HUDLeft.MenuButton.OreLimit.Text.Text = tostring(#Ores:GetChildren()).." / "..tostring(Owner.OreLimit.Value)
					local Progress = #Ores:GetChildren()/Owner.OreLimit.Value
					if Progress >= 0.7 then
						script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(255,84,84)
					elseif Progress >= 0.4 then
						script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(255,255,84)
					else
						script.Parent.HUDLeft.MenuButton.OreLimit.Progress.BackgroundColor3 = Color3.fromRGB(0,255,134)
					end
					script.Parent.HUDLeft.MenuButton.OreLimit.Progress.Size = UDim2.new(math.clamp(Progress,0,1),0,1,0)
				end
			end
		end
	end
	
	game.Players.LocalPlayer.ActiveTycoon.Changed:Connect(Hook)
	Hook()
	
	game.ReplicatedStorage.RequireModule.OnClientEvent:Connect(function(Module)
		require(Module)
	end)
end

return module