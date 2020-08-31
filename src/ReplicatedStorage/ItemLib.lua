local module = {}

function module.Error(Part)
	local OldColor = Part.BrickColor
	spawn(function()
		if Part:FindFirstChild("Error") then
			Part.Error:Play()
		end
		Part.BrickColor = BrickColor.new("Really red")
		wait(0.1)
		Part.BrickColor = OldColor
	end)
end

function module.GetTag(Ore,TagName)
	local Tag = Ore.Tags:FindFirstChild(TagName)
	if Tag then
		return Tag
	end
	return nil
end

function module.CreateTag(Ore,TagName,Type)
	if not Ore.Tags:FindFirstChild(TagName) then
		local Tag = Instance.new(Type or "IntValue")
		Tag.Name = TagName
		Tag.Parent = Ore.Tags
		return Tag
	end
	return Ore.Tags:FindFirstChild(TagName)
end

function module.UpdateTag(Ore,TagName,Value)
	local Tag = Ore.Tags:FindFirstChild(TagName)
	if Tag then
		Tag.Value = Value
		if Tag:IsA("IntValue") then
			local Total = 0
			for _,v in pairs(Ore.Tags:GetChildren()) do
				if v:IsA("IntValue") then
					Total = Total + v.Value
				end
			end
			Ore.TotalUpgrades.Value = Total
		end
	end
end

function module.FreezeOre(Ore,Cold)
	if not Ore:FindFirstChild("Frozen") then
		if Ore:FindFirstChild("Flaming") and Cold >= Ore.Flaming.Heat.Value then
			if Cold == Ore.Flaming.Heat.Value then
				Ore.Flaming:Destroy()
				return
			end
			Ore.Flaming:Destroy()
		elseif Ore:FindFirstChild("Flaming") then
			return
		end
		local Tag = script.Frozen:Clone()
		Tag.Parent = Ore
		Tag.Cold.Value = Cold
		local MaterialTag = Instance.new("StringValue")
		MaterialTag.Name = "PastMaterial"
		MaterialTag.Value = tostring(Ore.Material.Value)
		MaterialTag.Parent = Ore
		local ColorTag = Instance.new("StringValue")
		ColorTag.Name = "PastColor"
		ColorTag.Value = tostring(Ore.BrickColor)
		ColorTag.Parent = Ore
		Ore.Material = Enum.Material.Ice
		Ore.BrickColor = BrickColor.new("Pastel light blue")
	end
end

function module.FireOre(Ore,Heat,Color)
	if not Ore:FindFirstChild("Flaming") then
		if Ore:FindFirstChild("Frozen") and Heat >= Ore.Frozen.Cold.Value then
			if Heat == Ore.Frozen.Cold.Value then
				Ore.Frozen:Destroy()
				Ore.Material = Ore.PastMaterial.Value
				Ore.BrickColor = BrickColor.new(Ore.PastColor.Value)
				Ore.PastMaterial:Destroy()
				Ore.PastColor:Destroy()
				return
			end
			Ore.Frozen:Destroy()
			Ore.Material = Ore.PastMaterial.Value
			Ore.BrickColor = BrickColor.new(Ore.PastColor.Value)
			Ore.PastMaterial:Destroy()
			Ore.PastColor:Destroy()
		elseif Ore:FindFirstChild("Frozen") then
			return
		end
		local Tag = script.Flaming:Clone()
		Tag.Parent = Ore
		Tag.Heat.Value = Heat
		if Color then
			Tag.Color = Color
		end
		spawn(function()
			wait(5 - ((math.clamp(Heat,1,22) - 1)/10))
			if Ore and Ore.Parent and Ore:FindFirstChild("Flaming") then
				Ore:Destroy()
			end
		end)
	end
end

function module.ToxicOre(Ore)
	if not Ore:FindFirstChild("Toxic") then
		local Tag = script.Toxic:Clone()
		Tag.Parent = Ore
		spawn(function()
			wait(2.5)
			if Ore and Ore.Parent and Ore:FindFirstChild("Toxic") then
				Ore:Destroy()
			end
		end)
	end
end

return module