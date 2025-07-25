local Mod = Furtherance

local ASTRAGALI = {}

Furtherance.Item.ASTRAGALI = ASTRAGALI

ASTRAGALI.ID = Isaac.GetItemIdByName("Astragali")

---@param variant PickupVariant
function ASTRAGALI:IsChestAvailable(variant)
	local achievement = ASTRAGALI.IsChestUnlocked[variant]
	return not achievement or achievement()
end

---@type {ID: PickupVariant, Unlocked: fun(): boolean}[]
ASTRAGALI.Chests = {
	{ ID = PickupVariant.PICKUP_CHEST,        Unlocked = function() return true end },
	{ ID = PickupVariant.PICKUP_BOMBCHEST,    Unlocked = function() return true end },
	{ ID = PickupVariant.PICKUP_SPIKEDCHEST,  Unlocked = function() return true end },
	{ ID = PickupVariant.PICKUP_ETERNALCHEST, Unlocked = function() return true end },
	{ ID = PickupVariant.PICKUP_MIMICCHEST,   Unlocked = function() return true end },
	{ ID = PickupVariant.PICKUP_OLDCHEST,     Unlocked = function() return true end },
	{
		ID = PickupVariant.PICKUP_WOODENCHEST,
		Unlocked = function()
			return Mod.PersistGameData:Unlocked(Achievement
				.WOODEN_CHEST)
		end
	},
	{
		ID = PickupVariant.PICKUP_MEGACHEST,
		Unlocked = function()
			return Mod.PersistGameData:Unlocked(Achievement
				.MEGA_CHEST)
		end
	},
	{
		ID = PickupVariant.PICKUP_HAUNTEDCHEST,
		Unlocked = function()
			return Mod.PersistGameData:Unlocked(Achievement
				.HAUNTED_CHEST)
		end
	},
	{ ID = PickupVariant.PICKUP_LOCKEDCHEST, Unlocked = function() return true end },
	{ ID = PickupVariant.PICKUP_REDCHEST,    Unlocked = function() return true end }
}

---@param player EntityPlayer
---@param flags UseFlag
function ASTRAGALI:UseAstragali(_, _, player, flags)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then return end
	local rng = player:GetCollectibleRNG(ASTRAGALI.ID)
	local rerollChestList = {}
	local isChest = {}
	for _, chestTable in ipairs(ASTRAGALI.Chests) do
		isChest[chestTable.ID] = true
		if chestTable.Unlocked() then
			Mod.Insert(rerollChestList, chestTable.ID)
		end
	end
	Mod.Foreach.Pickup(function(pickup, index)
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.ASTRAGALI_PRE_SELECT_CHEST, pickup.Variant, pickup)
		if result == true or result ~= false and (isChest[pickup.Variant] and pickup.SubType == ChestSubType.CHEST_CLOSED) then
			local choice = rerollChestList[rng:RandomInt(#rerollChestList) + 1]
			local newChoice = Isaac.RunCallbackWithParam(Mod.ModCallbacks.ASTRAGALI_PRE_REROLL_CHEST, choice,
				pickup, choice)
			if newChoice and type(newChoice) == "table" and #newChoice == 3 then
				pickup:Morph(newChoice[1], newChoice[2], newChoice[3])
			else
				pickup:Morph(EntityType.ENTITY_PICKUP, choice, ChestSubType.CHEST_CLOSED)
			end
		end
	end)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ASTRAGALI.UseAstragali, ASTRAGALI.ID)
