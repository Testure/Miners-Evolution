local Stocks = {}
local Day = -1
local LastRestock = -1

local function GetDayOfTheWeek(Seconds)
	local Week = math.floor((Seconds - (86400 * 3)) / 604800)
	local Day = math.floor((Seconds - (86400 * 3)) / 86400)
	local DaysBeforeThisWeek = Week * 7
	local DayOfTheWeek = Day - DaysBeforeThisWeek
	return DayOfTheWeek,Day
end

local function GetEvoItems(Player)
	local Items = {}
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.Tier.Value == 16 and v:FindFirstChild("ShardWorth") then
			if Player.Evolution.Value >= v.EvoReq.Value then
				table.insert(Items,v)
			end
		end
		if Player.Evolution.Value >= 50 and v.Tier.Value == 20 and v:FindFirstChild("ShardWorth") then
			if Player.Evolution.Value >= v.EvoReq.Value then
				if (v:FindFirstChild("TrueReq") and Player.TrueEvolution.Value >= v.TrueReq.Value) or not v:FindFirstChild("TrueReq") then
					table.insert(Items,v)
				end
			end
		end
	end
	return Items
end

local function Restock(Player,Today,WeekDay)
	if not Player:FindFirstChild("BaseDataLoaded") then
		return
	end
	math.randomseed(((Today / 3) * 7.1) + (WeekDay * 20))
	Stocks[Player.Name] = nil
	local Stock = {}
	
	local Options = GetEvoItems(Player)
	local LastPicked
	for i = 1,6 do
		if #Options <= 0 then
			break
		end
		local Int = math.random(1,#Options)
		local Picked = Options[Int]
		if Picked then
			table.remove(Options,Int)
			local Id = Picked.ItemId.Value
			local Worth = Picked.ShardWorth.Value
			Stock[#Stock + 1] = {Id = Id,Cost = Worth * math.random(150,200)}
		end
	end
	
	Stocks[Player.Name] = Stock
end

local function IsIn(Table,Id)
	for _,v in pairs(Table) do
		if v.Id == Id then
			return v
		end
	end
	return false
end

function game.ReplicatedStorage.GetShopItems.OnServerInvoke(Player)
	if Stocks[Player.Name] == nil then
		if not Player:FindFirstChild("Leaving") then
			repeat wait() until Stocks[Player.Name] ~= nil
		end
	end
	return Stocks[Player.Name]
end

function game.ReplicatedStorage.BuyEvo.OnServerInvoke(Player,Item)
	if Player:FindFirstChild("Leaving") then
		return false
	end
	if Stocks[Player.Name] == nil or not IsIn(Stocks[Player.Name],Item) then
		return false
	end
	if Player.ActiveTycoon.Value ~= Player.PlayerTycoon.Value then
		return false
	end
	if Player.Evolution.Value < 50 then
		return false
	end
	local Cost = IsIn(Stocks[Player.Name],Item).Cost
	if Player.Values.Shards.Value >= Cost then
		Player.Values.Shards.Value = Player.Values.Shards.Value - Cost
		game.ServerStorage.AwardItem:Invoke(Player,Item,1)
		return true
	end
	return false
end

game.Players.PlayerRemoving:Connect(function(Player)
	Stocks[Player.Name] = nil
end)

game.ServerStorage.PlayerDataLoaded.Event:Connect(function(Player)
	local DayOfTheWeek,RawDay = GetDayOfTheWeek(os.time())
	Restock(Player,RawDay,DayOfTheWeek)
	game.ReplicatedStorage.ShopUpdated:FireClient(Player)
end)

while wait(5) do
	local DayOfTheWeek,RawDay = GetDayOfTheWeek(os.time())
	if Day ~= DayOfTheWeek then -- New day
		Day = DayOfTheWeek
		for _,v in pairs(game.Players:GetPlayers()) do
			if not v:FindFirstChild("Leaving") then
				Restock(v,RawDay,DayOfTheWeek)
				game.ReplicatedStorage.ShopUpdated:FireClient(v)
			end
		end
	elseif (LastRestock - tick()) >= 3600 then -- One hour
		LastRestock = tick()
		for _,v in pairs(game.Players:GetChildren()) do
			if not v:FindFirstChild("Leaving") then
				Restock(v,RawDay,DayOfTheWeek)
				game.ReplicatedStorage.ShopUpdated:FireClient(v)
			end
		end
	end
end