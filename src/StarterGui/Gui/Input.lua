local module = {}

module.Mode = script.Mode

local UIS = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer

if UIS.KeyboardEnabled then
	module.Mode.Value = "PC"
elseif UIS.GamepadEnabled then
	module.Mode.Value = "Xbox"
elseif UIS.TouchEnabled then
	module.Mode.Value = "Mobile"
end

game.GuiService.AutoSelectGuiEnabled = false

local function NoY(Vector,Tycoon,Item)
	local TycoonPos = Tycoon.Base.Position.Y + Tycoon.Base.Size.Y/2
	return Vector3.new(Vector.X,TycoonPos + (Item.Hitbox.Size.Y/2),Vector.Z)
end

function module.init(Modules)
	
	function module.Withdraw(Selected,Skipsound)
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		for _,v in pairs(Selected) do
			if v.Parent == nil then
				return false
			end
		end
		
		local Model
		if #Selected == 1 then
			Model = Selected[1]
			Model.Parent = game.Lighting
		end
		
		local Success = false
		if #Selected == 1 then
			Success = game.ReplicatedStorage.DestroyItem:InvokeServer(Selected[1])
		else
			Success = game.ReplicatedStorage.DestroyItems:InvokeServer(Selected)
		end
		
		if Success then
			if Model and Model.Parent then
				Model:Destroy()
			end
			Modules.Preview.Collapse()
			if not Skipsound then
				Modules.Menu.Sounds.Withdraw.Pitch = 1 + (math.random(-100,100)/500)
				Modules.Menu.Sounds.Withdraw:Play()
			end
			Modules.Preview.Collapse()
			return true
		else
			if Model and Model.Parent == game.Lighting then
				Model.Parent = Tycoon.Items
			end
			if not Skipsound then
				Modules.Menu.Sounds.Error:Play()
			end
			return false
		end
	end
	
	function module.Move(Selected)
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		if #Selected == 1 then
			local Item = Selected[1]
			if Item and Item:FindFirstChild("ItemId") then
				local Id = Item.ItemId.Value
				local Pos = Item:GetPrimaryPartCFrame()
				if Item.Hitbox:FindFirstChild("BaseHeight") and Item.Hitbox:FindFirstChild("Adjustable") then
					local Vector = NoY(Pos.p,Tycoon,Item)
					Vector = Vector + Vector3.new(0,Item.Hitbox.BaseHeight.Value.Y,0)
					Pos = CFrame.new(Vector) * (Pos - Pos.p)
				end
				if module.Withdraw(Selected,true) then
					Modules.Preview.Collapse()
					spawn(function()
						Modules.Placement.StartPlacement({Id},{Pos})
						Modules.Menu.Sounds.Move:Play()
					end)
				end
			end
		elseif #Selected > 1 then
			local Id = {}
			local CF = {}
			for _,v in pairs(Selected) do
				if v:FindFirstChild("ItemId") then
					table.insert(Id,v.ItemId.Value)
					local Pos = v:GetPrimaryPartCFrame()
					if v.Hitbox:FindFirstChild("BaseHeight") and v.Hitbox:FindFirstChild("Adjustable") then
						Pos = CFrame.new(NoY(Pos.p,Tycoon,v)) * (Pos - Pos.p)
						Pos = CFrame.new(Pos.p + Vector3.new(0,v.Hitbox.BaseHeight.Value.Y,0)) * (Pos - Pos.p)
					end
					table.insert(CF,Pos)
				end
			end
			if module.Withdraw(Selected,true) then
				Modules.Preview.Collapse()
				spawn(function()
					Modules.Placement.StartPlacement(Id,CF)
					Modules.Menu.Sounds.Move:Play()
				end)
			end
		end
	end
	
	function module.Buy(Selected)
		local Successs = false
		if #Selected == 1 and Selected[1] then
			Successs = game.ReplicatedStorage.BuyItem:InvokeServer(Selected[1].ItemId.Value,1)
			if Successs then
				Modules.Menu.Sounds.Purchase:Play()
			else
				Modules.Menu.Sounds.Error:Play()
			end
		end
		return Successs
	end
	
	function module.Sell(Selected)
		local Success = false
		if #Selected == 1 and Selected[1] then
			Success = game.ReplicatedStorage.SellItem:InvokeServer(Selected[1],1)
			if Success then
				Modules.Menu.Sounds.Money:Play()
				Modules.Preview.Collapse()
			else
				Modules.Menu.Sounds.Error:Play()
			end
		end
		return Success
	end
	
	UIS.InputEnded:Connect(function(Input,Processed)
		
		local InputVal = Input.UserInputType.Value
		if (InputVal == 8) or (InputVal >= 0 and InputVal <= 4) then
			module.Mode.Value = "PC"
		elseif InputVal == 7 then
			module.Mode.Value = "Mobile"
		elseif InputVal >= 12 and InputVal <= 19 then
			module.Mode.Value = "Xbox"
		end
		
		if Processed then
			return false
		end
		
		local Tycoon = Modules.GetTycoon(Player)
		
		--PC controls
		if true then
			if Input.KeyCode == Enum.KeyCode.E then
				if Modules.Menu.Open.Value and Modules.Menu.CurrentPage.Value == "Inventory" then
					Modules.Menu.CloseMenu()
				else
					Modules.Menu.OpenMenu("Inventory")
				end
			elseif Input.KeyCode == Enum.KeyCode.F then
				if Modules.Placement.Placing then
					Modules.Placement.Undo()
				elseif Modules.Menu.Open.Value and Modules.Menu.CurrentPage.Value == "Shop" then
					Modules.Menu.CloseMenu()
				else
					Modules.Menu.OpenMenu("Shop")
				end
			elseif Input.KeyCode == Enum.KeyCode.C then
				if Modules.Preview.Expanded.Value then
					module.Buy(Modules.ItemHover.SelectedItems)
				elseif Modules.Menu.Open.Value and Modules.Menu.CurrentPage.Value == "Settings" then
					Modules.Menu.CloseMenu()
				else
					Modules.Menu.OpenMenu("Settings")
				end
			elseif Input.KeyCode == Enum.KeyCode.P then
				if Modules.Menu.Open.Value and Modules.Menu.CurrentPage.Value == "Premium" then
					Modules.Menu.CloseMenu()
				else
					Modules.Menu.OpenMenu("Premium")
				end
			elseif Input.KeyCode == Enum.KeyCode.B then
				if Modules.Menu.Open.Value and Modules.Menu.CurrentPage.Value == "Boxes" then
					Modules.Menu.CloseMenu()
				else
					Modules.Menu.OpenMenu("Boxes")
				end
			elseif Input.KeyCode == Enum.KeyCode.V then
				if Modules.Menu.Open.Value and Modules.Menu.CurrentPage.Value == "Evolution" then
					Modules.Menu.CloseMenu()
				else
					Modules.Menu.OpenMenu("Evolution")
				end
			elseif Input.KeyCode == Enum.KeyCode.Q then
				if Modules.Placement.Placing then
					Modules.Placement.CancelPlacement()
				end
			elseif Input.KeyCode == Enum.KeyCode.R then
				if Modules.Preview.Expanded.Value then
					module.Move(Modules.ItemHover.SelectedItems)
				elseif Modules.Placement.Placing then
					Modules.Placement.Rotate()
				end
			elseif Input.KeyCode == Enum.KeyCode.Z then
				if Modules.Preview.Expanded.Value then
					module.Withdraw(Modules.ItemHover.SelectedItems)
				end
			elseif Input.KeyCode == Enum.KeyCode.X then
				if Modules.Preview.Expanded.Value then
					module.Sell(Modules.ItemHover.SelectedItems)
				end
			elseif Input.KeyCode == Enum.KeyCode.One then
				if Modules.Placement.Placing then
					Modules.Placement.Lower()
				end
			elseif Input.KeyCode == Enum.KeyCode.Two then
				if Modules.Placement.Placing then
					Modules.Placement.Raise()
				end
			end
		end
		
		--Xbox controls
		if true then
			if Input.KeyCode == Enum.KeyCode.ButtonX then
				if Modules.Preview.Expanded.Value then
					module.Withdraw(Modules.ItemHover.SelectedItems)
				elseif not Modules.Menu.Open.Value then
					Modules.Menu.OpenMenu(Modules.Menu.CurrentPage.Value)
				end
			elseif Input.KeyCode == Enum.KeyCode.ButtonY then
				if Modules.Preview.Expanded.Value then
					module.Buy(Modules.ItemHover.SelectedItems)
				end
			elseif Input.KeyCode == Enum.KeyCode.ButtonB then
				if Modules.Menu.Open.Value then
					Modules.Menu.CloseMenu()
				elseif script.Parent.MOTD.Visible then
					Modules.MOTD.Close()
				elseif script.Parent.Salesmen.Visible then
					Modules.Salesmen.Close()
				end
			elseif Input.KeyCode == Enum.KeyCode.ButtonL1 then
				if Modules.Menu.Open.Value then
					Modules.Menu.ChangePageLeft()
				end
			elseif Input.KeyCode == Enum.KeyCode.ButtonR1 then
				if Modules.Menu.Open.Value then
					Modules.Menu.ChangePageRight()
				end
			elseif Input.KeyCode == Enum.KeyCode.DPadUp then
				if Modules.Placement.Placing then
					Modules.Placement.Raise()
				elseif Modules.Preview.Expanded.Value then
					module.Move(Modules.SelectedItems)
				end
			elseif Input.KeyCode == Enum.KeyCode.DPadDown then
				if Modules.Placement.Placing then
					Modules.Placement.Lower()
				elseif Modules.Preview.Expanded.Value then
					module.Sell(Modules.ItemHover.SelectedItems)
				end
			elseif Input.KeyCode == Enum.KeyCode.DPadRight then
				if script.Parent.HUDRight.XboxKey.Visible then
					if script.Parent.HUDRight.MOTD.Visible then
						game.GuiService.GuiNavigationEnabled = true
						game.GuiService.SelectedObject = script.Parent.HUDRight.MOTD
					elseif script.Parent.HUDRight.Gift.Visible then
						game.GuiService.GuiNavigationEnabled = true
						game.GuiService.SelectedObject = script.Parent.HUDRight.Gift
					else
						game.GuiService.GuiNavigationEnabled = false
						game.GuiService.SelectedObject = nil
					end
				end
			end
		end
	end)
	
	script.Parent.Placing.MobileControls.Cancel.MouseButton1Click:Connect(function()
		Modules.Placement.CancelPlacement()
	end)
	
	script.Parent.Placing.MobileControls.Place.MouseButton1Click:Connect(function()
		Modules.Placement.Place()
	end)
	
	script.Parent.Placing.MobileControls.Rotate.MouseButton1Click:Connect(function()
		Modules.Placement.Rotate()
	end)
	
	script.Parent.Placing.MobileControls.Undo.MouseButton1Click:Connect(function()
		Modules.Placement.Undo()
	end)
	
	script.Parent.Placing.MobileControls.Raise.MouseButton1Click:Connect(function()
		Modules.Placement.Raise()
	end)
	
	script.Parent.Placing.MobileControls.Lower.MouseButton1Click:Connect(function()
		Modules.Placement.Lower()
	end)
	
	local function Scan()
		for _,v in pairs(script.Parent:GetDescendants()) do
			if v:IsA("GuiObject") then
				if v:FindFirstChild("PC") and v.PC:IsA("BoolValue") or v:FindFirstChild("Xbox") and v.Xbox:IsA("BoolValue") or v:FindFirstChild("Mobile") and v.Mobile:IsA("BoolValue") then
					v.Visible = v:FindFirstChild(module.Mode.Value) ~= nil
				end
			end
		end
		if module.Mode.Value == "Xbox" then
			script.Parent.HUDRight.XboxKey.Visible = Modules.Buttons.Active.Active
		end
	end
	Scan()
	module.Mode.Changed:Connect(Scan)
end

return module