import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "physicsComponent"
import "buoyancy"
import "player"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Mine').extends(gfx.sprite)

function Mine:init(x, y, image)
	self:moveTo(x, y)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self.PhysicsComponent = PhysicsComponent(x, y)

	self:setGroups(COLLISION_GROUPS.EXPLOSIVE)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.PLAYER})
end

function Mine:update()
	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(0, 0.5))
	self.PhysicsComponent:Move(self)
end

function Mine:collisionResponse(other)
	if other:isa(Player) then
		return "overlap"
	end
	return "slide"
end
