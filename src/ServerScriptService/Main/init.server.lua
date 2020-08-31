local Private = game.VIPServerId == "" and game.VIPServerOwnerId > 0
if Private then
	local Value = Instance.new("BoolValue")
	Value.Name = "Private"
	Value.Parent = workspace
	game.ServerStorage.PrivateMap:Clone().Parent = workspace
	for _,v in pairs(game.ServerStorage.Sets.Private:GetChildren()) do
		v:Clone().Parent = workspace.Tycoons
	end
	print("Loaded")
else
	game.ServerStorage.Map:Clone().Parent = workspace
	for _,v in pairs(game.ServerStorage.Sets.Main:GetChildren()) do
		v:Clone().Parent = workspace.Tycoons
	end
	print("Loaded")
end
game.StarterGui.Gui.Parent = game.ReplicatedStorage
_G["Codes"] = {}
_G["Inventory"] = {}
_G["SafeKeeping"] = {}
local TycoonLib = require(game.ReplicatedStorage.TycoonLib)
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)

spawn(function()
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		v.PrimaryPart.Touched:Connect(function()
			return
		end)
	end
end)

function game.ReplicatedStorage.PlaySolo.OnServerInvoke(Player)
	local Success,Error = pcall(function()
		local Server = game:GetService("TeleportService"):ReserveServer(game.PlaceId)
		game:GetService("TeleportService"):TeleportToPrivateServer(game.PlaceId,Server,{Player})
	end)
	if not Success then
		warn(Error)
	end
	return Success
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

local function GetTycoon(Player)
	for _,v in pairs(workspace.Tycoons:GetChildren()) do
		if v.Owner.Value == Player then
			return v
		end
	end
	return nil
end

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
	return nil
end

local function GetNewTycoon()
	for _,v in pairs(workspace.Tycoons:GetChildren()) do
		if v.Owner.Value == nil then
			return v
		end
	end
	return nil
end

local function GetUnusedColor()
	local Picked = BrickColor.Random()
	local Used = false
	for _,v in pairs(game.Players:GetPlayers()) do
		if v.TeamColor == Picked then
			Used = true
		end
	end
	if Used then
		return GetUnusedColor()
	else
		return Picked
	end
end

local function CanPlace1(NewItem, Cframe, PlayerTycoon)
	if true then
		local Test1 = Cframe:vectorToObjectSpace(NewItem.Hitbox.Size)
		local Test = Vector3.new(math.abs(Test1.x),math.abs(Test1.y),math.abs(Test1.z))	

		local Region = Region3.new(Cframe.p - Test*0.49, Cframe.p + Test*0.49)

		local Parts = workspace:FindPartsInRegion3(Region, NewItem, math.huge)

		for i,Part in pairs(Parts) do
			if Part:IsDescendantOf(PlayerTycoon) and Part.Name == "Hitbox" then
				return false
			end
		end
		return true
	end
	return false
end

local function CanPlace(ItemData,Tycoon)
	if not ItemData or not Tycoon then
		return false
	end
	if not ItemData[1] or not ItemData[2] then
		return false
	end
	local Item = GetItemById(ItemData[1]):Clone()
	Item.Parent = workspace
	Item:SetPrimaryPartCFrame(ItemData[2])
	local Parts = Item.PrimaryPart:GetTouchingParts()
	for _,v in pairs(Parts) do
		if v.Name == "Hitbox" and not CanPlace1(Item,ItemData[2],Tycoon) then
			Item:Destroy()
			return false
		end
	end
	if not ItemData[3] then
		local Offset = (Item.Hitbox:FindFirstChild("BaseHeight") ~= nil and Item.Hitbox.BaseHeight.Value.Y) or 0
		local Rey = Ray.new(ItemData[2].p,Vector3.new(0,-Item.Hitbox.Size.Y - Offset,0))
		local List = {Tycoon.Base}
		for _,v in pairs(Tycoon.Items:GetChildren()) do
			for _,b in pairs(v:GetChildren()) do
				if b:FindFirstChild("Platform") then
					table.insert(List,b)
				end
			end
		end
		local Part = workspace:FindPartOnRayWithWhitelist(Rey,List)
		if not Part then
			Item:Destroy()
			return false
		end
	end
	local Rey = Ray.new(ItemData[2].p,Vector3.new(0,-5000,0))
	local Part = workspace:FindPartOnRayWithWhitelist(Rey,{Tycoon.Base})
	if not Part then
		Item:Destroy()
		return false
	end
	Item:Destroy()
	return true
end

local function CalcOreLimit(Player)
	--local Level = Player.Values.OreLevel.Value
	local Limit = 150
	--Limit = Limit + (Level * 20)
	if Player:FindFirstChild("Premium") then
		Limit = Limit + 50
	end
	if Player:FindFirstChild("MVP") then
		Limit = Limit + 25
	end
	return Limit
end

function game.ReplicatedStorage.PlaceItems.OnServerInvoke(Permiee,ItemData,Plane)
	if not TycoonLib.HasPermission(Permiee,"Build") then
		return nil
	end
	local Tycoon = Permiee.ActiveTycoon.Value
	if Tycoon == nil then
		return nil
	end
	Plane = Plane or Tycoon.Base
	local Player = Tycoon.Owner.Value
	if Player == nil then
		return nil
	end
	local PlacedItems = {}
	for _,v in pairs(ItemData) do
		if _G["Inventory"][Player.Name][v[1]].Amount and _G["Inventory"][Player.Name][v[1]].Amount >= 1 then
			if CanPlace({v[1],v[2],v[3]},Tycoon) then
				_G["Inventory"][Player.Name][v[1]].Amount = _G["Inventory"][Player.Name][v[1]].Amount - 1
				if _G["Inventory"][Player.Name][v[1]].Amount < 1 then
					_G["Inventory"][Player.Name][v[1]].Amount = nil
				end
				local Item = GetItemById(v[1]):Clone()
				Item.Parent = Tycoon.Items
				Item:SetPrimaryPartCFrame(v[2])
				if Item then
					spawn(function()
						for _,v in pairs(Item:GetChildren()) do
							if v:IsA("ModuleScript") then
								game.ReplicatedStorage.RequireModule:FireClient(Player,v)
								require(v)
							end
							if v:IsA("BasePart") and v.Name == "Color" then
								v.BrickColor = Player.TeamColor
							end
							if v:IsA("BasePart") and v:FindFirstChild("Platform") then
								v.Touched:Connect(function(Hit)
									if Hit.Parent == Tycoon.Ores then
										Hit.Parent = workspace.Doomed
										Tween(Hit,{"Transparency"},1,1)
										game.Debris:AddItem(Hit,1)
									end
								end)
							end
						end
						if Item:FindFirstChild("Platform") and Item.Platform:FindFirstChild("Platform") then
							game.ReplicatedStorage.UpdatePlane:FireClient(Permiee,Tycoon.Base)
							if Permiee ~= Player then
								game.ReplicatedStorage.UpdatePlane:FireClient(Player,Tycoon.Base)
							end
						end
					end)
					Item.Hitbox.Touched:Connect(function()
						return
					end)
					table.insert(PlacedItems,Item)
				end
				game.ServerStorage.InvChange:Fire(Player)
			end
		end
	end
	return #PlacedItems > 0 and PlacedItems or nil
end

game.ReplicatedStorage.ProcessOre.OnServerEvent:Connect(function(Player,Ore,Part,Color,Audio)
	Color = Color or Color3.fromRGB(0,255,134)
	if Ore == nil or Ore.Parent == nil then
		return
	end
	if Part == nil or Part.Parent == nil then
		return
	end
	local Tycoon = GetTycoon(Player) -- Only the tycoon owner runs the item script locally
	if Tycoon == nil then
		return
	end
	if Ore:IsDescendantOf(Tycoon) then
		game.Debris:AddItem(Ore,1)
		Ore.Parent = workspace.Doomed
		game.ReplicatedStorage.Currency:FireAllClients(Part,"$"..MoneyLib.VTS(Ore.Cash.Value),Color,1,Audio)
		Player.Money.Value = Player.Money.Value + Ore.Cash.Value
	end
end)

function game.ReplicatedStorage.CanBuy.OnServerInvoke(Permiee,Item)
	local Tycoon = Permiee.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end
	local Player = Tycoon.Owner.Value
	if Player == nil then
		return false
	end
	if Item == nil or Item.Parent == nil then
		return false
	end
	if not TycoonLib.HasPermission(Permiee,"Buy") then
		return false
	end
	if Item:FindFirstChild("Cost") == nil then
		return false
	end
	local Type = "Money"
	if Item.Angel.Value then
		Type = "Angelite"
	end
	if Item:FindFirstChild("InShop") == nil then
		return false
	end
	return true,Type
end

function CanSell(Permiee,Item)
	local Tycoon = Permiee.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end
	local Player = Tycoon.Owner.Value
	if Player == nil then
		return false
	end
	if Item == nil or Item.Parent == nil then
		return false
	end
	if not TycoonLib.HasPermission(Permiee,"Sell") then
		return false
	end
	if Item:FindFirstChild("Cost") == nil then
		return false
	end
	if Item:FindFirstChild("InShop") == nil then
		return false
	end
	local Type = "Money"
	if Item.Angel.Value then
		Type = "Destroy"
	end
	return true,Type
end
game.ReplicatedStorage.CanSell.OnServerInvoke = CanSell

function game.ReplicatedStorage.DestroyItem.OnServerInvoke(Player,Item)
	if TycoonLib.HasPermission(Player,"Build") == false then
		return false
	end
	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end
	local Owner = Tycoon.Owner.Value
	if Owner == nil then
		return false
	end
	if Item ~= nil and Item.Parent ~= nil then
		if Item:IsDescendantOf(Tycoon) then
			local Id = Item.ItemId.Value
			if _G["Inventory"][Owner.Name][Id].Amount ~= nil then
				_G["Inventory"][Owner.Name][Id].Amount = _G["Inventory"][Owner.Name][Id].Amount + 1
			else
				_G["Inventory"][Owner.Name][Id].Amount = 1
			end
			Item:Destroy()
			game.ServerStorage.InvChange:Fire(Owner)
			return true
		end
	end
	return false
end

function game.ReplicatedStorage.DestroyItems.OnServerInvoke(Player,Items)
	if not TycoonLib.HasPermission(Player,"Build") then
		return false
	end
	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end
	local Owner = Tycoon.Owner.Value
	if Owner == nil then
		return false
	end
	if type(Items) == "table" and #Items >= 1 then
		for _,v in pairs(Items) do
			if v:IsDescendantOf(Tycoon) then
				local Id = v.ItemId.Value
				if _G["Inventory"][Owner.Name][Id].Amount ~= nil then
					_G["Inventory"][Owner.Name][Id].Amount = _G["Inventory"][Owner.Name][Id].Amount + 1
				else
					_G["Inventory"][Owner.Name][Id].Amount = 1
				end
				v:Destroy()
			end
		end
		game.ServerStorage.InvChange:Fire(Owner)
		return true
	end
	return false
end

function game.ReplicatedStorage.SellItem.OnServerInvoke(Permiee,Item)
	if not TycoonLib.HasPermission(Permiee,"Sell") then
		return false
	end
	local Tycoon = Permiee.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end
	local Owner = Tycoon.Owner.Value
	if Owner == nil then
		return false
	end
	local Can,Type = CanSell(Permiee,Item)
	if Can then
		if Type == "Money" then
			local RealItem = GetItemById(Item.ItemId.Value)
			if RealItem then
				Item:Destroy()
				local Price = (RealItem.Cost.Value * 0.3)
				Owner.Money.Value = Owner.Money.Value + Price
				return true
			end
		elseif Type == "Destroy" then
			Item:Destroy()
			return true
		end
	end
	return false
end

function game.ReplicatedStorage.BuyItem.OnServerInvoke(Permiee,Item,Amount)
	Amount = Amount or 1
	if Amount < 1 then
		Amount = 1
	end
	if Amount > 99 then
		Amount = 99
	end
	local RealItem = GetItemById(Item)
	if not TycoonLib.HasPermission(Permiee,"Buy") then
		return false
	end
	local Tycoon = Permiee.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end
	local Owner = Tycoon.Owner.Value
	if Owner == nil then
		return false
	end
	
	if RealItem and (RealItem.ItemType.Value >= 1 and RealItem.ItemType.Value <= 4 or RealItem.ItemType.Value == 7) then
		if not RealItem.Angel.Value then
			local Cost = RealItem.Cost.Value * Amount
			if Owner.Values.Research.Value >= RealItem.ReqResearch.Value or Owner:FindFirstChild("Premium") then
				if Owner.Money.Value >= Cost then
					Owner.Money.Value = Owner.Money.Value - Cost
					game.ServerStorage.AwardItem:Invoke(Owner,RealItem.ItemId.Value,Amount)
					return true
				end
			end
		else
			local Cost = RealItem.Cost.Value * Amount
			if Owner.Values.Angelite.Value >= Cost and (Owner.Values.Research.Value >= RealItem.ReqResearch.Value or Owner:FindFirstChild("Premium")) then
				Owner.Values.Angelite.Value = Owner.Values.Angelite.Value - Cost
				game.ServerStorage.AwardItem:Invoke(Owner,RealItem.ItemId.Value,Amount)
				return true
			end
		end
	end
	return false
end

game.Players.PlayerAdded:Connect(function(Player)
	if #game.Players:GetPlayers() > 4 then
		wait()
		Player:Kick("This server is full")
		return
	end
	local Color = GetUnusedColor()
	local Tycoon = GetNewTycoon()
	if Tycoon then
		Tycoon.Owner.Value = Player
		Tycoon.Base.Material = Enum.Material.Slate
		Tycoon.Base.BrickColor = BrickColor.new("Medium stone grey")
		local Folder = Instance.new("Folder")
		Folder.Parent = Player
		Folder.Name = "leaderstats"
		local CashMirror = Instance.new("StringValue")
		CashMirror.Name = "Cash"
		CashMirror.Parent = Folder
		CashMirror.Value = "Loading"
		local EvoMirror = Instance.new("StringValue")
		EvoMirror.Name = "Evolution"
		EvoMirror.Parent = Folder
		EvoMirror.Value = "Loading"
		
		local Active = Instance.new("ObjectValue")
		Active.Name = "ActiveTycoon"
		Active.Parent = Player
		Active.Value = Tycoon
		local Play = Instance.new("ObjectValue")
		Play.Name = "PlayerTycoon"
		Play.Parent = Player
		Play.Value = Tycoon
		local Near = Instance.new("ObjectValue")
		Near.Name = "NearTycoon"
		Near.Parent = Player
		Near.Value = Tycoon
		
		spawn(function()
			Player.CharacterAdded:Wait()
			repeat wait()
				Player.Character:SetPrimaryPartCFrame(CFrame.new(Tycoon.Base.Position + Vector3.new(0,20,0)))
			until Player.Character:GetPrimaryPartCFrame() == CFrame.new(Tycoon.Base.Position + Vector3.new(0,20,0))
		end)
		local Team = Instance.new("Team")
		Team.Name = Player.Name.."'s Base"
		Team.TeamColor = Color
		Player.TeamColor = Color
		Player.Neutral = false
		Team.Parent = game:GetService("Teams")
	end
end)

game.ServerStorage.PlayerDataLoaded.Event:Connect(function(Player)
	local Tycoon = GetTycoon(Player)
	if Tycoon == nil then
		return
	end
	local Tag = Instance.new("IntValue")
	Tag.Parent = Player
	Tag.Name = "OreLimit"
	Tag.Value = CalcOreLimit(Player)
	Tycoon.Ores.ChildAdded:Connect(function()
		Tycoon.Producing.Value = (Player.Settings.Mines.Value and #Tycoon.Ores:GetChildren() < Tag.Value)
	end)
	Tycoon.Ores.ChildRemoved:Connect(function()
		Tycoon.Producing.Value = (Player.Settings.Mines.Value and #Tycoon.Ores:GetChildren() < Tag.Value)
	end)
	Player.Settings.Mines.Changed:Connect(function()
		Tycoon.Producing.Value = (Player.Settings.Mines.Value and #Tycoon.Ores:GetChildren() < Tag.Value)
	end)
end)

function game.ReplicatedStorage.GetInventory.OnServerInvoke(Permiee)
	local Tycoon = Permiee.ActiveTycoon.Value
	if Tycoon == nil then
		return _G["Inventory"][Permiee.Name]
	end
	local Player = Tycoon.Owner.Value
	if Player == nil then
		return _G["Inventory"][Permiee.Name]
	end
	return _G["Inventory"][Player.Name]
end

game.ReplicatedStorage.ChangeFavorite.OnServerEvent:Connect(function(Permiee,Id)
	local Tycoon = Permiee.ActiveTycoon.Value
	if Tycoon == nil then
		return false
	end
	local Player = Tycoon.Owner.Value
	if Player == nil then
		return false
	end
	if TycoonLib.HasPermission(Permiee,"Owner") then
		if _G["Inventory"][Player.Name][Id] then
			if _G["Inventory"][Player.Name][Id].Favorite ~= nil then
				_G["Inventory"][Player.Name][Id].Favorite = nil
			else
				_G["Inventory"][Player.Name][Id].Favorite = true
			end
		end
	end
	return false
end)

function game.ServerStorage.AwardItem.OnInvoke(Player,Id,Amount)
	Amount = Amount or 1
	local Item = GetItemById(Id)
	if Item then
		if _G["Inventory"][Player.Name][Id].Amount ~= nil then
			_G["Inventory"][Player.Name][Id].Amount = _G["Inventory"][Player.Name][Id].Amount + Amount
		else
			_G["Inventory"][Player.Name][Id].Amount = Amount
		end
		game.ReplicatedStorage.ItemNotify:FireClient(Player,Item,Amount)
		game.ServerStorage.InvChange:Fire(Player)
	else
		warn("Could not find item")
	end
	return false
end

function game.ServerStorage.AwardBox.OnInvoke(Player,BoxType,Amount)
	Amount = Amount or 1
	local Box = Player.Boxes:FindFirstChild(BoxType)
	local RealBox = game.ReplicatedStorage.Boxes:FindFirstChild(BoxType)
	if Box and RealBox then
		Box.Value = Box.Value + Amount
		game.ReplicatedStorage.CurrencyNotify:FireClient(Player,BoxType.." Box",RealBox.Color.Value,RealBox.Image.Value)
	else
		warn("Could not find box")
		return false
	end
end

game.ReplicatedStorage.OpenedMOTD.OnServerEvent:Connect(function(Player)
	if Player.Values.MOTD.Value < game.ReplicatedStorage.MOTD.Value then
		Player.Values.MOTD.Value = game.ReplicatedStorage.MOTD.Value
	end
end)

game.ReplicatedStorage.ToggleSetting.OnServerEvent:Connect(function(Player,Setting,Value)
	if TycoonLib.HasPermission(Player,"Owner") then
		if Player.Settings:FindFirstChild(Setting) then
			Player.Settings[Setting].Value = Value
		end
	end
end)

function game.ReplicatedStorage.DestroyOres.OnServerInvoke(Player)
	if not TycoonLib.HasPermission(Player,"Owner") then
		return false
	end
	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon == nil or Tycoon ~= Player.PlayerTycoon.Value then
		return false
	end
	Tycoon.Ores:ClearAllChildren()
	return true
end

function game.ReplicatedStorage.Withdraw.OnServerInvoke(Player)
	if not TycoonLib.HasPermission(Player,"Owner") then
		return false
	end
	local Tycoon = Player.ActiveTycoon.Value
	if Tycoon == nil or Tycoon ~= Player.PlayerTycoon.Value then
		return false
	end
	for _,v in pairs(Tycoon.Items:GetChildren()) do
		if v:FindFirstChild("ItemId") ~= nil and GetItemById(v.ItemId.Value) then
			if _G["Inventory"][Player.Name][v.ItemId.Value].Amount then
				_G["Inventory"][Player.Name][v.ItemId.Value].Amount = _G["Inventory"][Player.Name][v.ItemId.Value].Amount + 1
			else
				_G["Inventory"][Player.Name][v.ItemId.Value].Amount = 1
			end
			v:Destroy()
		end
	end
	game.ServerStorage.InvChange:Fire(Player)
	return true
end