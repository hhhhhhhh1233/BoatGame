local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/healthComponent"

class('SincosEnemy').extends(gfx.sprite)

function SincosEnemy:init(x, y)
	self:moveTo(x + 16, y + 8)
	self:setImage(gfx.image.new("images/SincosEnemy"))
	self:setImageFlip(gfx.kImageFlippedX)
	self:setCollideRect(0, 0, 32, 16)
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.TRIGGER, COLLISION_GROUPS.PLAYER})
	self.direction = 1
	self.speed = 2
	self.healthComponent = HealthComponent(self, 50, 10)
	self:add()
end

function SincosEnemy:collisionResponse(other)
	if other:isa(DoorTrigger) then
		return "slide"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.PROJECTILE) then
		return "overlap"
	elseif other:isa(Player) then
		other:damage(20, 10)
		return "overlap"
	else
		return "slide"
	end

end

function SincosEnemy:damage(amount)
	self.healthComponent:damage(amount)
end

function SincosEnemy:update()
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.direction * self.speed, self.y + 2 * math.sin(2 * pd.getElapsedTime()))
	for i = 1, length do
		if math.abs(collisions[i].normal.x) == 1 and (EntityIsCollisionGroup(collisions[i].other, COLLISION_GROUPS.WALL) or collisions[i].other:isa(DoorTrigger)) then
			self.direction *= -1
			if self.direction == -1 then
				self:setImageFlip(gfx.kImageUnflipped)
			else
				self:setImageFlip(gfx.kImageFlippedX)
			end
		end
	end
end
