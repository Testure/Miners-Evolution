--[[
	
--]]
print("Module God 1.2 by Testure6")
local Modules = {}
local Player = game.Players.LocalPlayer

local Libs = {
	game.ReplicatedStorage.PlacementModule,
	game.ReplicatedStorage.LocalLib,
	game.ReplicatedStorage.MoneyLib,
	Player.PlayerScripts.Ambiance,
	game.ReplicatedStorage.Tiers,
	game.ReplicatedStorage.TycoonLib,
	workspace.Salesmen.SalesmenClick,
	game.ReplicatedStorage.Lottery
}

function init()
	local StartTime = tick()
	Modules.HasFinished = false
	function Modules.Tween(Object, Properties, Value, Time, Style, Direction)
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
	function Modules.GetTycoon(Player)
		if Player:FindFirstChild("ActiveTycoon") and Player:FindFirstChild("PlayerTycoon") then
			if Player.ActiveTycoon.Value ~= nil then
				return Player.ActiveTycoon.Value
			else
				return Player.PlayerTycoon.Value
			end
		else
			return nil
		end
	end
	print("Loading Librarys")
	for _,v in pairs(Libs) do
		local Start = tick()
		local Success,Error = pcall(function()
			Modules[v.Name] = require(v)
		end)
		if not Success then
			print("Error loading library "..v.Name.."! Library failed to load")
			warn(Error)
		else
			print("Library "..v.Name.." loaded! ("..tick()-Start.."s)")
		end
	end
	print("Librarys loaded! ("..tick()-StartTime.."s)")
	print("Loading Modules")
	StartTime = tick()
	for _,v in pairs(script.Parent:GetDescendants()) do
		if v:IsA("ModuleScript") then
			local Start = tick()
			local Success,Error = pcall(function()
				Modules[v.Name] = require(v)
			end)
			if not Success then
				print("Error loading module "..v.Name.."! Module failed to load")
				warn(Error)
			else
				print("Module "..v.Name.." loaded! ("..tick()-Start.."s)")
			end
		end
	end
	print("Modules loaded! ("..tick()-StartTime.."s)")
	print("Initalizing modules")
	StartTime = tick()
	for i,v in pairs(Modules) do
		local Start = tick()
		if type(v) == "table" and v["init"] then
			local Success,Error = pcall(v.init,Modules)
			if Success then
				print("Module "..i.." initalized! ("..tick()-Start.."s)")
			else
				print("Error initalizing "..i.."!")
				warn(Error)
			end
		end
	end
	print("Modules initalized!")
	Modules.HasFinished = true
	print("Done! ("..tick()-StartTime.."s)")
	
	print("------------------------------------------------------------")
	print("If you see any errors BELOW this point, Please report them to the dev.")
	print("------------------------------------------------------------")
	Modules.Preload.Thing()
end

init()