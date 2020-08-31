-- ToDo: Add more tiers.
-- 1 - 8 Are shop tiers.
local tiers = {
	{Color1 = Color3.fromRGB(120,120,120),Color2 = Color3.fromRGB(75,75,75),Name = "Common"},
	{Color1 = Color3.fromRGB(0,107,235),Color2 = Color3.fromRGB(0,72,200),Name = "Uncommon"},
	{Color1 = Color3.fromRGB(55,161,173),Color2 = Color3.fromRGB(25,131,143),Name = "Rare"},
	{Color1 = Color3.fromRGB(0,206,0),Color2 = Color3.fromRGB(0,148,0),Name = "Very Rare"},
	{Color1 = Color3.fromRGB(255,200,150),Color2 = Color3.fromRGB(255,170,127),Name = "Epic"},
	{Color1 = Color3.fromRGB(255,75,10),Color2 = Color3.fromRGB(255,0,0),Name = "Legendary"},
	{Color1 = Color3.fromRGB(255,75,255),Color2 = Color3.fromRGB(200,50,200),Name = "Mystical"},
	{Color1 = Color3.fromRGB(85,255,255),Color2 = Color3.fromRGB(50,200,255),Name = "Omega"},
	-- ^ Past this point is EvoProof
	{Color1 = Color3.fromRGB(170,85,127),Color2 = Color3.fromRGB(129,64,97),Name = "Angelite"},
	{Color1 = Color3.fromRGB(197,197,0),Color2 = Color3.fromRGB(143,143,0),Name = "Premium"},
	{Color1 = Color3.fromRGB(86,39,226),Color2 = Color3.fromRGB(28,60,150),Name = "Contraband"},
	{Color1 = Color3.fromRGB(206,229,234),Color2 = Color3.fromRGB(150,150,150),Name = "Luxury"},
	{Color1 = Color3.fromRGB(100,53,255),Color2 = Color3.fromRGB(46,67,143),Name = "Collectible"},
	{Color1 = Color3.fromRGB(87,226,131),Color2 = Color3.fromRGB(67,206,111),Name = "Vintage"},
	{Color1 = Color3.fromRGB(67,208,236),Color2 = Color3.fromRGB(58,128,203),Name = "Mint"},
	{Color1 = Color3.fromRGB(255,85,0),Color2 = Color3.fromRGB(170,85,0),Name = "Evolution"},
	{Color1 = Color3.fromRGB(60,255,125),Color2 = Color3.fromRGB(107,216,156),Name = "Fusion"},
	{Color1 = Color3.fromRGB(165,62,255),Color2 = Color3.fromRGB(93,35,144),Name = "Thaumiel"},
	{Color1 = Color3.fromRGB(221,100,75),Color2 = Color3.fromRGB(152,68,51),Name = "Evolved"},
	{Color1 = Color3.fromRGB(255,117,117),Color2 = Color3.fromRGB(180,0,72),Name = "Adv Evolution"},
	{Color1 = Color3.fromRGB(44,44,44),Color2 = Color3.fromRGB(18,18,18),Name = "Forbidden"},
	{Color1 = Color3.fromRGB(255,255,255),Color2 = Color3.fromRGB(34,34,34),Name = "Sigularity"},
	{Color1 = Color3.fromRGB(245,245,245),Color2 = Color3.fromRGB(55,55,55),Name = "Zeno"},
	{Color1 = Color3.fromRGB(232,71,114),Color2 = Color3.fromRGB(255,88,160),Name = "Forged"},
}
return tiers