local pd <const> = playdate
local gfx <const> = pd.graphics

class('PhysicsComponent').extends()

function PhysicsComponent:init(x, y)
	self.Position = pd.geometry.vector2D.new(x, y)
	self.Velocity = pd.geometry.vector2D.new(0, 0)
	self.Acceleration = pd.geometry.vector2D.new(0, 0)
end

function PhysicsComponent:AddForce(Force)
	self.Acceleration += Force
end

function PhysicsComponent:Update()
	self.Position += self.Velocity
	self.Velocity += self.Acceleration
	self.Acceleration = pd.geometry.vector2D.new(0, 0)
end

function PhysicsComponent:Move(owner)
	local collisions, length
	self.Position.x, self.Position.y, collisions, length = owner:moveWithCollisions(self.Position.x, self.Position.y)
	return collisions, length
end
