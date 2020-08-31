script.Parent.Touched:Connect(function(Hit)
	if Hit.Parent and Hit.Parent:FindFirstChild("Humanoid") and game.Players:GetPlayerFromCharacter(Hit.Parent) ~= nil then
		Hit.Parent.Humanoid.Health = 0
	end
end)