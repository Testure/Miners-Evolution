game.ReplicatedStorage:WaitForChild("Items")

local Awardables = {}
local AdvAwardables = {}
local Singularitys = {}

for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	if v.Tier.Value == 16 then
		table.insert(Awardables,v)
	elseif v.Tier.Value == 20 then
		table.insert(AdvAwardables,v)
	elseif v.Tier.Value == 22 then
		table.insert(Singularitys,v)
	end
end

math.randomseed(os.time()-tick())

local function Today()
	return math.floor(os.time()/(60*60*24))
end

local TycoonLib = require(game.ReplicatedStorage.TycoonLib)
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

local function RewardOptions(Player,Skips)
	local Options = {}
	for _,v in pairs(Awardables) do
		if Player.Evolution.Value >= v.EvoReq.Value then
			local Chance = v.Rarity.Value * Skips/2
			for i = 1,Chance do
				table.insert(Options,v)
			end
		end
	end
	if Player.Evolution.Value >= 50 then
		for _,v in pairs(AdvAwardables) do
			if Player.Evolution.Value >= v.EvoReq.Value then
				if (v:FindFirstChild("TrueReq") and Player.TrueEvolution.Value >= v.TrueReq.Value) or not v:FindFirstChild("TrueReq") then
					local Chance = v.Rarity.Value * Skips/2
					for i = 1,Chance do
						table.insert(Options,v)
					end
				end
			end
		end
	end
	return Options
end

local function Find(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return v
		end
	end
end

local function ReturnItems(Player)
	for i,v in pairs(_G["SafeKeeping"][Player.Name]) do
		if _G["Inventory"][Player.Name][i].Amount ~= nil then
			_G["Inventory"][Player.Name][i].Amount = _G["Inventory"][Player.Name][i].Amount + v.Amount
		else
			_G["Inventory"][Player.Name][i].Amount = v.Amount
		end
		table.remove(_G["SakeKeeping"][Player.Name],i)
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

function game.ReplicatedStorage.Evolution.OnServerInvoke(Player)
	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end
	
	local Tycoon = TycoonLib.GetTycoon(Player)
	if Tycoon and Player:FindFirstChild("Evolution") and Player:FindFirstChild("Evolving") == nil then
		local Price = MoneyLib.EvoPrice(Player.Evolution.Value)
		if Player.Money.Value >= Price then
			local Tag = Instance.new("BoolValue")
			Tag.Name = "Evolving"
			Tag.Parent = Player
			
			local Destroy = {}
			local Keep = {}
			
			for _,v in pairs(Tycoon.Items:GetChildren()) do
				if (v:FindFirstChild("Destroy") or (v.Tier.Value >= 1 and v.Tier.Value <= 8)) and v:FindFirstChild("Soulbound") == nil then
					table.insert(Destroy,v)
				else
					table.insert(Keep,v)
				end
			end
			
			local Skips = 1
			
			Skips = Skips + ((Player.Settings.SkipEvo.Value and MoneyLib.Skips(Player.Evolution.Value,Player.Money.Value)) or 0)
			
			for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				if (v:FindFirstChild("Destroy") or (v.Tier.Value >= 1 and v.Tier.Value <= 8)) and v:FindFirstChild("Soulbound") == nil then
					_G["Inventory"][Player.Name][v.ItemId.Value].Amount = nil
				end
			end
			
			Tycoon.Ores:ClearAllChildren()
			
			local qnv = MoneyLib.STV("1QnV")
			local Gotqnv = false
			if Player.Money.Value >= qnv and Player.Values.Lastqnv.Value < Today() then
				Gotqnv = true
				--game.ServerStorage.AwardItem:Invoke(Player,111,1)
				Player.Values.Lastqnv.Value = Today()
			end
			
			local tdd = MoneyLib.STV("1tdD")
			local Gottdd = false
			if Player.Money.Value >= tdd and Player.Values.Lasttdd.Value < Today() and not Gotqnv then
				Gottdd = true
				game.ServerStorage.AwardItem:Invoke(Player,98,1)
				Player.Values.Lasttdd.Value = Today()
			end
			
			local BoxChance = math.random(1,6)
			
			Player.Money.Value = 50
			
			for _,v in pairs(Tycoon.Items:GetChildren()) do
				if Find(Keep,v) then
					if _G["Inventory"][Player.Name][v.ItemId.Value].Amount ~= nil then
						_G["Inventory"][Player.Name][v.ItemId.Value].Amount = _G["Inventory"][Player.Name][v.ItemId.Value].Amount + 1
					else
						_G["Inventory"][Player.Name][v.ItemId.Value].Amount = 1
					end
					v:Destroy()
				elseif Find(Destroy,v) then
					v.Parent = workspace.DoomedItems
					Instance.new("Fire").Parent = v.Hitbox
					spawn(function()
						wait(math.random(1,100)/30)
						local Explode = Instance.new("Explosion")
						Explode.Parent = workspace
						Explode.Position = v.Hitbox.Position
						local Sound = script.Explode:Clone()
						Sound.Pitch = math.random(80,120)/100
						Sound.Volume = math.random(20,80)/100
						Sound.Parent = v
						Sound:Play()
						wait(1)
						v:Destroy()
					end)
				end
			end
			
			wait()
			
			if Player and Player.Parent == game.Players and Player:FindFirstChild("Leaving") == nil then
				local OldEvo = Player.Evolution.Value
				Player.Evolution.Value = Player.Evolution.Value + Skips
				
				if Player.TrueEvolution.Value >= 1 and OldEvo < 50 and Player.Evolution.Value >= 50 then
					ReturnItems(Player)
				end
				
				if Player.TrueEvolution.Value >= 1 and OldEvo < 10 and Player.Evolution.Value >= 10 then
					local Options = {}
					for _,v in pairs(Singularitys) do
						if Player.TrueEvolution.Value >= v.TrueReq.Value and Player.Evolution.Value >= v.EvoReq.Value then
							local Chance = v.Rarity.Value * Skips/2
							for i = 1,Chance do
								table.insert(Options,v)
							end
						end
					end
					local Reward = Options[math.random(1,#Options)]
					if Reward then
						game.ServerStorage.AwardItem:Invoke(Player,Reward.ItemId.Value,1)
					end
				end
				
				local Options = RewardOptions(Player,Skips)
				local Reward = Options[math.random(1,#Options)]
				
				if Reward then
					game.ServerStorage.AwardItem:Invoke(Player,Reward.ItemId.Value,1)
				end
				
				local Thaumiel = false
				local Calc = Player.Evolution.Value
				if Calc >= 1000 then
					Calc = 200
				elseif Calc >= 500 then
					Calc = 500
				end
				
				if Player.Evolution.Value >= 1 then
					local ThaumielChance = math.random(1,1000)
					if ThaumielChance > (1000 - Calc) then
						Thaumiel = true
					end
				end
				
				if Thaumiel then
					local Thaumiels = {}
					for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
						if v.Tier.Value == 18 then
							table.insert(Thaumiels,v)
						end
					end
					local ThaumReward = Thaumiels[math.random(1,#Thaumiels)]
					if ThaumReward then
						game.ServerStorage.AwardItem:Invoke(Player,ThaumReward,1)
					end
				end
				
				if BoxChance <= Skips then
					game.ReplicatedStorage.TextNotify:FireClient(Player,"As you advance to the next Evolution, an epic box joins you.",Color3.fromRGB(232,13,53))
					Player.Boxes.Epic.Value = Player.Boxes.Epic.Value + 1
					local Box = game.ReplicatedStorage.Boxes.Epic
					game.ReplicatedStorage.CurrencyNotify:FireClient(Player,Box.Name.." Box",Box.Color.Value,Box.Image.Value)
				end
				
				local Shards = math.random(0,5)
				Shards = Shards * ((Skips > 1 and Skips/2) or 1)
				Shards = math.floor(Shards)
				if Shards > 0 then
					Player.Values.Shards.Value = Player.Values.Shards.Value + Shards
					local Suffix = (Shards == 1 and "Evolutionary Shard") or "Evolutionary Shards"
					local Prefix = (Shards == 1 and "") or tostring(Shards).." "
					game.ReplicatedStorage.CurrencyNotify:FireClient(Player,Prefix..Suffix,Color3.fromRGB(235,195,84),"rbxassetid://4911845622")
				end
				
				local Inventory = _G["Inventory"][Player.Name]
				Inventory[1].Amount = 4
				Inventory[2].Amount = 10
				Inventory[3].Amount = 1
				
				local StringEvo = MoneyLib.HandleEvo(Player.Evolution.Value,Player.TrueEvolution.Value)
				local Skipped = Skips - 1
				local SkipSuffix = (Skipped ~= 1 and " Evolutions") or " Evolution"
				local Suffix = " has Evolved into their "..StringEvo.." Evolution"
				if Skipped > 0 then
					Suffix = " has skipped "..tostring(Skipped)..SkipSuffix.." into their "..StringEvo.." Evolution"
				end
				local Data = {Player.Name..Suffix.." with a "..Reward.ItemName.Value..".",235,195,84}
				game.ServerStorage.SendMessage:Fire("SystemChat",Data)
				
				wait()
				game.ServerStorage.SavePlayer:Invoke(Player)
				game.ServerStorage.InvChange:Fire(Player)
				Tag:Destroy()
				return true
			end
		end
	end
	return false
end

function game.ReplicatedStorage.TrueEvolution.OnServerInvoke(Player)
	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end
	if Player.Evolution.Value < 1000 then
		return false
	end
	if false then
		
	end
	return false
end

function game.ReplicatedStorage.Evolve.OnServerInvoke(Player,Item)
	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end
	if Player.Evolution.Value < 25 then
		return false
	end
	if GetItemById(Item) then
		local RealItem = GetItemById(Item)
		if RealItem.Tier.Value == 19 then
			if _G["Inventory"][Player.Name][RealItem.EvoId.Value].Amount ~= nil and _G["Inventory"][Player.Name][RealItem.EvoId.Value].Amount >= RealItem.EvoAmount.Value then
				_G["Inventory"][Player.Name][RealItem.EvoId.Value].Amount = _G["Inventory"][Player.Name][RealItem.EvoId.Value].Amount - RealItem.EvoAmount.Value
				if _G["Inventory"][Player.Name][RealItem.EvoId.Value].Amount < 1 then
					_G["Inventory"][Player.Name][RealItem.EvoId.Value].Amount = nil
				end
				game.ServerStorage.AwardItem:Invoke(Player,RealItem.ItemId.Value,1)
				return true
			end
		end
	end
	return false
end

function game.ReplicatedStorage.Fuse.OnServerInvoke(Player,Item)
	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end
	if Player.Evolution.Value < 75 then
		return false
	end
	if GetItemById(Item) then
		local RealItem = GetItemById(Item)
		if RealItem.Tier.Value == 17 then
			local Has = {}
			for _,v in pairs(RealItem.FuseFrom:GetChildren()) do
				local Id = tonumber(v.Name)
				if _G["Inventory"][Player.Name][Id].Amount ~= nil and _G["Inventory"][Player.Name][Id].Amount >= v.Value then
					table.insert(Has,Id,v.Value)
				end
			end
			local Sum = 0
			for i,v in pairs(Has) do
				Sum = Sum + 1
			end
			if Sum >= #RealItem.FuseFrom:GetChildren() then
				for i,v in pairs(Has) do
					_G["Inventory"][Player.Name][i].Amount = _G["Inventory"][Player.Name][i].Amount - v
					if _G["Inventory"][Player.Name][i].Amount < 1 then
						_G["Inventory"][Player.Name][i].Amount = nil
					end
				end
				game.ServerStorage.AwardItem:Invoke(Player,RealItem.ItemId.Value,1)
				return true
			end
		end
	end
	return false
end

function game.ReplicatedStorage.Salvage.OnServerInvoke(Player,Item)
	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end
	if Player.Evolution.Value < 100 then
		return false
	end
	if GetItemById(Item) then
		local RealItem = GetItemById(Item)
		if (RealItem.Tier.Value == 16 or RealItem.Tier.Value == 20) then
			if _G["Inventory"][Player.Name][RealItem.ItemId.Value].Amount ~= nil and _G["Inventory"][Player.Name][RealItem.ItemId.Value].Amount >= 1 then
				if RealItem:FindFirstChild("ShardWorth") then
					Player.Values.Shards.Value = Player.Values.Shards.Value + RealItem.ShardWorth.Value
					_G["Inventory"][Player.Name][RealItem.ItemId.Value].Amount = _G["Inventory"][Player.Name][RealItem.ItemId.Value].Amount - 1
					if _G["Inventory"][Player.Name][RealItem.ItemId.Value].Amount < 1 then
						_G["Inventory"][Player.Name][RealItem.ItemId.Value].Amount = nil
					end
					local Prefix = (RealItem.ShardWorth.Value == 1 and "") or tostring(RealItem.ShardWorth.Value).." "
					local Suffix = (RealItem.ShardWorth.Value == 1 and "Evolutionary Shard") or "Evolutionary Shards"
					game.ReplicatedStorage.CurrencyNotify:FireClient(Player,Prefix..Suffix,Color3.fromRGB(235,195,84),"rbxassetid://4911845622")
					game.ServerStorage.InvChange:Fire(Player)
					return true
				end
			end
		end
	end
	return false
end

function game.ReplicatedStorage.ForgeItem.OnServerInvoke(Player,Item)
	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end
	if Player.Evolution.Value < 250 then
		return false
	end
	if Item == 123 and Player.Values.MadeWalkway.Value then
		return false
	end
	if GetItemById(Item) then
		local RealItem = GetItemById(Item)
		if RealItem.Tier.Value == 24 then
			for _,v in pairs(RealItem.ForgeCost:GetChildren()) do
				if v.Name == "Shards" then
					if Player.Values.Shards.Value < v.Value then
						return false
					end
				else
					local Id = tonumber(v.Name)
					if Id and GetItemById(Id) then
						local Entry = _G["Inventory"][Player.Name][Id]
						if not (Entry and Entry.Amount and Entry.Amount >= v.Value) then
							return false
						end
					end
				end
			end
			for _,v in pairs(RealItem.ForgeCost:GetChildren()) do
				if v.Name == "Shards" then
					Player.Values.Shards.Value = Player.Values.Shards.Value - v.Value
				else
					local Id = tonumber(v.Name)
					if Id and GetItemById(Id) then
						local Entry = _G["Inventory"][Player.Name][Id]
						Entry.Amount = Entry.Amount - v.Value
						if Entry.Amount < 1 then
							Entry.Amount = nil
							if Id == 11 and Item == 123 then
								game.ServerStorage.AwardItem:Invoke(Player,11,1)
								game.ReplicatedStorage.TextNotify:FireClient(Player,"Heres your Ancient Mine back!")
								Player.Values.MadeWalkway.Value = true
							end
						end
					end
				end
			end
			game.ServerStorage.AwardItem:Invoke(Player,RealItem.ItemId.Value,1)
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." forged a "..RealItem.ItemName.Value.."!",Color3.fromRGB(232,88,139))
			return true
		end
	end
	return false
end