local pd <const> = playdate
local gfx <const> = pd.graphics

class('BouncingSpike').extends(gfx.sprite)

function BouncingSpike:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self:setImage(gfx.image.new("images/BouncingSpike"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.TRIGGER, COLLISION_GROUPS.PLAYER})
	self:setImageFlip(gfx.kImageFlippedX)
	self.flipped = 1
	self.yVel = 2
	self.xVel = 5
	self.range = 700
	self:add()
end

function BouncingSpike:collisionResponse(other)
	if other:isa(DoorTrigger) then
		return "slide"
	elseif other:isa(Player) then
		other:Damage(20, 10)
		return "overlap"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.WALL) then
		return "slide"
	else
		return "overlap"
	end

end

function BouncingSpike:update()
	local hit, _ = Raycast(self.x, self.y, -self.range * self.flipped, 0, {self})
	if hit and hit:isa(Player) then
		self.bSeenPlayer = true
	end
	if self.bSeenPlayer then
		local _, _, collisions, length = self:moveWithCollisions(self.x - self.xVel * self.flipped, self.y)
		for i = 1, length do
			if collisions[i].other:isa(Player) then
				self:remove()
				break
			elseif math.abs(collisions[i].normal.x) == 1 then
				if self.flipped == 1 then
					self:setImageFlip(gfx.kImageUnflipped)
				else
					self:setImageFlip(gfx.kImageFlippedX)
				end
				self.flipped *= -1
				self.bSeenPlayer = false
			end
		end
	else
		local _, _, collisions, length = self:moveWithCollisions(self.x, self.y + self.yVel)
		for i = 1, length do
			if collisions[i].other:isa(Player) then
				break
			elseif math.abs(collisions[i].normal.y) == 1 then
				self.yVel *= -1
			end
		end
	end
end
