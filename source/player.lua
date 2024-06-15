import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "physicsComponent"
import "mine"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init(x, y, image, speed)
	self:moveTo(x,y)
	self:setImage(image)
	-- NOTE: Smaller collision size to cover the boat more snugly
	self:setCollideRect(0, 10, 32, 22)
	self.Speed = speed

	self.PhysicsComponent = PhysicsComponent(x, y)

	self.bUnderwater = false
	self.bCanJump = true

	self:setCenter(0.5,1)

	self:setGroups(COLLISION_GROUPS.PLAYER)
	self:setCollidesWithGroups({COLLISION_GROUPS.WALL, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.EXPLOSIVE})
end

function Player:AddForce(Force)
	self.PhysicsComponent:AddForce(Force)
end

function Player:collisionResponse(other)
	if other:isa(Mine) then
		return "overlap"
	else
		return "slide"
	end
end

function Player:update()
	if self.bUnderwater then
		self.bCanJump = true
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		self:AddForce(pd.geometry.vector2D.new(0, -8))
		self.bCanJump = false
	end

	if pd.buttonIsPressed(pd.kButtonLeft) then
		self:setImageFlip(gfx.kImageFlippedX)
		self:AddForce(pd.geometry.vector2D.new(-self.Speed, 0))
	end

	if pd.buttonIsPressed(pd.kButtonRight) then
		self:setImageFlip(gfx.kImageUnflipped)
		self:AddForce(pd.geometry.vector2D.new(self.Speed, 0))
	end

	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(-self.PhysicsComponent.Velocity.x * 0.2, 0))

	self.PhysicsComponent:Move(self)
end
