local module = {}

local Player = game.Players.LocalPlayer
module.CurrentPage = script.Parent.CurrentPage
module.Open = script.Parent.MenuOpen
module.Sounds = script.Sounds
local Pages = {"Inventory","Shop","Settings","Premium","Boxes","Evolution"}

function module.init(Modules)
	local function Resize()
		if Modules.Input.Mode.Value == "Mobile" then
			script.Parent.Size = UDim2.new(1,0,1,0)
		else
			script.Parent.Size = UDim2.new(0.3,50,1,0)
		end
	end
	Resize()
	Modules.Input.Mode.Changed:Connect(Resize)
	
	local function GetCurrentPage()
		return script.Parent.Contents.Pages:FindFirstChild(module.CurrentPage.Value)
	end
	
	local function GetPagePos(PageName)
		for i,v in pairs(Pages) do
			if v == PageName then
				return i
			end
		end
		return 1
	end
	
	function module.OpenMenu(PageName,SkipAnim)
		local Tycoon = Player.ActiveTycoon.Value
		SkipAnim = SkipAnim or false
		if Tycoon then
			local Page = script.Parent.Contents.Pages:FindFirstChild(PageName)
			if script.Parent.Position ~= UDim2.new(0,0,0,0) then
				script.Parent:TweenPosition(UDim2.new(0,0,0,0),nil,nil,0.25,true)
			end
			script.Parent.Parent.HUDTop:TweenPosition(UDim2.new(0,0,-1,0),nil,nil,nil,true)
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false)
			if Modules.Input.Mode.Value ~= "PC" then
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
				Modules.Placement.CancelPlacement()
				Modules.Preview.Collapse()
			end
			local Before = module.Open.Value
			module.Open.Value = true
			Modules.ItemInfo.Hide()
			if not Before or GetCurrentPage() ~= Page then
				script.Sounds.Slide:Play()
			end
			if PageName == "Evolution" then
				script.Parent.Bottom.Shards.Visible = true
				script.Parent.Bottom.Research.Visible = false
			else
				script.Parent.Bottom.Shards.Visible = false
				script.Parent.Bottom.Research.Visible = true
			end
			if Page then
				if GetCurrentPage() ~= Page then
					local CurPageButton = script.Parent.Contents.NavBar:FindFirstChild(module.CurrentPage.Value)
					local PageButton = script.Parent.Contents.NavBar:FindFirstChild(PageName)
					if CurPageButton and PageButton then
						local CurPage = GetCurrentPage()
						CurPageButton.ZIndex = 6
						PageButton.ZIndex = 8
						local cX,cY = CurPageButton.Position.X,CurPageButton.Position.Y
						local X,Y = PageButton.Position.X,PageButton.Position.Y
						CurPageButton:TweenPosition(UDim2.new(cX.Scale,cX.Offset,cY.Scale,-15),nil,nil,0.1,true)
						PageButton:TweenPosition(UDim2.new(X.Scale,X.Offset,Y.Scale,-10),nil,nil,0.1,true)
						local Col = PageButton.Color.Value
						local ShadowCol = Color3.new(Col.R - 60/255,Col.G - 60/255,Col.B - 60/255)
						Modules.Tween(script.Parent.Contents.Title,{"BackgroundColor3"},Col,0.5)
						Modules.Tween(script.Parent.Contents.Title.Shadow,{"BackgroundColor3"},ShadowCol,0.5)
						Modules.Tween(script.Parent.Background,{"ImageColor3"},Col,0.5)
						script.Parent.Contents.Title.Title.Text = PageName
						PageButton.AutoButtonColor = false
						CurPageButton.AutoButtonColor = true
						local Diff = PageButton.AbsolutePosition.X - CurPageButton.AbsolutePosition.X
						local CurEndPos = UDim2.new(-1,0,0,0)
						local StartPos = UDim2.new(1,0,0,0)
						if Diff < 0 then
							CurEndPos = UDim2.new(1,0,0,0)
							StartPos = UDim2.new(-1,0,0,0)
						end
						module.CurrentPage.Value = PageName
						CurPage.Position = StartPos
						if Modules.Input.Mode.Value == "Xbox" then
							game.GuiService.GuiNavigationEnabled = true
							game.GuiService.SelectedObject = Page.SelectedObject.Value
						end
						Page.Visible = true
						if Modules[PageName] and Modules[PageName]["OnOpen"] then
							Modules[PageName].OnOpen()
						end
						if SkipAnim then
							Page.Position = UDim2.new(0,0,0,0)
							CurPage.Position = CurEndPos
						else
							Page:TweenPosition(UDim2.new(0,0,0,0),nil,nil,0.5,true)
							CurPage:TweenPosition(CurEndPos,nil,nil,0.5,true)
							wait(0.5)
						end
						CurPage.Visible = false
						return true
					end
				end
			end
		end
		return false
	end
	
	function module.ChangePageRight()
		if not module.Open.Value then
			return
		end
		local CurPage = GetCurrentPage()
		local PageName
		--Loop around
		if CurPage.Name == Pages[#Pages] then
			PageName = Pages[1]
		else
			PageName = Pages[GetPagePos(CurPage.Name) + 1]
		end
		if PageName then
			module.OpenMenu(PageName)
		end
	end
	
	function module.ChangePageLeft()
		if not module.Open.Value then
			return
		end
		local CurPage = GetCurrentPage()
		local PageName
		--Loop around
		if CurPage.Name == Pages[1] then
			PageName = Pages[#Pages]
		else
			PageName = Pages[GetPagePos(CurPage.Name) - 1]
		end
		if PageName then
			module.OpenMenu(PageName)
		end
	end
	
	function module.CloseMenu(SkipAnim)
		SkipAnim = SkipAnim or false
		local Before = module.Open.Value
		module.Open.Value = false
		if Modules.Input.Mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = false
			game.GuiService.SelectedObject = nil
		end
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
		if Modules.Placement.Placing and Modules.Input.Mode.Value == "PC" then
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
		end
		if SkipAnim then
			script.Parent.Position = UDim2.new(-1,0,0,0)
			--Don't play the sound as it only fits with the animation
		else
			script.Parent:TweenPosition(UDim2.new(-1,0,0,0),nil,nil,0.5,true)
			if Before then
				script.Sounds.Slide:Play()
			end
		end
		Modules.HUD.ShowHUD()
	end
	
	script.Parent.Visible = true
	script.Parent.Position = UDim2.new(-1,0,0,0)
	
	for _,v in pairs(script.Parent.Contents.NavBar:GetChildren()) do
		if v:IsA("TextButton") and script.Parent.Contents.Pages:FindFirstChild(v.Name) then
			v.MouseButton1Click:Connect(function()
				module.OpenMenu(v.Name)
			end)
		end
	end
	
	local Money = script.Parent.Parent.Money
	local Angelite = script.Parent.Parent.Angelite
	local Research = script.Parent.Parent.Research
	local Shards = script.Parent.Parent.Shards
	
	local function UpdateCash()
		Modules.LocalLib.ChangeText(script.Parent.Bottom.Cash,Modules.MoneyLib.VTS(Money.Value,true))
	end
	UpdateCash()
	Money.Changed:Connect(UpdateCash)
	
	local function UpdateAngel()
		Modules.LocalLib.ChangeText(script.Parent.Bottom.Angel,"&"..Modules.MoneyLib.VTS(Angelite.Value))
	end
	UpdateAngel()
	Angelite.Changed:Connect(UpdateAngel)
	
	local function UpdateResearch()
		Modules.LocalLib.ChangeText(script.Parent.Bottom.Research,"R"..Modules.MoneyLib.VTS(Research.Value))
	end
	UpdateResearch()
	Research.Changed:Connect(UpdateResearch)
	
	local function UpdateShards()
		local Suffix = (Shards.Value == 1 and " Shard") or " Shards"
		Modules.LocalLib.ChangeText(script.Parent.Bottom.Shards,Modules.MoneyLib.VTS(Shards.Value)..Suffix)
	end
	UpdateShards()
	Shards.Changed:Connect(UpdateShards)
	
	script.Parent.Parent.HUDLeft.MenuButton.MouseButton1Click:Connect(function()
		module.OpenMenu(module.CurrentPage.Value)
	end)
	
	script.Parent.Contents.Title.Close.MouseButton1Click:Connect(function()
		module.CloseMenu()
	end)
end

return module