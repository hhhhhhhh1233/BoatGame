local ds <const> = playdate.datastore

function LoadGame(GameManager)
	return ds.read()
	-- local SaveData = ds.read()
	-- if SaveData then
	-- 	printTable(SaveData)
	-- 	-- GameManager:goToLevel(info.CurrentLevel)
	-- 	return true
	-- else
	-- 	return false
	-- end
end

function ClearSave()
	print("Cleared!")
	ds.write()
end

function SaveGame(GameManager)
	local SaveData = {
		-- Positioning
		["CurrentLevel"] = GameManager.currentLevel,
		["PlayerX"] = GameManager.player.savePoint.x,
		["PlayerY"] = GameManager.player.savePoint.y,
		["PlayerDirection"] = GameManager.player.direction,

		-- Player Attributes
		["PlayerCoins"] = GameManager.player.coins,
		["PlayerAbilityAName"] = GameManager.player.AbilityAName,
		["PlayerAbilityBName"] = GameManager.player.AbilityBName,
		["PlayerPassiveAbilityName"] = GameManager.player.PassiveAbilityName,

		-- Water
		["WaterHeight"] = GameManager.water.Height,
		["WaterWheelCollected"] = GameManager.water.bActive,

		-- Collected Entities (Coins, Abilities, and the Water Wheel)
		["CollectedEntities"] = GameManager.collectedEntities
	}

	-- Player Corpse
	if GameManager.playerCorpse then
		SaveData["PlayerCorpseX"] = GameManager.playerCorpse.x + 16
		SaveData["PlayerCorpseY"] = GameManager.playerCorpse.y + 16
		SaveData["PlayerCorpseDirection"] = GameManager.playerCorpse.direction
		SaveData["PlayerCorpseCoins"] = GameManager.playerCorpse.coins
		SaveData["PlayerCorpseLevel"] = GameManager.playerCorpse.level
	end

	ds.write(SaveData)
end
