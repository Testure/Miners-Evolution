local module = {}

local Player = game.Players.LocalPlayer

function module.init(Modules)
	for _,v in pairs(script.Parent.Contents:GetDescendants()) do
		if v:IsA("TextButton") then
			if v.Name == "Premium" then
				v.MouseButton1Click:Connect(function()
					if not v.Owned.Visible then
						Modules.Menu.Sounds.Click:Play()
						game.MarketplaceService:PromptPremiumPurchase(Player)
					end
				end)
			elseif v:FindFirstChild("ProductId") then
				v.MouseButton1Click:Connect(function()
					if v:FindFirstChild("Owned") then
						if not v.Owned.Visible then
							Modules.Menu.Sounds.Click:Play()
							game.MarketplaceService:PromptGamePassPurchase(Player,v.ProductId.Value)
						end
					else
						Modules.Menu.Sounds.Click:Play()
						game.MarketplaceService:PromptProductPurchase(Player,v.ProductId.Value)
					end
				end)
			end
		end
	end
	
	local function Update()
		script.Parent.Contents.Top.Memberships.Contents.Premium.Owned.Visible = (Player:FindFirstChild("Premium") ~= nil)
		script.Parent.Contents.Top.Memberships.Contents.VIP.Owned.Visible = (Player:FindFirstChild("VIP") ~= nil)
		script.Parent.Contents.Top.Memberships.Contents.MVP.Owned.Visible = (Player:FindFirstChild("MVP") ~= nil)
		script.Parent.Contents.Passes.Customizer.Owned.Visible = (Player:FindFirstChild("Customizer") ~= nil)
		script.Parent.Contents.Passes.Radio.Owned.Visible = (Player:FindFirstChild("Radio") ~= nil)
	end
	Update()
	Player.ChildAdded:Connect(Update)
end

return module