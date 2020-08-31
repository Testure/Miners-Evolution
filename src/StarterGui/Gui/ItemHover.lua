local module = {}

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()
local MouseDown = false
module.SelectedItems = {}

local function GetItemsOnTopOf(Item,Tycoon)
	local Platform = Item:FindFirstChild("Platform")
	local List = {}
	for _,v in pairs(Tycoon.Items:GetChildren()) do
		local Rey = Ray.new(v.Hitbox.Position,Vector3.new(v.Hitbox.Position.X,-98232893289382938,v.Hitbox.Position.Z))
		local Part = workspace:FindPartOnRayWithWhitelist(Rey,{Platform})
		if Part and v.Hitbox:FindFirstChild("Adjustable") == nil then
			table.insert(List,v)
		end
	end
	return List
end

function module.init(Modules)
	local function Adapt(Item,Multi)
		if Multi and #module.SelectedItems > 1 then
			for _,v in pairs(module.SelectedItems) do
				Modules.ArrowHandler.RemoveConveyor(v)
				if v.Hitbox:FindFirstChild("Light") then
					v.Hitbox.Light:Destroy()
				end
				if v.Hitbox.Transparency < 1 then
					v.Hitbox.Transparency = 1
				end
				if v.Hitbox:FindFirstChild("SelectionBox") then
					v.Hitbox.SelectionBox:Destroy()
				end
				if v:FindFirstChild("BigBoy") then
					v.BigBoy:Destroy()
				end
				if v:FindFirstChild("SmolBoy") then
					v.SmolBoy:Destroy()
				end
			end
			script.SelectionBox.Color3 = Color3.new(0.0509804,0.411765,0.67451)
			script.SelectionBox.SurfaceColor3 = Color3.new(0.0509804,0.411765,0.67451)
			for _,v in pairs(module.SelectedItems) do
				Modules.ArrowHandler.AddConveyor(v)
				v.Hitbox.Transparency = 0.9
				v.Hitbox.Color = Color3.new(0.0509804,0.411765,0.67451)
				if not v.Hitbox:FindFirstChild("Light") then
					local Light = script.PointLight:Clone()
					Light.Name = "Light"
					Light.Parent = v.Hitbox
					Light.Color = Color3.new(1,1,1)
					Light.Enabled = game.ReplicatedStorage.Night.Value
					Light.Shadows = true
					Light.Range = 8
					Light.Brightness = 2
				end
				if not v.Hitbox:FindFirstChild("SelectionBox") then
					local Box = script.SelectionBox:Clone()
					Box.Parent = v.Hitbox
					Box.Adornee = v.Hitbox
					Box.Color3 = Color3.new(0.0509804,0.411765,0.67451)
					Box.SurfaceColor3 = Color3.new(0.0509804,0.411765,0.67451)
				end
			end
			Modules.Preview.Show(module.SelectedItems)
		else
			Modules.ArrowHandler.AddConveyor(Item[1])
			script.SelectionBox.Adornee = Item[1].Hitbox
			script.SelectionBox.Color3 = Modules.Tiers[Item[1].Tier.Value].Color2
			for _,v in pairs(module.SelectedItems) do
				if v ~= Item[1] then
					Modules.ArrowHandler.RemoveConveyor(v)
					if v.Hitbox:FindFirstChild("Light") then
						v.Hitbox.Light:Destroy()
					end
					if v.Hitbox.Transparency < 1 then
						v.Hitbox.Transparency = 1
					end
					if v.Hitbox:FindFirstChild("SelectionBox") then
						v.Hitbox.SelectionBox:Destroy()
					end
					if v:FindFirstChild("BigBoy") then
						v.BigBoy:Destroy()
					end
					if v:FindFirstChild("SmolBoy") then
						v.SmolBoy:Destroy()
					end
				end
			end
			Item[1].Hitbox.Transparency = 0.7
			Item[1].Hitbox.Color = Modules.Tiers[Item[1].Tier.Value].Color1
			if not Item[1]:FindFirstChild("BigBoy") then
				local Bigboy = Item[1].Hitbox:Clone()
				Bigboy.Name = "BigBoy"
				Bigboy.Parent = Item[1]
				Bigboy.Transparency = 0.8
				Bigboy.Size = Vector3.new(Bigboy.Size.X,Bigboy.Size.Y * 1000,Bigboy.Size.Z)
				Bigboy.Position = Item[1].Hitbox.Position
			end
			if not Item[1]:FindFirstChild("SmolBoy") then
				if true then
					local SmolBoy = Item[1].Hitbox:Clone()
					SmolBoy.Name = "SmolBoy"
					SmolBoy.Parent = Item[1]
					SmolBoy.Material = Enum.Material.Neon
					SmolBoy.Transparency = 0.2
					SmolBoy.Size = Vector3.new(SmolBoy.Size.X,0.5,SmolBoy.Size.Z)
					SmolBoy.Position = Vector3.new(Item[1].Hitbox.Position.X,Item[1].Hitbox.Position.Y - (Item[1].Hitbox.Size.Y/2),Item[1].Hitbox.Position.Z)
				end
			end
			if not Item[1].Hitbox:FindFirstChild("Light") then
				local Light = script.PointLight:Clone()
				Light.Name = "Light"
				Light.Parent = Item[1].Hitbox
				Light.Color = Modules.Tiers[Item[1].Tier.Value].Color1
				Light.Enabled = game.ReplicatedStorage.Night.Value
				Light.Shadows = true
				Light.Range = 8
				Light.Brightness = 2
			end
			Modules.Preview.Show(Item[1])
		end
	end
	
	local function Unadapt()
		script.SelectionBox.Adornee = nil
		for i,v in pairs(module.SelectedItems) do
			Modules.ArrowHandler.RemoveConveyor(v)
			if v.Hitbox:FindFirstChild("Light") then
				v.Hitbox.Light:Destroy()
			end
			if v.Hitbox.Transparency < 1 then
				v.Hitbox.Transparency = 1
			end
			if v.Hitbox:FindFirstChild("SelectionBox") then
				v.Hitbox.SelectionBox:Destroy()
			end
			if v:FindFirstChild("BigBoy") then
				v.BigBoy:Destroy()
			end
			if v:FindFirstChild("SmolBoy") then
				v.SmolBoy:Destroy()
			end
			table.remove(module.SelectedItems,i)
		end
		Modules.Preview.Hide()
	end
	module.Unadapt = Unadapt
	
	local function Repos()
		if Modules.Input.Mode.Value == "PC" and false then --script.Parent.ItemPreview.Frame.LockedToMouse.Value then
			script.Parent.ItemPreview.AnchorPoint = Vector2.new(0,0.5)
			local EndPos = UDim2.new(0,Mouse.X + 18,0,Mouse.Y + 18)
			script.Parent.ItemPreview.Position = EndPos
		else
			if script.Parent.ItemPreview.Frame.Title.Text == "Multiple items selected" then
				Modules.Preview.Pos(module.SelectedItems)
			elseif module.SelectedItems[1] ~= nil then
				Modules.Preview.Pos(module.SelectedItems[1])
			end
			local Pos,Vis = Camera:WorldToScreenPoint(script.Parent.ItemPreview.Frame.PhysicalPos.Value)
			local X,Y = Pos.X,Pos.Y
			script.Parent.ItemPreview.AnchorPoint = Vector2.new(0.5,0.5)
			local EndPos = UDim2.new(0,X,0,Y)
			script.Parent.ItemPreview.Position = EndPos
		end
	end
	
	local function Find(Table,Value,GetI)
		for i,v in pairs(Table) do
			if v == Value then
				if GetI then
					return i
				else
					return v
				end
			end
		end
	end
	
	Mouse.Button1Down:Connect(function()
		if not MouseDown then
			MouseDown = true
		end
	end)
	
	Mouse.Button1Up:Connect(function()
		if MouseDown then
			MouseDown = false
		end
		if not Modules.Preview.Expanded.Value and module.SelectedItems[1] ~= nil and not Modules.Placement.Placing then
			if #module.SelectedItems > 1 then
				local FakeItems = {}
				for _,v in pairs(module.SelectedItems) do
					local List = GetItemsOnTopOf(v,Modules.GetTycoon(Player))
					for _,b in pairs(List) do
						table.insert(FakeItems,b)
					end
				end
				for _,v in pairs(FakeItems) do
					if not Find(module.SelectedItems,v) then
						table.insert(module.SelectedItems,v)
					end
				end
				Adapt(module.SelectedItems,true)
				Modules.Preview.Expand(module.SelectedItems)
			elseif not Modules.Placement.Placing then
				local FakeItems = {}
				for _,v in pairs(module.SelectedItems) do
					local List = GetItemsOnTopOf(v,Modules.GetTycoon(Player))
					for _,b in pairs(List) do
						table.insert(FakeItems,b)
					end
				end
				for _,v in pairs(FakeItems) do
					if not Find(module.SelectedItems,v) then
						table.insert(module.SelectedItems,v)
					end
				end
				if #module.SelectedItems == 1 then
					Modules.Preview.Expand(module.SelectedItems[1])
				else
					Adapt(module.SelectedItems,true)
					Modules.Preview.Expand(module.SelectedItems)
				end
			end
		else
			Modules.Preview.Collapse()
		end
	end)
	
	local Open = Modules.Menu.Open
	local Expanded = Modules.Preview.Expanded
	game:GetService("RunService").RenderStepped:Connect(function()
		if (Modules.Input.Mode.Value == "PC" or game.GuiService.SelectedObject == nil) and not Modules.Placement.Placing and Player.ActiveTycoon.Value ~= nil then
			local ScreenPos
			if Modules.Input.Mode.Value == "PC" and Mouse then
				ScreenPos = Vector2.new(Mouse.X,Mouse.Y + 36)
				if Open.Value then
					if Mouse.X < (script.Parent.Menu.AbsolutePosition.X + script.Parent.Menu.AbsoluteSize.X) then
						Modules.Preview.Collapse()
						Unadapt()
						return
					end
				end
			else
				local CamView = Camera.ViewportSize
				ScreenPos = Vector2.new(math.floor(CamView.X/2),math.floor(CamView.Y/3))
			end
			
			local ScreenRay = Camera:ViewportPointToRay(ScreenPos.X,ScreenPos.Y)
			local Rey = Ray.new(ScreenRay.Origin,ScreenRay.Direction*1000)
			local Tycoon = Modules.GetTycoon(Player)
			local Part
			local WhiteList = {}
			for _,v in pairs(Tycoon.Items:GetChildren()) do
				table.insert(WhiteList,v.Hitbox)
			end
			Part = workspace:FindPartOnRayWithWhitelist(Rey,WhiteList)
			local Part2 = workspace:FindPartOnRayWithIgnoreList(Rey,WhiteList)
			if Part2 then
				if Part2:FindFirstChildWhichIsA("ClickDetector") then
					Modules.Preview.Collapse()
					Unadapt()
					return
				end
			end
			if Part and not Expanded.Value and not Modules.Placement.Placing then
				if Tycoon and not Modules.Placement.Placing and not Expanded.Value then
					if Part.Name == "Hitbox" then
						local Item = Part.Parent
						if Item and Item:IsDescendantOf(Tycoon) and not MouseDown then
							if not Expanded.Value and not Modules.Placement.Placing then
								Adapt({Item})
								module.SelectedItems = {}
								table.insert(module.SelectedItems,Item)
							end
						elseif not MouseDown and not Expanded.Value then
							Unadapt()
						elseif MouseDown and Item and Item:IsDescendantOf(Tycoon) and not Find(module.SelectedItems,Item) then
							if MouseDown and not Expanded.Value and not Modules.Placement.Placing then
								table.insert(module.SelectedItems,Item)
								Adapt({Item},true)
								Modules.Menu.Sounds.TickSoft:Play()
							end
						end
					elseif not MouseDown and not Expanded.Value then
						Unadapt()
					end
				elseif not MouseDown and not Expanded.Value then
					Unadapt()
				end
			elseif not MouseDown and not Expanded.Value then
				Unadapt()
			end
			if script.Parent.ItemPreview.Visible then
				Repos()
			end
		end
	end)
end

return module