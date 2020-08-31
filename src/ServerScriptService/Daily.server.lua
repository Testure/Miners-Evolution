local Code = "hum" -- Code to reset gift

local function Day()
	return math.floor(os.time()/(60*60*24))
end

game.ReplicatedStorage:WaitForChild("Items")
local Items = {}
for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	if v.ItemType.Value >= 1 and v.ItemType.Value <= 4 then
		if v:FindFirstChild("InShop") then
			table.insert(Items,v)
		end
	end
end

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
	return nil
end

function Award(Player)
	if Player:FindFirstChild("Gifted") == nil then
		local ExtraRewards = {}
		
		local Tag = Instance.new("BoolValue")
		Tag.Parent = Player
		Tag.Name = "Gifted"
		
		local Round = 7 * math.floor(Player.LoginStreak.Value / 7)
		local Progress = 0
		
		if Player.LoginStreak.Value > 1 and Player:FindFirstChild("SecondGift") == nil then
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." has opened their daily gift "..tostring(Player.LoginStreak.Value).." days in a row!",Color3.fromRGB(180,128,255))
		end
		
		if Player.LoginStreak.Value > 1 and (Player.LoginStreak.Value - Round == 3) then
			Player.Boxes.Rare.Value = Player.Boxes.Rare.Value + 1
			local Box = game.ReplicatedStorage.Boxes.Rare
			table.insert(ExtraRewards,{Name = "1 Rare Box ("..tostring(Player.LoginStreak.Value).." days)",Image = Box.Image.Value,Color = Box.Color.Value})
		end
		if Player.LoginStreak.Value > 1 and (Player.LoginStreak.Value - Round == 5) then
			Player.Boxes.Epic.Value = Player.Boxes.Epic.Value + 1
			local Box = game.ReplicatedStorage.Boxes.Epic
			table.insert(ExtraRewards,{Name = "1 Epic Box ("..tostring(Player.LoginStreak.Value).." days)",Image = Box.Image.Value,Color = Box.Color.Value})
		end
		
		-- Crate drops
		if Player:FindFirstChild("VIP") then
			local Crate = game.ServerStorage.VIPCrate:Clone()
			Crate.Parent = workspace
			require(Crate.CrateScript)
			pcall(function()
				Crate.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				Crate:SetNetworkOwnership(Player)
			end)
			local Chance = math.random(1,20)
			local CrateName = ""
			if Chance == 10 then
				CrateName = "DiamondCrate"
			elseif Chance >= 19 then
				CrateName = "AngeliteCrate"
				local Chance2 = math.random(1,3)
				if Chance2 == 3 then
					CrateName = "LargeAngeliteCrate"
				end
			else
				CrateName = "GoldCrate"
			end
			local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
			Crate.Parent = workspace
			require(Crate.CrateScript)
			pcall(function()
				Crate.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				Crate:SetNetworkOwnership(Player)
			end)
		end
		
		if Player:FindFirstChild("MVP") then
			local Crate = game.ServerStorage.MVPCrate:Clone()
			Crate.Parent = workspace
			require(Crate.CrateScript)
			pcall(function()
				Crate.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				Crate:SetNetworkOwnership(Player)
			end)
		end
		
		if Player:FindFirstChild("Premium") then
			local Crate = game.ServerStorage.PremiumCrate:Clone()
			Crate.Parent = workspace
			require(Crate.CrateScript)
			pcall(function()
				Crate.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				Crate:SetNetworkOwnership(Player)
			end)
			local Chance = math.random(1,20)
			local CrateName = ""
			if Chance == 10 then
				CrateName = "DiamondCrate"
			elseif Chance >= 19 then
				CrateName = "LargeAngeliteCrate"
			else
				CrateName = "GoldCrate"
			end
			local Crate = game.ServerStorage:FindFirstChild(CrateName):Clone()
			Crate.Parent = workspace
			require(Crate.CrateScript)
			pcall(function()
				Crate.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),50,math.random(-6,6))
				Crate:SetNetworkOwnership(Player)
			end)
		end
		
		if Player then
			local Crate = game.ServerStorage.DailyCrate:Clone()
			Crate.Parent = workspace
			Crate.Owner.Value = Player
			require(Crate.CrateScript)
			pcall(function()
				Crate.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-6,6),35,math.random(-6,6))
				Crate:SetNetworkOwnership(Player)
			end)
		end
		
		local AngelAmount = 0
		local UpperLimit = 3
		if Player.LoginStreak.Value > 100 then
			UpperLimit = 50
		elseif Player.LoginStreak.Value > 75 then
			UpperLimit = 40
		elseif Player.LoginStreak.Value > 50 then
			UpperLimit = 30
		elseif Player.LoginStreak.Value > 30 then
			UpperLimit = 25
		elseif Player.LoginStreak.Value > 20 then
			UpperLimit = 20
		elseif Player.LoginStreak.Value > 15 then
			UpperLimit = 15
		elseif Player.LoginStreak.Value > 10 then
			UpperLimit = 10
		elseif Player.LoginStreak.Value > 5 then
			UpperLimit = 7
		elseif Player.LoginStreak.Value > 3 then
			UpperLimit = 6
		elseif Player.LoginStreak.Value > 1 then
			UpperLimit = 5
		end
		
		AngelAmount = math.random(1,UpperLimit)
		if Player:FindFirstChild("VIP") then
			AngelAmount = AngelAmount + 5
		end
		if Player:FindFirstChild("MVP") then
			AngelAmount = AngelAmount + math.random(10,15)
			Player.Boxes.Epic.Value = Player.Boxes.Epic.Value + 1
			local Box = game.ReplicatedStorage.Boxes.Epic
			table.insert(ExtraRewards,{Name = "1 Epic Box (M.V.P.)",Image = Box.Image.Value,Color = Box.Color.Value})
		end
		if Player:FindFirstChild("Group") then
			AngelAmount = AngelAmount + math.random(0,4)
		end
		if Player:FindFirstChild("Clock") then
			AngelAmount = AngelAmount * 2
		end
		Player.Values.Angelite.Value = Player.Values.Angelite.Value + AngelAmount
		
		local Chance = math.random(3,45)
		if Player:FindFirstChild("VIP") and Chance < 40 then
			Chance = Chance + 5
		end
		local NewMoney = math.floor(Player.Money.Value * (Chance/100)) + math.random(700,3500)
		Player.Money.Value = Player.Money.Value + NewMoney
		
		local ItemsToChoseFrom = {}
		for _,v in pairs(Items) do
			if (v.Cost.Value > Player.Money.Value/50) and (v.Cost.Value < Player.Money.Value * 2.4) then
				table.insert(ItemsToChoseFrom,v)
			end
		end
		local Item
		if #ItemsToChoseFrom <= 1 then
			Item = Items[math.random(1,#Items)]
		else
			Item = ItemsToChoseFrom[math.random(1,#ItemsToChoseFrom)]
		end
		if Item then
			local ItemId = Item.ItemId.Value
			local Amount
			local Chance = math.random(1,1000)
			if Chance > 990 then
				Amount = 4
			elseif Chance > 900 then
				Amount = 3
			elseif Chance > 600 then
				Amount = 2
			else
				Amount = 1
			end
			if Player:FindFirstChild("Clock") then
				Amount = Amount * 2
			end
			game.ServerStorage.AwardItem:Invoke(Player,ItemId,Amount)
			spawn(function()
				wait(1)
				game.ReplicatedStorage.GiftInfo:FireClient(Player,NewMoney,ItemId,Amount,AngelAmount,ExtraRewards)
			end)
		end
	end
end

game.ReplicatedStorage.RewardReady.OnServerEvent:Connect(function(Player)
	if Player:FindFirstChild("LastGift") == nil or Player:FindFirstChild("LoginStreak") == nil then
		warn("Can't find values")
		return false
	end
	
	local GiftStatus
	if Player:FindFirstChild("GiftStatus") == nil then
		GiftStatus = Instance.new("BoolValue")
		GiftStatus.Parent = Player
		GiftStatus.Name = "GiftStatus"
		GiftStatus.Value = true
	else
		GiftStatus = Player.GiftStatus
	end
	
	if GiftStatus.Value then
		GiftStatus.Value = false
		
		local RawDay = string.gsub(Player.LastGift.Value,"[^0-9]","")
		RawDay = tonumber(RawDay) or 0
		if RawDay == (Day() - 1) then
			Player.LoginStreak.Value = Player.LoginStreak.Value + 1
		elseif RawDay < (Day() - 1) then
			Player.LoginStreak.Value = 1
		end
		
		Award(Player)
		
		Player.LastGift.Value = tostring(Day())..Code
	end
end)

function Check(Player)
	if #game.Players:GetPlayers() <= 4 then
		if Player:FindFirstChild("LastGift") == nil or Player:FindFirstChild("LoginStreak") == nil then
			warn("Can't find values")
			return false
		end
		
		local Status = (Player.LastGift.Value ~= tostring(Day())..Code)
		
		local GiftStatus
		if Player:FindFirstChild("GiftStatus") == nil then
			GiftStatus = Instance.new("BoolValue")
			GiftStatus.Parent = Player
			GiftStatus.Name = "GiftStatus"
		else
			GiftStatus = Player.GiftStatus
		end
		
		GiftStatus.Value = Status
	end
end

game.ServerStorage.PlayerDataLoaded.Event:Connect(Check)