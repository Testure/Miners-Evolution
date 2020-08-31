local function GetPlayerById(Id)
	for _,v in pairs(game.Players:GetPlayers()) do
		if v.UserId == Id then
			return v
		end
	end
	return nil
end

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
	return nil
end

local function GetBadgeById(Id)
	for _,v in pairs(game.ReplicatedStorage.Badges:GetChildren()) do
		if v.Value == Id then
			return v
		end
	end
	return nil
end

function game.ServerStorage.AwardBadge.OnInvoke(Player,BadgeId)
	spawn(function()
		local BadgeInfo = game.MarketplaceService:GetProductInfo(BadgeId)
		local Badge = GetBadgeById(BadgeId)
		if Player:FindFirstChild(Badge.Name) == nil then
			Badge:Clone().Parent = Player
			if not game.BadgeService:UserHasBadgeAsync(Player.UserId,BadgeId) then
				if BadgeInfo then
					game.BadgeService:AwardBadge(Player.UserId,BadgeId)
					game.ReplicatedStorage.BadgeEarned:FireClient(Player,BadgeId)
				end
			end
		end
	end)
end

game.Players.PlayerAdded:Connect(function(Player)
	for _,v in pairs(game.ReplicatedStorage.Badges:GetChildren()) do
		if Player:FindFirstChild(v.Name) == nil then
			if game.BadgeService:UserHasBadgeAsync(Player.UserId,v.Value) then
				v:Clone().Parent = Player
			end
		end
	end
end)

-- Easy list of product and gamepass ids
local VIP = 6330754
local MVP = 6330747
local Customizer = 7596006
local Radio = 9379444
local SecondGift = 869537694
local Angelite20 = 528136621
local Angelite50 = 528136761
local Angelite100 = 528136852
local Angelite200 = 874454700

local function HasItem(Player,Id)
	local InInv = _G["Inventory"][Player.Name][Id].Amount ~= nil and _G["Inventory"][Player.Name][Id].Amount >= 1
	local Tycoon = Player.PlayerTycoon.Value
	local OnBase = false
	if Tycoon then
		for _,v in pairs(Tycoon.Items:GetChildren()) do
			if v.ItemId.Value == Id then
				OnBase = true
				break
			end
		end
	end
	return (InInv or OnBase)
end

game.ServerStorage.CheckPasses.Event:Connect(function(Player,SkipWait)
	spawn(function()
		repeat wait() until Player:FindFirstChild("CheckDone")
		repeat wait() until Player:FindFirstChild("BaseDataLoaded")
		if not SkipWait then
			wait(5)
		end
		
		if Player:FindFirstChild("VIP") then
			if not HasItem(Player,81) then
				if not SkipWait then
					game.ReplicatedStorage.TextNotify:FireClient(Player,"V.I.P. perks unlocked!",Color3.fromRGB(94,156,255),nil,"TierUnlock")
				end
				game.ServerStorage.AwardItem:Invoke(Player,81,1)
			end
		end
		if Player:FindFirstChild("MVP") then
			if not HasItem(Player,26) and not HasItem(Player,27) then
				if not SkipWait then
					game.ReplicatedStorage.TextNotify:FireClient(Player,"M.V.P. perks unlocked!",Color3.fromRGB(255,114,101),nil,"TierUnlock")
				end
				game.ServerStorage.AwardItem:Invoke(Player,26,1)
				game.ServerStorage.AwardItem:Invoke(Player,27,1)
			end
		end
		if Player:FindFirstChild("Customizer") then
			if not HasItem(Player,12) then
				if not SkipWait then
					game.ReplicatedStorage.TextNotify:FireClient(Player,"Base Customizer unlocked!",Color3.fromRGB(235,235,235),nil,"TierUnlock")
				end
				game.ServerStorage.AwardItem:Invoke(Player,12,1)
			end
		end
		if Player:FindFirstChild("Radio") then
			if not HasItem(Player,100) then
				if not SkipWait then
					game.ReplicatedStorage.TextNotify:FireClient(Player,"Base Radio unlocked!",Color3.fromRGB(235,235,235),nil,"TierUnlock")
				end
				game.ServerStorage.AwardItem:Invoke(Player,100,1)
			end
		end
		if Player:FindFirstChild("Submitter") then
			if not HasItem(Player,80) then
				game.ReplicatedStorage.TextNotify:FireClient(Player,"Woah your submission was added to the game!",Color3.fromRGB(200,188,114),nil,"TierUnlock")
				game.ServerStorage.AwardItem:Invoke(Player,80,1)
			end
		end
		if Player:FindFirstChild("Orb") then
			game.ReplicatedStorage.TextNotify:FireClient(Player,"The Defensive Orb grants you resilience.")
		end
	end)
end)

game.MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player,PassId,Bought)
	if Bought then
		if PassId == VIP then
			Player:LoadCharacter()
			if Player:FindFirstChild("VIP") == nil then
				local Tag = Instance.new("BoolValue")
				Tag.Name = "VIP"
				Tag.Parent = Player
			end
			spawn(function()
				wait(1)
				game.ReplicatedStorage.TextNotify:FireClient(Player,"V.I.P. perks unlocked!",Color3.fromRGB(94,156,255),nil,"TierUnlock")
				wait()
				game.ServerStorage.CheckPasses:Fire(Player,true)
			end)
			local Data = {Player.Name.." is now a V.I.P!",94,156,255}
			game.ServerStorage.SendMessage:Fire("SystemChat",Data)
		elseif PassId == MVP then
			Player:LoadCharacter()
			if Player:FindFirstChild("MVP") == nil then
				local Tag = Instance.new("BoolValue")
				Tag.Name = "MVP"
				Tag.Parent = Player
			end
			spawn(function()
				wait(1)
				game.ReplicatedStorage.TextNotify:FireClient(Player,"M.V.P. perks unlocked!",Color3.fromRGB(255,114,101),nil,"TierUnlock")
				game.ServerStorage.CheckPasses:Fire(Player,true)
			end)
			local Data = {Player.Name.." is now an M.V.P!",255,114,101}
			game.ServerStorage.SendMessage:Fire("SystemChat",Data)
		elseif PassId == Customizer then
			if Player:FindFirstChild("Customizer") == nil then
				local Tag = Instance.new("BoolValue")
				Tag.Name = "Customizer"
				Tag.Parent = Player
			end
			game.ReplicatedStorage.TextNotify:FireClient(Player,"Base Customizer unlocked!",Color3.fromRGB(235,235,235))
			game.ServerStorage.CheckPasses:Fire(Player,true)
		elseif PassId == Radio then
			if Player:FindFirstChild("Radio") == nil then
				local Tag = Instance.new("BoolValue")
				Tag.Name = "Radio"
				Tag.Parent = Player
			end
			game.ReplicatedStorage.TextNotify:FireClient(Player,"Base Radio unlocked!",Color3.fromRGB(235,235,235))
			game.ServerStorage.CheckPasses:Fire(Player,true)
		end
	end
end)

game.Players.PlayerMembershipChanged:Connect(function(Player)
	if Player.MembershipType == Enum.MembershipType.Premium then
		if Player:FindFirstChild("Premium") == nil then
			local Tag = Instance.new("BoolValue")
			Tag.Name = "Premium"
			Tag.Parent = Player
		end
		spawn(function()
			wait(1)
			game.ReplicatedStorage.TextNotify:FireClient(Player,"Roblox Premium perks unlocked!",Color3.fromRGB(255,214,90),nil,"TierUnlock")
		end)
		local Data = {Player.Name.." is now a Roblox Premium member!",255,214,90}
		game.ServerStorage.SendMessage:Fire("SystemChat",Data)
	end
end)

game.MarketplaceService.ProcessReceipt = function(Info)
	local Player = GetPlayerById(Info.PlayerId)
	if Player then
		repeat wait() until Player == nil or Player:FindFirstChild("BaseDataLoaded") ~= nil
		if Player == nil then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		local Tycoon = Player.PlayerTycoon.Value
		local Completed = false
		if Info.ProductId == SecondGift then
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." purchased a second gift!",Color3.fromRGB(0,255,134))
			if Player:FindFirstChild("Gifted") and Player:FindFirstChild("SecondGift") == nil then
				Player.Gifted:Destroy()
				local Tag = Instance.new("BoolValue")
				Tag.Name = "SecondGift"
				Tag.Parent = Player
				if Player:FindFirstChild("GiftStatus") then
					Player.GiftStatus.Value = true
				end
				Completed = true
			end
		elseif Info.ProductId == Angelite20 then
			Player.Values.Angelite.Value = Player.Values.Angelite.Value + 20
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." bought 20 Angelite!",Color3.fromRGB(255,114,255))
			game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"&20",Color3.fromRGB(255,114,255),"rbxassetid://4994457097")
			Completed = true
		elseif Info.ProductId == Angelite50 then
			Player.Values.Angelite.Value = Player.Values.Angelite.Value + 50
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." bought 50 Angelite!",Color3.fromRGB(255,114,255))
			game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"&50",Color3.fromRGB(255,114,255),"rbxassetid://4994457097")
			Completed = true
		elseif Info.ProductId == Angelite100 then
			Player.Values.Angelite.Value = Player.Values.Angelite.Value + 100
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." bought 100 Angelite!",Color3.fromRGB(255,114,255))
			game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"&100",Color3.fromRGB(255,114,255),"rbxassetid://4994457097")
			Completed = true
		elseif Info.ProductId == Angelite200 then
			Player.Values.Angelite.Value = Player.Values.Angelite.Value + 200
			game.ReplicatedStorage.CreateChatMessage:FireAllClients(Player.Name.." bought 200 Angelite!",Color3.fromRGB(255,114,255))
			game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"&200",Color3.fromRGB(255,114,255),"rbxassetid://4994457097")
			Completed = true
		end
		if Completed then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

