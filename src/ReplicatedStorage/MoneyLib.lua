local module = {}

module.Suffixes = {"K","M","B","T","qd","Qn","sx","Sp","O","N","de","Ud","DD","tdD","qdD","QnD","sxD","SpD","OcD","NvD","Vgn","UVg","DVg","TVg","qtV","QnV","SeV","SPG","OVG","NVG","TGN","UTG","DTG","TsTg","qtTG","QnTG","ssTG","SpTG","OcTG","NoTG","QdDR","uQDR","dQDR","tQDR","qdQDR","QnQDR","sxQDR","SpQDR","OQDDr","NQDDr","qQGNT","uQGNT","dQGNT","tQGNT","qdQGNT","QnQGNT","sxQGNT","SpQGNT", "OQQGNT","NQQGNT","SXGNTL"}
module.Cache = {}
	
local function Shorten(Input)
	local Negative = Input < 0
	Input = math.abs(Input)

	local Paired = false
	for i,v in pairs(module.Suffixes) do
		if not (Input >= 10^(3*i)) then
			Input = Input / 10^(3*(i-1))
			local isComplex = (string.find(tostring(Input),".") and string.sub(tostring(Input),4,4) ~= ".")
			Input = string.sub(tostring(Input),1,(isComplex and 4) or 3) .. (module.Suffixes[i-1] or "")
			Paired = true
			break;
		end
	end
	if not Paired then
		local Rounded = math.floor(Input)
		Input = tostring(Rounded)
	end

	if Negative then
		return "-"..Input
	end
	return Input
end

function module.STV(MoneyShort)
	if module.Cache[MoneyShort] ~= nil then
		return module.Cache[MoneyShort]
	end
	local result
	local eCutoff = string.find(MoneyShort,"e%+")
	if eCutoff ~= nil then
		local Coeff = tonumber(string.sub(tostring(MoneyShort),1,1))
		local Zeros = tonumber(string.sub(tostring(MoneyShort),eCutoff+2))
		result = Coeff * 10^Zeros
	else	
		for i,v in pairs(module.Suffixes) do
			local Cutoff = string.find(MoneyShort,v)
			if Cutoff ~= nil and string.sub(MoneyShort,string.len(MoneyShort)-string.len(v)+1) == v then
				local Moneh = string.sub(MoneyShort,1,string.len(MoneyShort)-string.len(v))
				local Answer = tonumber(Moneh) * 10^(3*i)
				result = Answer
			end
		end
	end
	module.Cache[MoneyShort] = result
	return result
end

function module.VTS(Input,Override)
	Override = Override or false
	local Negative = Input < 0
	if Override and Negative then
		return "-($"..Shorten(math.abs(Input))..")"
	end
	if Override then
		return "$"..Shorten(Input)
	else
		return Shorten(Input)
	end
end

function module.Skips(Evo,Money)
	local Cost = module.EvoPrice(Evo)
	local Num = 3
	for i = 10,1,-1 do
		local Price = Cost * (10^(Num*i))
		if Money > Price then
			return i
		end
	end
	return 0
end

function module.EvoPrice(Evo)
	local Price = module.STV("25Qn")
	local Mod = ((1 + (0.1 * Evo)) * (1 + math.floor(Evo/5))) * (1 + math.floor(Evo/100))
	Price = Price * Mod
	return Price
end

function module.HandleEvo(Evo,TEvo)
	local Suffix = ""
	local Prefix = (TEvo > 0 and tostring(TEvo).."+") or ""
	local StringEvo = Shorten(Evo)
	local LastDigit = tonumber(string.sub(tostring(Evo),string.len(tostring(Evo))))
	if Evo < 1000 then
		if Evo <= 20 and Evo >= 10 then
			Suffix = "th"
		elseif LastDigit == 1 then
			Suffix = "st"
		elseif LastDigit == 2 then
			Suffix = "nd"
		elseif LastDigit == 3 then
			Suffix = "rd"
		else
			Suffix = "th"
		end
	end
	if Suffix ~= "" then
		return Prefix..tostring(Evo)..Suffix
	else
		return Prefix..StringEvo
	end
end
	
return module