import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scripts/physicsComponent"
import "scripts/buoyancy"
import "scripts/entities/player"
import "scripts/explosion"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Mine').extends(gfx.sprite)

function Mine:init(x, y, image)
	self:moveTo(x, y)
	self:setCenter(0, 0)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self.PhysicsComponent = PhysicsComponent(x, y, 10)

	self:setGroups(COLLISION_GROUPS.EXPLOSIVE)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.PLAYER})
	self:add()

end

function Mine:update()
	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(0, 0.5))
	self.PhysicsComponent:Move(self)
end

function Mine:Damage(amount)
	self:Explode()
end

function Mine:Explode()
	self:remove()
	Explosion(self.x, self.y)
end

function Mine:collisionResponse(other)
	if other:isa(Player) then
		self:Explode()
		return "overlap"
	end
	return "slide"
end
