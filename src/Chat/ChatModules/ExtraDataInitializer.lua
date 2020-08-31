--	// FileName: ExtraDataInitializer.lua
--	// Written by: Xsitsu
--	// Editted by: nforeman (and then again by berezaa) (and then again by Testure6)
--	// Description: Module that sets some basic ExtraData such as prefix color, name color, and chat color.


--[[
			--- I added prefix compatability. Why not keep me here? Please? xD
			  UserId = 9221415,
			  ChatColor = Color3.new(1, 215/255, 0),
			
]]





local Players = game:GetService("Players")

function GetSpecialChatColor(speakerName)
	-- return a chatcolor
	local Player = game.Players:FindFirstChild(speakerName)
	if Player then
		if Player.userId == 36102180 then
			return Color3.fromRGB(0,255,134)
		elseif Player:FindFirstChild("Dev") then
			return Color3.fromRGB(255,44,44)
		elseif Player:FindFirstChild("Submitter") then
			return Color3.fromRGB(51,255,221)
		elseif Player:FindFirstChild("Premium") then
			return Color3.fromRGB(255,225,55)
		elseif Player:FindFirstChild("MVP") then
			return Color3.fromRGB(255,87,87)
		elseif Player:FindFirstChild("VIP") then
			return Color3.fromRGB(74,101,255)
		end
	end
end

function GetSpecialPrefix(speakerName)
-- Return prefix
	local Player = game.Players:FindFirstChild(speakerName)
	if Player then
		if Player.userId == 36102180 then
			return "[Creator] "
		elseif Player:FindFirstChild("Dev") then
			return "[Dev] "
		elseif Player:FindFirstChild("Submitter") then
			return "[Submitter] "
		elseif Player.userId == 9221415 then -- guy who made this module
			return "[Cool guy] "
		elseif Player:FindFirstChild("Premium") then
			return "[Premium] "
		elseif Player:FindFirstChild("Premium") then
			return "[M.V.P.] "
		elseif Player:FindFirstChild("VIP") then
			return "[V.I.P.] "		
		end
	end
end

function GetSpecialPrefixColor(speakerName)
-- return a prefix Color
	local Player = game.Players:FindFirstChild(speakerName)
	if Player then
		if Player.userId == 36102180 then
			return Color3.fromRGB(210,40,255)
		elseif Player:FindFirstChild("Dev") then
			return Color3.fromRGB(255,69,69)
		elseif Player:FindFirstChild("Submitter") then
			return Color3.fromRGB(82,255,235)
		elseif Player.userId == 9221415 then -- guy who made this module
			return Color3.fromRGB(255,0,0)
		elseif Player:FindFirstChild("Premium") then
			return Color3.fromRGB(255,214,90)
		elseif Player:FindFirstChild("MVP") then
			return Color3.fromRGB(255,114,101)
		elseif Player:FindFirstChild("VIP") then
			return Color3.fromRGB(94,156,255)
		end
	end

	return Color3.fromRGB(225,225,225)
end

local function Run(ChatService)
	local NAME_COLORS =
	{

		BrickColor.new("White").Color,
		BrickColor.new("White").Color,
	}

	local function GetNameValue(pName)
		local value = 0
		for index = 1, #pName do
			local cValue = string.byte(string.sub(pName, index, index))
			local reverseIndex = #pName - index + 1
			if #pName%2 == 1 then
				reverseIndex = reverseIndex - 1
			end
			if reverseIndex%4 >= 2 then
				cValue = -cValue
			end
			value = value + cValue
		end
		return value
	end

	local color_offset = 0
	local function ComputeNameColor(pName)
		return NAME_COLORS[((GetNameValue(pName) + color_offset) % #NAME_COLORS) + 1]
	end

	local function GetNameColor(speaker)
		local player = speaker:GetPlayer()
		if player then
			if player.Team ~= nil then
				return player.TeamColor.Color
			end
		end
		return ComputeNameColor(speaker.Name)
	end

	ChatService.SpeakerAdded:connect(function(speakerName)
		local speaker = ChatService:GetSpeaker(speakerName)
		
		speaker:SetExtraData("NameColor", GetNameColor(speaker))
		
		local specialChatColor = GetSpecialChatColor(speakerName)
		if specialChatColor then
			speaker:SetExtraData("ChatColor", specialChatColor)
		end
		
		speaker:SetExtraData("Tags", {})
		
		local specialPrefix = GetSpecialPrefix(speakerName)
		if specialPrefix then
			speaker:SetExtraData("Prefix", specialPrefix)
		end	
	
		local specialPrefixColor = GetSpecialPrefixColor(speakerName)
		if specialPrefixColor then
			speaker:SetExtraData("PrefixColor", specialPrefixColor)
		end
		
	end)
	
	game.ServerStorage.PlayerDataLoaded.Event:Connect(function(Player)
		local speaker = ChatService:GetSpeaker(Player.Name)
		if speaker then
			local speakerName = Player.Name
			
			speaker:SetExtraData("NameColor", GetNameColor(speaker))
			
			local specialChatColor = GetSpecialChatColor(speakerName)
			if specialChatColor then
				speaker:SetExtraData("ChatColor", specialChatColor)
			end
			
			speaker:SetExtraData("Tags", {})
			
			local specialPrefix = GetSpecialPrefix(speakerName)
			if specialPrefix then
				speaker:SetExtraData("Prefix", specialPrefix)
			end	
		
			local specialPrefixColor = GetSpecialPrefixColor(speakerName)
			if specialPrefixColor then
				speaker:SetExtraData("PrefixColor", specialPrefixColor)
			end
					
		end
	end)
	

	local PlayerChangedConnections = {}
	Players.PlayerAdded:connect(function(player)
		local changedConn = player.Changed:connect(function(property)
			local speaker = ChatService:GetSpeaker(player.Name)
			if speaker then
				if property == "TeamColor" or property == "Neutral" or property == "Team" then
					speaker:SetExtraData("NameColor", GetNameColor(speaker))
				end
			end
		end)
		PlayerChangedConnections[player] = changedConn
	end)

	Players.PlayerRemoving:connect(function(player)
		local changedConn = PlayerChangedConnections[player]
		if changedConn then
			changedConn:Disconnect()
		end
		PlayerChangedConnections[player] = nil
	end)
end

return Run
