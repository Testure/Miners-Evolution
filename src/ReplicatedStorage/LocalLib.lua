local module = {}

local RegisteredButtons = {}

local function Tween(Object, Properties, Value, Time, Style, Direction)
	Style = Style or Enum.EasingStyle.Quad
	Direction = Direction or Enum.EasingDirection.Out
	
	Time = Time or 0.5

	local propertyGoals = {}
	
	local Table = (type(Value) == "table" and true) or false
	
	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Style,
		Direction
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end

function module.RegisterButton(Button,Color,Click)
	local ImageButton = Button:IsA("ImageLabel")
	local Register = RegisteredButtons[Button.Name]
	if not Register then
		RegisteredButtons[Button.Name] = {}
		Register = RegisteredButtons[Button.Name]
	end
	if Color then
		local NormalColor
		if ImageButton then
			NormalColor = Button.ImageColor3
		else
			NormalColor = Button.BackgroundColor3
		end
		local HoverIn = Button.Button.MouseEnter:Connect(function()
			if ImageButton then
				Tween(Button,{"ImageColor3"},Color3.new(NormalColor.R - 20/255,NormalColor.G - 20/255,NormalColor.B - 20/255),0.1)
			else
				Tween(Button,{"BackgroundColor3"},Color3.new(NormalColor.R - 20/255,NormalColor.G - 20/255,NormalColor.B - 20/255),0.1)
			end
		end)
		local HoverOut = Button.Button.MouseLeave:Connect(function()
			if ImageButton then
				Tween(Button,{"ImageColor3"},NormalColor,0.1)
			else
				Tween(Button,{"ImageColor3"},NormalColor,0.1)
			end
		end)
		table.insert(Register,HoverIn)
		table.insert(Register,HoverOut)
	end
	
	if Click and Button:FindFirstChild("Shadow") then
		local Click = Button.Button.MouseButton1Click:Connect(function()
			local NormalPos = Button.Shadow.Position
			local NormalPos2 = Button.Position
			Tween(Button,{"Position"},UDim2.new(NormalPos2.X.Scale,NormalPos2.X.Offset,NormalPos2.Y.Scale,NormalPos2.Y.Offset + NormalPos.Y.Offset),0.25)
			Tween(Button.Shadow,{"Position"},UDim2.new(NormalPos.X.Scale,NormalPos.X.Offset,NormalPos.Y.Scale,0),0.25)
			wait(0.2)
			if Button and Button.Parent then
				Tween(Button,{"Position"},NormalPos2,0.25)
				Tween(Button.Shadow,{"Position"},NormalPos,0.25)
			end
		end)
		table.insert(Register,Click)
	end
end

function module.UnregisterButton(Button)
	if RegisteredButtons[Button.Name] then
		for _,v in pairs(RegisteredButtons[Button.Name]) do
			v:Disconnect()
		end
		RegisteredButtons[Button.Name] = nil
	end
end

function module.ChangeText(Label,Text)
	Label.Text = Text
	if Label:FindFirstChild("Shadow") then
		Label.Shadow.Text = Text
	end
end

return module