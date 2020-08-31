return function(Player)
	local Box = game.ReplicatedStorage.Boxes.Epic
	Player.Boxes.Epic.Value = Player.Boxes.Epic.Value + 1
	game.ReplicatedStorage.CurrencyNotify:FireClient(Player,"Epic Box",Box.Color.Value,Box.Image.Value)
end