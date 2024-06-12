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
	self:setCollideRect(0, 0, self:getSize())
	self.Speed = speed

	self.PhysicsComponent = PhysicsComponent(x, y)
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
	if pd.buttonIsPressed(pd.kButtonLeft) then
		self:setImageFlip(gfx.kImageFlippedX)
		self:AddForce(pd.geometry.vector2D.new(-self.Speed, 0))
	end

	if pd.buttonIsPressed(pd.kButtonRight) then
		self:setImageFlip(gfx.kImageUnflipped)
		self:AddForce(pd.geometry.vector2D.new(self.Speed, 0))
	end

	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(-self.PhysicsComponent.Velocity.x * 0.2, 0))

	self.PhysicsComponent:Update()

	local collisions, length
	collisions, length = self.PhysicsComponent:Move(self)

	-- If we hit a surface set our velocity to zero in that direction
	-- NOTE: Kinda hacky, this only works so long as there are no slanted normals, feel free to be more cleverer
	for i = 1, length, 1 do
		-- NOTE: So that it allows the player to go through overlap collisions
		if not (collisions[i].type == 2) then
			self.PhysicsComponent.Velocity.x *= math.abs(collisions[i].normal.y)
			self.PhysicsComponent.Velocity.y *= math.abs(collisions[i].normal.x)
		end
	end
end
