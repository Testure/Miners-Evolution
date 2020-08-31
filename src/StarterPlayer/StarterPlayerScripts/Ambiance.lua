local module = {}

function module.init(Modules)
	local Music = workspace.CurrentCamera:FindFirstChild("Music")
	local Day = script.Day
	local Night = script.Night
	game.ContentProvider:PreloadAsync(script:GetChildren())
	
	if Music == nil then
		Music = Instance.new("Sound")
		Music.Name = "Music"
		Music.Parent = workspace.CurrentCamera
		Music.Looped = true
		local Tag = Instance.new("NumberValue")
		Tag.Name = "PlayerVolume"
		Tag.Value = 0.07
		Tag.Parent = Music
	end
	
	local AutoChange = true
	
	local function ChangeSong(Song,Override)
		if Music.SoundId ~= Song and (AutoChange or Override) then
			if Override then
				AutoChange = false
			end
			spawn(function()
				if Music.IsPlaying then
					Modules.Tween(Music,{"Volume","PlaybackSpeed"},{0,0.7},1.2)
					wait(1)
					Music:Stop()
				end
				wait()
				Music.SoundId = Song
				Music.Volume = 0
				Music.PlaybackSpeed = 0.7
				wait()
				Music:Play()
				Modules.Tween(Music,{"Volume","PlaybackSpeed"},{Music.PlayerVolume.Value,1},1)
			end)
		end
	end
	
	local function Apply()
		if game.ReplicatedStorage.Night.Value then
			if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Gui") then
				ChangeSong(Night.SoundId)
			end
			Modules.Tween(game.Lighting,{
				"Ambient",
				"Brightness",
				"OutdoorAmbient"
			},
			{
				Color3.fromRGB(0,0,0),
				0,
				Color3.fromRGB(0,0,0)
			},4)
			Modules.Tween(game.Lighting.Atmosphere,{
				"Density",
				"Glare",
				"Color",
				"Decay"
			},{
				0.4,
				0,
				Color3.fromRGB(102,99,168),
				Color3.fromRGB(46,45,77)
			},4)
		else
			if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Gui") then
				ChangeSong(Day.SoundId)
			end
			Modules.Tween(game.Lighting,{
				"Ambient",
				"Brightness",
				"OutdoorAmbient",
			},
			{
				Color3.fromRGB(0,0,0),
				1,
				Color3.fromRGB(0,0,0)
			},4)
			Modules.Tween(game.Lighting.Atmosphere,{
				"Density",
				"Glare",
				"Color",
				"Decay"
			},{
				0.3,
				0.35,
				Color3.fromRGB(114,184,255),
				Color3.fromRGB(114,184,255)
			},4)
		end
	end
	
	local function Reset()
		AutoChange = true
		Apply()
	end
	
	local Connection
	
	local function Custom()
		if Connection then
			Connection:Disconnect()
		end
		local Tycoon = game.Players.LocalPlayer.NearTycoon.Value
		if Tycoon and Tycoon:FindFirstChild("SpecialMusic") then
			local function Set()
				ChangeSong("rbxassetid://"..Tycoon.SpecialMusic.Value,true)
			end
			if Tycoon.SpecialMusic.Value == 0 then
				Reset()
			else
				Set()
			end
			Connection = Tycoon.SpecialMusic.Changed:Connect(Set)
		else
			Reset()
		end
	end
	spawn(function()
		game.Players.LocalPlayer:WaitForChild("NearTycoon",math.huge)
		game.Players.LocalPlayer.NearTycoon.Changed:Connect(Custom)
		Custom()
	end)
	
	game.ReplicatedStorage.Night.Changed:Connect(function()
		Apply()
	end)
	
	Apply()
	
	local function Adjust()
		if Music.PlayerVolume.Value ~= Music.Volume then
			local PitchGoal = 0.7
			if Music.PlayerVolume.Value > 0 then
				PitchGoal = 1
			end
			if Music.Volume == 0 then
				Music.PlaybackSpeed = 0.7
			end
			Modules.Tween(Music,{"Volume","PlaybackSpeed"},{Music.PlayerVolume.Value,PitchGoal},1.2)
		end
	end
	
	Adjust()
	Music.PlayerVolume.Changed:Connect(Adjust)
end

return module