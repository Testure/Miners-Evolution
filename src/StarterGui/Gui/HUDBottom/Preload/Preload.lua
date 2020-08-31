local module = {}

local Assets = {}
local Player = game.Players.LocalPlayer

local function Insert(Value)
	if type(Value) == "table" then
		for _,v in pairs(Value) do
			table.insert(Assets,v)
		end
	else
		table.insert(Assets,Value)
	end
end

function module.init(Modules)
	script.Parent.Position = UDim2.new(1,250,0,-10)
	Insert(script.Parent.Parent.Parent:GetDescendants())
	Insert(workspace.Map)
	Insert(workspace.Tycoons:GetDescendants())
	for _,v in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
		Insert(v.Image)
	end
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		Insert(v.Image)
		for _,b in pairs(v:GetDescendants()) do
			if b:IsA("PartOperation") or b:IsA("Texture") or b:IsA("Decal") or b:IsA("FileMesh") or b:IsA("MeshPart") then
				Insert(b)
			end
		end
	end
	for _,v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") then
			Insert(v)
		end
	end
	
	local Done = false
	local Progress = 0
	
	local function Spin()
		spawn(function()
			while not Done do
				script.Parent.Icon.Rotation = script.Parent.Icon.Rotation + 2
				if script.Parent.Icon.Rotation >= 360 then
					script.Parent.Icon.Rotation = 0
				end
				wait()
			end
		end)
	end
	
	local function Flash()
		local Clone = script.Parent.Icon:Clone()
		Clone.ZIndex = 3
		Clone.Parent = script.Parent.Icon
		Clone.ImageTransparency = 0.8
		Clone.AnchorPoint = Vector2.new(0.5,0.5)
		Clone.Position = UDim2.new(0.5,0,0.5,0)
		Clone.Size = UDim2.new(1,0,1,0)
		Clone:TweenSize(UDim2.new(1.5,0,1.5,0),nil,nil,0.5,true)
		game.Debris:AddItem(Clone,0.5)
	end
	
	local function DoTheThing()
		local Settings = Player:WaitForChild("Settings")
		if not Settings.Preload.Value then
			return false
		end
		script.Parent:TweenPosition(UDim2.new(1,0,0,-10),nil,nil,1,true)
		Spin()
		local Sucess,Error = pcall(function()
			for i = 1,#Assets do
				if not script.Parent then
					error("Uh oh")
				end
				local Asset = Assets[i]
				Modules.LocalLib.ChangeText(script.Parent.Info,tostring(i).."/"..tostring(#Assets))
				game.ContentProvider:PreloadAsync({Asset})
				Progress = i/#Assets
				script.Parent.Bar.Progress.Size = UDim2.new(math.clamp(Progress,0,1),0,1,0)
			end
		end)
		if not Sucess then
			warn(Error)
		end
		Progress = 1
		if not script.Parent then
			return
		end
		script.Parent.Bar.Progress.Size = UDim2.new(1,0,1,0)
		Done = true
		Flash()
		wait(0.7)
		script.Parent:TweenPosition(UDim2.new(1,250,0,-10),nil,nil,0.25,true)
	end
	
	module.Thing = DoTheThing
end

return module