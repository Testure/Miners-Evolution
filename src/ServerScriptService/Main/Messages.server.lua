local MS = game:GetService("MessagingService")
local Http = game:GetService("HttpService")
local MegaphoneWatcher = "https://discordapp.com/api/webhooks/708433320081621115/yw5pAjjRMgaysxqbGl1AelzV1UPAcJbs-gF8BJ6KJsBgXJJtR-UEKee8t9lo8w4vxTOG"
local DB = false

game.ServerStorage.SendMessage.Event:Connect(function(Topic,Data)
	local Success,Error = pcall(function()
		MS:PublishAsync(Topic,Http:JSONEncode(Data))
	end)
	if not Success then
		warn("Message publish was not successful")
		warn(Error)
	end
	print("Message was sent for topic: "..Topic)
end)

spawn(function()
	local Topic = "SystemChat"
	local Connect = MS:SubscribeAsync(Topic,function(Table)
		print("Message was recieved for topic: "..Topic.." sent at: "..Table.Sent)
		local Data = Table.Data
		Data = Http:JSONDecode(Data)
		local Color = Color3.fromRGB(Data[2],Data[3],Data[4])
		game.ReplicatedStorage.CreateChatMessage:FireAllClients(Data[1],Color)
	end)
	Event = game.ServerStorage.Disconnect.Event:Connect(function()
		Connect:Disconnect()
		Event:Disconnect()
	end)
end)

spawn(function()
	local Topic = "PlayerChat"
	local Connect = MS:SubscribeAsync(Topic,function(Table)
		print("Message was recieved for topic: "..Topic.." sent at: "..Table.Sent)
		local Data = Table.Data
		Data = Http:JSONDecode(Data)
		local Color = Color3.fromRGB(Data[2],Data[3],Data[4])
		game.ReplicatedStorage.CreateChatMessage:FireAllClients(Data[1],Color)
		local function Send()
			DB = true
			local DiscordData = Http:JSONEncode({["content"] = Data[1]})
			Http:PostAsync(MegaphoneWatcher,DiscordData)
			wait(1)
			DB = false
		end
		if DB then
			delay(1,Send)
		else
			Send()
		end
	end)
end)