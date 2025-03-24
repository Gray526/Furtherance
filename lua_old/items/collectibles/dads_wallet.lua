local mod = Furtherance

mod.DadsWalletCards = {
	Card.CARD_CREDIT,
	Card.CARD_HUMANITY,
	Card.CARD_GET_OUT_OF_JAIL,
	Card.CARD_HOLY,
	Card.CARD_WILD,
	Card.CARD_EMERGENCY_CONTACT,
	Card.CARD_DICE_SHARD,
	Card.CARD_CRACKED_KEY
}

---@param player EntityPlayer
function mod:GiveCardsOnPickUp(player)
	local data = mod:GetData(player)
	if player.QueuedItem.Item
		and not player.QueuedItem.Touched
		and player.QueuedItem.Item.ID == CollectibleType.COLLECTIBLE_DADS_WALLET
		and not data.FR_SpawnDadsWalletCards
	then
		data.FR_SpawnDadsWalletCards = true
	elseif not player.QueuedItem.Item and data.FR_SpawnDadsWalletCards then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DADS_WALLET)
		local choice1 = rng:RandomInt(#mod.DadsWalletCards) + 1
		local card1 = table.remove(mod.DadsWalletCards, choice1)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card1,
			Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)

		local choice2 = rng:RandomInt(#mod.DadsWalletCards) + 1
		local card2 = mod.DadsWalletCards[choice2]
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card2,
			Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)

		table.insert(mod.DadsWalletCards, card1)
		data.FR_SpawnDadsWalletCards = nil
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.GiveCardsOnPickUp)
