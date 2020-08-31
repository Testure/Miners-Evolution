local module = {}

math.randomseed(os.time())
local Enabled = true
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

function Tween(Object, Properties, Value, Time, Style, Direction)
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

script.Parent.Touched:Connect(function(Hit)
	if (Hit.Position - script.Parent.Position).Magnitude > 30 then
		return false
	end
	if Enabled then
		local Human = Hit.Parent:FindFirstChild("Humanoid")
		if Human then
			local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
			if Player then
				Enabled = false
				script.Parent.Open:Play()
				wait(0.3)
				local Amount = script.Base.Value * (math.random(50,150)/100)
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+R"..MoneyLib.VTS(Amount),Color3.fromRGB(0,200,255),3,"245520987")
				Player.Values.Research.Value = Player.Values.Research.Value + Amount
				local Chance = math.random(1,20)
				if Chance == 13 then
					local Box = game.ReplicatedStorage.Boxes.Epic
					game.ReplicatedStorage.CurrencyNotify:FireClient(Player,Box.Name.." Box",Box.Color.Value,Box.Image.Value)
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Epic Box",Box.Color.Value,4,"131144461")
					Player.Boxes.Epic.Value = Player.Boxes.Epic.Value + 1
				elseif Chance < 10 then
					local Box = game.ReplicatedStorage.Boxes.Rare
					game.ReplicatedStorage.CurrencyNotify:FireClient(Player,Box.Name.." Box",Box.Color.Value,Box.Image.Value)
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Rare Box",Box.Color.Value,4,"131144461")
					Player.Boxes.Rare.Value = Player.Boxes.Rare.Value + 1
				else
					local Box = game.ReplicatedStorage.Boxes.Regular
					game.ReplicatedStorage.CurrencyNotify:FireClient(Player,Box.Name.." Box",Box.Color.Value,Box.Image.Value)
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Regular Box",Box.Color.Value,4,"131144461")
					Player.Boxes.Regular.Value = Player.Boxes.Regular.Value + 1
				end
				game.ServerStorage.PlayerOpenedCrate:Fire(Player,script.Parent)
				local Tools = {}
				for _,v in pairs(game.Lighting:GetChildren()) do
					if v:IsA("Tool") then
						table.insert(Tools,v)
					end
				end
				local Tool = Tools[math.random(1,#Tools)]
				Tool:Clone().Parent = Player.Backpack
				game.ReplicatedStorage.TextNotify:FireClient(Player,"You've been givin a "..Tool.Name.."!")
				game.ReplicatedStorage.TextNotify:FireClient(Player,"You feel your power growing.")
				pcall(function()
					Player.Character.Humanoid.MaxHealth = Player.Character.Humanoid.MaxHealth + 20
					Player.Character.Humanoid.WalkSpeed = Player.Character.Humanoid.WalkSpeed + 5
					Player.Character.Humanoid.JumpPower = Player.Character.Humanoid.JumpPower + 8
					Player.Character.Humanoid.MaxSlopeAngle = Player.Character.Humanoid.MaxSlopeAngle + 15
				end)
				wait(0.25)
				script.Parent.Anchored = true
				script.Parent.CanCollide = false
				Tween(script.Parent,{"Transparency"},1,2.5)
				for _,v in pairs(script.Parent:GetChildren()) do
					if v:IsA("SurfaceGui") then
						Tween(v.Icon,{"ImageTransparency"},1,2.5)
					end
				end
				wait(2.5)
				script.Parent:Destroy()
			end
		end
	end
end)

return module