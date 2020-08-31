local module = {}

local RunService = game:GetService("RunService")

local PromptOut
local PromptFrame = script.Parent.Parent
local ButtonCons = {}
local CurrentDecision

function module.ForceClose()
	if PromptOut then
		PromptFrame.Visible = false
	end
end

function module.IsPrompting()
	return PromptOut
end

function module.init(Modules)
	PromptFrame.AbsorbInput.Visible = false
	PromptFrame.BackgroundTransparency = 1
	PromptFrame.Prompt.Position = UDim2.new(0.5,0,0,-250)
	PromptFrame.Visible = true
	local Sounds = Modules.Menu.Sounds
	
	function module.Prompt(Text)
		if PromptOut then
			return false
		end
		
		local function selfIsSelected()
			local obj = game.GuiService.SelectedObject
			if obj then
				return obj:IsDescendantOf(PromptFrame)
			else
				return false
			end
		end
		
		PromptOut = true
		PromptFrame.Prompt.Position = UDim2.new(0.5,0,0,-250)
		PromptFrame.Prompt.Title.Text = Text
		PromptFrame.BackgroundTransparency = 1
		
		local con0 = PromptFrame.Prompt.No.MouseButton1Click:Connect(function()
			Sounds.Click:Play()
			CurrentDecision = false
		end)
		local con1 = PromptFrame.Prompt.Yes.MouseButton1Click:Connect(function()
			Sounds.Click:Play()
			CurrentDecision = true
		end)
		
		PromptFrame.AbsorbInput.Visible = true
		Modules.Tween(PromptFrame,{"BackgroundTransparency"},0.8,0.7,Enum.EasingStyle.Quint)
		Modules.Tween(PromptFrame.Prompt,{"Position"},UDim2.new(0.5,0,0.5,0),0.7,Enum.EasingStyle.Quint)
		
		local PreObj = game.GuiService.SelectedObject
		repeat
			if Modules.Input.Mode.Value == "Xbox" and not selfIsSelected() then
				game.GuiService.GuiNavigationEnabled = true
				game.GuiService.SelectedObject = PromptFrame.Prompt.Yes
			end
			RunService.Heartbeat:Wait()
		until CurrentDecision ~= nil
		
		local ThisDecision = CurrentDecision
		CurrentDecision = nil
		
		con0:Disconnect()
		con1:Disconnect()
		
		PromptOut = false
		
		if PreObj then
			game.GuiService.GuiNavigationEnabled = false
			game.GuiService.SelectedObject = nil
		end
		PromptFrame.AbsorbInput.Visible = false
		Modules.Tween(PromptFrame,{"BackgroundTransparency"},1,0.7,Enum.EasingStyle.Quint)
		Modules.Tween(PromptFrame.Prompt,{"Position"},UDim2.new(0.5,0,0,-250),0.7,Enum.EasingStyle.Quint)
		return ThisDecision
	end
end

return module