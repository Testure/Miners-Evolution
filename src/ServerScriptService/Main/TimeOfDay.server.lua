local DTIM = 20
local Hour = 10
local Min = 0

math.randomseed(os.time())
local Range = 6000
if workspace:FindFirstChild("Private") then
	Range = 25000
end

repeat wait() until workspace:FindFirstChild("Map") ~= nil and #workspace.Tycoons:GetChildren() == 4
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

spawn(function() -- Players with low research get more crates
	while wait(180) do
		for _,Player in pairs(game.Players:GetPlayers()) do
			if Player:FindFirstChild("Values") and Player.Values:FindFirstChild("Research") then
				if Player.Values.Research.Value < MoneyLib.STV("10K") then
					if Player.PlayerTycoon.Value then
						local Crate = game.ServerStorage.Crate:Clone()
						Crate.CFrame = Player.PlayerTycoon.Value.Base.CFrame + Vector3.new(math.random(-50,50),100,math.random(-50,50))
						Crate.Parent = workspace
						require(Crate.CrateScript)
						game.Debris:AddItem(Crate,600)
					end
				end
			end
		end
	end
end)

local Tycoons = workspace.Tycoons:GetChildren()

while true do
	wait(DTIM/48)
	
	local TycoonCFrame = Tycoons[math.random(1,#Tycoons)].Base.CFrame + Vector3.new(0,100,0)
	local CrateCFrame = TycoonCFrame + Vector3.new(math.random(-200,200),5,math.random(-200,200))
	local Chance = math.random(1,Range)
	
	if (game.ReplicatedStorage.Night.Value and (Chance == 3400 or Chance == 3700)) or Chance == 2183 then
		local Crate = game.ServerStorage.DiamondCrate:Clone()
		Crate.CFrame = CrateCFrame
		Crate.Parent = workspace
		require(Crate.CrateScript)
		game.Debris:AddItem(Crate,600)
		game.ReplicatedStorage.CreateChatMessage:FireAllClients("A Diamond Crate has dropped!",Color3.fromRGB(159,243,233))
	elseif (game.ReplicatedStorage.Night.Value and Chance == 4777) or Chance == 777 then
		local Crate = game.ServerStorage.LargeAngeliteCrate:Clone()
		Crate.CFrame = CrateCFrame
		Crate.Parent = workspace
		require(Crate.CrateScript)
		game.Debris:AddItem(Crate,600)
	elseif Chance == 4000 or Chance == 1000 or Chance == 5800 or Chance == 2000 or Chance == 2005 or Chance == 2008 then
		local Crate = game.ServerStorage.AngeliteCrate:Clone()
		Crate.CFrame = CrateCFrame
		Crate.Parent = workspace
		require(Crate.CrateScript)
		game.Debris:AddItem(Crate,500)
	end
	
	if game.ReplicatedStorage.Night.Value then
		Min = Min + 2
		local Chance = math.random(1,(workspace:FindFirstChild("Private") and 1300) or 300)
		if Chance <= 7 then
			local Crate = game.ServerStorage.Crate:Clone()
			Crate.CFrame = CrateCFrame
			Crate.Parent = workspace
			require(Crate.CrateScript)
			game.Debris:AddItem(Crate,300)
		elseif Chance == 8 or Chance == 9 then
			local Crate = game.ServerStorage.GoldCrate:Clone()
			Crate.CFrame = CrateCFrame
			Crate.Parent = workspace
			require(Crate.CrateScript)
			game.Debris:AddItem(Crate,300)
		end
	else
		Min = Min + 1
		local Chance = math.random(1,600)
		if Chance == 5 or Chance == 6 or Chance == 7 or Chance == 14 or Chance == 18 or Chance == 22 then
			local Crate = game.ServerStorage.Crate:Clone()
			Crate.CFrame = CrateCFrame
			Crate.Parent = workspace
			require(Crate.CrateScript)
			game.Debris:AddItem(Crate,300)
		end
	end
	
	if Min >= 120 then
		Min = 0
		Hour = Hour + 1
		if Hour >= 24 then
			Hour = 0
		end
	end
	
	game.ReplicatedStorage.Night.Value = ((Hour > 17 and Min > 20) or Hour > 18 or (Hour < 6 and Min < 15) or Hour < 7)
	game.Lighting.TimeOfDay = Hour..":"..Min/2
end