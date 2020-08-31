local module = {}

local Client = game:FindService("NetworkClient")
local Server = game:FindService("NetworkServer")
local Tycoon = script.Parent.Parent.Parent
local Owner = Tycoon.Owner
local Item

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

function Check()
	if Tycoon.Items:FindFirstChild("5K teleport center") then
		script.ToggleEnable:FireServer(true)
		Item = Tycoon.Items:FindFirstChild("5K teleport center")
	else
		script.ToggleEnable:FireServer(false)
		Item = nil
	end
end

if Client then
	script.Parent.Furnace.Touched:Connect(function(Hit)
		if Hit.Parent ~= nil and Hit:IsDescendantOf(Tycoon) then
			if Hit:FindFirstChild("Cash") ~= nil then
				if Item ~= nil and Hit:FindFirstChild("TP") == nil and script.Enabled.Value then
					local Tag = Instance.new("BoolValue")
					Tag.Name = "TP"
					Tag.Parent = Hit
					Hit.Velocity = Vector3.new(0,0,0)
					Hit.RotVelocity = Vector3.new(0,0,0)
					Hit.Position = Item.TargetPad.Position + Vector3.new(0,4,0)
					Tag:Destroy()
				else
					Hit.Parent = workspace.Doomed
					Tween(Hit,{"Transparency"},1,1)
					game.Debris:AddItem(Hit,1)
					script.DestroyOre:FireServer(Hit)
				end
			end
		end
	end)
	
	Check()
	Tycoon.Items.ChildAdded:Connect(Check)
	Tycoon.Items.ChildRemoved:Connect(Check)
end

if Server then
	script.ToggleEnable.OnServerEvent:Connect(function(Player,Bool)
		script.Enabled.Value = Bool
		if Bool then
			script.Parent.Furnace.PointLight.Enabled = true
			script.Parent.Lava.BrickColor = BrickColor.new("Hot pink")
			script.Parent.MiniLava.BrickColor = BrickColor.new("Hot pink")
		else
			script.Parent.Furnace.PointLight.Enabled = false
			script.Parent.Lava.BrickColor = BrickColor.new("Black")
			script.Parent.MiniLava.BrickColor = BrickColor.new("Black")
		end
	end)
	
	script.DestroyOre.OnServerEvent:Connect(function(Player,Ore)
		if Ore:FindFirstChild("Cash") and Ore:IsDescendantOf(Tycoon) then
			Ore.Parent = workspace.Doomed
			game.Debris:AddItem(Ore,1)
		end
	end)
end

return module