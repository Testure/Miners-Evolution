local Saving = require(script.Saving)
local Lib = require(script.DataLib)
local Suffix = require(game.ReplicatedStorage.MoneyLib)

local Closing = false

local function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.ItemId.Value == Id then
			return v
		end
	end
end

local function SaveData(Player)
	local Success = false
	local Error
	
	if Player:FindFirstChild("Error") then
		return false
	end
	
	local Slot = nil
	if Player:FindFirstChild("DataSlot") then
		Slot = Player.DataSlot.Value
	else
		error("Invaild Save Slot")
		return false
	end
	
	if Player ~= nil and Player:FindFirstChild("BaseDataLoaded") and Player:FindFirstChild("PlayerData") then
		local Tycoon = Lib.GetTycoon(Player)
		local PlayerData = require(Player.PlayerData)
		if PlayerData and Tycoon then
			if Player:FindFirstChild("Blueprints") then
				PlayerData.Blueprints = PlayerData.Blueprints or {}
				for _,v in pairs(Player.Blueprints:GetChildren()) do
					PlayerData.Blueprints[v.Name] = v.Value
				end
			end
			
			local Money = Player.Money
			local FinalVal = "0"
			if Money and Money.Value > 10^200 then
				Money.Value = 10^200
			end
			if Money then
				FinalVal = tostring(Money.Value)
			end
			
			if string.len(FinalVal) > 100 then
				FinalVal = "0"
			end
			
			local Codes = _G["Codes"][Player.Name]
			if Codes then
				PlayerData.Codes = Codes
			end
			
			PlayerData.Money = FinalVal
			
			if _G["Inventory"][Player.Name] ~= nil and _G["Inventory"][Player.Name] ~= {} then
				PlayerData.Inventory = _G["Inventory"][Player.Name]
			end
			if _G["SafeKeeping"][Player.Name] ~= nil and _G["SafeKeeping"][Player.Name] ~= {} then
				PlayerData.SafeKeeping = _G["SafeKeeping"][Player.Name]
			end
			
			PlayerData.Settings = PlayerData.Settings or {}
			if Player:FindFirstChild("Settings") then
				for _,v in pairs(Player.Settings:GetChildren()) do
					PlayerData.Settings[v.Name] = v.Value
				end
			end
			
			PlayerData.Values = PlayerData.Values or {}
			if Player:FindFirstChild("Values") then
				for _,v in pairs(Player.Values:GetChildren()) do
					PlayerData.Values[v.Name] = v.Value
				end
			end
			
			if Player:FindFirstChild("Evolution") then
				PlayerData.Evolution = Player.Evolution.Value
			end
			if Player:FindFirstChild("TrueEvolution") then
				PlayerData.TrueEvolution = Player.TrueEvolution.Value
			end
			if Player:FindFirstChild("LastGift") then
				PlayerData.LastGift = Player.LastGift.Value
			end
			if Player:FindFirstChild("LoginStreak") then
				PlayerData.LoginStreak = Player.LoginStreak.Value
			end
			
			if Player:FindFirstChild("AverageIncome") then
				if Player.AverageIncome.Value > 10^100 then
					Player.AverageIncome.Value = 10^100
				end
				PlayerData.Income = Player.AverageIncome.Value
			end
			
			local BaseData = Lib.TycoonToTable(Tycoon)
			if BaseData ~= nil then
				PlayerData.Base = BaseData
			else
				warn("AHHHHH YOUR BASE DATA IS NIL!!!!! AHHHHH")
			end
			
			PlayerData.TycoonColor = Tycoon.Base.BrickColor.Name
			PlayerData.TycoonMaterial = Tycoon.Base.Material.Name
			
			PlayerData.Boxes = PlayerData.Boxes or {}
			for _,v in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
				local Val = Player.Boxes:FindFirstChild(v.Name)
				if Val then
					PlayerData.Boxes[v.Name] = Val.Value
				end
			end
			
			PlayerData.TimeStamp = os.time()
			
			Success,Error = Saving.SaveData(Player,PlayerData,Slot)
			
			if not Success then
				warn("Error saving "..Player.Name.."'s data: "..Error)
			end
		else
			warn("Failed to save data")
		end
	end
	return Success,Error
end

local function GetSum(Boxes)
	local Total = 0
	for _,v in pairs(Boxes:GetChildren()) do
		Total = Total + v.Value
	end
	return Total
end

local function QuickLoad(Player,Slot)
	if Player:FindFirstChild("BaseDataLoaded") then
		return false
	end
	if Player:FindFirstChild("LoadRequests") then
		if Player.LoadRequests.Value > 5 then
			return false
		end
	else
		local Tag = Instance.new("IntValue")
		Tag.Name = "LoadRequests"
		Tag.Parent = Player
	end
	
	local Success,PlayerDataRaw,Error = Saving.LoadData(Player,Slot)
	
	if Success then
		local SaveString = "nil"
		
		if PlayerDataRaw ~= nil then
			SaveString = game.HttpService:JSONEncode(PlayerDataRaw)
		end
		
		local Tag = Instance.new("BindableFunction")
		Tag.Name = "DataSaveSlot"..tostring(Slot)
		Tag.Parent = Player
		Tag.OnInvoke = function()
			return SaveString
		end
		
		if PlayerDataRaw then
			PlayerDataRaw.Base = {}
		end
		
		Player.LoadRequests.Value = Player.LoadRequests.Value + 1
	else
		Error = Error or "Unknown error quick loading data"
		warn(Error)
	end
	return Success,PlayerDataRaw
end

local function LoadData(Player,Slot)
	if Player:FindFirstChild("LoadingData") then
		return false
	end
	if Player:FindFirstChild("BaseDataLoaded") then
		return false
	end
	if Player:FindFirstChild("Error") then
		return false
	end
	
	local CurrentTag = Instance.new("BoolValue")
	CurrentTag.Name = "LoadingData"
	CurrentTag.Parent = Player
	
	print("Slot: "..tostring(Slot))
	
	local SlotTag = Instance.new("IntValue")
	SlotTag.Name = "DataSlot"
	SlotTag.Parent = Player
	SlotTag.Value = Slot
	
	local Error = "none"
	local Success = false
	local DataTag = Player:FindFirstChild("DataSaveSlot"..tostring(Slot))
	local PlayerDataRaw
	
	if DataTag then
		local Value = DataTag:Invoke()
		if Value then
			Success = true
			if Value ~= "nil" then
				PlayerDataRaw = game.HttpService:JSONDecode(Value)
			end
		end
	else
		Error = "Wow this data is non existant"
	end
	
	if Success then
		local PlayerDataFormat = game.ReplicatedStorage.PlayerDataFormat:Clone()
		PlayerDataFormat.Name = "PlayerData"
		PlayerDataFormat.Parent = Player
		local PlayerData = require(PlayerDataFormat)
		
		if PlayerDataRaw == nil then
			print("Noob!!!!")
			
			PlayerData.Money = "50"
			PlayerData.Inventory = nil
			PlayerData.SafeKeeping = nil
			PlayerData.Settings = {}
			PlayerData.Values = {}
			PlayerData.Boxes = {}
			PlayerData.Codes = {}
			PlayerData.Evolution = 0
			PlayerData.TrueEvolution = 0
			PlayerData.LastGift = "0"
			PlayerData.LoginStreak = 0
			
			local Noob = Instance.new("BoolValue")
			Noob.Name = "Noob"
			Noob.Parent = Player
		else
			for i,v in pairs(PlayerDataRaw) do
				PlayerData[i] = v
			end
		end
		
		local Tycoon = Lib.GetTycoon(Player)
		
		if Tycoon then
			Tycoon.Base.Material = PlayerData.TycoonMaterial or Enum.Material.Slate
			Tycoon.Base.BrickColor = BrickColor.new(tostring(PlayerData.TycoonColor)) or BrickColor.new("Medium stone grey")
			for _,v in pairs(Tycoon.Items:GetChildren()) do
				v:Destroy()
			end
			
			if PlayerData.Base == nil then
				print(Player.Name.." had no base so default base was loaded")
				PlayerData.Base = {}
				for i,v in pairs(Lib.DefaultBase) do
					PlayerData.Base[i] = v
				end
			end
			if PlayerData.Base ~= nil then
				local BaseSuccess = Lib.TableToTycoon(PlayerData.Base,Player,Tycoon)
				if BaseSuccess then
					print(Player.Name.."'s base was loaded")
				else
					warn(Player.Name.."'s base failed to load")
					return false
				end
			else
				warn("Player had no base to load")
			end
			
			if PlayerData.Inventory ~= nil and PlayerData.Inventory ~= {} then
				_G["Inventory"][Player.Name] = PlayerData.Inventory
				print("Inventory was loaded")
			else
				local Inv = {}
				Inv[1] = {Amount = 4}
				Inv[2] = {Amount = 10}
				Inv[3] = {Amount = 1}
				_G["Inventory"][Player.Name] = Inv
				print("Default inventory was loaded")
			end
			if PlayerData.SafeKeeping ~= nil and PlayerData.SafeKeeping ~= {} then
				_G["SafeKeeping"][Player.Name] = PlayerData.SafeKeeping
			else
				_G["SafeKeeping"][Player.Name] = {}
			end
			
			for i,v in pairs(_G["Inventory"][Player.Name]) do
				if v.Amount and v.Amount < 1 then
					v.Amount = nil
				end
				if GetItemById(i) == nil then
					table.remove(_G["Inventory"][Player.Name],i)
				end
			end
			for i,v in pairs(_G["SafeKeeping"][Player.Name]) do
				if v.Amount and v.Amount < 1 then
					v.Amount = nil
				end
				if GetItemById(i) == nil then
					table.remove(_G["SafeKeeping"][Player.Name],i)
				end
			end
			for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				if _G["Inventory"][Player.Name][v.ItemId.Value] == nil then
					_G["Inventory"][Player.Name][v.ItemId.Value] = {Amount = nil}
				end
			end
			for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
				if _G["SafeKeeping"][Player.Name][v.ItemId.Value] == nil then
					_G["SafeKeeping"][Player.Name][v.ItemId.Value] = {Amount = nil}
				end
			end
			
			local Money = Instance.new("NumberValue")
			
			local RealMon = tonumber(PlayerData.Money)
			if RealMon == nil or RealMon < 0 then
				RealMon = 50
			end
			if RealMon > 10^200 then
				RealMon = 10^200
			end
			if not (RealMon == RealMon) then
				RealMon = 50
			end
			
			PlayerData.Money = RealMon
			
			Money.Value = RealMon
			Money.Name = "Money"
			Money.Parent = Player
			
			Money.Changed:Connect(function()
				if Money.Value > 10^200 then
					Money.Value = 10^200
				end
			end)
			
			local Blueprints = Instance.new("Folder")
			Blueprints.Name = "Blueprints"
			Blueprints.Parent = Player
			PlayerData.Blueprints = PlayerData.Blueprints or {{},{},{}}
			for i,v in pairs(PlayerData.Blueprints) do
				local Tag = Instance.new("StringValue")
				Tag.Name = i
				if type(v) == "table" then
					Tag.Value = game.HttpService:JSONEncode(v)
				elseif type(v) == "string" and v ~= "" then
					Tag.Value = v
				else
					Tag.Value = "[]"
				end
				Tag.Parent = Blueprints
			end
			
			_G["Codes"][Player.Name] = PlayerData.Codes
			
			local Evo = Instance.new("IntValue")
			Evo.Name = "Evolution"
			Evo.Parent = Player
			Evo.Value = PlayerData.Evolution
			local TEvo = Instance.new("IntValue")
			TEvo.Name = "TrueEvolution"
			TEvo.Parent = Player
			TEvo.Value = PlayerData.TrueEvolution
			local LG = Instance.new("StringValue")
			LG.Name = "LastGift"
			LG.Parent = Player
			LG.Value = tostring(PlayerData.LastGift)
			local LS = Instance.new("IntValue")
			LS.Name = "LoginStreak"
			LS.Parent = Player
			LS.Value = (PlayerData.LoginStreak) or 0
			
			PlayerData.Settings = PlayerData.Settings or {}
			local Folder = script.Settings:Clone()
			Folder.Parent = Player
			for _,v in pairs(Folder:GetChildren()) do
				local Val = PlayerData.Settings[v.Name]
				if Val then
					v.Value = Val
				end
			end
			
			PlayerData.Values = PlayerData.Values or {}
			local Folder2 = script.Values:Clone()
			Folder2.Parent = Player
			for _,v in pairs(Folder2:GetChildren()) do
				local Val = PlayerData.Values[v.Name]
				if Val then
					v.Value = Val
				end
			end
			
			spawn(function()
				spawn(function()
					if Player:FindFirstChild("Boxes") == nil then
						local Boxes = Instance.new("IntValue")
						Boxes.Parent = Player
						Boxes.Name = "Boxes"
						
						for _,v in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
							local Tag = Instance.new("IntValue")
							Tag.Name = v.Name
							Tag.Parent = Boxes
						end
						for _,v in pairs(Boxes:GetChildren()) do
							v.Changed:Connect(function()
								Boxes.Value = GetSum(Boxes)
							end)
						end
					end
					wait()
					for _,v in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
						local Tag = Player.Boxes:FindFirstChild(v.Name)
						if Tag then
							Tag.Value = PlayerData.Boxes[v.Name]
						end
					end
				end)
				
				local DataCount
				pcall(function()
					local JSONPlayerData = game.HttpService:JSONEncode(PlayerData)
					DataCount = string.len(JSONPlayerData)
					print(Player.Name.."'s data is "..tostring(DataCount).." characters long")
				end)
				
				spawn(function()
					if Player then
						local SuccessTag = Instance.new("BoolValue")
						SuccessTag.Name = "BaseDataLoaded"
						SuccessTag.Parent = Player
						
						game.ReplicatedStorage.DataLoaded:FireClient(Player)
						game.ServerStorage.PlayerDataLoaded:Fire(Player)
						
						Player.leaderstats.Evolution.Value = Suffix.HandleEvo(Player.Evolution.Value,Player.TrueEvolution.Value)
						Player.leaderstats.Cash.Value = Suffix.VTS(Player.Money.Value)
						
						Player.Money.Changed:Connect(function()
							Player.leaderstats.Cash.Value = Suffix.VTS(Player.Money.Value)
						end)
						Player.Evolution.Changed:Connect(function()
							Player.leaderstats.Evolution.Value = Suffix.HandleEvo(Player.Evolution.Value,Player.TrueEvolution.Value)
						end)
						
						local TimeAway = 0
						if PlayerData.TimeStamp and PlayerData.TimeStamp > 1 then
							TimeAway = os.time() - PlayerData.TimeStamp
						end
						
						spawn(function()
							wait(2)
							if TimeAway >= 600 and PlayerData.Income and PlayerData.Income > 0 then
								if TimeAway > 259200 then
									TimeAway = 259200
								end
								
								local Earnings = PlayerData.Income * (TimeAway / 10)
								if Earnings > RealMon * 500 then
									Earnings = RealMon * 500
								end
								Money.Value = Money.Value + Earnings
								--Hint here
							else
								print("No money for ya")
							end
						end)
						
						while wait(60) do
							if Player ~= nil and Player.Parent == game.Players and Player:FindFirstChild("Leaving") == nil and not Closing then
								if Player:FindFirstChild("Evolving") == nil then
									SaveData(Player,PlayerData)
								end
							else
								break
							end
						end
					end
				end)
				if CurrentTag then
					CurrentTag:Destroy()
				end
				return true,DataCount
			end)
		else
			if CurrentTag then
				CurrentTag:Destroy()
			end
			return false
		end
	end
end

function game.ReplicatedStorage.LoadData.OnServerInvoke(Player,Slot)
	if Player:FindFirstChild("BaseDataLoaded") == nil and Player:FindFirstChild("LoadingData") == nil then
		local Success,Error,Result,DataCount = pcall(function()
			return LoadData(Player,Slot)
		end)
		
		if not Success then
			local Tag = Instance.new("BoolValue")
			Tag.Parent = Player
			Tag.Name = "Error"
			Error = Error or "Unknown error loading data"
			warn("ERROR LOADING DATA: "..Error)
		end
		
		return Result,Success,Error,DataCount
	end
end

function game.ServerStorage.SavePlayer.OnInvoke(Player)
	return SaveData(Player)
end

game.ReplicatedStorage.PreLoadData.OnServerInvoke = QuickLoad

game.Players.PlayerRemoving:Connect(function(Player)
	local LeavingTag = Instance.new("BoolValue")
	LeavingTag.Name = "Leaving"
	LeavingTag.Parent = Player
	if not Closing then
		if Player:FindFirstChild("BaseDataLoaded") and Player:FindFirstChild("Evolving") == nil then
			SaveData(Player)
		end
		local Tycoon = Lib.GetTycoon(Player)
		if Tycoon then
			for _,v in pairs(Tycoon.Items:GetChildren()) do
				v:Destroy()
			end
			Tycoon.Ores:ClearAllChildren()
			Tycoon.Owner.Value = nil
		end
		local Team = game:GetService("Teams"):FindFirstChild(Player.Name.."'s Base")
		if Team then
			Team:Destroy()
		end
		
		_G["Inventory"][Player.Name] = nil
		_G["SafeKeeping"][Player.Name] = nil
	end
end)

game:BindToClose(function()
	Closing = true
	local IsStudio = game:GetService("RunService"):IsStudio()
	for _,v in pairs(game.Players:GetPlayers()) do
		spawn(function()
			
			SaveData(v)
		end)
	end
	if not IsStudio then
		while wait() do
			print("WE'RE GONNA DIE! WE'RE ALL GONNA DIE!")
		end
	end
end)