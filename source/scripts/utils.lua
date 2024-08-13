function Clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

-- TODO: FIX IGNORELIST
-- The ignoreList is not properly implemented, it can only ignore one sprite
function Raycast(sourceX, sourceY, directionX, directionY, ignoreSpritesList, ignoreClassesList)
	local source = playdate.geometry.point.new(sourceX, sourceY)
	local collisions, len = playdate.graphics.sprite.querySpriteInfoAlongLine(sourceX, sourceY, sourceX + directionX, sourceY + directionY)
	local closestCollision, closestCollisionLength, collisionPoint
	for _, collision in ipairs(collisions) do
		-- if not (collision.sprite == ignoreList) then
		local ignored = false
		if ignoreSpritesList then
			-- print("IGNORING")
			-- printTable(ignoreSpritesList)
			-- print("COLLIDING WITH")
			-- printTable(collision.sprite)
			for _, ignoreSprite in ipairs(ignoreSpritesList) do
				print("ignoreSprite")
				printTable(ignoreSprite)
				if collision.sprite == ignoreSprite then
					ignored = true
					break
				end
			end
		end

		if ignoreClassesList then
			printTable(ignoreClassesList)
			for _, ignoreClass in ipairs(ignoreClassesList) do
				if collision.sprite.className == ignoreClass then
					ignored = true
					break
				end
			end
		end

		if not ignored then
			if not closestCollision or (collision.entryPoint - source):magnitude() < closestCollisionLength then
				closestCollisionLength = (collision.entryPoint - source):magnitude()
				closestCollision = collision.sprite
				collisionPoint = collision.entryPoint
			end
		end
		-- end
	end
	return closestCollision, collisionPoint
end
