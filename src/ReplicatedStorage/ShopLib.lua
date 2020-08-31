Tables = {}

Tables.Mines = {}
Tables.Furnaces = {}
Tables.Machines = {}
Tables.Other = {}
Tables.Premium = {}

Tables.SortedMines = {}
Tables.SortedFurnaces = {}
Tables.SortedMachines = {}
Tables.SortedOther = {}
Tables.SortedPremium = {}

Tables.RawTypes = {"Mines","Furnaces","Machines","Other","Misc","Research","Premium"}
Tables.Sets = {"Mines","Furnaces","Machines","Other","Premium"}

Items = {}

Tables.Sort = function(Table)
	local NewTable = {}
	for i = 1,#Table do
		local LowestPrice = Table[1]
		local LowestPos = 1
		for a,v in pairs(Table) do
			if (v.Cost.Value < LowestPrice.Cost.Value) then
				LowestPrice = v
				LowestPos = a
			end
		end
		table.remove(Table,LowestPos)
		table.insert(NewTable,LowestPrice)
	end
	return NewTable
end

for _,v in pairs(game.ReplicatedStorage.Items:GetChildren()) do
	table.insert(Items,v.ItemId.Value,v)
	if v:FindFirstChild("ItemType") and v:FindFirstChild("Cost") and v.ItemType.Value ~= 6 and v.ItemType.Value ~= 5 and Tables.RawTypes[v.ItemType.Value] ~= nil then
		local Success,Error = pcall(function()
			table.insert(Tables[Tables.RawTypes[v.ItemType.Value]],v)
		end)
		if not Success then
			print(v.Name)
			print(v.ItemType.Value)
			warn(Error)
		end
	end
end

for _,v in pairs(Tables.Sets) do
	Tables["Sorted"..v] = Tables.Sort(Tables[v])
end

return Tables