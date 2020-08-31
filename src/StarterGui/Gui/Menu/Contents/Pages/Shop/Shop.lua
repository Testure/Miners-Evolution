local module = {}

local Player = game.Players.LocalPlayer
local Lib = require(game.ReplicatedStorage.ShopLib)
local Sets = Lib.Sets

local function Find(Mode)
	for i,v in pairs(Sets) do
		if v == Mode then
			return i
		end
	end
end

local function Sort(Table)
	local NewTable = {}
	for i = 1,#Table do
		local LowestPrice = Table[1]
		local LowestPos = 1
		for a,v in pairs(Table) do
			if (v.Cost.Value < LowestPrice.Cost.Value) then
				LowestPrice = v
				LowestPos = a
			end
		end
		table.remove(Table,LowestPos)
		table.insert(NewTable,LowestPrice)
	end
	return NewTable
end

function module.Reset()
	script.Parent.Mode.Value = "New"
end

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
end

function module.init(Modules)
	local AllItems = {}
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if (v.ItemType.Value >= 1 and v.ItemType.Value <= 4) or v.ItemType.Value == 7 then
			table.insert(AllItems,v)
		end
	end
	
	local Money = script.Parent.Parent.Parent.Parent.Parent.Money
	local Angelite = script.Parent.Parent.Parent.Parent.Parent.Angelite
	local Research = script.Parent.Parent.Parent.Parent.Parent.Research
	
	local function Fill()
		local Mode = script.Parent.Mode.Value
		local Items
		local Tycoon = Player.ActiveTycoon.Value
		script.Parent.Content.CanvasPosition = Vector2.new(0,0)
		if Mode == "New" then
			Items = {}
			local Down = Money.Value ^ 0.8
			local Up = Money.Value ^ 1.2
			local Lowest = 10^100
			for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				if v:FindFirstChild("New") then
					local t = v.ItemType.Value
					if (t >= 1 and t <= 4) or t == 7 then
						table.insert(Items,v)
					end
				elseif v:FindFirstChild("Cost") then
					local t = v.ItemType.Value
					if (t >= 1 and t <= 4) or t == 7 then
						local p = v.Cost.Value / Money.Value
						local Dis = math.abs(v.Cost.Value - Money.Value)
						if ((p >= 0.1 or (v.Cost.Value >= Down)) and (p < 5 or (v.Cost.Value <= Up))) or Dis <= 500 then
							table.insert(Items,v)
						end
					end
				end
			end
			Items = Sort(Items)
			script.Parent.Content.Top.Visible = true
			script.Parent.Content.Desc.Title.Text = "Recommended"
			script.Parent.Content.Desc.Return.Visible = false
		elseif Mode == "Custom" then
			script.Parent.Content.Top.Visible = true
			script.Parent.Content.Desc.Title.Text = "Custom Search"
			script.Parent.Content.Desc.Return.Visible = true
			Items = AllItems
		else
			script.Parent.Content.Top.Visible = false
			script.Parent.Content.Desc.Return.Visible = true
			if Modules.Input.Mode.Value == "Xbox" then
				game.GuiService.SelectedObject = script.Parent.Content.Desc.Return
			end
			Items = Lib["Sorted"..Mode]
		end
		
		local Count = 1
		for i,v in pairs(Items) do
			local Button = script.Parent.Content.Items:FindFirstChild("Button"..tostring(Count))
			if Button then
				if v.ItemType.Value == 7 and v.Angel.Value then
					Button.Cost.Text = "&"..Modules.MoneyLib.VTS(v.Cost.Value)
					Button.Cost.TextColor3 = Color3.fromRGB(156,58,195)
				elseif v:FindFirstChild("Cost") then
					Button.Cost.Text = "$"..Modules.MoneyLib.VTS(v.Cost.Value)
					Button.Cost.TextColor3 = Color3.fromRGB(34,255,96)
				end
				local Active = true
				Button.Id.Value = v.ItemId.Value
				Button.Icon.Image = v.Image.Value
				local Tier = Modules.Tiers[v.Tier.Value]
				if Tier then
					Button.Cost.BackgroundColor3 = Tier.Color1
					Button.BackgroundColor3 = Tier.Color1
					Button.Locked.BackgroundColor3 = Tier.Color1
					Button.Icon.BackgroundColor3 = Tier.Color2
				end
				local Locked = Research.Value < v.ReqResearch.Value and Player:FindFirstChild("Premium") == nil
				Button.Cost.Visible = not Locked
				Button.Locked.Visible = Locked
				Button.New.Visible = v:FindFirstChild("New") and not Locked
				Button.Locked.Req.Text = "R"..Modules.MoneyLib.VTS(v.ReqResearch.Value)
				local Max = #Items
				
				if v:FindFirstChild("New") and Mode == "New" then
					Button.New.Visible = true
					Button.LayoutOrder =  Max + 2
				else
					Button.LayoutOrder = i
				end
				
				Button.Visible = Active
				Count = Count + 1
			end
		end
		script.Parent.Content.Items.Count.Value = Count
		for i = Count,#script.Parent.Content.Items:GetChildren() do
			local Button = script.Parent.Content.Items:FindFirstChild("Button"..tostring(i))
			if Button then
				Button.Visible = false
				Button.Id.Value = 0
			end
		end
		script.Parent.Content.CanvasSize = UDim2.new(0,0,0,(script.Parent.Content.Items.UIGridLayout.AbsoluteContentSize.Y + 120) + 156)
	end
	
	local function PermCheck()
		script.Parent.Locked.Visible = not Modules.TycoonLib.HasPermission(Player,"Buy")
	end
	PermCheck()
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(PermCheck)
	
	for _,v in pairs(script.Parent.Content.Top.Buttons:GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Click:Connect(function()
				if not Modules.TycoonLib.HasPermission(Player,"Buy") then
					return
				end
				Modules.Menu.Sounds.Click:Play()
				script.Parent.Mode.Value = v.Name
				script.Parent.Content.Desc.Title.Text = v.Name
				script.Parent.SelectedItem.Value = 0
			end)
		end
	end
	
	script.Parent.Content.Desc.Return.MouseButton1Click:Connect(function()
		if not Modules.TycoonLib.HasPermission(Player,"Buy") then
			return
		end
		Modules.Menu.Sounds.Click:Play()
		script.Parent.SelectedItem.Value = 0
		if Modules.Input.Mode.Value == "Xbox" then
			local Button = script.Parent.Content.Top.Buttons:FindFirstChild(script.Parent.Mode.Value)
			if Button then
				game.GuiService.SelectedObject = Button
			end
		end
		script.Parent.Mode.Value = "New"
	end)
	
	local function ButtonSetup()
		local SampleButton = script.Parent.Content.Items.Sample
		for i = 1,100 do
			local Button = SampleButton:Clone()
			Button.Name = "Button"..tostring(i)
			Button.Parent = script.Parent.Content.Items
			Button.MouseButton1Click:Connect(function()
				if not Modules.TycoonLib.HasPermission(Player,"Buy") then
					return
				end
				if Button.Visible and Button.Id.Value > 0 then
					Modules.Menu.Sounds.Click:Play()
					script.Parent.SelectedItem.Value = Button.Id.Value
				end
			end)
			local function Enter()
				if not Modules.TycoonLib.HasPermission(Player,"Buy") then
					return
				end
				if not script.Parent.Confirm.Visible then
					if not Button.Locked.Visible then
						Modules.ItemInfo.Show(Button)
					end
				end
			end
			local function Leave()
				Modules.ItemInfo.Hide(Button)
			end
			Button.MouseEnter:Connect(Enter)
			Button.MouseLeave:Connect(Leave)
			Button.SelectionGained:Connect(Enter)
			Button.SelectionLost:Connect(Leave)
		end
		SampleButton:Destroy()
	end
	
	ButtonSetup()
	
	script.Parent.Mode.Changed:Connect(function()
		Fill()
		if script.Parent.Mode.Value ~= "New" and script.Parent.Mode.Value ~= "Custom" then
			local Real = script.Parent.Content.Top.Buttons:FindFirstChild(script.Parent.Mode.Value)
			if Real then
				local Col = Real.BackgroundColor3
				Modules.Tween(script.Parent.Content.Desc,{"BackgroundColor3"},Color3.new(Col.r - 0.1,Col.g - 0.1,Col.b - 0.1),0.5)
			end
			local Button = script.Parent.Content.Items:FindFirstChild("Button1")
			if Button and Modules.Input.Mode.Value == "Xbox" then
				game.GuiService.SelectedObject = Button
			end
		else
			Modules.Tween(script.Parent.Content.Desc,{"BackgroundColor3"},Color3.fromRGB(94,94,94),0.5)
		end
	end)
	
	function module.OnOpen()
		script.Parent.SelectedItem.Value = 0
		if script.Parent.Mode.Value ~= "New" then
			script.Parent.Mode.Value = "New"
		else
			Fill()
		end
		Modules.ItemInfo.Hide()
	end
	
	script.Parent.Mode.Value = "New"
	
	local function CompareCash()
		local Item = GetItemById(script.Parent.SelectedItem.Value)
		if Item then
			if Item.Angel.Value then
				if Angelite.Value >= (Item.Cost.Value * script.Parent.Amount.Value) then
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.fromRGB(71,255,102)
				else
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.fromRGB(150,150,150)
				end
			else
				if Money.Value >= (Item.Cost.Value * script.Parent.Amount.Value) then
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.fromRGB(71,255,102)
				else
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.fromRGB(150,150,150)
				end
			end
		end
	end
	Money.Changed:Connect(CompareCash)
	
	script.Parent.Confirm.Locked.Close.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		script.Parent.SelectedItem.Value = 0
	end)
	
	local function CostCheck()
		CompareCash()
		local Id = script.Parent.SelectedItem.Value
		if Id > 0 then
			local Item = GetItemById(Id)
			if Item then
				if Item.ItemType.Value == 7 and Item.Angel.Value then
					local Cost = (Item.Cost.Value * script.Parent.Amount.Value)
					script.Parent.Confirm.Price.Text = "&"..Modules.MoneyLib.VTS(Cost)
				else
					local Cost = (Item.Cost.Value * script.Parent.Amount.Value)
					script.Parent.Confirm.Price.Text = "$"..Modules.MoneyLib.VTS(Cost)
				end
			end
		end
	end
	
	script.Parent.Amount.Changed:Connect(CostCheck)
	
	script.Parent.SelectedItem.Changed:Connect(function()
		local Id = script.Parent.SelectedItem.Value
		if Id > 0 then
			local Item = GetItemById(Id)
			if Item then
				local Locked = Research.Value < Item.ReqResearch.Value and Player:FindFirstChild("Premium") == nil
				if not Locked then
					script.Parent.Confirm.Locked.Visible = false
					script.Parent.Confirm.Icon.Image = Item.Image.Value
					script.Parent.Confirm.Icon.Title.Text = Item.ItemName.Value
					local Tier = Modules.Tiers[Item.Tier.Value]
					if Tier then
						script.Parent.Confirm.Icon.Tier.BackgroundColor3 = Tier.Color1
						script.Parent.Confirm.Icon.Tier.TextColor3 = Tier.Color2
						script.Parent.Confirm.Icon.Tier.Text = Tier.Name
					end
					script.Parent.Confirm.Desc.Text = Item.Desc.Value
					CostCheck()
					script.Parent.Confirm.Visible = true
					if Modules.Input.Mode.Value == "Xbox" then
						game.GuiService.SelectedObject = script.Parent.Confirm.Buy
					end
				else
					script.Parent.Confirm.Locked.Visible = true
					if Modules.Input.Mode.Value == "Xbox" then
						game.GuiService.SelectedObject = script.Parent.Confirm.Locked.Close
					end
				end
			end
		else
			script.Parent.Confirm.Visible = false
		end
	end)
	
	script.Parent.Confirm.Cancel.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		if Modules.Input.Mode.Value == "Xbox" then
			for _,v in pairs(script.Parent.Content.Items:GetChildren()) do
				if v:FindFirstChild("Id") and v.Visible and v.Id.Value == script.Parent.SelectedItem.Value then
					game.GuiService.SelectedObject = v
					break
				end
			end
		end
		script.Parent.SelectedItem.Value = 0
	end)
	
	script.Parent.Amount.Changed:Connect(function()
		script.Parent.Confirm.Amount.Value.Text = tostring(script.Parent.Amount.Value)
	end)
	
	script.Parent.Confirm.Amount.Value:GetPropertyChangedSignal("Text"):Connect(function()
		local Num = tonumber(script.Parent.Confirm.Amount.Value.Text)
		Num = Num or 0
		local Value = math.ceil(Num)
		if Value == nil or Value <= 0 then
			Value = 1
		elseif Value > 99 then
			Value = 99
		end
		script.Parent.Amount.Value = Value
	end)
	
	script.Parent.Confirm.Amount.Increase.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Tick:Play()
		local Value = math.ceil(script.Parent.Amount.Value * 1.3) + 1
		if Value > 99 then
			Value = 99
		end
		script.Parent.Amount.Value = Value
	end)
	
	script.Parent.Confirm.Amount.Decrease.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Tick:Play()
		local Value = math.ceil(script.Parent.Amount.Value * 0.7) - 1
		if Value <= 0 then
			Value = 1
		end
		script.Parent.Amount.Value = Value
	end)
	
	local DB = false
	
	function module.Buy()
		if not DB then
			DB = true
			local Old = script.Parent.SelectedItem.Value
			local Item = GetItemById(script.Parent.SelectedItem.Value)
			if Item then
				if Item.ItemType.Value == 7 and Item.Angel.Value and (Item.Cost.Value * script.Parent.Amount.Value) >= 100 and Angelite.Value >= (Item.Cost.Value * script.Parent.Amount.Value) then
					local Cost = (Item.Cost.Value * script.Parent.Amount.Value)
					if not Modules.InputPrompt.Prompt("Are you sure you want to spend &"..Modules.MoneyLib.VTS(Cost).."?") then
						DB = false
						return false
					end
				end
				
				local Success = game.ReplicatedStorage.BuyItem:InvokeServer(Item.ItemId.Value,script.Parent.Amount.Value)
				if Success then
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.fromRGB(30,255,30)
					Modules.Menu.Sounds.Purchase:Play()
					
					wait(0.3)
					if script.Parent.SelectedItem.Value == Old then
						script.Parent.SelectedItem.Value = 0
					end
				else
					script.Parent.Confirm.Buy.BackgroundColor3 = Color3.fromRGB(255,115,115)
					Modules.Menu.Sounds.Error:Play()
					wait(0.5)
				end
			end
			CompareCash()
			wait()
			DB = false
		end
	end
	
	script.Parent.Confirm.Buy.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		module.Buy()
	end)
	
	script.Parent.SelectedItem.Value = -1
end

return module