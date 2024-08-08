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
	self.ChainLength = self.AttachmentPoint.y - self.y--entity.fields.ChainLength
	self:add()
	self.chainImage = gfx.image.new("images/Chain")

end

function MooredMine:update()
	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(0, 0.5))
	self.PhysicsComponent:Move(self)

	local chainPixelLength = (self.PhysicsComponent.Position - self.AttachmentPoint):magnitude()
	local chainChunks = math.ceil(chainPixelLength / 16)
	for i = 0, chainChunks do
		self.chainImage:draw(self.x - 8, self.y + 12 + i * 16)
	end

	if (self.AttachmentPoint - self.PhysicsComponent.Position):magnitude() > self.ChainLength then
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
	if other:isa(Player) or other:isa(Fish) then
		self:Explode()
		return "overlap"
	end
	return "slide"
end
