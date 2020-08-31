local module = {}
math.randomseed(tick())

function module.init(Modules)
	function module.Display(Target,String,Color,Time,Audio)
		local Gui = Target:FindFirstChild("CurrencyGui")
		if Gui == nil then
			Gui = script.Parent.CurrencyGui:Clone()
			Gui.Parent = Target
			Gui.Adornee = Target
			Gui.Enabled = true
		end
		
		if Audio then
			local Sound = Instance.new("Sound")
			Sound.Volume = 0.05
			Sound.MaxDistance = 100
			if string.find(Audio,"rbxassetid://") then
				Sound.SoundId = Audio
			else
				Sound.SoundId = "rbxassetid://"..Audio
			end
			Sound.Name = tostring(Audio)
			Sound.Parent = Target
			Sound:Play()
			game.Debris:AddItem(Sound,2)
		end
		
		local Msg = Gui.Sample:Clone()
		local X,Y = (math.random(15,85)/100), (math.random(50,100)/100)
		
		Msg.Position = UDim2.new(X,0,Y,0)
		Msg.TextTransparency = 1
		Msg.TextStrokeTransparency = 1
		Msg.Text = String
		Msg.TextColor3 = Color
		Msg.Parent = Gui
		Msg.Visible = true
		game.Debris:AddItem(Msg,Time)
		Modules.Tween(Msg,{"TextTransparency","TextStrokeTransparency","Position"},{0,0,UDim2.new(X,0,Y-0.25,0)},Time/2,Enum.EasingStyle.Linear)
		wait(Time/2)
		Modules.Tween(Msg,{"TextTransparency","TextStrokeTransparency","Position"},{1,1,UDim2.new(X,0,Y-0.5,0)},Time/2,Enum.EasingStyle.Linear)
	end
	
	game.ReplicatedStorage.Currency.OnClientEvent:Connect(module.Display)
end

return module