local function CreateTag(Player,Name)
	local Tag = Instance.new("BoolValue")
	Tag.Name = Name
	Tag.Value = true
	Tag.Parent = Player
	return Tag
end

local function Check(Player)
	if Player:FindFirstChild("Checking") then
		return
	end
	if Player:FindFirstChild("CheckDone") then
		return
	end
	local Tag = CreateTag(Player,"Checking")
	
	-- Gamepasses
	if Player:FindFirstChild("VIP") == nil and game.MarketplaceService:UserOwnsGamePassAsync(Player.UserId,6330754) then
		CreateTag(Player,"VIP")
	end
	
	if Player:FindFirstChild("MVP") == nil and game.MarketplaceService:UserOwnsGamePassAsync(Player.UserId,6330747) then
		CreateTag(Player,"MVP")
	end
	
	if Player:FindFirstChild("Customizer") == nil and game.MarketplaceService:UserOwnsGamePassAsync(Player.UserId,7596006) then
		CreateTag(Player,"Customizer")
	end
	
	if Player:FindFirstChild("Radio") == nil and false then --game.MarketplaceService:UserOwnsGamePassAsync(Player.UserId,-1) then
		CreateTag(Player,"Radio")
	end
	
	if Player:FindFirstChild("Premium") == nil and Player.MembershipType == Enum.MembershipType.Premium then
		CreateTag(Player,"Premium")
	end
	
	-- Artifacts
	if Player:FindFirstChild("Orb") == nil and game.MarketplaceService:UserOwnsGamePassAsync(Player.UserId,7773202) then
		CreateTag(Player,"Orb")
	end
	
	if Player:FindFirstChild("Clock") == nil and game.MarketplaceService:UserOwnsGamePassAsync(Player.UserId,7773208) then
		CreateTag(Player,"Clock")
	end
	
	if Player:FindFirstChild("Code") == nil and game.MarketplaceService:UserOwnsGamePassAsync(Player.UserId,7773204) then
		CreateTag(Player,"Code")
	end
	
	-- Group stuff
	if Player:FindFirstChild("Creator") == nil and Player.UserId == 36102180 then
		CreateTag(Player,"Creator")
	end
	
	if Player:FindFirstChild("Dev") == nil and Player:GetRankInGroup(4894996) >= 254 then
		CreateTag(Player,"Dev")
	end
	
	if Player:FindFirstChild("Submitter") == nil and Player:GetRankInGroup(4894996) >= 252 then
		CreateTag(Player,"Submitter")
	end
	
	if Player:FindFirstChild("Tester") == nil and Player:GetRankInGroup(4894996) == 251 then
		CreateTag(Player,"Tester")
	end
	
	if Player:FindFirstChild("Group") == nil and Player:GetRankInGroup(4894996) >= 1 then
		CreateTag(Player,"Group")
	end
	
	-- Done
	Tag:Destroy()
	CreateTag(Player,"CheckDone")
end
game.Players.PlayerAdded:Connect(Check)