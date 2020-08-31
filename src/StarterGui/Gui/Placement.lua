local module = {}

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local CurrentModels = {}
local PrevPlacements = {}
local DB = false
local DB2 = false
local MouseDown = false
module.Placing = false
module.Plane = script.Plane

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
end

local function NoY(Vector,Tycoon,Item)
	local TycoonPos = Tycoon.Base.Position.Y + Tycoon.Base.Size.Y/2
	return Vector3.new(Vector.X,TycoonPos + (Item.Hitbox.Size.Y/2),Vector.Z)
end

function module.init(Modules)
	local Placement
	
	if Modules.Input.Mode.Value == "Mobile" then
		script.Parent.Placing.Position = UDim2.new(0.5,0,0.9,0)
	else
		script.Parent.Placing.Position = UDim2.new(0.5,0,0.95,0)
	end
 	
	local function GetAvaliblePlanes()
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return {}
		end
		local Table = {Tycoon.Base}
		for _,v in pairs(Tycoon.Items:GetChildren()) do
			if v:FindFirstChild("Platform") and v.Platform:FindFirstChild("Platform") then
				table.insert(Table,v.Platform)
			end
		end
		return Table
	end
	
	local function DoThing()
		local Settings = Player:WaitForChild("Settings")
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		Placement = Modules.PlacementModule.new(GetAvaliblePlanes(),Tycoon.Items,3,Modules,Settings.Smooth.Value)
		return
	end
	DoThing()
	
	function module.CancelPlacement()
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		PrevPlacements = {}
		module.Placing = false
		for _,v in pairs(CurrentModels) do
			v:Destroy()
		end
		CurrentModels = {}
		for _,v in pairs(GetAvaliblePlanes()) do
			if v:FindFirstChild("Grid") then
				v.Grid.Transparency = 1
			end
		end
		script.Parent.Placing.Visible = false
		if Placement then
			Placement:disable()
		end
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)
		return
	end
	
	local function Round(Height,Base)
		return math.clamp(Height,0,Base + 33)
	end
	
	function module.Raise()
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		local Settings = Player:WaitForChild("Settings")
		local Amount = (Settings.PrecisePlacing.Value and 1) or 3
		if #CurrentModels >= 1 then
			for _,v in pairs(CurrentModels) do
				if v.Hitbox:FindFirstChild("BaseHeight") and v.Hitbox:FindFirstChild("Adjustable") then
					v.Hitbox.BaseHeight.Value = Vector3.new(0,Round(v.Hitbox.BaseHeight.Value.Y + Amount,GetItemById(v.ItemId.Value).Hitbox.BaseHeight.Value.Y),0)
				end
			end
		end
		return
	end
	-- Placement module uses base height every update, so changing that should work
	function module.Lower()
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		local Settings = Player:WaitForChild("Settings")
		local Amount = (Settings.PrecisePlacing.Value and 1) or 3
		if #CurrentModels >= 1 then
			for _,v in pairs(CurrentModels) do
				if v.Hitbox:FindFirstChild("BaseHeight") and v.Hitbox:FindFirstChild("Adjustable") then
					v.Hitbox.BaseHeight.Value = Vector3.new(0,Round(v.Hitbox.BaseHeight.Value.Y - Amount,v.Hitbox.BaseHeight.Value.Y),0)
				end
			end
		end
		return
	end
	
	function module.StartPlacement(Items,Positions,Override)
		Override = Override or false
		Positions = Positions or false
		Items = (type(Items) == "table" and Items) or {Items}
		if not Override then
			module.CancelPlacement()
		else
			for _,v in pairs(CurrentModels) do
				v:Destroy()
			end
			CurrentModels = {}
			PrevPlacements = {}
			Placement:disable()
		end
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		module.ChangePlane(Tycoon.Base)
		local IsAdjustable = false
		for i,v in pairs(Items) do
			local Item = (type(v) == "number" and GetItemById(v)) or v
			if Item == nil then
				warn("Invalid Item!")
				module.CancelPlacement()
				return false
			end
			local Model = Item:Clone()
			Modules.ArrowHandler.AddConveyor(Model)
			if Model.Hitbox:FindFirstChild("Adjustable") then
				IsAdjustable = true
			end
			if Positions and Positions[i] then
				Model:SetPrimaryPartCFrame(Positions[i])
			else
				local Offset = (Model.Hitbox:FindFirstChild("BaseHeight") ~= nil and Model.Hitbox.BaseHeight.Value.Y) or 0
				local Plane = (module.Plane.Value ~= nil and module.Plane.Value) or Tycoon.Base
				Model:SetPrimaryPartCFrame(CFrame.new(0,(Plane.Position.Y + Model.Hitbox.Size.Y/2) + Offset,0))
			end
			Model.Parent = workspace.Placing
			for _,b in pairs(Model:GetChildren()) do
				if b:IsA("BasePart") then
					b.Anchored = true
					b.CanCollide = false
				end
			end
			table.insert(CurrentModels,Model)
			if Model.Hitbox:FindFirstChild("Light") == nil then
				local Light = script.Light:Clone()
				Light.Parent = Model.Hitbox
				Light.Enabled = game.ReplicatedStorage.Night.Value
			end
		end
		Modules.Preview.Collapse()
		Modules.Preview.Hide()
		Modules.ItemInfo.Hide()
		Modules.ItemHover.Unadapt()
		module.Placing = true
		for _,v in pairs(GetAvaliblePlanes()) do
			if v:FindFirstChild("Grid") then
				v.Grid.Transparency = 0
			else
				local Grid = script.Grid:Clone()
				Grid.Transparency = 0
				Grid.Parent = v
			end
		end
		Placement:enable(CurrentModels)
		script.Parent.Placing.Visible = true
		if IsAdjustable then
			script.Parent.Placing.Controls.Lower.Visible = true
			script.Parent.Placing.Controls.Raise.Visible = true
			script.Parent.Placing.MobileControls.Lower.Visible = true
			script.Parent.Placing.MobileControls.Raise.Visible = true
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		else
			script.Parent.Placing.Controls.Lower.Visible = false
			script.Parent.Placing.Controls.Raise.Visible = false
			script.Parent.Placing.MobileControls.Lower.Visible = false
			script.Parent.Placing.MobileControls.Raise.Visible = false
		end
		if Modules.Input.Mode.Value == "Mobile" then
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		end
		if #Items > 1 then
			script.Parent.Placing.Amount.Text = "Placing "..tostring(#Items).." items."
		else
			local Count = game.ReplicatedStorage.GetInventory:InvokeServer()[Items[1]].Amount
			Count = Count or 0
			script.Parent.Placing.Count.Value = Count
			script.Parent.Placing.Amount.Text = tostring(Count).." Left."
		end
		if Modules.Input.Mode.Value ~= "PC" then
			Modules.Menu.CloseMenu()
		end
		return
	end
	
	function module.ChangePlane(Plane)
		local New = true--(Plane ~= Placement.plane)
		module.Plane.Value = Plane
		local Tycoon = Player.ActiveTycoon.Value
		if DB2 then
			return false
		end
		if Tycoon == nil then
			return false
		end
		DB2 = true
		local Settings = Player:WaitForChild("Settings")
		if module.Placing and New then
			local Models = {}
			local Pos = {}
			for _,v in pairs(CurrentModels) do
				table.insert(Pos,v:GetPrimaryPartCFrame())
				table.insert(Models,v.ItemId.Value)
			end
			Placement:disable()
			Placement = Modules.PlacementModule.new(GetAvaliblePlanes(),Tycoon.Items,3,Modules,Settings.Smooth.Value)
			if module.Placing then
				module.StartPlacement(Models,Pos,true)
			end
		elseif New then
			Placement = Modules.PlacementModule.new(GetAvaliblePlanes(),Tycoon.Items,3,Modules,Settings.Smooth.Value)
		end
		wait()
		DB2 = false
		return
	end
	
	function module.Rotate()
		if DB then
			return false
		end
		DB = true
		if Placement then
			Placement:rotate()
		end
		wait()
		DB = false
		return
	end
	
	function module.Place()
		if DB then
			return false
		end
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			return false
		end
		DB = true
		if Placement then
			if not Placement:isGood() then
				DB = false
				return false
			end
			local Positions = Placement:place()
			local ItemData = {}
			for i,v in pairs(CurrentModels) do
				local Yes = v.Hitbox:FindFirstChild("Adjustable") ~= nil
				local Part = nil
				local Height = nil
				if Positions[i] then
					local Offset = (v.Hitbox:FindFirstChild("BaseHeight") ~= nil and v.Hitbox.BaseHeight.Value.Y) or 0
					local Rey = Ray.new(Positions[i].p,Vector3.new(0,-v.Hitbox.Size.Y - Offset,0))
					local List = {Tycoon.Base}
					if workspace.Placing:FindFirstChild("Platform",true) then
						for _,b in pairs(workspace.Placing:GetChildren()) do
							if b:FindFirstChild("Platform") and b.Platform:FindFirstChild("Platform") then
								table.insert(List,b.Platform)
							end
						end
					end
					Part = workspace:FindPartOnRayWithWhitelist(Rey,List)
					if Yes and Offset > 0 then
						Height = Offset
					end
				end
				local Eh = Part ~= nil
				ItemData[i] = {v.ItemId.Value,Positions[i],(Yes or Eh) or false,Height}
			end
			if ItemData == {} then
				DB = false
				return false
			end
			if not Placement:isGood() then
				DB = false
				return false
			end
			local PlacedItems = game.ReplicatedStorage.PlaceItems:InvokeServer(ItemData,module.Plane.Value)
			if #ItemData > 1 then
				module.CancelPlacement()
			end
			if PlacedItems then
				for _,v in pairs(PlacedItems) do
					table.insert(PrevPlacements,v)
				end
				if #ItemData == 1 then
					script.Parent.Placing.Count.Value = script.Parent.Placing.Count.Value - 1
					script.Parent.Placing.Amount.Text = tostring(script.Parent.Placing.Count.Value).." Left."
				end
			end
			if script.Parent.Placing.Count.Value < 1 and #ItemData == 1 then
				Placement:override(true)
			end
			Modules.Menu.Sounds.Placement.Pitch = 1 + (math.random(-100,100)/500)
			Modules.Menu.Sounds.Placement:Play()
			DB = false
			return true
		end
		DB = false
		return false
	end
	
	function module.ToggleAnchor()
		if DB then
			return false
		end
		DB = true
		if Placement then
			if Placement.achored then
				Placement:release()
			else
				Placement:anchor()
			end
		end
		wait()
		DB = false
		return
	end
	
	function module.Undo()
		if DB then
			return false
		end
		DB = true
		if #PrevPlacements >= 1 then
			local LastItem = PrevPlacements[#PrevPlacements]
			local Success = false
			local Id = 0
			if LastItem then
				Id = LastItem.ItemId.Value
				script.SelectionBox.Adornee = LastItem.Hitbox
				Success = game.ReplicatedStorage.DestroyItem:InvokeServer(LastItem)
			end
			if Success then
				Modules.Menu.Sounds.Withdraw.Pitch = 1 + (math.random(-100,100)/500)
				Modules.Menu.Sounds.Withdraw:Play()
				script.SelectionBox.Adornee = nil
				if #CurrentModels == 1 and CurrentModels[1].ItemId.Value == Id then
					script.Parent.Placing.Count.Value = script.Parent.Placing.Count.Value + 1
					script.Parent.Placing.Amount.Text = tostring(script.Parent.Placing.Count.Value).." Left."
				end
				table.remove(PrevPlacements,#PrevPlacements)
			else
				Modules.Menu.Sounds.Error:Play()
			end
		end
		wait()
		DB = false
		return
	end
	
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(function()
		local Tycoon = Player.ActiveTycoon.Value
		if Tycoon == nil then
			module.CancelPlacement()
			return
		end
		module.ChangePlane(Tycoon.Base)
	end)
	
	Mouse.Button1Down:Connect(function()
		MouseDown = true
	end)
	
	Mouse.Button1Up:Connect(function()
		MouseDown = false
	end)
	
	game:GetService("UserInputService").InputBegan:Connect(function(Input,Processed)
		if not Processed and Input.UserInputType == Enum.UserInputType.Gamepad1 then
			if Input.KeyCode == Enum.KeyCode.ButtonR2 then
				MouseDown = true
			end
		end
	end)
	
	game:GetService("UserInputService").InputEnded:Connect(function(Input,Processed)
		if not Processed and Input.UserInputType == Enum.UserInputType.Gamepad1 then
			if Input.KeyCode == Enum.KeyCode.ButtonR2 then
				MouseDown = false
			end
		end
	end)
	
	spawn(function()
		while wait() do
			if module.Placing and Modules.Input.Mode.Value ~= "Mobile" then
				if MouseDown and not DB then
					module.Place()
				end
			end
		end
	end)
	
	game.ReplicatedStorage.UpdatePlane.OnClientEvent:Connect(function(Plane)
		module.ChangePlane(Plane)
	end)
end

return module