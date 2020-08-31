local module = {}

function module.init(Modules)
	local Id = 869537694
	local Player = game.Players.LocalPlayer
	
	script.Parent.Buttons.Close.MouseButton1Click:Connect(function()
		script.Parent.Parent.Visible = false
	end)
	
	script.Parent.Buttons.Extra.MouseButton1Click:Connect(function()
		script.Parent.Parent.Visible = false
		if Id ~= 0 then
			game.MarketplaceService:PromptProductPurchase(Player,Id)
		end
	end)
	
	local Count = 0
	
	local function Clear()
		for _,v in pairs(script.Parent.Scroll:GetChildren()) do
			if v:FindFirstChild("Title") then
				v:Destroy()
			end
		end
		Count = 0
	end
	
	local function AddItem(Text,Image,Color)
		Color = Color or Color3.fromRGB(150,150,150)
		
		local Item = script.Parent.SampleItem:Clone()
		
		Item.Title.Text = Text
		Item.Title.TextColor3 = Color
		
		Item.BackgroundColor3 = Color3.fromRGB(100 + Color.r*40,100 + Color.g*40,100 + Color.b*40)
		
		if Image then
			Item.Image.Visible = true
			Item.Image.Image = Image
		else
			Item.Image.Visible = false
		end
		
		Item.Parent = script.Parent.Scroll
		Item.Visible = true
		Item.LayoutOrder = Count
		
		Count = Count + 1
		script.Parent.Scroll.CanvasSize = UDim2.new(0,0,0,10 + (Count * (script.Parent.SampleItem.AbsoluteSize.Y + 10)))
	end
	
	local function GetItemById(Id)
		for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
			if v.ItemId.Value == Id then
				return v
			end
		end
		return nil
	end
	
	local function Update()
		if Player:FindFirstChild("SecondGift") then
			script.Parent.Parent.Parent.HUDRight.Gift.Icon.ImageColor3 = Color3.fromRGB(0,255,134)
			script.Parent.Parent.Parent.HUDRight.Gift.Hover.Title.TextColor3 = Color3.fromRGB(0,255,134)
		elseif Player:FindFirstChild("Premium") then
			script.Parent.Parent.Parent.HUDRight.Gift.Icon.ImageColor3  = Color3.fromRGB(255,255,134)
			script.Parent.Parent.Parent.HUDRight.Gift.Hover.Title.TextColor3 = Color3.fromRGB(255,255,134)
		elseif Player:FindFirstChild("MVP") then
			script.Parent.Parent.Parent.HUDRight.Gift.Icon.ImageColor3  = Color3.fromRGB(255,134,134)
			script.Parent.Parent.Parent.HUDRight.Gift.Hover.Title.TextColor3 = Color3.fromRGB(255,134,134)
		elseif Player:FindFirstChild("VIP") then
			script.Parent.Parent.Parent.HUDRight.Gift.Icon.ImageColor3  = Color3.fromRGB(0,134,255)
			script.Parent.Parent.Parent.HUDRight.Gift.Hover.Title.TextColor3 = Color3.fromRGB(0,134,255)
		else
			script.Parent.Parent.Parent.HUDRight.Gift.Icon.ImageColor3  = Color3.fromRGB(255,134,255)
			script.Parent.Parent.Parent.HUDRight.Gift.Hover.Title.TextColor3 = Color3.fromRGB(255,134,255)
		end
	end
	Update()
	Player.GiftStatus.Changed:Connect(Update)
	
	local function Open(Money,ItemId,Amount,Angelite,ExtraRewards)
		script.Parent.Parent.Position = UDim2.new(0.5,0,1,0)
		script.Parent.Parent.Visible = true
		Modules.Menu.CloseMenu()
		if Modules.Input.Mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = false
			game.GuiService.SelectedObject = nil
		end
		
		if Player:FindFirstChild("SecondGift") then
			script.Parent.Title.TextColor3 = Color3.fromRGB(0,255,134)
			script.Parent.Title.Text = "Extra Gift"
			script.Parent.Buttons.Extra.Visible = false
		elseif Player:FindFirstChild("Premium") then
			script.Parent.Title.TextColor3 = Color3.fromRGB(255,255,134)
			script.Parent.Title.Text = "Premium Gift"
		elseif Player:FindFirstChild("MVP") then
			script.Parent.Title.TextColor3 = Color3.fromRGB(255,134,134)
			script.Parent.Title.Text = "M.V.P. Gift"
		elseif Player:FindFirstChild("VIP") then
			script.Parent.Title.TextColor3 = Color3.fromRGB(0,134,255)
			script.Parent.Title.Text = "V.I.P. Gift"
		else
			script.Parent.Title.TextColor3 = Color3.fromRGB(255,134,255)
			script.Parent.Title.Text = "Daily Gift"
		end
		
		Clear()
		
		local RealItem = GetItemById(ItemId)
		
		if RealItem and Amount > 0 then
			local Suffix = " "..RealItem.ItemName.Value
			if Amount > 1 then
				Suffix = Suffix.."s"
			end
			local TierColor = Color3.new(0.7,0.7,0.7)
			local Tier = Modules.Tiers[RealItem.Tier.Value]
			if Tier then
				TierColor = Tier.Color1
			end
			AddItem(tostring(Amount)..Suffix,RealItem.Image.Value,TierColor)
		end
		
		if Angelite and Angelite > 0 then
			AddItem("&"..Modules.MoneyLib.VTS(Angelite),"rbxassetid://4994457097",Color3.fromRGB(255,34,134))
		end
		
		if Money and Money > 0 then
			AddItem(Modules.MoneyLib.VTS(Money,true),"rbxassetid://4999088908",Color3.fromRGB(0,255,34))
		end
		
		if ExtraRewards then
			for _,v in pairs(ExtraRewards) do
				AddItem(v.Name,v.Image,v.Color)
			end
		end
		
		if true then
			script.Parent.Streak.Visible = true
			if Player.LoginStreak.Value <= 1 then
				script.Parent.Streak.Text = "Thanks for playing! Login tomorrow for a better gift!"
				script.Parent.Streak.TextColor3 = Color3.fromRGB(255,253,193)
			else
				local Streak = Player.LoginStreak.Value
				script.Parent.Streak.Text = "You've opened your daily gift "..tostring(Streak).." days in a row. Each day upgrades your gift."
				local Col = Color3.fromRGB(255,253,193)
				if Streak >= 100 then
					Col = Color3.fromRGB(255,0,230)
				elseif Streak >= 75 then
					Col = Color3.fromRGB(0,255,106)
				elseif Streak >= 50 then
					Col = Color3.fromRGB(116,244,255)
				elseif Streak >= 25 then
					Col = Color3.fromRGB(174,180,255)
				elseif Streak >= 10 then
					Col = Color3.fromRGB(206,255,188)
				elseif Streak >= 5 then
					Col = Color3.fromRGB(255,253,193)
				end
				script.Parent.Streak.TextColor3 = Col
			end
		end
		
		Modules.Menu.Sounds.OpenedGift:Play()
		script.Parent.Parent:TweenPosition(UDim2.new(0.5,0,0.5,0),nil,nil,0.5,true)
		wait(0.5)
		
		if script.Parent.Parent.Visible and Modules.Input.Mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = true
			game.GuiService.SelectedObject = script.Parent.Buttons.Close
		end
	end
	
	game.ReplicatedStorage.GiftInfo.OnClientEvent:Connect(Open)
end

return module