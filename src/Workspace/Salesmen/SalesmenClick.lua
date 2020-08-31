local module = {}

function module.init(Modules)
	script.Parent.ClickDetector.MouseHoverEnter:Connect(function()
		script.Parent.ClickDetector.SelectionBox.Visible = true
	end)
	
	script.Parent.ClickDetector.MouseHoverLeave:Connect(function()
		script.Parent.ClickDetector.SelectionBox.Visible = false
	end)
	
	script.Parent.ClickDetector.MouseClick:Connect(function()
		Modules.Menu.Sounds.Click:Play()
		if script.Parent.Active.Value then
			Modules.Salesmen.Open()
		else
			game.ReplicatedStorage.Currency:FireClient(game.Players.LocalPlayer,script.Parent,"How did you get to me?",Color3.new(.6,.6,.6),0.5)
		end
	end)
end

return module