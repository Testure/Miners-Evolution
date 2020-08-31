local module = {}

function module.init(Modules)
	game.ReplicatedStorage.CurrencyNotify.OnClientEvent:Connect(function(Text,Color,Icon)
		local Template = script.Parent.Currency:Clone()
		Modules.Menu.Sounds.Obtained:Play()
		Template.Parent = script.Parent
		Template.Visible = true
		Template.Title.Text = Text
		Template.Icon.Image = Icon
		Template.Icon.BackgroundColor3 = Color
		Template.BackgroundColor3 = Color
		Template.Size = UDim2.new(0,50,0,50)
		Modules.Tween(Template,{"Size"},UDim2.new(1,0,0,50),0.5)
		wait(2.5)
		Modules.Tween(Template,{"Size"},UDim2.new(0,0,0,50),0.5)
		wait(0.5)
		Template:Destroy()
	end)
	
	game.ReplicatedStorage.TextNotify.OnClientEvent:Connect(function(Text,Color,BGColor,Sound,Time)
		Time = Time or 1
		Sound = Sound or "Message"
		Color = Color or Color3.new(1,1,1)
		BGColor = BGColor or Color3.new(0,0,0)
		
		local RealSound = Modules.Menu.Sounds[Sound]
		if RealSound then
			RealSound:Play()
		end
		
		local Template = script.Parent.Template:Clone()
		Template.Parent = script.Parent
		Template.Text = Text
		
		Template.TextColor3 = Color
		Template.BackgroundColor3 = BGColor
		
		local Bounds = Template.TextBounds
		Template.Size = UDim2.new(0,Bounds.X + 10,0,Bounds.Y + 5)
		Template.Visible = true
		
		Template.TextTransparency = 1
		Template.TextStrokeTransparency = 1
		
		Modules.Tween(Template,{"TextTransparency","TextStrokeTransparency"},{0,0},0.5)
		
		wait((3 + string.len(Text)/25) * Time)
		
		Modules.Tween(Template,{"TextTransparency","TextStrokeTransparency"},{1,1},0.5)
		Modules.Tween(Template,{"Size"},UDim2.new(0,0,0,Bounds.Y + 5),0.5)
		
		wait(0.5)
		Template:Destroy()
	end)
	
	game.ReplicatedStorage.ItemNotify.OnClientEvent:Connect(function(Item,Amount)
		Amount = Amount or 1
		local Template = script.Parent.Item:Clone()
		Template.Parent = script.Parent
		Modules.Menu.Sounds.Obtained:Play()
		Template.Title.Text = Item.Name
		Template.Visible = true
		Template.Icon.Image = Item.Image.Value
		local Tier = Modules.Tiers[Item.Tier.Value]
		if Tier then
			Template.BackgroundColor3 = Tier.Color2
			Template.Icon.BackgroundColor3 = Template.BackgroundColor3
			Template.Tier.TextColor3 = Tier.Color1
			Template.Tier.Text = Tier.Name
		end
		
		if Amount > 1 then
			Template.Icon.Amount.Text = "x"..tostring(Amount)
			Template.Icon.Amount.Visible = true
		else
			Template.Icon.Amount.Visible = false
		end
		
		Template.Size = UDim2.new(0,100,0,100)
		Modules.Tween(Template,{"Size"},UDim2.new(1,0,0,100),0.5)
		wait(4)
		Modules.Tween(Template,{"Size"},UDim2.new(0,0,0,100),0.5)
		wait(0.5)
		Template:Destroy()
	end)
end

return module