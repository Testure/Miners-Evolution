local module = {}

local Player = game.Players.LocalPlayer

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
end

function module.init(Modules)
	function module.Hide(Button)
		if script.Parent.Button.Value == Button or Button == nil then
			script.Parent.Button.Value = nil
		end
	end
	
	function module.Show(Button)
		script.Parent.Button.Value = Button
		script.Parent.Position = UDim2.new(0,math.floor(Button.AbsolutePosition.X) + 100,0,math.ceil(Button.AbsolutePosition.Y))
	end
	
	script.Parent.Button.Changed:Connect(function()
		local Button = script.Parent.Button.Value
		if Button then
			if Button:IsDescendantOf(script.Parent.Parent.Menu.Contents.Pages.Inventory) and Button:FindFirstChild("Favorite") then
				script.Parent.Prompt.Contents.Visible = true
				if Button.Favorite.Visible then
					script.Parent.Prompt.Contents.Title.Text = "Unfavorite Item"
				else
					script.Parent.Prompt.Contents.Title.Text = "Favorite Item"
				end
			else
				script.Parent.Prompt.Contents.Visible = false
				script.Parent.Inner.Subtitles.Visible = false
			end
			
			script.Parent.BackgroundColor3 = Button.BackgroundColor3
			script.Parent.Inner.BackgroundColor3 = Button.Icon.BackgroundColor3
			script.Parent.Inner.Desc.TextColor3 = Color3.fromRGB(197,197,197)
			script.Parent.Inner.Desc.TextStrokeColor3 = Color3.fromRGB(42,42,42)
			script.Parent.Inner.Tier.TextStrokeColor3 = Color3.new(0,0,0)
			
			local Color = Color3.new(1,1,1)
			local BGColor = Color3.new(0,0,0)
			
			if Button:FindFirstChild("Box") then
				local RealItem = game.ReplicatedStorage.Boxes:FindFirstChild(Button.Box.Value)
				if RealItem then
					script.Parent.Inner.Tier.Visible = true
					local Count = 0
					if Player.Boxes:FindFirstChild(Button.Box.Value) then
						Count = Player.Boxes[Button.Box.Value].Value
					else
						script.Parent.Inner.Tier.Visible = false
					end
					script.Parent.Inner.Tier.Text = "You own "..tostring(Count).."."
					script.Parent.Inner.Tier.TextColor3 = Color3.new(1,1,1)
					script.Parent.Inner.Title.Text = Button.Box.Value.." Box"
					script.Parent.Inner.Desc.Text = RealItem.Desc.Value
					script.Parent.Visible = true
				else
					module.Hide()
				end
			elseif Button:FindFirstChild("Id") then
				local RealItem = GetItemById(Button.Id.Value)
				if RealItem then
					script.Parent.Inner.Desc.Text = RealItem.Desc.Value
					script.Parent.Inner.Title.Text = RealItem.ItemName.Value
					script.Parent.BackgroundColor3 = Button.BackgroundColor3
					local Tier = Modules.Tiers[RealItem.Tier.Value]
					
					if Tier then
						script.Parent.Inner.Tier.Visible = true
						script.Parent.Inner.Tier.Text = Tier.Name
						script.Parent.Inner.Desc.TextColor3 = Color3.fromRGB(25,25,25)
						script.Parent.Inner.Desc.TextStrokeColor3 = Tier.Color1
						script.Parent.Inner.Tier.TextStrokeColor3 = Tier.Color1
					else
						script.Parent.Inner.Tier.Visible = false
					end
					
					if RealItem:FindFirstChild("Soulbound") then
						script.Parent.Inner.Subtitles.Soulbound.Visible = true
					else
						script.Parent.Inner.Subtitles.Soulbound.Visible = false
					end
					if RealItem.Tier.Value >= 8 and RealItem:FindFirstChild("Destroy") == nil then
						script.Parent.Inner.Subtitles.EvoProof.Visible = true
					else
						script.Parent.Inner.Subtitles.EvoProof.Visible = false
					end
					if RealItem:FindFirstChild("EvoReq") then
						script.Parent.Inner.Subtitles.EvoReq.Visible = true
						script.Parent.Inner.Subtitles.EvoReq.Text = "Evolution "..Modules.MoneyLib.VTS(RealItem.EvoReq.Value).."+"
					else
						script.Parent.Inner.Subtitles.EvoReq.Visible = false
					end
					if RealItem:FindFirstChild("Rarity") then
						script.Parent.Inner.Subtitles.Rarity.Visible = true
						script.Parent.Inner.Subtitles.Rarity.Text = "Rarity "..tostring(RealItem.Rarity.Value)
					else
						script.Parent.Inner.Subtitles.Rarity.Visible = false
					end
					
					script.Parent.Visible = true
				else
					module.Hide()
				end
			end
		else
			script.Parent.Visible = false
		end
	end)
end

return module