import "CoreLibs/sprites"
import "CoreLibs/graphics"


local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init(x, y, image, speed)
	self:moveTo(x,y)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self.Speed = speed

	self.Position = pd.geometry.vector2D.new(x, y)
	self.Velocity = pd.geometry.vector2D.new(0, 0)
	self.Acceleration = pd.geometry.vector2D.new(0, 0)
end

-- Looks nicer
function Player:AddForce(Force)
	self.Acceleration += Force
end

-- Calculates the velocity and position of the player
function Player:HandleForces()
	self.Position += self.Velocity
	self.Velocity += self.Acceleration
	self.Acceleration = pd.geometry.vector2D.new(0, 0)
end

function Player:collisionResponse(other)
	return "slide"
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

	self:AddForce(pd.geometry.vector2D.new(-self.Velocity.x * 0.2, 0))

	self:HandleForces()

	local collisions
	local length
	self.Position.x, self.Position.y, collisions, length = self:moveWithCollisions(self.Position.x, self.Position.y)

	-- If we hit a surface set our velocity to zero in that direction
	for i = 1, length, 1 do
		self.Velocity.x *= -collisions[i]["normal"].y
		self.Velocity.y *= -collisions[i]["normal"].x
	end
end
