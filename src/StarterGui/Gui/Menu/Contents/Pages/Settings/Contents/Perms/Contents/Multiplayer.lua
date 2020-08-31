local module = {}

function module.init(Modules)
	for i = 1,5 do
		local Tab = script.Parent.Sample:Clone()
		Tab.Name = tostring(i)
		
		local function CloseTab()
			Modules.Menu.Sounds.Error:Play()
			Tab.Visible = false
			Tab.PlayerName.Text = ""
		end
		
		local function Toggle()
			Modules.Menu.Sounds.Click:Play()
			local Player = game.Players:FindFirstChild(Tab.PlayerName.Text)
			if Player then
				local Success = game.ReplicatedStorage.TogglePerms:InvokeServer(Player)
				if not Success then
					Modules.Menu.Sounds.Error:Play()
				end
			else
				CloseTab()
			end
		end
		
		Tab.Parent = script.Parent.Players
		Tab.Add.MouseButton1Click:Connect(Toggle)
		Tab.Rem.MouseButton1Click:Connect(Toggle)
		
		for _,v in pairs(Tab:GetChildren()) do
			if v:FindFirstChild("Perm") then
				v.MouseButton1Click:Connect(function()
					Modules.Menu.Sounds.Click:Play()
					local Player = game.Players:FindFirstChild(Tab.PlayerName.Text)
					if Player then
						local Success = game.ReplicatedStorage.TogglePerm:InvokeServer(Player,v.Name)
						if not Success then
							Modules.Menu.Sounds.Error:Play()
						end
					end
				end)
			end
		end
	end
	
	local function HasPermission(Player,Perm)
		local Permissions = Player.Permissions:FindFirstChild(game.Players.LocalPlayer.Name)
		if Permissions then
			local Permission = Permissions:FindFirstChild(Perm)
			if Permission and Permission.Value then
				return true
			end
		end
		return false
	end
	
	local function UpdatePermissions()
		local Count = 1
		for _,Player in pairs(game.Players:GetPlayers()) do
			local Button = script.Parent.Players:FindFirstChild(tostring(Count))
			if Button and Player:WaitForChild("Permissions",1) and Player ~= game.Players.LocalPlayer then
				Button.PlayerName.Text = Player.Name
				if Player.Permissions:FindFirstChild(game.Players.LocalPlayer.Name) then
					Button.Add.Visible = false
					for _,v in pairs(Button:GetChildren()) do
						if v:FindFirstChild("Perm") then
							v.Visible = true
							local Has = HasPermission(Player,v.Name)
							v.BackgroundColor3 = (Has and Color3.fromRGB(106,255,131)) or Color3.fromRGB(255,134,134)
						end
					end
					Button.Rem.Visible = true
				else
					Button.Add.Visible = true
					for _,v in pairs(Button:GetChildren()) do
						if v:FindFirstChild("Perm") then
							v.Visible = false
						end
					end
					Button.Rem.Visible = false
				end
				Button.Visible = true
				Count = Count + 1
			end
		end
		for i = Count,5 do
			local Button = script.Parent.Players:FindFirstChild(tostring(Count))
			Button.Visible = false
			Button.PlayerName.Text = ""
		end
		if Count <= 1 then
			script.Parent.Parent.Visible = false
		else
			script.Parent.Parent.Visible = true
		end
	end
	
	game.Players.PlayerAdded:Connect(UpdatePermissions)
	game.Players.PlayerRemoving:Connect(UpdatePermissions)
	UpdatePermissions()
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(UpdatePermissions)
end

return module