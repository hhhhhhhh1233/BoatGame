local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/saves"

class('SavePoint').extends(gfx.sprite)

function SavePoint:init(x, y, level)
	self.level = level
	self:moveTo(x + 16, y + 16)
	self:setImage(gfx.image.new("images/SaveSpot"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:setZIndex(-1)
	self:add()
	self.bCanSave = true
end

function SavePoint:update()
	self:moveTo(self.x, self.y + 0.2 * math.cos(5 * pd.getElapsedTime()))

	self.bCanSave = not self.bCollidingWithPlayer
	self.bCollidingWithPlayer = false
	local collisions = self:overlappingSprites()
	for _, sprite in ipairs(collisions) do
		if sprite:isa(Player) then
			self.bCollidingWithPlayer = true
			self.player = sprite
		end
	end

	if self.bCollidingWithPlayer and self.bCanSave then
		self:save(self.player.GameManager)
		self.player.savePoint = self
		self.bCanSave = false
	end
end

function SavePoint:save(GameManager)
	print("Saved")
	SaveGame(GameManager)
end
