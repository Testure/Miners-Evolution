local module = {}

local cache = {}
local dss = game:GetService("DataStoreService")
local inventoryStore = dss:GetDataStore("InventoryStore")
local miscStore = dss:GetDataStore("MiscStore")
local globalStore = dss:GetDataStore("GlobalStore")
local http = game:GetService("HttpService")

function module.Addtocache(Player)
	local Id = Player.UserId
	cache[Id] = {}
	cache[Id]["Misc"] = miscStore:GetAsync(Id) or {[1] = {},[2] = {},[3] = {}}
	cache[Id]["Inventory"] = inventoryStore:GetAsync(Id) or {[1] = {["Iron mine"] = 2,["Basic conveyor"] = 6,["Basic furnace"] = 1},[2] = {["Iron mine"] = 2,["Basic conveyor"] = 6,["Basic furnace"] = 1},[3] = {["Iron mine"] = 2,["Basic conveyor"] = 6,["Basic furnace"] = 1}}
end

function module.PlayerHasOldData(Player)
	if inventoryStore:GetAsync(Player.UserId) then
		return true
	end
	return false
end

function module:GetMisc(player,data,default,slot)
	local id = player.UserId
	if cache[id] then
		if cache[id]["Misc"][slot][data] ~= nil then
			return cache[id]["Misc"][slot][data]
		else
			local d
			pcall(function()
				d = miscStore:GetAsync(id)[slot][data]
				if type(d) == "table" and d[slot] then
					d = d[slot][data]
				else
					d = nil
				end
			end)
			cache[id]["Misc"][slot][data] = d or default
			if d then
				return d
			else
				return default
			end
		end
	end
end

function module:GetInventory(player,slot)
	local id = player.UserId
	if cache[id] then
		if cache[id]["Inventory"][slot]["Iron mine"] ~= nil then
			return cache[id]["Inventory"][slot]
		else
			return {["Iron mine"] = 2,["Basic conveyor"] = 6,["Basic furnace"] = 1}
		end
	end
end

function module:SetMisc(player,data,value,slot)
	local id = player.UserId
	if cache[id] and cache[id]["Misc"][slot] then
		cache[id]["Misc"][slot][data] = value
	end
end

function module:SetInventory(player,inv,slot)
	local id = player.UserId
	if cache[id] and cache[id]["Inventory"][slot] then
		cache[id]["Inventory"][slot] = inv
	end
end

return module