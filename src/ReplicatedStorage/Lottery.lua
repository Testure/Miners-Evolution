local module = {}

math.randomseed(tick() + os.time()^10)
module.Cache = nil

function module.Run(Player,Mode,Client)
	local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Mode)
	if not Real then
		warn("Invaild Lottery Mode!")
		return false
	end
	local Items = {}
	if game.Players.LocalPlayer and module.Cache ~= nil then
		Items = module.Cache
		local Range = Items[#Items][4]
		local Win
		local Selected = math.random(1,Range)
		for _,v in pairs(Items) do
			if Selected >= v[3] and Selected <= v[4] then
				Win = v
				break
			end
		end
		if Win then
			return Win
		end
	end
	local Cash = Player.Money.Value
	if Cash <= 0 then
		Cash = 50
	end
	
	for i,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		local Rarity = 10
		if v.Tier.Value > 10 and v.Tier.Value < 13 then
			if v:FindFirstChild("Box") then
				local Chance = 0
				if Real.SalesmenChance.Value > 0 then
					Chance = Real.SalesmenChance.Value
					if Client then
						Chance = math.floor(Chance * 2.5)
					end
					Rarity = 1
				end
				if Chance > 0 then
					local RangeStart
					if #Items > 0 then
						RangeStart = Items[#Items][4] + 1
					else
						RangeStart = 0
					end
					local RangeEnd = RangeStart + Chance
					table.insert(Items,{v,Chance,RangeStart,RangeEnd,Rarity})
				end
			end
		end
		if v.ItemType.Value == 7 and Real.AngelChance.Value > 0 then
			local Val = 0
			if v.Cost.Value <= 7 and not Real.Name == "Epic" then
				Val = 200
				Rarity = 9
			elseif v.Cost.Value <= 15 and not Real.Name == "Epic" then
				Val = 80
				Rarity = 7
			elseif v.Cost.Value <= 35 then
				Val = 45
				if Client then
					Val = 60
				end
				Rarity = 5
			elseif v.Cost.Value <= 150 then
				Val = 12
				if Client then
					Val = 20
				end
				Rarity = 3
			else
				Val = 5
				Rarity = 2
			end
			local Chance = math.floor((Val ^ (1/Real.AngelChance.Value)) * Real.AngelChance.Value * 3)
			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items,{v,Chance,RangeStart,RangeEnd,Rarity})
			end
		end
		if v.ItemType.Value == 99 and Real.MintChance.Value > 0 then
			local Chance = math.floor((1 * Real.MintChance.Value) + math.random(10,55)/100)
			if Client then
				Chance = math.ceil(Chance * 3)
			end
			Rarity = 1
			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items,{v,Chance,RangeStart,RangeEnd,Rarity})
			end
		end
		if v.Tier.Value <= 8 and v:FindFirstChild("InShop") and Real.ShopChance.Value > 0 then
			local Chance = 0
			if v.Cost.Value <= Cash * 3 then
				local Val = 0
				if v.Cost.Value >= Cash * 2.4 then
					Val = 3
					Rarity = 2
				elseif v.Cost.Value >= Cash * 2 then
					Val = 7
					Rarity = 3
				elseif v.Cost.Value >= Cash * 1.6 then
					Val = 10
					Rarity = 4
				elseif v.Cost.Value >= Cash * 1.3 then
					Val = 25
					Rarity = 5.5
				elseif v.Cost.Value >= Cash * 0.7 then
					Val = 50
					Rarity = 7
				elseif v.Cost.Value >= Cash * 0.4 and Real.Name ~= "Epic" then
					Val = 120
					Rarity = 8
				elseif v.Cost.Value >= Cash * 0.2 and Real.Name ~= "Epic" then
					Val = 200
					Rarity = 9
				end
				Chance = math.floor((Val ^ (1/Real.ShopChance.Value)) * Real.ShopChance.Value * 2)
			end
			if Chance > 0 then
				local RangeStart
				if #Items > 0 then
					RangeStart = Items[#Items][4] + 1
				else
					RangeStart = 0
				end
				local RangeEnd = RangeStart + Chance
				table.insert(Items,{v,Chance,RangeStart,RangeEnd,Rarity})
			end
		end
	end
	
	local Range = Items[#Items][4]
	local Win
	local Selected = math.random(1,Range)
	
	for _,v in pairs(Items) do
		if Selected >= v[3] and Selected <= v[4] then
			Win = v
			break
		end
	end
	
	if game.Players.LocalPlayer then
		module.Cache = Items
		delay(1,function()
			module.Cache = nil
		end)
	end
	
	if Win then
		return Win
	end
end

return module