import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scripts/physicsComponent"
import "scripts/buoyancy"
import "scripts/entities/player"
import "scripts/explosion"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('MooredMine').extends(gfx.sprite)

function MooredMine:init(x, y, image, entity)
	self:moveTo(x + 16, y + 16)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 10)

	self:setGroups(COLLISION_GROUPS.EXPLOSIVE)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.PLAYER})
	self.AttachmentPoint = pd.geometry.vector2D.new(entity.fields.AttachmentPoint.cx, entity.fields.AttachmentPoint.cy) * 16
	self.AttachmentPoint.x += 16
	print(self.AttachmentPoint)
	self.ChainLength = entity.fields.ChainLength
	self:add()

end

function MooredMine:update()
	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(0, 0.5))
	self.PhysicsComponent:Move(self)

	for i = 0, math.ceil(self.ChainLength / 16) + 1 do
		gfx.image.new("images/Chain"):draw(self.x - 8, self.y + 12 + 16 * i)
	end

	if (self.AttachmentPoint - self.PhysicsComponent.Position):magnitude() > self.ChainLength then
		local s = (self.AttachmentPoint - self.PhysicsComponent.Position):normalized() * self.ChainLength
		self.PhysicsComponent.Position = self.AttachmentPoint + pd.geometry.vector2D.new(0, -self.ChainLength)
		self.x, self.y = self.PhysicsComponent.Position.x, self.PhysicsComponent.Position.y
		self.PhysicsComponent.Velocity = pd.geometry.vector2D.new(0, 0)
	end
end

function MooredMine:Damage(amount)
	self:Explode()
end

function MooredMine:Explode()
	self:remove()
	Explosion(self.x, self.y)
end

function MooredMine:collisionResponse(other)
	if other:isa(Player) then
		self:Explode()
		return "overlap"
	end
	return "slide"
end
