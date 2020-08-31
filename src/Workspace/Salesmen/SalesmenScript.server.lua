local Locations = game.ServerStorage.CFrames:GetChildren()
local ItemNames = {"First","Second","Third","Fourth"}
local Day = -1
local Overwrite = false
local Multiplayer = true

-- Credit to berezaa for this function
local function GetDayOfWeek(Seconds)
	local Week = math.floor((Seconds-(86400*3))/604800)
	local Day = math.floor((Seconds-(86400*3))/86400)
	local DaysBeforeThisWeek = Week * 7
	local DayOfTheWeek = Day - DaysBeforeThisWeek
	return DayOfTheWeek,Day
end

function game.ReplicatedStorage.BuySalesmenItem.OnServerInvoke(Player,Name)
	local Item = script.Parent.Goods:FindFirstChild(Name)
	if Item and Item.Stock.Value > 0 and script.Parent.Active.Value then
		if Item:FindFirstChild("CostType") and Item.CostType.Value ~= "Robux" then
			local Curreny = (Player:FindFirstChild(Item.CostType.Value) or Player.Values:FindFirstChild(Item.CostType.Value))
			if Curreny and Curreny.Value >= Item.Cost.Value then
				if Item:FindFirstChild("ItemId") then
					game.ServerStorage.AwardItem:Invoke(Player,Item.ItemId.Value,1)
				elseif Item:FindFirstChild("Special") then
					local Success = require(Item.Special)(Player)
				else
					return false
				end
				Curreny.Value = Curreny.Value - Item.Cost.Value
				Item.Stock.Value = Item.Stock.Value - 1
				--if not game.ServerStorage.HasBadge:Invoke(Player,{Name = "GoodDeal",Id = 1}) then
					--game.BadgeService:AwardBadge(Player,1) Might make a badge for this
				--end
				return true
			else
				return false
			end
		elseif Item:FindFirstChild("CostType") and Item.CostType.Value == "Robux" then
			print("Prompting...")
			game.MarketplaceService:PromptProductPurchase(Player,Item.Id.Value)
			return true
		end
	end
end

local function Restock(Today,WeekDay)
	math.randomseed((((Today + 0) /3) * 7.1) + ((WeekDay + 0) * 20))
	Multiplayer = true
	local Location
	if Multiplayer then
		Location = Locations[math.random(1,#Locations)]
	end
	script.Parent:SetPrimaryPartCFrame(Location.Value)
	local RawItems = game.ServerStorage.SalesmenItems:GetChildren()
	local Items = {}
	for i = 1,4 do
		local Index = math.random(1,#RawItems)
		local Item = RawItems[Index]:Clone()
		table.insert(Items,Item)
		table.remove(RawItems,Index)
		Item.Parent = script.Parent.Goods
		local NameTag = Instance.new("StringValue")
		NameTag.Value = Item.Name
		NameTag.Name = "ItemName"
		NameTag.Parent = Item
		Item.Name = ItemNames[i]
	end
	math.randomseed(tick())
	for _,v in pairs(script.Parent.Goods:GetChildren()) do
		v.Stock.Value = math.floor(v.Stock.Value * (math.random(25,75)/50))
		if v.CostType.Value == "Angelite" or v.CostType.Value == "Research" or v.CostType.Value == "Money" or v.CostType.Value == "Shards" then
			v.Cost.Value = math.ceil(v.Cost.Value * (math.random(37,65)/50))
		end
	end
	game.ReplicatedStorage.UpdateSalesmen:FireAllClients()
	script.Parent.Timer.Value = 7200
	spawn(function()
		while script.Parent.Active.Value and script.Parent.Timer.Value >  6 do
			wait(1)
			script.Parent.Timer.Value = script.Parent.Timer.Value - 1
		end
		if script.Parent.Active.Value then
			script.Parent.Timer.Value = 5
		end
	end)
end

local NewServer = true

wait(10)

while wait(5) do
	local DayOfTheWeek,RawDay = GetDayOfWeek(os.time())
	script.Parent.Active.Value = Overwrite or ((DayOfTheWeek >= 5 or DayOfTheWeek == 0)) and Multiplayer
	if script.Parent.Active.Value and Day ~= DayOfTheWeek then
		Day = DayOfTheWeek
		Restock(RawDay,DayOfTheWeek)
		local St = "The Salesmen has moved!"
		if NewServer or Day == 5 then
			NewServer = false
			St = "The Salesmen has arrived!"
		end
		game.ReplicatedStorage.TextNotify:FireAllClients(St)
	elseif script.Parent.Timer.Value == 5 then
		Restock(RawDay,DayOfTheWeek)
		game.ReplicatedStorage.TextNotify:FireAllClients("The Salesmen has restocked his inventory!")
	elseif not script.Parent.Active.Value then
		script.Parent:SetPrimaryPartCFrame(CFrame.new(0,5000,0))
	end
end