if game.Players.LocalPlayer:FindFirstChild("BaseDataLoaded") then
	wait()
	script.Parent:Destroy()
else
	local Module = require(script.Parent.LoadingScript)
	script.Parent.Enabled = true
	Module.init()
end