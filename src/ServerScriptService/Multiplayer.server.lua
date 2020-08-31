local function GetTycoon(Player)
	for _,v in pairs(workspace.Tycoons:GetChildren()) do
		if v.Owner.Value == Player then
			return v
		end
	end
end

local function CreateTag(Perm,Parent)
	local Tag = Instance.new("BoolValue")
	Tag.Parent = Parent
	Tag.Name = Perm
	return Tag
end

function game.ReplicatedStorage.TogglePerm.OnServerInvoke(Player,Permiee,Perm)
	local Permissions = Permiee.Permissions:FindFirstChild(Player.Name)
	if Permissions then
		local PermTag = Permissions:FindFirstChild(Perm)
		if PermTag then
			PermTag.Value = not PermTag.Value
		else
			PermTag = CreateTag(Perm,Permissions)
			PermTag.Value = true
		end
		if Permiee.ActiveTycoon.Value == Player.PlayerTycoon.Value then
			game.ReplicatedStorage.TextNotify:FireClient(Permiee,string.upper(Perm).." permission set to "..string.upper(tostring(PermTag.Value)),Color3.new(0.5,0.5,1))
		end
		game.ReplicatedStorage.PermsChanged:FireClient(Permiee)
		game.ReplicatedStorage.PermsChanged:FireClient(Player)
		return true
	else
		warn("Could not find permissions")
	end
	return false
end

function game.ReplicatedStorage.TogglePerms.OnServerInvoke(Player,Permiee)
	if Permiee.Permissions:FindFirstChild(Player.Name) then
		Permiee.Permissions:FindFirstChild(Player.Name):Destroy()
		if Permiee.ActiveTycoon.Value == Player.PlayerTycoon.Value then
			Permiee.ActiveTycoon.Value = nil
			game.ReplicatedStorage.TextNotify:FireClient(Permiee,Player.Name.." has revoked your permisions!",Color3.new(1,0.5,0.5))
		end
	else
		local Perms = Instance.new("BoolValue")
		Perms.Name = Player.Name
		Perms.Parent = Permiee.Permissions
		
		CreateTag("Build",Perms).Value = false
		CreateTag("Buy",Perms).Value = false
		CreateTag("Sell",Perms).Value = false
		
		local Character = Permiee.Character
		if Character and Character:FindFirstChild("HumanoidRootPart") then
			local Tycoon = Player.PlayerTycoon.Value
			if Tycoon then
				if (Character.HumanoidRootPart.Position - Tycoon.Base.Position).Magnitude < Tycoon.Base.Size.X * 1.1 then
					Permiee.ActiveTycoon.Value = Tycoon
					game.ReplicatedStorage.TextNotify:FireClient(Permiee,Player.Name.." has added you to their base!",Color3.new(0.5,1,0.5))
				end
			end
		end
	end
	game.ReplicatedStorage.PermsChanged:FireClient(Permiee)
	game.ReplicatedStorage.PermsChanged:FireClient(Player)
	return true
end

local function FindTycoon(Character)
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		for _,v in pairs(workspace.Tycoons:GetChildren()) do
			if (Character.HumanoidRootPart.Position - v.Base.Position).Magnitude <= v.Base.Size.X * 1.1 then
				if (Character.HumanoidRootPart.Position.Y - v.Base.Position.Y) >= -20 then
					return v
				end
			end
		end
	end
end

game.Players.PlayerAdded:Connect(function(Player)
	local Perms = Instance.new("Folder")
	Perms.Name = "Permissions"
	Perms.Parent = Player
	
	local Tag = Instance.new("BoolValue")
	Tag.Name = "Editing"
	Tag.Parent = Player
	Tag.Value = true
	
	Player.CharacterAdded:Connect(function(Character)
		local Alive = true
		
		local Human = Character:WaitForChild("Humanoid")
		Human.Died:Connect(function()
			Alive = false
		end)
		
		Character:WaitForChild("HumanoidRootPart")
		local function Check()
			if not Alive then
				return
			end
			local NearestTycoon = FindTycoon(Character)
			if NearestTycoon then
				if Player.Permissions:FindFirstChild(tostring(NearestTycoon.Owner.Value)) or Player.PlayerTycoon.Value == NearestTycoon then
					if Player.ActiveTycoon.Value == nil then
						if NearestTycoon == Player.PlayerTycoon.Value then
							game.ReplicatedStorage.TextNotify:FireClient(Player,"Welcome back to your base.")
						elseif NearestTycoon.Owner.Value ~= nil then
							game.ReplicatedStorage.TextNotify:FireClient(Player,"Now entering "..NearestTycoon.Owner.Value.Name.."'s base.")
						end
						Player.ActiveTycoon.Value = NearestTycoon
						game.ReplicatedStorage.PermsChanged:FireClient(Player)
					end
				elseif Player.NearTycoon.Value ~= NearestTycoon and NearestTycoon:FindFirstChild("SpecialMusic") and NearestTycoon.SpecialMusic.Value ~= 0 then
					game.ReplicatedStorage.TextNotify:FireClient(Player,"Now playing "..NearestTycoon.Owner.Value.Name.."'s music.",nil,nil,"Swoosh")
				elseif NearestTycoon.Owner.Value == nil and Player.ActiveTycoon.Value == NearestTycoon then
					Player.ActiveTycoon.Value = nil
					game.ReplicatedStorage.TextNotify:FireClient(Player,"The base owner left the game.",nil,nil,"Swoosh")
				end
				Player.NearTycoon.Value = NearestTycoon
			else
				Player.NearTycoon.Value = nil
				if Player.ActiveTycoon.Value then
					game.ReplicatedStorage.TextNotify:FireClient(Player,"You've left the base.",nil,nil,"Swoosh")
					Player.ActiveTycoon.Value = nil
				end
			end
		end
		while Alive do
			Check()
			wait(1)
		end
	end)
end)

game.ServerStorage.InvChange.Event:Connect(function(Owner)
	game.ReplicatedStorage.InventoryChanged:FireClient(Owner)
	for _,v in pairs(game.Players:GetPlayers()) do
		if v.Permissions:FindFirstChild(Owner.Name) then
			game.ReplicatedStorage.InventoryChanged:FireClient(v)
		end
	end
end)