local function Tween(Object, Properties, Value, Time, Style, Direction)
	Style = Style or Enum.EasingStyle.Quad
	Direction = Direction or Enum.EasingDirection.Out
	
	Time = Time or 0.5

	local propertyGoals = {}
	
	local Table = (type(Value) == "table" and true) or false
	
	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Style,
		Direction
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end
repeat wait() until #workspace.Tycoons:GetChildren() == 4
for _,v in pairs(workspace.Tycoons:GetChildren()) do
	v.Base.Touched:Connect(function(Hit)
		if Hit.Parent == v.Ores then
			Hit.Parent = workspace.Doomed
			Hit:Destroy()
		end
	end)
end

local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	local Cost = v:FindFirstChild("Cost")
	if Cost and Cost:IsA("StringValue") then
		Cost.Name = "StringCost"
		local NewCost = Instance.new("NumberValue")
		NewCost.Name = "Cost"
		NewCost.Parent = v
		NewCost.Value = (string.find(Cost.Value,"%a") and MoneyLib.STV(Cost.Value)) or tonumber(Cost.Value)
	end
	
	if v:FindFirstChild("Cost") and v.Angel.Value and v:FindFirstChild("ReqResearch") then
		if v.ItemType.Value == 7 and v.Tier.Value ~= 13 then
			if v.Cost.Value >= 40 then
				v.Tier.Value = 10
				v.ReqResearch.Value = MoneyLib.STV("12.5K")
			else
				v.Tier.Value = 9
				v.ReqResearch.Value = 0
			end
			if v:FindFirstChild("InShop") == nil then
				local Tag = Instance.new("BoolValue")
				Tag.Name = "InShop"
				Tag.Value = true
				Tag.Parent = v
			end
		end
	elseif v:FindFirstChild("Cost") and v:FindFirstChild("ReqResearch") then
		if v.ItemType.Value >= 1 and v.ItemType.Value <= 4 then
			if v.Cost.Value >= MoneyLib.STV("1O") then
				v.Tier.Value = 8
				v.ReqResearch.Value = MoneyLib.STV("600M")
			elseif v.Cost.Value >= MoneyLib.STV("10Qn") then
				v.Tier.Value = 7
				v.ReqResearch.Value = MoneyLib.STV("60M")
			elseif v.Cost.Value >= MoneyLib.STV("1qd") then
				v.Tier.Value = 6
				v.ReqResearch.Value = MoneyLib.STV("10M")
			elseif v.Cost.Value >= MoneyLib.STV("1T") then
				v.Tier.Value = 5
				v.ReqResearch.Value = MoneyLib.STV("600K")
			elseif v.Cost.Value >= MoneyLib.STV("1B") then
				v.Tier.Value = 4
				v.ReqResearch.Value = MoneyLib.STV("225K")
			elseif v.Cost.Value >= MoneyLib.STV("1M") then
				v.Tier.Value = 3
				v.ReqResearch.Value = MoneyLib.STV("125K")
			elseif v.Cost.Value >= MoneyLib.STV("50K") then
				v.Tier.Value = 2
				v.ReqResearch.Value = MoneyLib.STV("12.5K")
			else
				v.Tier.Value = 1
				v.ReqResearch.Value = 0
			end
			if v:FindFirstChild("InShop") == nil then
				local Tag = Instance.new("BoolValue")
				Tag.Name = "InShop"
				Tag.Value = true
				Tag.Parent = v
			end
		end
	end
	
	if (v.Tier.Value == 15 or v.Tier.Value == 22) and v:FindFirstChild("Soulbound") == nil then
		local Tag = Instance.new("BoolValue")
		Tag.Value = true
		Tag.Parent = v
		Tag.Name = "Soulbound"
	end
	
	if v.Tier.Value == 21 and v:FindFirstChild("Destroy") == nil then
		local Tag = Instance.new("BoolValue")
		Tag.Value = true
		Tag.Parent = v
		Tag.Name = "Destroy"
	end
end