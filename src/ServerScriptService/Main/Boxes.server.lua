local Lottery = require(game.ReplicatedStorage.Lottery)
local Tiers = require(game.ReplicatedStorage.Tiers)
math.randomseed(os.time())

function game.ReplicatedStorage.BuyBox.OnServerInvoke(Player,Type)
	if Type == "Megaphone" then
		if Player.Values.Angelite.Value >= 80 then
			Player.Values.Angelite.Value = Player.Values.Angelite.Value - 80
			Player.Values.Megaphones.Value = Player.Values.Megaphones.Value + 1
			return true
		end
		return false
	end
	local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Type)
	if Real then
		if Real:FindFirstChild("Cost") then
			if Player.Values.Angelite.Value >= Real.Cost.Value then
				local Val = Player.Boxes:FindFirstChild(Type)
				if Val then
					Player.Values.Angelite.Value = Player.Values.Angelite.Value - Real.Cost.Value
					Val.Value = Val.Value + 1
					return true
				end
			end
		end
	end
	return false
end

function game.ReplicatedStorage.OpenBox.OnServerInvoke(Player,Type)
	local Real = game.ReplicatedStorage.Boxes:FindFirstChild(Type)
	if Real then
		local Val = Player.Boxes:FindFirstChild(Type)
		if Player:FindFirstChild("OpeningBox") then
			return false
		end
		if Val and Val.Value > 0 then
			Val.Value = Val.Value - 1
		else
			return false
		end
		
		local Tag = Instance.new("BoolValue")
		Tag.Parent = Player
		Tag.Name = "OpeningBox"
		
		local PrizeInfo = Lottery.Run(Player,Type,false)
		local Prize = PrizeInfo[1]
		spawn(function()
			wait(7)
			local Color = Tiers[Prize.Tier.Value].Color1
			local Prefix = ""
			if PrizeInfo[5] < 9 then
				if PrizeInfo[5] > 7 then
					Prefix = "Cool! "
				elseif PrizeInfo[5] > 5 then
					Prefix = "Wow! "
				elseif PrizeInfo[5] > 3 then
					Prefix = "Woah!! "
				elseif Prize.Tier.Value == 14 then
					Prefix = "OMG!!! "
				elseif Prize.Tier.Value == 15 then
					Prefix = "AAHHHH!!!! "
					local Data = {Prefix..Player.Name.." won a mint "..Prize.ItemName.Value.."!!",Color.r,Color.g,Color.b}
					game.ServerStorage.SendMessage:Fire("SystemChat",Data)
				end
			end
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Prefix..Player.Name.." won a "..Prize.ItemName.Value.."!",Color)
			game.ServerStorage.AwardItem:Invoke(Player,Prize.ItemId.Value,1)
			Tag:Destroy()
		end)
		game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." opened a "..Type.." Box!",Color3.new(1,1,1))
		return PrizeInfo
	end
	return false
end