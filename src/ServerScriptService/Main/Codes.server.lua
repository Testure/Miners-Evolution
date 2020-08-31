local function Money(Player,Amount)
	Player.Money.Value = Player.Money.Value + Amount
	local StringAmount = require(game.ReplicatedStorage.MoneyLib).VTS(Amount,true)
	game.ReplicatedStorage.TextNotify:FireClient(Player,"You got "..StringAmount.."!",Color3.new(1,1,1),Color3.new(0,0.5,0))
end

local function Item(Player,Id,Amount)
	game.ServerStorage.AwardItem:Invoke(Player,Id,Amount)
end

local function Box(Player,BoxType,Amount)
	game.ServerStorage.AwardBox:Invoke(Player,BoxType,Amount)
end

local function Angelite(Player,Amount)
	Player.Values.Angelite.Value = Player.Values.Angelite.Value + Amount
	game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"&"..require(game.ReplicatedStorage.MoneyLib).VTS(Amount),Color3.fromRGB(180,128,255),"rbxassetid://4994457097")
end

local Codes = {
	{"Nice",Money,69420},
	{"Elevated",Item,108,5}
}

local function DoCode(Player,Data)
	local Args = {}
	for i = 2,#Data do
		table.insert(Args,i - 1,Data[i])
	end
	Data[1](Player,unpack(Args))
end

function game.ReplicatedStorage.TryCode.OnServerInvoke(Player,Code)
	if Player:FindFirstChild("BaseDataLoaded") == nil then
		return false
	end
	if _G["Codes"][Player.Name][Code] then
		return 1
	end
	local CodeData
	for _,v in pairs(Codes) do
		if v[1] == Code then
			CodeData = v
			break
		end
	end
	if CodeData then
		_G["Codes"][Player.Name][Code] = true
		local Args = CodeData
		table.remove(Args,1)
		DoCode(Player,Args)
	end
	return 2
end