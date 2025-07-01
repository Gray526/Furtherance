local Mod = Furtherance

return function(modifiers)
	return {
		[Mod.Pill.HEARTACHE.ID_UP] = {
			Name = "Mas Dolor De Corazon",
			Description = {
				"↓ {{BrokenHeart}} +1 Corazon Roto"
			}

		},
		[Mod.Pill.HEARTACHE.ID_DOWN] = {
			Name = "Menos Dolor De Corazon",
			Description = {
				"↑ {{BrokenHeart}} -1 Corazon Roto"
			}

		},
	}
end
