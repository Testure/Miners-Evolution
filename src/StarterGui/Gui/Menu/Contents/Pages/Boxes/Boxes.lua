local module = {}
math.randomseed(tick() + os.time()^10)

local Player = game.Players.LocalPlayer

function module.init(Modules)
	local function PermCheck()
		script.Parent.Warn.Visible = not Modules.TycoonLib.HasPermission(Player,"Owner")
	end
	PermCheck()
	game.ReplicatedStorage.PermsChanged.OnClientEvent:Connect(PermCheck)
	
	-- Box Buttons
	local function Setup()
		script.Parent.Boxes.Sample.Visible = false
		for _,v in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
			local Button = script.Parent.Boxes.Sample:Clone()
			Button.Parent = script.Parent.Boxes
			Button.Name = v.Name
			Button.Icon.Image = v.Image.Value
			Button.BackgroundColor3 = v.Color.Value
			Button.Icon.BackgroundColor3 = Color3.new(v.Color.Value.R * 0.8,v.Color.Value.G * 0.8,v.Color.Value.B * 0.8)
			Button.Box.Value = v.Name
		end
		script.Parent.SelectedObject.Value = script.Parent.Boxes.Regular
	end
	
	local function Update()
		for _,v in pairs(script.Parent.Boxes:GetChildren()) do
			if v:IsA("TextButton") then
				local Val = Player.Boxes:FindFirstChild(v.Name)
				if Val and Val.Value > 0 then
					v.Visible = true
					v.Amount.Text = Modules.MoneyLib.VTS(Val.Value)
				else
					v.Visible = false
				end
			end
		end
	end
	Player.Boxes.Changed:Connect(Update)
	
	Setup()
	Update()
	
	-- Opening Boxes
	local Last = script.Parent.Open.Contents.Roll.AbsolutePosition.X
	script.Parent.Open.Contents.Roll:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if script.Parent.Open.Visible then
			local Current = script.Parent.Open.Contents.Roll.AbsolutePosition.X
			if math.abs(Last - Current) > 15 then
				Modules.Menu.Sounds.TickSoft:Play()
				Last = Current
			end
		end
	end)
	
	local Opening = false
	local function OpenBox(Type)
		if Player:FindFirstChild("OpeningBox") then
			return false
		end
		if not Opening and Player.Boxes:FindFirstChild(Type) and Player.Boxes[Type].Value > 0 then
			Modules.ItemInfo.Hide()
			Opening = true
			Modules.Menu.Sounds.UnlockGift:Play()
			script.Parent.Open.Loading.Visible = true
			local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Type)
			if Modules.Input.Mode.Value == "Xbox" then
				game.GuiService.GuiNavigationEnabled = false
			end
			script.Parent.Open.BackgroundColor3 = Real.Color.Value
			script.Parent.Open.Title.Text = Real.Name.." Box"
			script.Parent.Open.Visible = true
			script.Parent.Open.Contents.Roll:ClearAllChildren()
			local Target = math.random(15,23)
			local Prize = game.ReplicatedStorage.OpenBox:InvokeServer(Type)
			script.Parent.Open.Contents.Roll.Position = UDim2.new(0,1500,0,0)
			local RewardButton
			local RewardRarity
			if Prize == nil then
				Modules.Menu.Sounds.Error:Play()
				script.Parent.Open.Visible = false
				return false
			end
			
			for i = 1,30 do
				local Button = script.Parent.Open.Contents.Sample:Clone()
				local Item
				if i ~= Target then
					Item = Modules.Lottery.Run(Player,Type,true)
				else
					Item = Prize
					RewardRarity = Item[5]
					RewardButton = Button
				end
				local RealItem = Item[1]
				Button.Parent = script.Parent.Open.Contents.Roll
				Button.Position = UDim2.new(0,(i-1)*100,0,0)
				Button.Icon.Image = RealItem.Image.Value
				if RealItem.Tier.Value == 14 then
					Button.Vintage.Visible = true
				end
				if RealItem.Tier.Value == 15 then
					Button.Mint.Visible = true
				end
				if RealItem.Tier.Value == 11 or RealItem.Tier.Value == 12 then
					Button.Sales.Visible = true
				end
				
				local Rarity = Item[5]
				local Color = Modules.Tiers[RealItem.Tier.Value].Color1
				if Rarity == 2 then
					--Color = Color3.new(1,1,1)
				elseif Rarity <= 4 then
					--Color = Color3.new(1,1,1)
				elseif Rarity <= 6 then
					--Color = Color3.new(1,1,1)
				elseif Rarity <= 8 then
					--Color = Color3.new(1,1,1)
				end
				Button.BackgroundColor3 = Color
				Button.Visible = true
			end
			
			script.Parent.Open.Loading.Visible = false
			local Offset = script.Parent.Open.Arrow.AbsolutePosition.X - script.Parent.Open.Contents.AbsolutePosition.X
			script.Parent.Open.Contents.Roll:TweenPosition(UDim2.new(0,1500 - (100 * (Target - 1)) + Offset,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,5,true)
			wait(5)
			
			if RewardRarity >= 5 then
				Modules.Menu.Sounds.Unboxxed:Play()
			elseif RewardRarity >= 2 then
				Modules.Menu.Sounds.UnboxxedRare:Play()
			else
				Modules.Menu.Sounds.UnboxxedExotic:Play()
			end
			
			if RewardButton then
				local Copy = RewardButton.Icon:Clone()
				local ASize = RewardButton.Icon.AbsoluteSize
				local APos = RewardButton.Icon.AbsolutePosition
				Copy.Size = UDim2.new(0,ASize.X,0,ASize.Y)
				Copy.AnchorPoint = Vector2.new(0.5,0.5)
				Copy.Position = UDim2.new(0,APos.X + ASize.X/2,0,APos.Y + ASize.Y/2)
				Copy.Name = "RewardAnim"
				Copy.Parent = script.Parent.Parent.Parent
				Copy.ImageTransparency = 0
				Copy.ZIndex = 10
				Modules.Tween(Copy,{"ImageTransparency","Size"},{1,UDim2.new(0,ASize.X * 4,0,ASize.Y * 4)},0.3)
				game.Debris:AddItem(Copy,0.4)
				RewardButton.Icon.ImageTransparency = 0
				RewardButton.BorderSizePixel = 4
				RewardButton.ZIndex = RewardButton.ZIndex + 3
				for _,v in pairs(RewardButton:GetDescendants()) do
					if v:IsA("GuiObject") then
						v.ZIndex = v.ZIndex + 3
					end
				end
			end
			wait(1.5)
			script.Parent.Open.Visible = false
			if Modules.Input.Mode.Value == "Xbox" and game.GuiService.SelectedObject ~= nil then
				game.GuiService.GuiNavigationEnabled = true
			end
			Opening = false
		end
	end
	
	-- Make Buttons Work
	for _,v in pairs(script.Parent.Boxes:GetChildren()) do
		if v:IsA("TextButton") then
			local function Enter()
				if not script.Parent.Open.Visible then
					Modules.ItemInfo.Show(v)
				end
			end
			local function Leave()
				Modules.ItemInfo.Hide()
			end
			v.MouseEnter:Connect(Enter)
			v.MouseLeave:Connect(Leave)
			v.SelectionGained:Connect(Enter)
			v.SelectionLost:Connect(Leave)
			v.MouseButton1Click:Connect(function()
				local Type = v.Name
				if Player.Boxes:FindFirstChild(Type) and Player.Boxes[Type].Value > 0 then
					OpenBox(Type)
				end
			end)
		end
	end
end

return module