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

function PhysicsComponent:Move(owner)
	-- Updates all of the info before moving it
	self.Velocity += self.Acceleration
	self.Position += self.Velocity
	self.Acceleration = pd.geometry.vector2D.new(0, 0)

	-- Actual moving
	local collisions, length
	self.Position.x, self.Position.y, collisions, length = owner:moveWithCollisions(self.Position.x, self.Position.y)

	-- If we hit a surface set our velocity in that direction to zero 
	-- NOTE: Kinda hacky, this only works so long as there are no slanted normals, feel free to be more cleverer
	for i = 1, length, 1 do
		-- NOTE: So that it allows the player to go through overlap collisions
		if collisions[i].type ~= 2 then
			self.Velocity.x *= math.abs(collisions[i].normal.y)
			self.Velocity.y *= math.abs(collisions[i].normal.x)
		end
	end

	return collisions, length
end
