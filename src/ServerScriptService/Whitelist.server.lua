local Mode = "Closed"
local IsTesting = (game.GameId == 4759149031)
local Whitelist = {"Testure6","Maxis_s"}
local Blacklist = {}

if IsTesting then
	Instance.new("BoolValue",workspace).Name = "Testing"
end

local function Find(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return v
		end
	end
end

local function CheckList(Player)
	if not IsTesting then
		return true
	end
	if Player:FindFirstChild("CheckDone") == nil then
		repeat wait() until Player:FindFirstChild("CheckDone") ~= nil
	end
	if Find(Whitelist,Player.Name) then
		return true
	end
	if Player:FindFirstChild("Tester") then
		return true
	end
	if Mode == "Submitters" then
		if Player:FindFirstChild("Submitter") then
			return true
		end
	elseif Mode == "M.V.P. Members" then
		if Player:FindFirstChild("MVP") then
			return true
		end
	elseif Mode == "Open" then
		return true
	end
	return false
end

game.Players.PlayerAdded:Connect(function(Player)
	if Find(Blacklist,Player.Name) then
		Player:Kick("You're not allowed to join this game, you have been banned from this game.")
		return
	end
	local Allowed = CheckList(Player)
	if not Allowed then
		local Message = "You're not allowed to join this game, "..(Mode == "Closed" and "testing is closed." or "testing is for "..Mode.." only.")
		Player:Kick(Message)
	end
end)