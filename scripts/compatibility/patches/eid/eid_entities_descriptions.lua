local Mod = Furtherance
local FR_EID = Mod.EID_Support
local DD = FR_EID.DynamicDescriptions

local modifiers = {
	[EntityType.ENTITY_PICKUP] = {
		[PickupVariant.PICKUP_HEART] = {
			[Mod.Pickup.MOON_HEART.ID] = {
				---@param descObj EID_DescObj
				---@param noLuna string
				---@param hasLuna string
				_modifier = function(descObj, noLuna, hasLuna)
					local player = FR_EID:ClosestPlayerTo(descObj.Entity)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_LUNA) then
						return hasLuna
					else
						return noLuna
					end
				end,
			}
		}
	},
	[EntityType.ENTITY_SLOT] = {
		[Mod.Slot.LOVE_TELLER.ID] = {
			[0] = {
				_modifier = function(charList)
					local renderedPlayerTypes = {}
					local desc = "#"
					for _, player in ipairs(EID.coopAllPlayers) do
						local playerType = player:GetPlayerType()
						local iconPlayerType = playerType
						local parentType = Mod.Slot.LOVE_TELLER.ParentPlayerTypes[playerType]
						if parentType then
							playerType = parentType
						end
						if not renderedPlayerTypes[playerType] then
							local icon = EID:GetPlayerIcon(iconPlayerType)
							local lover = Mod.Slot.LOVE_TELLER:GetMatchMaker(playerType, 2)
							local loverIcon = EID:GetPlayerIcon(lover)
							desc = desc .. icon .. " {{Heart}}" .. loverIcon .. " - " .. charList[lover] .. "#"
							renderedPlayerTypes[playerType] = true
						end
					end
					desc = string.sub(desc, 1, -2)
					return desc
				end,
			}
		}
	}
}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_entities.entities_en_us")(modifiers),
	spa = Mod.Include("scripts.compatibility.patches.eid.eid_entities.entities_spa")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for entType, typeTable in pairs(desc) do
		allDescData[entType] = allDescData[entType] or {}
		local dataEntType = allDescData[entType]
		for entVar, varTable in pairs(typeTable) do
			dataEntType[entVar] = dataEntType[entVar] or {}
			local dataVar = dataEntType[entVar]
			for entSub, data in pairs(varTable) do
				dataVar[entSub] = dataVar[entSub] or {}
				local dataFull = dataVar[entSub]
				if modifiers[entType][entVar] and modifiers[entType][entVar][entSub] then
					Mod:AddToDictionary(dataFull, modifiers[entType][entVar][entSub])
				end
				dataFull[lang] = data
			end
		end
	end
end

for id, variantDescData in pairs(allDescData) do
	for variant, subtypeDescData in pairs(variantDescData) do
		for subtype, entityDescData in pairs(subtypeDescData) do
			for language, descData in pairs(entityDescData) do
				if language:match('^_') then goto continue end -- skip helper private fields

				local name = descData.Name
				local description = descData.Description

				if not DD:IsValidDescription(description) then
					Mod:Log("Invalid entity description for " .. name .. " (" .. subtype .. ")", "Language: " .. language)
					goto continue
				end

				local minimized = DD:MakeMinimizedDescription(description)

				if not DD:ContainsFunction(minimized) and not entityDescData._AppendToEnd then
					EID:addEntity(id, variant, subtype, name, table.concat(minimized, ""), language)
				else
					EID:addEntity(id, variant, subtype, name, "", language) -- description only contains name/language, the actual description is generated at runtime
					DD:SetCallback(DD:CreateCallback(minimized, entityDescData._AppendToEnd), id, variant, subtype,
						language)
				end

				::continue::
			end
		end
	end
end
