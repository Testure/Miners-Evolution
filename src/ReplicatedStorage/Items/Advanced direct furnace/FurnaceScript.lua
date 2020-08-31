local module = {}

local Client = game:FindService("NetworkClient")
local Server = game:FindService("NetworkServer")
local Tycoon = script.Parent.Parent.Parent
local Owner = Tycoon.Owner

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

if Client then
	script.Parent.Furnace.Touched:Connect(function(Hit)
		if Hit.Parent ~= nil and Hit:IsDescendantOf(Tycoon) then
			if Hit:FindFirstChild("Cash") ~= nil and Hit.TotalUpgrades.Value <= 0 then
				script.HandleCash:FireServer(Hit)
				game.ReplicatedStorage.ProcessOre:FireServer(Hit,script.Parent.Furnace,Color3.fromRGB(0,235,100),"rbxassetid://298181829")
				Hit.Parent = workspace.Doomed
				Tween(Hit,{"Transparency"},1,1)
				game.Debris:AddItem(Hit,1)
			end
		end
	end)
end

if Server then
	script.HandleCash.OnServerEvent:Connect(function(Player,Ore)
		if Ore:FindFirstChild("Cash") and Ore:IsDescendantOf(Tycoon) then
			if Ore.TotalUpgrades.Value <= 0 then
				Ore.Cash.Value = (Ore.Cash.Value * 35)
			end
		end
	end)
end

return module