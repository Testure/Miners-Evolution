local module = {}

local Physics = game:GetService("PhysicsService")
Physics:CreateCollisionGroup("Ores")
Physics:CollisionGroupSetCollidable("Ores","Ores",false)

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

function module.NewOre(Item,Name)
	local Tycoon = Item.Parent.Parent
	if Tycoon == nil then
		error("Tycoon is nil")
	end
	if Item.Parent.Parent.Producing.Value then
		Name = Name or "Unknown"
		local Ore = Instance.new("Part")
		Ore.Size = Vector3.new(1,1,1)
		Ore.TopSurface = Enum.SurfaceType.Smooth
		Ore.BottomSurface = Enum.SurfaceType.Smooth
		Ore.Name = Name
		
		local Cash = Instance.new("NumberValue")
		Cash.Name = "Cash"
		Cash.Value = 1
		Cash.Parent = Ore
		
		local Config = Instance.new("Folder")
		Config.Name = "OreInfo"
		local Tags = Instance.new("Folder")
		Tags.Name = "Tags"
		
		local Timestamp = Instance.new("NumberValue")
		Timestamp.Name = "Created"
		Timestamp.Value = os.time()
		Timestamp.Parent = Config
		
		local Origin = Instance.new("ObjectValue")
		Origin.Name = "Origin"
		Origin.Value = Item
		Origin.Parent = Config
		
		local Total = Instance.new("IntValue")
		Total.Name = "TotalUpgrades"
		Total.Value = 0
		Total.Parent = Ore
		
		Config.Parent = Ore
		Tags.Parent = Ore
		
		Physics:SetPartCollisionGroup(Ore,"Ores")
		game.CollectionService:AddTag(Ore,"Ore")
		
		Ore.Parent = Tycoon.Ores
		
		local Player = Tycoon.Owner.Value
		if Player == nil then
			warn("No player lmao")
		end
		if Player then
			Ore:SetNetworkOwner(Player)
		end
		Ore.Touched:Connect(function(Hit)
			if Ore.Parent ~= workspace.Doomed then
				if Hit:IsDescendantOf(workspace.Map) then
					Ore.Parent = workspace.Doomed
					Ore:Destroy()
				end
			end
		end)
		return Ore,Cash
	end
end

return module