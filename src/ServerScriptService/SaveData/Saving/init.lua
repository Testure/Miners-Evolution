local module = {}

local self = game.ServerScriptService.SaveData.Saving

local Store = game:GetService("DataStoreService"):GetDataStore("PlayerData")
local Legacy = require(script.LegacyData)

function GetMostRecentSaveTime(OrderedStore)
	local Pages = OrderedStore:GetSortedAsync(false,1)
	for _,v in pairs(Pages:GetCurrentPage()) do
		return v.value
	end
end

function GetItemById(Id)
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if v.Id.Value == Id then
			return v
		end
	end
end

function ConvertData(Player)
	if not Legacy.PlayerHasOldData(Player) then
		return nil
	end
	Legacy.Addtocache(Player)
	local NewData = {}
	local Inventory = Legacy:GetInventory(Player,1)
	local Favs = Legacy:GetMisc(Player,"Favorites",nil,1)
	local NewInv = {}
	for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
		if Inventory[v.Name] then
			NewInv[v.ItemId.Value] = {Amount = Inventory[v.Name] or nil}
			if Favs and Favs[v.Name] then
				NewInv[v.ItemId.Value].Favorite = true
			end
		end
	end
	NewData.Inventory = NewInv
	local Table = {}
	Table.Megaphones = Legacy:GetMisc(Player,"Megaphones",0,1)
	Table.Angelite = Legacy:GetMisc(Player,"Angel",0,1)
	NewData.Money = Legacy:GetMisc(Player,"Cash",50,1)
	NewData.Evolution = Legacy:GetMisc(Player,"Evo",0,1)
	NewData.Boxes = {}
	for _,v in pairs(game.ReplicatedStorage.Boxes:GetChildren()) do
		local Val = Legacy:GetMisc(Player,v.Name.." Box",0,1)
		NewData.Boxes[v.Name] = Val
	end
	NewData.Settings = {}
	Table.Research = Legacy:GetMisc(Player,"Points",0,1)
	NewData.Values = Table
	return NewData
end

function module.LoadData(Player,Slot)
	local Data
	local Success,Error = pcall(function()
		if Slot < 1 or Slot > 4 then
			return false
		end
	
		local Prefix = ""
		if Slot == 2 then
			Prefix = "-two"
		elseif Slot == 3 then
			Prefix = "-three"
		elseif Slot == 4 then
			Prefix = "-four"
		end
	
		local OrderedStore = game:GetService("DataStoreService"):GetOrderedDataStore(tostring(Player.UserId),"PlayerSave"..Prefix)
		OrderedStore:SetAsync("Default",1)
	
		local LastSave = GetMostRecentSaveTime(OrderedStore)
	
		if LastSave > 1 then
			print(LastSave)
			print("Loading "..Player.Name.."'s data from new system")
			local DataStore = game:GetService("DataStoreService"):GetDataStore(tostring(Player.UserId),"PlayerData"..Prefix)
			Data = DataStore:GetAsync(tostring(LastSave))
			if Data ~= nil then
				print("Success")
			else
				warn("Data not found.")
			end
		elseif Slot == 1 then
			print("Loading "..Player.Name.."'s data from old system")
			Data = ConvertData(Player)
			if Data ~= nil then
				print("Success")
			else
				warn("Data not found")
			end
		end
	end)
	return Success,Data,Error
end

function module.SaveData(Player,Data,Slot)
	local Success,Error = pcall(function()
		local TimeStamp = os.time()
		
		if Slot < 1 or Slot > 4 then
			error("Invalid Slot")
			return false
		end
		
		local Prefix = ""
		if Slot == 2 then
			Prefix = "-two"
		elseif Slot == 3 then
			Prefix = "-three"
		elseif Slot == 4 then
			Prefix = "-four"
		end
		
		local OrderedStore = game:GetService("DataStoreService"):GetOrderedDataStore(tostring(Player.UserId),"PlayerSave"..Prefix)
		local DataStore = game:GetService("DataStoreService"):GetDataStore(tostring(Player.UserId),"PlayerData"..Prefix)
		DataStore:SetAsync(tostring(TimeStamp),Data)
		OrderedStore:SetAsync("s"..tostring(TimeStamp),TimeStamp)
	end)
	return Success,Error
end

return module