local module = {}

local DataStore = game:GetService("DataStoreService"):GetDataStore("ItemSavingStore")

function module.GetTycoon(Player)
	for _,v in pairs(workspace.Tycoons:GetChildren()) do
		if v.Owner.Value == Player then
			return v
		end
	end
end

local function EncodeCFrame(Cf)
	return {Cf:components()}
end

local function DecodeCFrame(Cf)
	return CFrame.new(unpack(Cf))
end

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
end

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

module.DefaultBase = {
	
}

local function AttemptRestore(Player,Tycoon)
	local HasData = false
	local Return = {}
	local Data = DataStore:GetAsync(Player.UserId)
	if Data then
		if Data == "AlreadyRestored" then
			HasData = false
			Return = nil
		elseif type(Data) == "table" and Data[1] ~= nil then
			local Cf = Data[1].cf
			local Name = Data[1].name
			if Cf and Name then
				for i,v in pairs(Name) do
					for a,b in pairs(Cf) do
						if i == a then
							if game.ReplicatedStorage.Items:FindFirstChild(v) then
								local Item = game.ReplicatedStorage.Items[v]
								local Tbl = {}
								Tbl[1] = Item.ItemId.Value
								Tbl[2] = b
								Return[#Return + 1] = Tbl
							end
						end
					end
				end
			end
			DataStore:SetAsync(Player.UserId,"AlreadyRestored")
		end
	else
		HasData = false
		Return = nil
	end
	return HasData,Return
end

function module.TycoonToTable(Tycoon)
	local Return = {}
	for _,v in pairs(Tycoon.Items:GetChildren()) do
		local Cf = Tycoon.Base.CFrame:ToObjectSpace(v.PrimaryPart.CFrame)
		local Table = {}
		Table[1] = v.ItemId.Value
		Table[2] = EncodeCFrame(Cf)
		Return[#Return + 1] = Table
	end
	return Return
end

function module.TableToTycoon(Table,Player,Tycoon)
	local Models = {}
	local HasData,Table2 = AttemptRestore(Player,Tycoon)
	if (not HasData and Table2 == {}) or (not HasData and Table2 == nil) then
		for _,v in pairs(Table) do
			if Tycoon.Owner.Value == nil or Tycoon.Owner.Value ~= Player then
				print("Player missing, Stopping base load")
				for _,b in pairs(Models) do
					b:Destroy()
				end
				return false
			end
			if GetItemById(v[1]) then
				local Item = GetItemById(v[1]):Clone()
				Item.Parent = Tycoon.Items
				Item:SetPrimaryPartCFrame(Tycoon.Base.CFrame:ToWorldSpace(DecodeCFrame(v[2])))
				spawn(function()
					for _,b in pairs(Item:GetChildren()) do
						if b:IsA("ModuleScript") then
							game.ReplicatedStorage.RequireModule:FireClient(Player,b)
							require(b)
						end
						if b:IsA("BasePart") and b.Name == "Colored" then
							b.BrickColor = Player.TeamColor
						end
						if b:IsA("BasePart") and b:FindFirstChild("Platform") then
							b.Touched:Connect(function(Hit)
								if Hit.Parent == Tycoon.Ores then
									Tween(Hit,{"Transparency"},1,1)
									game.Debris:AddItem(Hit,1)
								end
							end)
						end
					end
				end)
				Item.Hitbox.Touched:Connect(function()
					return
				end)
				table.insert(Models,Item)
			end
		end
	else
		for _,v in pairs(Table2) do
			if Tycoon.Owner.Value == nil or Tycoon.Owner.Value ~= Player then
				print("Player missing, Stopping base load")
				for _,b in pairs(Models) do
					b:Destroy()
				end
				return false
			end
			if GetItemById(v[1]) then
				local Item = GetItemById(v[1]):Clone()
				Item.Parent = Tycoon.Items
				Item:SetPrimaryPartCFrame(Tycoon.Base.CFrame:ToWorldSpace(DecodeCFrame(v[2])))
				spawn(function()
					for _,b in pairs(Item:GetChildren()) do
						if b:IsA("ModuleScript") then
							game.ReplicatedStorage.RequireModule:FireClient(Player,b)
							require(b)
						end
						if b:IsA("BasePart") and b.Name == "Colored" then
							b.BrickColor = Player.TeamColor
						end
						if b:IsA("BasePart") and b:FindFirstChild("Platform") then
							b.Touched:Connect(function(Hit)
								if Hit.Parent == Tycoon.Ores then
									Tween(Hit,{"Transparency"},1,1)
									game.Debris:AddItem(Hit,1)
								end
							end)
						end
					end
				end)
				Item.Hitbox.Touched:Connect(function()
					return
				end)
				table.insert(Models,Item)
			end
		end
	end
	return true
end

return module