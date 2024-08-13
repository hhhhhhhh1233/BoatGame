local pd <const> = playdate
local gfx <const> = pd.graphics

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
	self:add()
end

function SincosEnemy:collisionResponse(other)
	if other:isa(DoorTrigger) then
		return "slide"
	elseif other:isa(Player) then
		other:Damage(20, 10)
		return "overlap"
	else
		return "slide"
	end

end

function SincosEnemy:update()
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.direction * self.speed, self.y + 2 * math.sin(2 * pd.getElapsedTime()))
	for i = 1, length do
		if collisions[i].other:isa(Player) then
			break
		elseif math.abs(collisions[i].normal.x) == 1 then
			self.direction *= -1
			if self.direction == -1 then
				self:setImageFlip(gfx.kImageUnflipped)
			else
				self:setImageFlip(gfx.kImageFlippedX)
			end
		end
	end
end
