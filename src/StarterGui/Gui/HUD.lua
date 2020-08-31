local module = {}

local Player = game.Players.LocalPlayer

function module.init(Modules)
	function module.ShowHUD()
		script.Parent.HUDRight:TweenPosition(UDim2.new(1,0,0,0),nil,nil,nil,true)
		script.Parent.HUDBottom:TweenPosition(UDim2.new(0,0,1,0),nil,nil,nil,true)
		if Player.ActiveTycoon.Value then
			script.Parent.HUDAway:TweenPosition(UDim2.new(-1,0,0,0),nil,nil,nil,true)
			script.Parent.HUDLeft:TweenPosition(UDim2.new(0,0,0,0),nil,nil,nil,true)
			script.Parent.HUDTop:TweenPosition(UDim2.new(0,0,0,0),nil,nil,nil,true)
		end
	end
	
	function module.HideHUD(Override)
		Override = Override or false
		
		script.Parent.HUDLeft:TweenPosition(UDim2.new(-1,0,0,0),nil,nil,nil,true)
		script.Parent.HUDBottom:TweenPosition(UDim2.new(0,0,2,0),nil,nil,nil,true)
		if Override then
			script.Parent.HUDRight:TweenPosition(UDim2.new(2,0,0,0),nil,nil,nil,true)
			script.Parent.HUDTop:TweenPosition(UDim2.new(0,0,-1,0),nil,nil,nil,true)
		end
	end
	
	function module.CloseAll(Override)
		Override = Override or false
		if Modules.Input.Mode.Value == "Xbox" then
			game.GuiService.GuiNavigationEnabled = false
			game.GuiService.SelectedObject = nil
		end
		Modules.Menu.CloseMenu()
		module.HideHUD(Override)
		Modules.Placement.CancelPlacement()
		Modules.Preview.Collapse()
		Modules.ItemInfo.Hide()
		Modules.MOTD.Close()
		Modules.Salesmen.Close()
	end
	
	function module.LeaveBase()
		module.CloseAll(true)
		script.Parent.HUDAway:TweenPosition(UDim2.new(0,0,0,0),nil,nil,nil,true)
	end
	
	Player.ActiveTycoon.Changed:Connect(function()
		if Player.ActiveTycoon.Value == nil then
			module.LeaveBase()
		else
			if Player:FindFirstChild("Evolving") == nil then
				module.ShowHUD()
			end
		end
	end)
	
	Player.ChildAdded:Connect(function(Child)
		if Child.Name == "Evolving" then
			module.LeaveBase()
		end
	end)
	
	Player.ChildRemoved:Connect(function(Child)
		if Child.Name == "Evolving" then
			wait(5)
			if Player.ActiveTycoon.Value ~= nil then
				module.ShowHUD()
			end
		end
	end)
	
	local Money = script.Parent.Money
	local function UpdateMoney()
		script.Parent.HUDTop.Money.Value.Text = Modules.MoneyLib.VTS(Money.Value,true)
		script.Parent.HUDAway.Currency.Money.Value.Text = Modules.MoneyLib.VTS(Money.Value,true)
	end
	UpdateMoney()
	Money.Changed:Connect(UpdateMoney)
	
	local Expanded = true
	local function Collapse()
		if Expanded then
			Expanded = false
			Modules.Tween(script.Parent.HUDTop.Money.Change,{"TextTransparency"},1,0.5)
			Modules.Tween(script.Parent.HUDTop.Money.Value,{"Size"},UDim2.new(1,0,1,0),0.5)
		end
	end
	local function Expand()
		if not Expanded then
			Expanded = true
			Modules.Tween(script.Parent.HUDTop.Money.Change,{"TextTransparency"},0,0.5)
			Modules.Tween(script.Parent.HUDTop.Money.Value,{"Size"},UDim2.new(0.7,0,1,0),0.5)
		end
	end
	
	Collapse()
	
	local Change = script.Parent.Change
	Change.Changed:Connect(function()
		script.Parent.HUDTop.Money.Change.Text = "+"..Modules.MoneyLib.VTS(Change.Value).."/s"
		if Change.Value > 0.1 then
			Expand()
		else
			Collapse()
		end
	end)
	
	local Shards = script.Parent.Shards
	local function UpdateShards()
		local Suffix = (Shards.Value == 1 and " Shard") or " Shards"
		script.Parent.HUDAway.Currency.Shards.Value.Text = Modules.MoneyLib.VTS(Shards.Value)..Suffix
		script.Parent.HUDAway.Currency.Shards.Visible = (Shards.Value >= 1)
	end
	UpdateShards()
	Shards.Changed:Connect(UpdateShards)
	
	local Angelite = script.Parent.Angelite
	local function UpdateAngelite()
		script.Parent.HUDAway.Currency.Angelite.Value.Text = "&"..Modules.MoneyLib.VTS(Angelite.Value)
	end
	UpdateAngelite()
	Angelite.Changed:Connect(UpdateAngelite)
	
	local Research = script.Parent.Research
	local function UpdateResearch()
		script.Parent.HUDAway.Currency.Research.Value.Text = "R"..Modules.MoneyLib.VTS(Research.Value)
	end
	UpdateResearch()
	Research.Changed:Connect(UpdateResearch)
end

return module