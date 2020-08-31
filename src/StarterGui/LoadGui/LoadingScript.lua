local Module = {}
function Module.init()
local Player = game.Players.LocalPlayer
script.Parent.Enabled = true
local Modules = {}
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)
spawn(function()
	local Success,Error = pcall(function()
		game.ContentProvider:PreloadAsync(script.Parent:GetDescendants())
	end)
	if not Success then
		warn(Error)
	end
end)

function Tween(Object, Properties, Value, Time)
	Time = Time or 0.5

	local propertyGoals = {}
	
	local Table = (type(Value) == "table" and true) or false
	
	for i,Property in pairs(Properties) do
		propertyGoals[Property] = Table and Value[i] or Value
	end
	local tweenInfo = TweenInfo.new(
		Time,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	local tween = game:GetService("TweenService"):Create(Object,tweenInfo,propertyGoals)
	tween:Play()
end
Modules.Tween = Tween

local tycoon = Player.PlayerTycoon.Value
if tycoon ~= nil then
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	local CF = CFrame.new(tycoon.Base.Position) * CFrame.Angles(0,math.rad(70),0) * CFrame.new(0,0,230)
	workspace.CurrentCamera.CFrame = CFrame.new(CF.p + Vector3.new(0,35,0),tycoon.Base.Position + Vector3.new(0,10,0))
end

math.randomseed(os.time())
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
script.Parent.Top.Position = UDim2.new(0,0,-1,0)
script.Parent.Bottom.Position = UDim2.new(0,0,1,0)
script.Parent.Bottom.Slots.Position = UDim2.new(.5,0,1.5,0)
require(Player.PlayerScripts.Ambiance).init(Modules)
if workspace:FindFirstChild("Testing") then
	script.Parent.Top.Title.Testing.Visible = true
end

script.Music:Play()

game.Lighting.Blur.Enabled = true

if workspace:FindFirstChild("Private") then
	script.Parent.Bottom.Solo.Visible = false
	script.Parent.Bottom.Enter.Position = UDim2.new(0.5,0,0.62,0)
end

local Tips = {
	"The salesmen will appear on weekends to sell his goods. You just have to find him.",
	"When you reach $25Qn, You can Evolve into your next Evolution with a powerful Evolution-tier item.",
	"Many upgraders have limits on how they can be used. an upgrader may flash red if it's not used correctly.",
	"Play with your friends! You can add people to your base and edit their permissions in the settings tab.",
	"Other players bugging you? Try Play solo, where you get sent to your own private island.",
	"Crates will drop arround the map, Collect them to earn research and maybe even a mystery box!",
}

if game:GetService("UserInputService").MouseEnabled and game:GetService("UserInputService").KeyboardEnabled then
	table.insert(Tips,"Right-click items in your inventory to favorite them. Favorited items always appear at the top.")
	table.insert(Tips,"You can click and drag your mouse while placing an item to quickly place an item multiple times.")
	table.insert(Tips,"Click and hold to quickly select multiple items on your base.")
	table.insert(Tips,"All menu pages have a hotkey that quickly toggles them. [E] toggles the inventory and [F] toggles the shop.")
end

local Tip = Tips[math.random(1,#Tips)]
script.Parent.Tip.Text = Tip

local DataDB = false

local function SlotButton(Button)
	local Slot = tonumber(Button.Name)
	if Slot and not DataDB then
		DataDB = true
		script.Click:Play()
		if not Button.Loaded.Value then
			Button.Button.Text = "Loading..."
			local Success,Data = game.ReplicatedStorage.PreLoadData:InvokeServer(Slot)
			if Success then
				Button.Button.Text = "[ Play ]"
				local Col = Color3.fromRGB(0,255,134)
				Button.Button.BackgroundColor3 = Col
				Button.Loaded.Value = true
				Button.Cash.Visible = true
				if Data and Data["Money"] then
					Button.Cash.Text = MoneyLib.VTS(tonumber(Data.Money))
					if Data["Evolution"] and Data["TrueEvolution"] then
						Button.Evo.Visible = true
						Button.Evo.Text = MoneyLib.HandleEvo(Data.Evolution,Data.TrueEvolution)
					end
				else
					Button.Cash.Text = "New Game"
					local Col = Color3.fromRGB(0,84,255)
					Button.Cash.TextColor3 = Col
				end
			else
				Button.Button.Text = "Failed!"
				local Col = Color3.fromRGB(255,114,114)
				Button.Button.BackgroundColor3 = Col
				wait(3)
				Button.Button.Text = "[ Load ]"
				local Col = Color3.fromRGB(225,225,225)
				Button.Button.BackgroundColor3 = Col
			end
			DataDB = false
		else
			Button.Button.Text = "Loading..."
			local _,Success = game.ReplicatedStorage.LoadData:InvokeServer(Slot)
			if not Success then
				Button.Button.Text = "Failed!"
				wait(1)
				Button.Button.Text = "[ Play ]"
				DataDB = false
			end
			Button.Button.Text = "Success!"
		end
	end
end

local DB = false
local Done = false

script.Parent.Bottom.Solo.MouseButton1Click:Connect(function()
	if DB then
		return
	end
	DB = true
	script.Click:Play()
	local Success = game.ReplicatedStorage.PlaySolo:InvokeServer()
	if Success then
		script.Parent.Bottom.Status.Visible = true
		script.Parent.Bottom.Status.Text = "Teleporting to your private island!"
		script.Parent.Bottom.Status.TextColor3 = Color3.new(1,1,1)
	else
		script.Parent.Bottom.Status.Visible = true
		script.Parent.Bottom.Status.Text = "Teleport failed!"
		script.Parent.Bottom.Status.TextColor3 = Color3.new(1,0,0)
		wait(1)
		script.Parent.Bottom.Status.Visible = false
	end
	DB = false
end)

script.Parent.Bottom.Enter.MouseButton1Click:Connect(function()
	if DB then
		return
	end
	DB = true
	script.Click:Play()
	spawn(function()
		Tween(game.Lighting.Blur,{"Size"},30,0.4)
		wait(0.3)
		local Tycoon = Player.PlayerTycoon.Value
		if not Tycoon then
			Done = true
		end
	
		Tween(game.Lighting.Blur,{"Size"},5,0.4)
	
		local Camera = workspace.CurrentCamera
		local Angle = math.rad(70)
		local Velo = 0.05
	
		workspace.CurrentCamera.FieldOfView = 40
	
		while not Done do
			local CF = CFrame.new(Tycoon.Base.Position) * CFrame.Angles(0,Angle,0) * CFrame.new(0,0,230)
			Angle = Angle + math.rad(Velo)
			workspace.CurrentCamera.CFrame = CFrame.new(CF.p + Vector3.new(0,35,0),Tycoon.Base.Position + Vector3.new(0,10,0))
			game:GetService("RunService").RenderStepped:Wait()
		end
		wait(0.3)
	end)
	script.Parent.Bottom.Enter.Visible = false
	script.Parent.Bottom.Solo.Visible = false
	script.Parent.Bottom.Slots.Visible = true
	script.Parent.Tip.Visible = true
	script.Parent.Bottom.Slots:TweenPosition(UDim2.new(0.5,0,0.62,0),nil,nil,0.5,true)
	if game:GetService("UserInputService").GamepadEnabled then
		game.GuiService.GuiNavigationEnabled = true
		game.GuiService.SelectedObject = script.Parent.Bottom.Slots.Slots["1"].Button.Button
	end
	DB = false
end)

for _,v in pairs(script.Parent.Bottom.Slots.Slots:GetChildren()) do
	if v:IsA("Frame") then
		v.Button.MouseButton1Click:Connect(function()
			SlotButton(v)
		end)
	end
end

local function Close()
	Tween(game.Lighting.Blur,{"Size"},0,0.2)
	Tween(script.Parent.Tunnel,{"ImageTransparency"},1,0.2)
	wait(0.2)
	game.Lighting.Blur.Enabled = false
	local Gui = game.ReplicatedStorage:WaitForChild("Gui")
	Gui:Clone().Parent = Player.PlayerGui
	script.Parent.Cover.Visible = true
	wait()
	script.Parent:Destroy()
	workspace.CurrentCamera.FieldOfView = 70
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true)
end
game.ReplicatedStorage.DataLoaded.OnClientEvent:Connect(Close)

wait(2)
script.Parent.Top:TweenPosition(UDim2.new(0,0,0,0),"Out","Bounce",2,true)
script.Parent.Bottom:TweenPosition(UDim2.new(0,0,0,0),"Out","Bounce",2,true)
wait(2)
if game:GetService("UserInputService").GamepadEnabled then
	game.GuiService.GuiNavigationEnabled = true
	game.GuiService.SelectedObject = script.Parent.Bottom.Enter.Button
	script.Parent.Bottom.Xbox.Visible = true
end
end
return Module