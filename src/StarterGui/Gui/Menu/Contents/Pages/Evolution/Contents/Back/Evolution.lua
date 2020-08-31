local module = {}

module.CurrentPage = script.CurrentPage

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
end

local function GetInventory()
	return game.ReplicatedStorage.GetInventory:InvokeServer()
end

function module.init(Modules)
	local Player = game.Players.LocalPlayer
	local DB = false
	script.Parent.Evolve.Contents.Sample.Visible = false
	script.Parent.Fuse.Contents.Sample.Visible = false
	script.Parent.Salvage.Contents.Sample.Visible = false
	script.Parent.Fuse.Selected.From.Sample.Visible = false
	script.Parent.Forge.Contents.Sample.Visible = false
	
	local function PermCheck()
		script.Parent.Parent.Locked.Visible = not Modules.TycoonLib.HasPermission(Player,"Owner")
	end
	PermCheck()
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(PermCheck)
	
	local function UpdateLocked()
		script.Parent.Top.Buttons.Evolve.Locked.Visible = Player.Evolution.Value < 25
		script.Parent.Top.Buttons.Shop.Locked.Visible = Player.Evolution.Value < 50
		script.Parent.Top.Buttons.Fuse.Locked.Visible = Player.Evolution.Value < 75
		script.Parent.Top.Buttons.Salvage.Locked.Visible = Player.Evolution.Value < 100
		script.Parent.Top.Buttons.Forge.Locked.Visible = Player.Evolution.Value < 250
		script.Parent.Top.Buttons.True.Locked.Visible = Player.Evolution.Value < 1000
	end
	UpdateLocked()
	Player.Evolution.Changed:Connect(UpdateLocked)
	
	local function ChangePage(PageName)
		if script.Parent:FindFirstChild(PageName) then
			local Page = script.Parent:FindFirstChild(PageName)
			if Page and Page ~= module.CurrentPage.Value then
				local PageButton = script.Parent.Top.Buttons:FindFirstChild(PageName)
				if PageButton then
					Modules.Tween(script.Parent,{"BackgroundColor3"},PageButton.BackgroundColor3,0.5)
					module.CurrentPage.Value.Visible = false
					Page.Visible = true
					if module.CurrentPage.Value:FindFirstChild("Selected") then
						module.CurrentPage.Value.Selected.Visible = false
						module.CurrentPage.Value.Selected.Id.Value = 0
					end
					module.CurrentPage.Value = Page
				end
			end
		end
	end
	
	for _,v in pairs(script.Parent.Top.Buttons:GetChildren()) do
		if v:IsA("TextButton") and script.Parent:FindFirstChild(v.Name) then
			v.MouseButton1Click:Connect(function()
				if DB then
					return
				end
				if v.Locked.Visible then
					return
				end
				DB = true
				Modules.Menu.Sounds.Click:Play()
				ChangePage(v.Name)
				wait()
				DB = false
			end)
		end
	end
	
	local function UpdateEvo()
		local Price = Modules.MoneyLib.EvoPrice(Player.Evolution.Value)
		script.Parent.Evo.Price.Text = Modules.MoneyLib.VTS(Price,true)
		script.Parent.Evo.Desc.Text = "Destroy your money and all of your base to enter your "..Modules.MoneyLib.HandleEvo(Player.Evolution.Value + 1,Player.TrueEvolution.Value).." Evolution with a powerful Evolution-tier item."
		local Skips = Modules.MoneyLib.Skips(Player.Evolution.Value,Player.Money.Value)
		script.Parent.Evo.Skip.Visible = (Skips >= 1 and Player.Settings.SkipEvo.Value)
		local Suffix = (Skips == 1 and " Evolution") or " Evolutions"
		script.Parent.Evo.Skip.Text = "You will skip "..tostring(Skips)..Suffix
	end
	UpdateEvo()
	Player.Money.Changed:Connect(UpdateEvo)
	
	script.Parent.Evo.Evolve.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		if Player.Money.Value >= Modules.MoneyLib.EvoPrice(Player.Evolution.Value) then
			if Modules.InputPrompt.Prompt("Are you sure? Your base and most of your items will be destroyed.") then
				local Success = game.ReplicatedStorage.Evolution:InvokeServer()
				if Success then
					--Modules.Menu.Sounds.Evolution:Play()
					Modules.Menu.CloseMenu()
					Modules.Placement.CancelPlacement()
				else
					Modules.Menu.Sounds.Error:Play()
				end
			end
		else
			Modules.Menu.Sounds.Error:Play()
			script.Parent.Evo.Evolve.BackgroundColor3 = Color3.fromRGB(255,84,84)
			wait(0.3)
			script.Parent.Evo.Evolve.BackgroundColor3 = Color3.fromRGB(255,162,0)
		end
		wait()
		DB = false
	end)
	
	local function EvolveSelect(Button)
		local Id = Button.Id.Value
		if Id > 0 then
			local Item = GetItemById(Id)
			if not script.Parent.Evolve.Selected.Visible and Item ~= nil then
				local FromItem = GetItemById(Item.EvoId.Value)
				script.Parent.Evolve.Selected.Visible = true
				script.Parent.Evolve.Selected.Id.Value = Id
				local Tier = Modules.Tiers[Item.Tier.Value]
				script.Parent.Evolve.Selected.Item.BackgroundColor3 = Tier.Color1
				script.Parent.Evolve.Selected.Item.Icon.Image = Item.Image.Value
				script.Parent.Evolve.Selected.Item.Amount.Text = "x"..tostring(Item.EvoAmount.Value)
				script.Parent.Evolve.Selected.Item.From.BackgroundColor3 = Modules.Tiers[FromItem.Tier.Value].Color1
				script.Parent.Evolve.Selected.Item.From.Icon.Image = FromItem.Image.Value
				local Inventory = GetInventory()
				if Inventory then
					script.Parent.Evolve.Selected.Item.From.Amount.Visible = true
					local Amount = Inventory[FromItem.ItemId.Value].Amount
					if Amount then
						script.Parent.Evolve.Selected.Item.From.Amount.Text = "You have "..tostring(Amount)
					else
						script.Parent.Evolve.Selected.Item.From.Amount.Text = "You have 0"
					end
				else
					script.Parent.Evolve.Selected.Item.From.Amount.Visible = false
				end
			end
		end
	end
	
	local function UpdateEvolve()
		for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if v.Tier.Value == 19 then
				local Button = script.Parent.Evolve.Contents:FindFirstChild("Button"..tostring(v.ItemId.Value))
				if not Button then
					Button = script.Parent.Evolve.Contents.Sample:Clone()
					Button.Parent = script.Parent.Evolve.Contents
					Button.Visible = true
					Button.Name = "Button"..tostring(v.ItemId.Value)
					Button.Id.Value = v.ItemId.Value
					Button.Icon.Image = v.Image.Value
					Button.BackgroundColor3 = Modules.Tiers[19].Color1
					Button.MouseButton1Click:Connect(function()
						if DB then
							return
						end
						DB = true
						Modules.Menu.Sounds.Click:Play()
						EvolveSelect(Button)
						wait()
						DB = false
					end)
				end
			end
		end
		script.Parent.Evolve.Contents.CanvasSize = UDim2.new(0,0,0,script.Parent.Evolve.Contents.UIGridLayout.AbsoluteContentSize.Y + 20)
	end
	UpdateEvolve()
	
	script.Parent.Evolve.Selected.Evolve.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		if script.Parent.Evolve.Selected.Visible and script.Parent.Evolve.Selected.Id.Value > 0 then
			local Success = game.ReplicatedStorage.Evolve:InvokeServer(script.Parent.Evolve.Selected.Id.Value)
			if not Success then
				Modules.Menu.Sounds.Error:Play()
				script.Parent.Evolve.Selected.Evolve.BackgroundColor3 = Color3.fromRGB(255,84,84)
				wait(0.3)
				script.Parent.Evolve.Selected.Evolve.BackgroundColor3 = Color3.fromRGB(115,211,255)
			end
		end
		wait()
		DB = false
	end)
	
	script.Parent.Evolve.Selected.Cancel.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		script.Parent.Evolve.Selected.Id.Value = 0
		script.Parent.Evolve.Selected.Visible = false
	end)
	
	local function ClearFuse()
		for _,v in pairs(script.Parent.Fuse.Selected.From:GetChildren()) do
			if v:IsA("TextButton") and v.Name ~= "Sample" then
				v:Destroy()
			end
		end
	end
	
	local function FuseSelect(Button)
		local Id = Button.Id.Value
		if Id > 0 then
			local Item = GetItemById(Id)
			if not script.Parent.Fuse.Selected.Visible and Item ~= nil then
				local From = Item.FuseFrom:GetChildren()
				script.Parent.Fuse.Selected.Item.BackgroundColor3 = Modules.Tiers[Item.Tier.Value].Color1
				script.Parent.Fuse.Selected.Item.Icon.Image = Item.Image.Value
				script.Parent.Fuse.Selected.Visible = true
				script.Parent.Fuse.Selected.Id.Value = Id
				ClearFuse()
				local Inventory = GetInventory()
				for _,v in pairs(From) do
					local FromItem = GetItemById(tonumber(v.Name))
					local Button = script.Parent.Fuse.Selected.From.Sample:Clone()
					Button.Parent = script.Parent.Fuse.Selected.From
					Button.Visible = true
					Button.BackgroundColor3 = Modules.Tiers[FromItem.Tier.Value].Color1
					Button.Icon.Image = FromItem.Image.Value
					Button.Name = "Button"..tostring(FromItem.ItemId.Value)
					if Inventory then
						local Prefix = ""
						if Inventory[FromItem.ItemId.Value].Amount then
							Prefix = tostring(Inventory[FromItem.ItemId.Value].Amount)
						else
							Prefix = "0"
						end
						Button.Amount.Text = Prefix.."/"..tostring(v.Value)
					else
						Button.Amount.Text = "0/"..tostring(v.Value)
					end
				end
				script.Parent.Fuse.Selected.From.CanvasSize = UDim2.new(0,0,0,script.Parent.Fuse.Selected.From.UIGridLayout.AbsoluteContentSize.Y + 20)
			end
		end
	end
	
	local function UpdateFuse()
		for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if v.Tier.Value == 17 then
				local Button = script.Parent.Fuse.Contents:FindFirstChild("Button"..tostring(v.ItemId.Value))
				if not Button then
					Button = script.Parent.Fuse.Contents.Sample:Clone()
					Button.Parent = script.Parent.Fuse.Contents
					Button.Visible = true
					Button.BackgroundColor3 = Modules.Tiers[17].Color1
					Button.Icon.Image = v.Image.Value
					Button.Id.Value = v.ItemId.Value
					Button.MouseButton1Click:Connect(function()
						if DB then
							return
						end
						DB = true
						Modules.Menu.Sounds.Click:Play()
						FuseSelect(Button)
						wait()
						DB = false
					end)
				end
			end
		end
		script.Parent.Fuse.Contents.CanvasSize = UDim2.new(0,0,0,script.Parent.Fuse.Contents.UIGridLayout.AbsoluteContentSize.Y + 20)
	end
	UpdateFuse()
	
	script.Parent.Fuse.Selected.Fuse.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		if script.Parent.Fuse.Selected.Visible and script.Parent.Fuse.Selected.Id.Value > 0 then
			local Success = game.ReplicatedStorage.Fuse:InvokeServer(script.Parent.Fuse.Selected.Id.Value)
			if not Success then
				Modules.Menu.Sounds.Error:Play()
				script.Parent.Fuse.Selected.Fuse.BackgroundColor3 = Color3.fromRGB(255,84,84)
				wait(0.3)
				script.Parent.Fuse.Selected.Fuse.BackgroundColor3 = Color3.fromRGB(128,255,168)
			end
		end
		wait()
		DB = false
	end)
	
	script.Parent.Fuse.Selected.Cancel.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		script.Parent.Fuse.Selected.Id.Value = 0
		script.Parent.Fuse.Selected.Visible = false
	end)
	
	local function SalvageSelect(Button)
		local Id = Button.Id.Value
		if Id > 0 then
			local Item = GetItemById(Id)
			local Inventory = GetInventory()
			if not script.Parent.Salvage.Selected.Visible and Item ~= nil then
				script.Parent.Salvage.Selected.Visible = true
				script.Parent.Salvage.Selected.Id.Value = Id
				script.Parent.Salvage.Selected.Item.BackgroundColor3 = Modules.Tiers[Item.Tier.Value].Color1
				script.Parent.Salvage.Selected.Item.Icon.Image = Item.Image.Value
				local Amount = 0
				if Inventory and Inventory[Id] and Inventory[Id].Amount then
					Amount = Inventory[Id].Amount
				end
				script.Parent.Salvage.Selected.Amount.Text = tostring(Amount).." Left."
			end
		end
	end
	
	local function UpdateSalvage()
		local Inventory = GetInventory()
		if Inventory then
			for i,v in pairs(Inventory) do
				local Item = GetItemById(i)
				if Item and (Item.Tier.Value == 16 or Item.Tier.Value == 22) then
					local Button = script.Parent.Salvage.Contents:FindFirstChild("Button"..tostring(i))
					if not Button and v.Amount ~= nil and v.Amount > 1 then
						Button = script.Parent.Salvage.Contents.Sample:Clone()
						Button.Visible = true
						Button.Parent = script.Parent.Salvage.Contents
						Button.BackgroundColor3 = Modules.Tiers[Item.Tier.Value].Color1
						Button.Icon.Image = Item.Image.Value
						Button.Id.Value = i
						Button.Name = "Button"..tostring(i)
						Button.MouseButton1Click:Connect(function()
							if DB then
								return
							end
							DB = true
							Modules.Menu.Sounds.Click:Play()
							SalvageSelect(Button)
							wait()
							DB = false
						end)
					elseif Button and (v.Amount == nil or v.Amount <= 1) then
						Button:Destroy()
					end
				end
			end
		end
		script.Parent.Salvage.Contents.CanvasSize = UDim2.new(0,0,0,script.Parent.Salvage.Contents.UIGridLayout.AbsoluteContentSize.Y + 20)
		if script.Parent.Salvage.Selected.Visible then
			local Id = script.Parent.Salvage.Selected.Id.Value
			local Amount = 0
			if Inventory and Inventory[Id] and Inventory[Id].Amount then
				Amount = Inventory[Id].Amount
			end
			script.Parent.Salvage.Selected.Amount.Text = tostring(Amount).." Left."
		end
	end
	UpdateSalvage()
	game.ReplicatedStorage.InventoryChanged.OnClientEvent:Connect(UpdateSalvage)
	
	script.Parent.Salvage.Selected.Salvage.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		if script.Parent.Salvage.Selected.Visible and script.Parent.Salvage.Selected.Id.Value > 0 then
			local Success = game.ReplicatedStorage.Salvage:InvokeServer(script.Parent.Salvage.Selected.Id.Value)
			if not Success then
				Modules.Menu.Sounds.Error:Play()
				script.Parent.Salvage.Selected.Salvage.BackgroundColor3 = Color3.fromRGB(255,84,84)
				wait(0.3)
				script.Parent.Salvage.Selected.Salvage.BackgroundColor3 = Color3.fromRGB(255,135,75)
			end
		end
		wait()
		DB = false
	end)
	
	script.Parent.Salvage.Selected.Cancel.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		script.Parent.Salvage.Selected.Visible = false
		script.Parent.Salvage.Selected.Id.Value = 0
	end)
	
	script.Parent.True.Do.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		if Player.Evolution.Value < 1000 then
			return
		end
		DB = true
		if Modules.InputPrompt.Prompt("Are you sure? All of your base and items will be destroyed.") then
			if Modules.InputPrompt.Prompt("Are you REALLY sure? only your soulbound items will be returned at Evolution 50.") then
				local Success = game.ReplicatedStorage.TrueEvolution:InvokeServer()
				if Success then
					Modules.Menu.Sounds.TrueEvo:Play()
					Modules.Menu.CloseMenu()
					Modules.Placement.CancelPlacement()
					spawn(function()
						Modules.Tween(workspace.CurrentCamera,{"FieldOfView"},120,4.3)
						wait(4.3)
						Modules.Tween(workspace.CurrentCamera,{"FieldOfView"},5,0.4)
						wait(0.4)
						pcall(function()
							Player.Character:BreakJoints()
							Instance.new("Explosion",workspace).Position = Player.Character.Head.Position
						end)
					end)
				else
					Modules.Menu.Sounds.Error:Play()
					script.Parent.True.Do.BackgroundColor3 = Color3.fromRGB(255,84,84)
					wait(0.3)
					script.Parent.True.Do.BackgroundColor3 = Color3.fromRGB(255,103,103)
				end
			end
		end
		wait()
		DB = false
	end)
	
	local function UpdateShop()
		local Items = game.ReplicatedStorage.GetShopItems:InvokeServer()
		if Items then
			for i,v in pairs(Items) do
				local Button = script.Parent.Shop.Contents:FindFirstChild("Item"..tostring(i))
				if Button then
					local RealItem = GetItemById(v.Id)
					if RealItem then
						local Tier = Modules.Tiers[RealItem.Tier.Value]
						Button.BackgroundColor3 = Tier.Color1
						Button.Icon.Image = RealItem.Image.Value
						Button.ItemName.Text = RealItem.ItemName.Value
						Button.Cost.Text = Modules.MoneyLib.VTS(v.Cost)
						Button.Id.Value = v.Id
					end
				end
			end
		end
		for _,v in pairs(script.Parent.Shop.Contents:GetChildren()) do
			if v:IsA("TextButton") then
				v.Visible = (v.Id.Value > 0)
			end
		end
	end
	UpdateShop()
	game.ReplicatedStorage.ShopUpdated.OnClientEvent:Connect(UpdateShop)
	
	for _,v in pairs(script.Parent.Shop.Contents:GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Click:Connect(function()
				if DB then
					return
				end
				if v.Id.Value <= 0 then
					return
				end
				DB = true
				Modules.Menu.Sounds.Click:Play()
				local Success = game.ReplicatedStorage.BuyEvo:InvokeServer(v.Id.Value)
				if Success then
					Modules.Menu.Sounds.Purchase:Play()
				else
					Modules.Menu.Sounds.Error:Play()
				end
				wait()
				DB = false
			end)
		end
	end
	
	local function ClearForge()
		for _,v in pairs(script.Parent.Forge.Selected.From:GetChildren()) do
			if v:IsA("TextButton") and v.Name ~= "Sample" and v.Name ~= "Shards" then
				v:Destroy()
			end
		end
	end
	
	local function SelectForge(Button)
		local Id = Button.Id.Value
		if Id > 0 then
			if not script.Parent.Forge.Selected.Visible then
				local Item = GetItemById(Id)
				local Inventory = GetInventory()
				if Item and Inventory then
					ClearForge()
					script.Parent.Forge.Selected.From.Shards.Visible = (Item.ForgeCost:FindFirstChild("Shards") ~= nil)
					script.Parent.Forge.Selected.Item.Icon.Image = Item.Image.Value
					script.Parent.Forge.Selected.Visible = true
					script.Parent.Forge.Selected.Id.Value = Item.ItemId.Value
					for _,v in pairs(Item.ForgeCost:GetChildren()) do
						if v.Name == "Shards" then
							script.Parent.Forge.Selected.From.Shards.Amount.Text = Modules.MoneyLib.VTS(Player.Values.Shards.Value).."/"..Modules.MoneyLib.VTS(v.Value)
						else
							local FromId = tonumber(v.Name)
							if FromId and GetItemById(FromId) then
								local FromItem = GetItemById(FromId)
								local Button = script.Parent.Forge.Selected.From.Sample:Clone()
								Button.Parent = script.Parent.Forge.Selected.From
								Button.Visible = true
								Button.Icon.Image = FromItem.Image.Value
								Button.BackgroundColor3 = Modules.Tiers[FromItem.Tier.Value].Color1
								local Entry = Inventory[FromId]
								local Amount = (Entry.Amount ~= nil and Entry.Amount) or 0
								Button.Amount.Text = Modules.MoneyLib.VTS(Amount).."/"..Modules.MoneyLib.VTS(v.Value)
								Button.Name = "Button"..tostring(FromId)
							end
						end
					end
				end
			end
		end
		script.Parent.Forge.Selected.From.CanvasSize = UDim2.new(0,0,0,script.Parent.Forge.Selected.From.UIGridLayout.AbsoluteContentSize.Y + 20)
	end
	
	local function UpdateForge()
		for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if v.Tier.Value == 24 then
				local Button = script.Parent.Forge.Contents:FindFirstChild("Button"..tostring(v.ItemId.Value))
				if not Button then
					Button = script.Parent.Forge.Contents.Sample:Clone()
					Button.Parent = script.Parent.Forge.Contents
					Button.Visible = true
					Button.BackgroundColor3 = Modules.Tiers[24].Color1
					Button.Icon.Image = v.Image.Value
					Button.Id.Value = v.ItemId.Value
					Button.Name = "Button"..tostring(v.ItemId.Value)
					Button.MouseButton1Click:Connect(function()
						if DB then
							return
						end
						DB = true
						Modules.Menu.Sounds.Click:Play()
						SelectForge(Button)
						wait()
						DB = false
					end)
				end
			end
		end
		script.Parent.Forge.Contents.CanvasSize = UDim2.new(0,0,0,script.Parent.Forge.Contents.UIGridLayout.AbsoluteContentSize.Y + 20)
	end
	UpdateForge()
	
	script.Parent.Forge.Selected.Forge.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		if not script.Parent.Forge.Selected.Visible or script.Parent.Forge.Selected.Id.Value <= 0 then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		local Success = game.ReplicatedStorage.ForgeItem:InvokeServer(script.Parent.Forge.Selected.Id.Value)
		if Success then
			Modules.Menu.Sounds.ForgedItem:Play()
			script.Parent.Forge.Selected.Visible = false
			script.Parent.Forge.Selected.Id.Value = 0
		else
			Modules.Menu.Sounds.Error:Play()
			script.Parent.Forge.Selected.Forge.BackgroundColor3 = Color3.fromRGB(255,84,84)
			wait(0.3)
			script.Parent.Forge.Selected.Forge.BackgroundColor3 = Color3.fromRGB(232,89,165)
		end
		wait()
		DB = false
	end)
	
	script.Parent.Forge.Selected.Cancel.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		script.Parent.Forge.Selected.Id.Value = 0
		script.Parent.Forge.Selected.Visible = false
	end)
	
	function module.OnOpen()
		ChangePage("Evo")
		script.Parent.Top.Buttons.CanvasPosition = Vector2.new(0,0)
	end
end

return module