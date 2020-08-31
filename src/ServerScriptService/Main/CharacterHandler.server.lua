game.Players.PlayerAdded:Connect(function(Player)
	if #game.Players:GetPlayers() <= 4 then
		Player.CharacterAdded:Connect(function(Character)
			Character:WaitForChild("HumanoidRootPart")
			Character:WaitForChild("Humanoid")
			repeat wait() until Player:FindFirstChild("CheckDone")
			local Tycoon = Player.PlayerTycoon.Value
			local Spawns = {}
			
			if Tycoon ~= nil then
				for _,v in pairs(Tycoon.Items:GetChildren()) do
					if v.Name == "Spawn Pad" then
						table.insert(Spawns,v.Spawn)
					end
				end
			end
			
			wait(0.05)
			local CF
			if #Spawns > 0 then
				local Spawn = Spawns[math.random(1,#Spawns)]
				if Spawn ~= nil then
					CF = Spawn.CFrame + Vector3.new(0,20,0)
				else
					CF = Tycoon.Base.CFrame + Vector3.new(0,20,0)
				end
			else
				CF = Tycoon.Base.CFrame + Vector3.new(0,20,0)
			end
			for i = 1,5 do
				Character.HumanoidRootPart.CFrame = CF
				wait()
			end
			
			--Gamepass stuff related to their character
			if Player:FindFirstChild("Dev") then
				if Character.HumanoidRootPart:FindFirstChild("Dev") == nil then
					script.Dev:Clone().Parent = Character.HumanoidRootPart
				end
			elseif Player:FindFirstChild("MVP") then
				if Character.HumanoidRootPart:FindFirstChild("MVP") == nil then
					script.MVP:Clone().Parent = Character.HumanoidRootPart
				end
			elseif Player:FindFirstChild("VIP") then
				if Character.HumanoidRootPart:FindFirstChild("VIP") == nil then
					script.VIP:Clone().Parent = Character.HumanoidRootPart
				end
			end
			if Player:FindFirstChild("Orb") then
				if Player.Backpack:FindFirstChild("Defense Orb") == nil then
					game.Lighting["Defense Orb"]:Clone().Parent = Player.Backpack
				end
				Character.Humanoid.MaxHealth = Character.Humanoid.MaxHealth + 20
				Character.Humanoid.Health = Character.Humanoid.MaxHealth
			end
			if Player:FindFirstChild("MVP") then
				if Player.Backpack:FindFirstChild("Sword") == nil then
					game.Lighting.Sword:Clone().Parent = Player.Backpack
				end
			end
			
			Character.Humanoid.NameOcclusion = Enum.NameOcclusion.OccludeAll
			game.ServerStorage.CheckPasses:Fire(Player)
		end)
	end
end)