local module = {}

function module.init(Modules)
	function module.Close()
		Modules.Menu.Sounds.Click:Play()
		script.Parent.Visible = false
	end
	script.Parent.Top.Exit.MouseButton1Click:Connect(module.Close)
	
	function module.Open()
		script.Parent.Visible = true
		Modules.Menu.CloseMenu()
		if Modules.Input.Mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = true
			game.GuiService.SelectedObject = script.Parent.Contents.Options.Item1.Button
		end
	end
	
	local DB = false
	for _,v in pairs(script.Parent.Contents.Options:GetChildren()) do
		if v:FindFirstChild("Item") then
			v.Button.MouseButton1Click:Connect(function()
				if DB then
					return
				end
				DB = true
				Modules.Menu.Sounds.Click:Play()
				if v.Item.Value ~= nil then
					local Cost = v.Item.Value.Cost.Value
					if v.Item.Value.CostType.Value == "Angelite" and Cost >= 100 then
						if not Modules.InputPrompt.Prompt("Are you sure you want to spend &"..Modules.MoneyLib.VTS(Cost).."?") then
							DB = false
							return false
						end
					end
					if v.Item.Value.CostType.Value == "Shards" and Cost >= 100 then
						if not Modules.InputPrompt.Prompt("Are you sure you want to spend "..Modules.MoneyLib.VTS(Cost).." Shards?") then
							DB = false
							return false
						end
					end
					v.BackgroundColor3 = Color3.new(0,0,0)
					local Result = game.ReplicatedStorage.BuySalesmenItem:InvokeServer(v.Item.Value.Name)
					if Result then
						v.BackgroundColor3 = Color3.fromRGB(0,255,134)
						Modules.Menu.Sounds.Purchase:Play()
						v.Amount.Text = tostring(v.Item.Value.Stock.Value).." Remaining"
						if v.Item.Value.Stock.Value <= 0 then
							v.SoldOut.Visible = true
						else
							v.SoldOut.Visible = false
						end
						wait(0.25)
						v.BackgroundColor3 = Color3.new(1,1,1)
					else
						v.BackgroundColor3 = Color3.fromRGB(255,84,84)
						Modules.Menu.Sounds.Error:Play()
						wait(0.25)
						v.BackgroundColor3 = Color3.new(1,1,1)
					end
				end
				wait()
				DB = false
			end)
		end
	end
	
	local function GetItemById(Id)
		for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if v.ItemId.Value == Id then
				return v
			end
		end
		return nil
	end
	
	local PriceColors = {
		Angelite = Color3.fromRGB(255,84,185),
		Research = Color3.fromRGB(0,134,255),
		Shards = Color3.fromRGB(255,200,134),
		Robux = Color3.fromRGB(84,255,205),
		Money = Color3.fromRGB(84,255,185),
	}
	local Suffixes = {
		Shards = " Shards",
	}
	local Prefixes = {
		Money = "$",
		Research = "R",
		Angelite = "&",
		Robux = "R$"
	}
	
	local function AssignItemToButton(Item,Button)
		if Item then
			if Item:FindFirstChild("Special") then
				Button.Title.Text = Item.ItemName.Value
				Button.Type.Text = "Misc"
				Button.Type.BackgroundColor3 = Color3.new(.5,.5,.5)
				Button.Icon.Image = Item.Thumbnail.Value
				local CostString = Modules.MoneyLib.VTS(Item.Cost.Value)
				local CostColor = PriceColors[Item.CostType.Value] or Color3.new(.3,.3,.3)
				local FinalString = (Prefixes[Item.CostType.Value] or "")..CostString..(Suffixes[Item.CostType.Value] or "")
				Button.Price.Text = FinalString
				Button.Price.TextColor3 = CostColor
				Button.Item.Value = Item
				Button.Amount.Text = tostring(Item.Stock.Value).." Remaining"
			elseif Item:FindFirstChild("ItemId") then
				local RealItem = GetItemById(Item.ItemId.Value)
				local Tier = Modules.Tiers[RealItem.Tier.Value]
				Button.Type.BackgroundColor3 = Tier.Color1
				Button.Type.Text = Tier.Name
				Button.Title.Text = RealItem.ItemName.Value
				Button.Icon.Image = RealItem.Image.Value
				local CostString = Modules.MoneyLib.VTS(Item.Cost.Value)
				local CostColor = PriceColors[Item.CostType.Value] or Color3.new(.3,.3,.3)
				local FinalString = (Prefixes[Item.CostType.Value] or "")..CostString..(Suffixes[Item.CostType.Value] or "")
				Button.Price.TextColor3 = CostColor
				Button.Price.Text = FinalString
				Button.Item.Value = Item
				Button.Amount.Text = tostring(Item.Stock.Value).." Remaining"
			elseif Item:FindFirstChild("ProductId") then
				Button.Title.Text = Item.ItemName.Value
				Button.Type.Text = "Misc"
				Button.Type.BackgroundColor3 = Color3.new(.4,.4,.4)
				Button.Icon.Image = Item.Thumbnail.Value
				local CostColor = PriceColors[Item.CostType.Value] or Color3.new(.3,.3,.3)
				local FinalString = "R$"..Modules.MoneyLib.VTS(Item.Cost.Value)
				Button.Price.Text = FinalString
				Button.Price.TextColor3 = CostColor
				Button.Item.Value = Item
				Button.Amount.Text = tostring(Item.Stock.Value).." Remaining"
			end
		end
		if Item and Item.Stock.Value <= 0 then
			Button.SoldOut.Visible = true
		else
			Button.SoldOut.Visible = false
		end
	end
	
	local function Refresh()
		local Item1 = workspace.Salesmen.Goods:WaitForChild("First")
		local Item2 = workspace.Salesmen.Goods:WaitForChild("Second")
		local Item3 = workspace.Salesmen.Goods:WaitForChild("Third")
		local Item4 = workspace.Salesmen.Goods:WaitForChild("Fourth")
		AssignItemToButton(Item1,script.Parent.Contents.Options.Item1)
		AssignItemToButton(Item2,script.Parent.Contents.Options.Item2)
		AssignItemToButton(Item3,script.Parent.Contents.Options.Item3)
		AssignItemToButton(Item4,script.Parent.Contents.Options.Item4)
	end
	
	local function CountDown()
		if script.Parent.Visible then
			local RawTime = workspace.Salesmen.Timer.Value
			local Hours = math.floor(RawTime/3600)
			RawTime = RawTime - (Hours * 3600)
			local Minutes = math.floor(RawTime/60)
			local Seconds = RawTime - (Minutes * 60)
			if string.len(tostring(Minutes)) == 1 then
				Minutes = "0"..Minutes
			end
			if string.len(tostring(Seconds)) == 1 then
				Seconds = "0"..Seconds
			end
			local TimeString = "Inventory Refreshes in "..Hours..":"..Minutes..":"..Seconds
			script.Parent.Contents.Time.Text.Text = TimeString
		end
	end
	CountDown()
	workspace.Salesmen.Timer.Changed:Connect(CountDown)
	
	spawn(Refresh)
	game.ReplicatedStorage.UpdateSalesmen.OnClientEvent:Connect(Refresh)
end

return module