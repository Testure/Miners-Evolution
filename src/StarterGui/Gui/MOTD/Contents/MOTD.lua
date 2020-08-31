local module = {}

function module.init(Modules)
	local Player = game.Players.LocalPlayer
	local Settings = Player:WaitForChild("Settings")
	
	function module.Close(String,Type)
		if Type == Enum.UserInputState.Cancel then
			return false
		end
		
		Modules.Menu.Sounds.Click:Play()
		script.Parent.Parent.Visible = false
	end
	
	script.Parent.Parent.Top.Exit.MouseButton1Click:Connect(module.Close)
	
	function module.Open()
		script.Parent.Parent.Visible = true
		Modules.Menu.CloseMenu()
		if Modules.Input.Mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = false
			game.GuiService.SelectedObject = nil
		end
		game.ReplicatedStorage.OpenedMOTD:FireServer()
		script.Parent.Parent.Parent.HUDRight.MOTD.Amount.Visible = false
		if not Settings.ConstantMOTD.Value then
			script.Parent.Parent.Parent.HUDRight.MOTD.Visible = false
		end
	end
	
	local function Check()
		if Player.Values.MOTD.Value < game.ReplicatedStorage.MOTD.Value then
			script.Parent.Parent.Parent.HUDRight.MOTD.Visible = true
			script.Parent.Parent.Parent.HUDRight.MOTD.Amount.Visible = true
		else
			script.Parent.Parent.Parent.HUDRight.MOTD.Amount.Visible = false
			if Settings.ConstantMOTD.Value then
				script.Parent.Parent.Parent.HUDRight.MOTD.Visible = true
			else
				script.Parent.Parent.Parent.HUDRight.MOTD.Visible = false
			end
		end
	end
	Check()
	Player.Values.MOTD.Changed:Connect(Check)
	Settings.ConstantMOTD.Changed:Connect(Check)
	
	local function GetItemById(Id)
		for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if v.ItemId.Value == Id then
				return v
			end
		end
	end
	
	for _,v in pairs(script.Parent.Body.Items:GetChildren()) do
		if v:IsA("TextButton") and v.Name ~= "Sample" then
			local Item = GetItemById(v.Id.Value)
			if Item then
				v.Icon.Image = Item.Image.Value
				local Tier = Modules.Tiers[Item.Tier.Value]
				if Tier then
					v.Icon.BackgroundColor3 = Tier.Color2
					v.BackgroundColor3 = Tier.Color1
				end
				local function Enter()
					Modules.ItemInfo.Show(v)
				end
				local function Leave()
					Modules.ItemInfo.Hide(v)
				end
				v.MouseEnter:Connect(Enter)
				v.MouseLeave:Connect(Leave)
				v.SelectionGained:Connect(Enter)
				v.SelectionLost:Connect(Leave)
			end
		end
	end
	
	script.Parent.Body.Items.CanvasSize = UDim2.new(0,0,0,script.Parent.Body.Items.UIGridLayout.AbsoluteContentSize.Y + 120)
	script.Parent.Body.TextScroll.CanvasSize = UDim2.new(0,0,0,script.Parent.Body.TextScroll.UIListLayout.AbsoluteContentSize.Y + 50)
end

return module