local module = {}

function module.GetTycoon(Player)
	if Player:FindFirstChild("ActiveTycoon") then
		return Player.ActiveTycoon.Value
	end
end

module.PermTemplate = script.Template:Clone()

function module.HasPermission(Player,Perm)
	local Tycoon = module.GetTycoon(Player)
	if Tycoon then
		local Owner = Tycoon.Owner.Value
		if Owner == Player then
			return true
		else
			local Perms = Player.Permissions:FindFirstChild(Owner.Name)
			if Perms then
				if Perms:FindFirstChild(Perm) and Perms[Perm].Value then
					return true
				end
			end
		end
	end
	return false
end

return module