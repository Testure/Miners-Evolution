local module = {}

module.Active = script.Parent
local DB = false
local Buttons = {}
local Player = game.Players.LocalPlayer

function module.init(Modules)
	script.Parent.Gift.Visible = (Player:FindFirstChild("Gifted") == nil and Player.GiftStatus.Value)
	module.Active.Active = (script.Parent.Gift.Visible and script.Parent.MOTD.Visible)
	
	script.Parent.MOTD.Changed:Connect(function()
		module.Active.Active = (script.Parent.Gift.Visible and script.Parent.MOTD.Visible)
	end)
	script.Parent.Gift.Changed:Connect(function()
		module.Active.Active = (script.Parent.Gift.Visible and script.Parent.MOTD.Visible)
	end)
	
	script.Parent.MOTD.MouseButton1Click:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		Modules.MOTD.Open()
	end)
	
	Player.GiftStatus.Changed:Connect(function()
		script.Parent.Gift.Visible = (Player:FindFirstChild("Gifted") == nil and Player.GiftStatus.Value)
	end)
	
	script.Parent.Gift.MouseButton1Click:Connect(function()
		if not DB and script.Parent.Gift.Visible and Player:FindFirstChild("Gifted") == nil then
			if not Player.GiftStatus.Value then
				return
			end
			DB = true
			Modules.Menu.Sounds.UnlockGift:Play()
			game.ReplicatedStorage.RewardReady:FireServer()
			script.Parent.Gift.Visible = false
		end
		wait()
		DB = false
	end)
	
	local function Close(Button)
		local Goal = UDim2.new(1,0,0,0)
		if Button.Hover.Active then
			Button.Hover.Active = false
			if Button.Hover.Title.Position ~= Goal then 
				Modules.Tween(Button.Hover.Title,{"Position"},Goal,1,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
			end
		elseif Button.Hover.Title.Position ~= Goal then
			Modules.Tween(Button.Hover.Title,{"Position"},Goal,1,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		end
	end
	
	local function Open(Button)
		if not Button.Hover.Active then
			Button.Hover.Active = true
			local Goal = UDim2.new(0,10,0,0)
			if Button.Hover.Title.Position ~= Goal then
				Modules.Tween(Button.Hover.Title,{"Position"},Goal,1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
			end
		end
	end
	
	for _,v in pairs(script.Parent:GetChildren()) do
		if v:IsA("TextButton") then
			table.insert(Buttons,v)
			
			local Opened = false
			
			if v:FindFirstChild("Hover") then
				v.Hover.Visible = true
				if Modules.Input.Mode.Value == "Mobile" then
					v.Hover.Title.Position = UDim2.new(1,0,0,0)
					v.Hover.Active = false
					Opened = true
				else
					v.Hover.Title.Position = UDim2.new(0,10,0,0)
					v.Hover.Active = true
				end
			end
			
			spawn(function()
				wait(5 - v.LayoutOrder / 4)
				if not Opened then
					Close(v)
				end
			end)
			
			v.MouseLeave:Connect(function()
				Close(v)
			end)
			
			v.MouseEnter:Connect(function()
				Opened = true
				if Modules.Input.Mode.Value == "PC" then
					for _,b in pairs(Buttons) do
						if b ~= v then
							Close(b)
						end
					end
					Open(v)
				end
			end)
			
			v.MouseButton1Click:Connect(function()
				v.Active = false
				Close(v)
				wait(0.3)
				v.Active = true
			end)
		end
	end
	
	spawn(function()
		while script.Parent.Gift.Visible do
			wait(5)
			local Icon = script.Parent.Gift:FindFirstChild("Icon")
			if Icon then
				Icon:TweenPosition(UDim2.new(0.5,0,0.5,-30),nil,nil,0.5,true)
				wait(0.6)
				Icon:TweenPosition(UDim2.new(0.5,0,0.5,0),nil,Enum.EasingStyle.Bounce,0.8,true)
			else
				break
			end
		end
	end)
end

return module