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
				local Thing = math.random(1,20)
				local AngelAmount = 1
				if Thing < 10 then
					AngelAmount = 7
				elseif Thing < 16 then
					AngelAmount = 8
				elseif Thing <= 19 then
					AngelAmount = 9
				elseif Thing == 20 then
					AngelAmount = 10
				end
				local Amount = script.Base.Value * (math.random(50,150)/100)
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+R"..MoneyLib.VTS(Amount),Color3.fromRGB(0,200,255),3,"245520987")
				game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+&"..MoneyLib.VTS(AngelAmount),Color3.fromRGB(180,128,255),3,"245520987")
				game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"&"..MoneyLib.VTS(AngelAmount),Color3.fromRGB(180,128,255),"rbxassetid://4994457097")
				Player.Values.Angelite.Value = Player.Values.Angelite.Value + AngelAmount
				Player.Values.Research.Value = Player.Values.Research.Value + Amount
				if true then
					local Box = game.ReplicatedStorage.Boxes.Regular
					game.ReplicatedStorage.Currency:FireClient(Player,script.Parent,"+1 Regular Box",Box.Color.Value,3,"131144461")
					game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"Regular Box",Box.Color.Value,Box.Image.Value)
					Player.Boxes.Regular.Value = Player.Boxes.Regular.Value + 1
				end
				game.ServerStorage.PlayerOpenedCrate:Fire(Player,script.Parent)
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