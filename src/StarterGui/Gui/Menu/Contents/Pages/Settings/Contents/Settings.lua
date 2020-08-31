local module = {}

function module.init(Modules)
	local Player = game.Players.LocalPlayer
	local Settings = Player:WaitForChild("Settings")
	local Tycoon = Modules.GetTycoon(Player)
	local DB = false
	
	local function PermCheck()
		script.Parent.Locked.Visible = not Modules.TycoonLib.HasPermission(Player,"Owner")
	end
	PermCheck()
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(PermCheck)
	
	local function RefreshMines()
		if Settings.Mines.Value then
			script.Parent.Mines.Toggle.Title.Text = "ON"
			script.Parent.Mines.Toggle.Title.AnchorPoint = Vector2.new(0,0)
			script.Parent.Mines.Toggle.Title.Position = UDim2.new(0,0,0,0)
			script.Parent.Mines.Toggle.Title.BackgroundColor3 = Color3.fromRGB(102,255,102)
		else
			script.Parent.Mines.Toggle.Title.Text = "OFF"
			script.Parent.Mines.Toggle.Title.AnchorPoint = Vector2.new(1,0)
			script.Parent.Mines.Toggle.Title.Position = UDim2.new(1,0,0,0)
			script.Parent.Mines.Toggle.Title.BackgroundColor3 = Color3.fromRGB(255,102,102)
		end
	end
	RefreshMines()
	Settings.Mines.Changed:Connect(RefreshMines)
	
	script.Parent.Mines.Toggle.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		game.ReplicatedStorage.ToggleSetting:FireServer("Mines",not Settings.Mines.Value)
		wait()
		DB = false
	end)
	
	local function RefreshSmooth()
		if Settings.Smooth.Value then
			script.Parent.Smooth.Toggle.Title.Text = "ON"
			script.Parent.Smooth.Toggle.Title.AnchorPoint = Vector2.new(0,0)
			script.Parent.Smooth.Toggle.Title.Position = UDim2.new(0,0,0,0)
			script.Parent.Smooth.Toggle.Title.BackgroundColor3 = Color3.fromRGB(102,255,102)
		else
			script.Parent.Smooth.Toggle.Title.Text = "OFF"
			script.Parent.Smooth.Toggle.Title.AnchorPoint = Vector2.new(1,0)
			script.Parent.Smooth.Toggle.Title.Position = UDim2.new(1,0,0,0)
			script.Parent.Smooth.Toggle.Title.BackgroundColor3 = Color3.fromRGB(255,102,102)
		end
	end
	RefreshSmooth()
	Settings.Smooth.Changed:Connect(RefreshSmooth)
	
	script.Parent.Smooth.Toggle.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		game.ReplicatedStorage.ToggleSetting:FireServer("Smooth",not Settings.Smooth.Value)
		wait()
		DB = false
	end)
	
	local function RefreshMOTD()
		if Settings.ConstantMOTD.Value then
			script.Parent.MOTD.Toggle.Title.Text = "ON"
			script.Parent.MOTD.Toggle.Title.AnchorPoint = Vector2.new(0,0)
			script.Parent.MOTD.Toggle.Title.Position = UDim2.new(0,0,0,0)
			script.Parent.MOTD.Toggle.Title.BackgroundColor3 = Color3.fromRGB(102,255,102)
		else
			script.Parent.MOTD.Toggle.Title.Text = "OFF"
			script.Parent.MOTD.Toggle.Title.AnchorPoint = Vector2.new(1,0)
			script.Parent.MOTD.Toggle.Title.Position = UDim2.new(1,0,0,0)
			script.Parent.MOTD.Toggle.Title.BackgroundColor3 = Color3.fromRGB(255,102,102)
		end
	end
	RefreshMOTD()
	Settings.ConstantMOTD.Changed:Connect(RefreshMOTD)
	
	script.Parent.MOTD.Toggle.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		game.ReplicatedStorage.ToggleSetting:FireServer("ConstantMOTD",not Settings.ConstantMOTD.Value)
		wait()
		DB = false
	end)
	
	local function RefreshHeight()
		if Settings.PrecisePlacing.Value then
			script.Parent.Height.Toggle.Title.Text = "ON"
			script.Parent.Height.Toggle.Title.AnchorPoint = Vector2.new(0,0)
			script.Parent.Height.Toggle.Title.Position = UDim2.new(0,0,0,0)
			script.Parent.Height.Toggle.Title.BackgroundColor3 = Color3.fromRGB(102,255,102)
		else
			script.Parent.Height.Toggle.Title.Text = "OFF"
			script.Parent.Height.Toggle.Title.AnchorPoint = Vector2.new(1,0)
			script.Parent.Height.Toggle.Title.Position = UDim2.new(1,0,0,0)
			script.Parent.Height.Toggle.Title.BackgroundColor3 = Color3.fromRGB(255,102,102)
		end
	end
	RefreshHeight()
	Settings.PrecisePlacing.Changed:Connect(RefreshHeight)
	
	script.Parent.Height.Toggle.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		game.ReplicatedStorage.ToggleSetting:FireServer("PrecisePlacing",not Settings.PrecisePlacing.Value)
		wait()
		DB = false
	end)
	
	local function RefreshLoad()
		if Settings.Preload.Value then
			script.Parent.Preload.Toggle.Title.Text = "ON"
			script.Parent.Preload.Toggle.Title.AnchorPoint = Vector2.new(0,0)
			script.Parent.Preload.Toggle.Title.Position = UDim2.new(0,0,0,0)
			script.Parent.Preload.Toggle.Title.BackgroundColor3 = Color3.fromRGB(102,255,102)
		else
			script.Parent.Preload.Toggle.Title.Text = "OFF"
			script.Parent.Preload.Toggle.Title.AnchorPoint = Vector2.new(1,0)
			script.Parent.Preload.Toggle.Title.Position = UDim2.new(1,0,0,0)
			script.Parent.Preload.Toggle.Title.BackgroundColor3 = Color3.fromRGB(255,102,102)
		end
	end
	RefreshLoad()
	Settings.Preload.Changed:Connect(RefreshLoad)
	
	script.Parent.Preload.Toggle.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		game.ReplicatedStorage.ToggleSetting:FireServer("Preload",not Settings.Preload.Value)
		wait()
		DB = false
	end)
	
	local function RefreshSkip()
		if Settings.SkipEvo.Value then
			script.Parent.Skip.Toggle.Title.Text = "ON"
			script.Parent.Skip.Toggle.Title.AnchorPoint = Vector2.new(0,0)
			script.Parent.Skip.Toggle.Title.Position = UDim2.new(0,0,0,0)
			script.Parent.Skip.Toggle.Title.BackgroundColor3 = Color3.fromRGB(102,255,102)
		else
			script.Parent.Skip.Toggle.Title.Text = "OFF"
			script.Parent.Skip.Toggle.Title.AnchorPoint = Vector2.new(1,0)
			script.Parent.Skip.Toggle.Title.Position = UDim2.new(1,0,0,0)
			script.Parent.Skip.Toggle.Title.BackgroundColor3 = Color3.fromRGB(255,102,102)
		end
	end
	RefreshSkip()
	Settings.SkipEvo.Changed:Connect(RefreshSkip)
	
	script.Parent.Skip.Toggle.MouseButton1Click:Connect(function()
		if DB then
			return
		end
		DB = true
		Modules.Menu.Sounds.Click:Play()
		game.ReplicatedStorage.ToggleSetting:FireServer("SkipEvo",not Settings.SkipEvo.Value)
		wait()
		DB = false
	end)
	
	script.Parent.Extra.Withdraw.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		if Modules.InputPrompt.Prompt("Withdraw all items on your base?") then
			local Sound = #Tycoon.Items:GetChildren() >= 1
			local Success = game.ReplicatedStorage.Withdraw:InvokeServer()
			if Success then
				if Sound then
					Modules.Menu.Sounds.Withdraw:Play()
				end
			else
				Modules.Menu.Sounds.Error:Play()
			end
		end
	end)
	
	script.Parent.Extra.Ores.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		if Modules.InputPrompt.Prompt("Destroy all of your ores?") then
			local Success = game.ReplicatedStorage.DestroyOres:InvokeServer()
			if not Success then
				Modules.Menu.Sounds.Error:Play()
			end
		end
	end)
end

return module