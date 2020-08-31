game.StarterGui:SetCore("ChatMakeSystemMessage",{
	Text = "Welcome to Miner's Evolution!",
	Color = Color3.fromRGB(0,255,134),
})

game.ReplicatedStorage.CreateChatMessage.OnClientEvent:Connect(function(Text,Color,Font)
	game.StarterGui:SetCore("ChatMakeSystemMessage",{
		Text = Text,
		Color = Color,
		Font = Font
	})
end)

local Player = game.Players.LocalPlayer
repeat wait() until Player.PlayerGui:FindFirstChild("Gui")
Player.CharacterAdded:Connect(function()
	local Gui = game.ReplicatedStorage.Gui
	Gui:Clone().Parent = Player.PlayerGui
end)