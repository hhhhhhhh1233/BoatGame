function Clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local point_new <const> = playdate.geometry.point.new
local querySpriteInfoAlongLine <const> = playdate.graphics.sprite.querySpriteInfoAlongLine

function Raycast(sourceX, sourceY, directionX, directionY, ignoreSpritesList, ignoreClassesList)
	local source = point_new(sourceX, sourceY)
	local collisions, _ = querySpriteInfoAlongLine(sourceX, sourceY, sourceX + directionX, sourceY + directionY)
	local closestCollision, closestCollisionLength, collisionPoint
	for _, collision in ipairs(collisions) do
		if not closestCollision or (collision.entryPoint - source):magnitude() < closestCollisionLength then
			local ignored = false
			if ignoreSpritesList then
				for _, ignoreSprite in ipairs(ignoreSpritesList) do
					if collision.sprite == ignoreSprite then
						ignored = true
						break
					end
				end
			end
			if not ignored and ignoreClassesList then
				for _, ignoreClass in ipairs(ignoreClassesList) do
					if collision.sprite.className == ignoreClass then
						ignored = true
						break
					end
				end
			end

			if not ignored then
				closestCollisionLength = (collision.entryPoint - source):magnitude()
				closestCollision = collision.sprite
				collisionPoint = collision.entryPoint
			end
		end
	end
	return closestCollision, collisionPoint
end
