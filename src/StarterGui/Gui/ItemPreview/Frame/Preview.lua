local module = {}

local Goal
local DB = false
module.Expanded = script.Parent.Expanded

function module.Hide()
	warn("Modules.Preview.Hide() not ready yet.")
	return false
end

function module.init(Modules)
	function module.Pos(Item)
		if type(Item) == "table" then
			local Sum = Vector3.new(0,0,0)
			local Count = 0
			for _,v in pairs(Item) do
				Sum = Sum + v.Hitbox.Position
			end
			
			local EndPos = Sum/#Item
			if Goal ~= EndPos then
				EndPos = Goal
				local PropertyGoals = {Value = Sum/#Item}
				local TweenProps = TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In)
				game.TweenService:Create(script.Parent.PhysicalPos,TweenProps,PropertyGoals):Play()
			end
		else
			script.Parent.PhysicalPos.Value = Item.Hitbox.Position
		end
	end
	
	function module.Info(Item)
		local ItemName = Item.Name
		if Item:FindFirstChild("ItemName") then
			ItemName = Item.ItemName.Value
		end
		script.Parent.Title.Text = ItemName
		local Tier = Modules.Tiers[Item.Tier.Value]
		script.Parent.Tier.Text = Tier.Name
		script.Parent.Tier.TextColor3 = Tier.Color1
		script.Parent.Tier.BackgroundColor3 = Tier.Color2
		script.Parent.BackgroundColor3 = Tier.Color1
	end
	
	function module.Show(Item)
		if Item and not script.Parent.Expanded.Value then
			module.Pos(Item)
			if type(Item) == "table" then
				script.Parent.LockedToMouse.Value = false
				script.Parent.Title.Text = "Multiple items selected"
				script.Parent.BackgroundColor3 = Color3.new(0.98,0.98,0.98)
				script.Parent.Tier.TextColor3 = Color3.new(0.88,0.88,0.88)
				script.Parent.Tier.Text = tostring(#Item).." items"
				script.Parent.Tier.BackgroundColor3 = Color3.new(0.98,0.98,0.98)
			else
				script.Parent.LockedToMouse.Value = true
				module.Info(Item)
			end
			script.Parent.Withdraw.Visible = false
			script.Parent.Parent.Visible = true
			if type(Item) == "table" then
				script.Parent.Size = UDim2.new(1,0,0,script.Parent.Title.TextBounds.Y + 18)
			else
				script.Parent:TweenSize(UDim2.new(1,0,0,script.Parent.Title.TextBounds.Y + 18),nil,nil,0.25,false)
			end
		end
	end
	
	function module.Expand(Item)
		if Item and not Modules.Placement.Placing then
			script.Parent.LockedToMouse.Value = false
			local Pre = script.Parent.Expanded.Value
			script.Parent.Expanded.Value = true
			
			local EndSize
			module.Pos(Item)
			
			Modules.Menu.Sounds.Slide:Play()
			
			script.Parent.Withdraw.Visible = true
			if type(Item) == "table" then
				script.Parent.Multi.Value = true
				script.Parent.Object.Value = nil
				script.Parent.Title.Text = "Multiple items selected"
				script.Parent.Move.Title.Text = "Move Items"
				script.Parent.BackgroundColor3 = Color3.new(0.98,0.98,0.98)
				script.Parent.Tier.Text = tostring(#Item).." items"
				script.Parent.Tier.TextColor3 = Color3.new(0.98,0.98,0.98)
				script.Parent.Tier.BackgroundColor3 = Color3.new(0.88,0.88,0.88)
				EndSize = UDim2.new(1,0,0,116)
				script.Parent.Sell.Visible = false
				script.Parent.Buy.Visible = false
			else
				EndSize = UDim2.new(1,0,0,178)
				script.Parent.Move.Title.Text = "Move Item"
				script.Parent.Object.Value = Item
				script.Parent.Multi.Value = false
				script.Parent.Sell.Visible = true
				script.Parent.Buy.Visible = true
				
				module.Info(Item)
				
				local Tier = Modules.Tiers[Item.Tier.Value]
				local CanSell,SellType = game.ReplicatedStorage.CanSell:InvokeServer(Item)
				local CanBuy,BuyType = game.ReplicatedStorage.CanBuy:InvokeServer(Item)
				
				if CanBuy then
					if BuyType == "Money" then
						script.Parent.Buy.BackgroundColor3 = Color3.fromRGB(61,255,184)
						script.Parent.Buy.Title.Text = "Buy - $"..Modules.MoneyLib.VTS(Item.Cost.Value)
					elseif BuyType == "Angelite" then
						script.Parent.Buy.BackgroundColor3 = Color3.fromRGB(165,62,255)
						script.Parent.Buy.Title.Text = "Buy - &"..Modules.MoneyLib.VTS(Item.Cost.Value)
					end
				else
					script.Parent.Buy.Title.Text = "Can't Buy"
					script.Parent.Buy.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
				end
				if CanSell then
					if SellType == "Money" then
						script.Parent.Sell.Title.Text = "Sell - $"..Modules.MoneyLib.VTS(Item.Cost.Value*0.35)
					elseif SellType == "Destroy" then
						script.Parent.Sell.Title.Text = "Destroy"
					end
					script.Parent.Sell.BackgroundColor3 = Color3.fromRGB(255,71,197)
				else
					script.Parent.Sell.Title.Text = "Can't Sell"
					script.Parent.Sell.BackgroundColor3 = Color3.new(0.6,0.6,0.6)
				end
			end
			
			if Pre then
				script.Parent.Size = EndSize
			else
				script.Parent:TweenSize(EndSize,nil,nil,0.5,true)
			end
			script.Parent.Parent.Visible = true
		end
	end
	
	function module.Hide()
		if DB then
			return
		end
		DB = true
		if not script.Parent.Expanded.Value then
			script.Parent.Object.Value = nil
			script.Parent:TweenSize(UDim2.new(1,0,0,0),nil,nil,0.25,true)
			wait(0.25)
			script.Parent.Parent.Visible = false
		end
		wait()
		DB = false
	end
	
	function module.Collapse()
		if script.Parent.Expanded.Value then
			script.Parent.Expanded.Value = false
			script.Parent.Object.Value = nil
		end
	end
	
	local function Resize()
		if Modules.Input.Mode.Value == "Mobile" then
			script.Parent.Parent.Size = UDim2.new(0,130,0,200)
		else
			script.Parent.Parent.Size = UDim2.new(0,160,0,200)
		end
	end
	Resize()
	Modules.Input.Mode.Changed:Connect(Resize)
	
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(function()
		if module.Expanded.Value and script.Parent.Object.Value ~= nil then
			module.Expand(script.Parent.Object.Value)
		end
	end)
	
	script.Parent.Withdraw.MouseButton1Click:Connect(function()
		if not DB then
			DB = true
			Modules.Menu.Sounds.Click:Play()
			Modules.Input.Withdraw(Modules.ItemHover.SelectedItems)
			wait()
			DB = false
		end
	end)
	
	script.Parent.Move.MouseButton1Click:Connect(function()
		if not DB then
			DB = true
			Modules.Menu.Sounds.Click:Play()
			Modules.Input.Move(Modules.ItemHover.SelectedItems)
			wait()
			DB = false
		end
	end)
	
	script.Parent.Buy.MouseButton1Click:Connect(function()
		if not DB then
			DB = true
			Modules.Menu.Sounds.Click:Play()
			Modules.Input.Buy(Modules.ItemHover.SelectedItems)
			wait()
			DB = false
		end
	end)
	
	script.Parent.Sell.MouseButton1Click:Connect(function()
		if not DB then
			DB = true
			Modules.Menu.Sounds.Click:Play()
			Modules.Input.Sell(Modules.ItemHover.SelectedItems)
			wait()
			DB = false
		end
	end)
	
	script.Parent.PhysicalPos.Changed:Connect(function()
		if tostring(script.Parent.PhysicalPos.Value.X) == "-nan(ind)" then
			script.Parent.PhysicalPos.Value = Vector3.new(0,0,0)
		elseif tostring(script.Parent.PhysicalPos.Value.Y) == "-nan(ind)" then
			script.Parent.PhysicalPos.Value = Vector3.new(0,0,0)
		elseif tostring(script.Parent.PhysicalPos.Value.Z) == "-nan(ind)" then
			script.Parent.PhysicalPos.Value = Vector3.new(0,0,0)
		end
	end)
end

return module