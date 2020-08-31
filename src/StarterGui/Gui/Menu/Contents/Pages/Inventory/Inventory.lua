local module = {}

local Player = game.Players.LocalPlayer
local Alphabet = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local SortType = "Name"
local ButtonDB = false

local function GetInventory()
	local Inv = game.ReplicatedStorage.GetInventory:InvokeServer()
	return Inv
end

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
end

local function Find(Table,Value,I)
	for i,v in pairs(Table) do
		if v == Value then
			if I then
				return i
			else
				return v
			end
		end
	end
end

local function SortName()
	local Table = {}
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		table.insert(Table,v)
	end
	table.sort(Table,function(a,b)
		local A = Find(Alphabet,string.lower(string.sub(a.ItemName.Value,1,1)),true)
		local B = Find(Alphabet,string.lower(string.sub(b.ItemName.Value,1,1)),true)
		if A and B and A < B then
			return true
		end
		return false
	end)
	return Table
end

local function SortTier()
	local Table = {}
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		table.insert(Table,v)
	end
	table.sort(Table,function(a,b)
		if a.Tier.Value > b.Tier.Value then
			return true
		end
		return false
	end)
	return Table
end

local function GetLayoutOrder(Button)
	local Id = Button.Id.Value
	local Item = GetItemById(Id)
	local Return = 0
	if SortType == "Id" then
		Return = Id
	elseif SortType == "Tier" then
		local Table = SortTier()
		Return = Find(Table,Item,true)
	elseif SortType == "Name" then
		local Table = SortName()
		Return = Find(Table,Item,true)
	end
	if Button.Favorite.Visible then
		Return = Return - 99
	end
	return Return
end

local function GetFirst()
	local Last = 99
	local LastButton
	for _,v in pairs(script.Parent.Items:GetChildren()) do
		if v:IsA("TextButton") and v.Name ~= "Sample" and v.Visible then
			if v.LayoutOrder < Last then
				Last = v.LayoutOrder
				LastButton = v
			end
		end
	end
	return LastButton
end

local function GetButtonById(Id)
	for _,v in pairs(script.Parent.Items:GetChildren()) do
		if v:IsA("TextButton") and v.Name ~= "Sample" and v.Id.Value == Id then
			return v
		end
	end
end

function module.init(Modules)
	script.Parent.Items.Sample.Visible = false
	local Settings = Player:WaitForChild("Settings")
	SortType = Settings.InvSort.Value
	for _,v in pairs(script.Parent.Top.Sorts:GetChildren()) do
		if v:IsA("TextButton") then
			if v.Name == SortType.."Sort" then
				v.BackgroundColor3 = Color3.fromRGB(212,212,212)
			else
				v.BackgroundColor3 = Color3.fromRGB(139,139,139)
			end
		end
	end
	
	local function PermsCheck()
		script.Parent.Top.Locked.Visible = not Modules.TycoonLib.HasPermission(Player,"Build")
	end
	PermsCheck()
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(PermsCheck)
	
	function module.Favorite(Button)
		if not Modules.TycoonLib.HasPermission(Player,"Owner") then
			return
		end
		local Id = Button.Id.Value
		if GetInventory()[Id].Favorite then
			Modules.Menu.Sounds.Tick:Play()
			Button.Favorite.Visible = false
			Button.LayoutOrder = GetLayoutOrder(Button)
		else
			Modules.Menu.Sounds.Favorite:Play()
			Button.Favorite.Visible = true
			Button.LayoutOrder = GetLayoutOrder(Button)
		end
		game.ReplicatedStorage.ChangeFavorite:FireServer(Id)
	end
	
	local function HandleButton(Button)
		local Id = Button.Id.Value
		local Item = GetItemById(Id)
		Button.MouseButton1Click:Connect(function()
			if ButtonDB then
				return
			end
			if Modules.Input.Mode.Value == "Xbox" and not Button.Selected then
				return
			end
			if not Modules.TycoonLib.HasPermission(Player,"Build") then
				return
			end
			ButtonDB = true
			Modules.Placement.StartPlacement(Id)
			Modules.Menu.Sounds.Move:Play()
			wait()
			ButtonDB = false
		end)
		Button.MouseButton2Click:Connect(function()
			if ButtonDB then
				return
			end
			if Modules.Input.Mode.Value == "Xbox" and not Button.Selected then
				return
			end
			ButtonDB = true
			module.Favorite(Button)
			wait()
			ButtonDB = false
		end)
		local function Enter()
			Modules.ItemInfo.Show(Button)
			Button.Amount.Visible = true
		end
		local function Leave()
			Modules.ItemInfo.Hide(Button)
			Button.Amount.Visible = false
		end
		Button.MouseEnter:Connect(Enter)
		Button.MouseLeave:Connect(Leave)
		Button.SelectionGained:Connect(Enter)
		Button.SelectionLost:Connect(Leave)
	end
	
	local function FillItems()
		local Inventory = GetInventory()
		if Inventory then
			for i,v in pairs(Inventory) do
				local Button = script.Parent.Items.Sample:Clone()
				local Item = GetItemById(i)
				local Tier = Modules.Tiers[Item.Tier.Value]
				Button.Parent = script.Parent.Items
				Button.Name = "ItemButton"..tostring(i)
				Button.Favorite.Visible = v.Favorite ~= nil
				Button.Visible = (v.Amount ~= nil and v.Amount >= 1) or false
				Button.Icon.Image = Item.Image.Value
				Button.Icon.BackgroundColor3 = Tier.Color2
				Button.Id.Value = Item.ItemId.Value
				Button.Amount.Text = (v.Amount ~= nil and tostring(v.Amount)) or "0"
				Button.BackgroundColor3 = Tier.Color1
				Button.LayoutOrder = GetLayoutOrder(Button)
				HandleButton(Button)
			end
		end
	end
	FillItems()
	local function UpdateItems()
		local Inventory = GetInventory()
		if Inventory then
			for i,v in pairs(Inventory) do
				if v.Amount ~= nil and v.Amount >= 1 then
					local Item = GetItemById(i)
					local Tier = Modules.Tiers[Item.Tier.Value]
					local Button = GetButtonById(i)
					if Button then
						Button.Visible = true
						Button.Favorite.Visible = v.Favorite ~= nil
						Button.Amount.Text = (v.Amount ~= nil and tostring(v.Amount)) or "0"
						Button.LayoutOrder = GetLayoutOrder(Button)
					end
				else
					local Button = GetButtonById(i)
					if Button then
						Button.Visible = false
					end
				end
			end
			script.Parent.Items.CanvasSize = UDim2.new(0,0,0,script.Parent.Items.UIGridLayout.AbsoluteContentSize.Y + 120)
			script.Parent.Items.CanvasPosition = Vector2.new(0,0)
			local Top = GetFirst()
			script.Parent.SelectedObject.Value = Top
		end
	end
	game.ReplicatedStorage.InventoryChanged.OnClientEvent:Connect(UpdateItems)
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(UpdateItems)
	UpdateItems()
	
	script.Parent.Top.Search.Box:GetPropertyChangedSignal("Text"):Connect(function()
		local Box = script.Parent.Top.Search.Box
		local Inventory = GetInventory()
		if Box.Text ~= "" and Box.Text ~= "Search..." then
			for _,v in pairs(script.Parent.Items:GetChildren()) do
				if v:IsA("TextButton") and v.Name ~= "Sample" then
					local Item = GetItemById(v.Id.Value)
					if string.find(string.lower(Item.ItemName.Value),string.lower(Box.Text)) or string.find(string.lower(Modules.Tiers[Item.Tier.Value].Name),string.lower(Box.Text)) then
						if Inventory and Inventory[v.Id.Value].Amount ~= nil and Inventory[v.Id.Value].Amount >= 1 then
							v.Visible = true
						end
					else
						v.Visible = false
					end
				end
			end
		else
			for _,v in pairs(script.Parent.Items:GetChildren()) do
				if v:IsA("TextButton") and v.Name ~= "Sample" then
					if Inventory and Inventory[v.Id.Value].Amount ~= nil and Inventory[v.Id.Value].Amount >= 1 then
						v.Visible = true
					end
				end
			end
		end
		if Box.Text ~= "Search..." then
			script.Parent.Top.Search.Clear.Visible = true
			Box.TextTransparency = 0
			Box.Font = Enum.Font.SourceSansBold
		end
	end)
	
	script.Parent.Top.Search.Clear.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		script.Parent.Top.Search.Clear.Visible = false
		script.Parent.Top.Search.Box.Text = "Search..."
		script.Parent.Top.Search.Box.TextTransparency = 0.5
		script.Parent.Top.Search.Box.Font = Enum.Font.SourceSansItalic
	end)
	
	script.Parent.Top.Sorts.NameSort.MouseButton1Click:Connect(function()
		if SortType ~= "Name" then
			Modules.Menu.Sounds.Click:Play()
			SortType = "Name"
			game.ReplicatedStorage.ToggleSetting:FireServer("InvSort","Name")
			script.Parent.Top.Sorts.NameSort.BackgroundColor3 = Color3.fromRGB(212,212,212)
			script.Parent.Top.Sorts.TierSort.BackgroundColor3 = Color3.fromRGB(139,139,139)
			script.Parent.Top.Sorts.IdSort.BackgroundColor3 = Color3.fromRGB(139,139,139)
			UpdateItems()
		end
	end)
	
	script.Parent.Top.Sorts.TierSort.MouseButton1Click:Connect(function()
		if SortType ~= "Tier" then
			Modules.Menu.Sounds.Click:Play()
			SortType = "Tier"
			game.ReplicatedStorage.ToggleSetting:FireServer("InvSort","Tier")
			script.Parent.Top.Sorts.TierSort.BackgroundColor3 = Color3.fromRGB(212,212,212)
			script.Parent.Top.Sorts.NameSort.BackgroundColor3 = Color3.fromRGB(139,139,139)
			script.Parent.Top.Sorts.IdSort.BackgroundColor3 = Color3.fromRGB(139,139,139)
			UpdateItems()
		end
	end)
	
	script.Parent.Top.Sorts.IdSort.MouseButton1Click:Connect(function()
		if SortType ~= "Id" then
			Modules.Menu.Sounds.Click:Play()
			SortType = "Id"
			game.ReplicatedStorage.ToggleSetting:FireServer("InvSort","Id")
			script.Parent.Top.Sorts.IdSort.BackgroundColor3 = Color3.fromRGB(212,212,212)
			script.Parent.Top.Sorts.TierSort.BackgroundColor3 = Color3.fromRGB(139,139,139)
			script.Parent.Top.Sorts.NameSort.BackgroundColor3 = Color3.fromRGB(139,139,139)
			UpdateItems()
		end
	end)
end



return module