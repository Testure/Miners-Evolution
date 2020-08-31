local function Init(Money)
	local LastValue = Money.Value
	local Player = game.Players:FindFirstChild(Money.Parent.Name)
	if Player ~= nil then
		local ClientVal = Instance.new("NumberValue")
		ClientVal.Parent = Player
		ClientVal.Name = "Change"
		
		local Avg = Instance.new("NumberValue")
		Avg.Parent = Player
		Avg.Name = "AverageIncome"
		
		local Averages = {}
		
		local function Wipe()
			Averages = {}
			Avg.Value = 0
			ClientVal.Value = 0
		end
		
		wait(60)
		
		Player.ChildAdded:Connect(function(Child)
			if Child.Name == "Gifted" or Child.Name == "SecondGift" then
				Wipe()
			end
		end)
		
		Player.Evolution.Changed:Connect(function()
			Wipe()
		end)
		
		while wait(2) do
			if Money ~= nil and Player ~= nil and Player.Parent == game.Players then
				local DeltaValue = (Money.Value - LastValue)/2
				if DeltaValue > 0 then
					table.insert(Averages,DeltaValue)
					if #Averages > 20 then
						table.remove(Averages,1)
					end
					
					local Sum = 0
					for _,v in pairs(Averages) do
						Sum = Sum + v
					end
					Avg.Value = Sum / (#Averages * 2)
					
					if DeltaValue >= 0 then
						ClientVal.Value = DeltaValue
					end
				end
				LastValue = Money.Value
			else
				break
			end
		end
	end
end

game.ServerStorage.PlayerDataLoaded.Event:Connect(function(Player)
	Init(Player.Money)
end)