local pd <const> = playdate
local gfx <const> = pd.graphics

class('PondSkater').extends(gfx.sprite)

function PondSkater:init(x, y, water)
	self.stillImage = gfx.image.new("images/PondSkater1")
	self.kickImage = gfx.image.new("images/PondSkater2")
	self:setImage(self.stillImage)
	self:setCollideRect(0, 10, 32, 22)
	self.water = water
	self:moveTo(x, y)
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups(COLLISION_GROUPS.WALL, COLLISION_GROUPS.WATER)
	self:add()
	self:moveWithCollisions(x, self.water.Height - 30)
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 20)
	self.moveTimer = pd.frameTimer.performAfterDelay(150, function ()
		local i = math.random(-1, 1)
		if i == 0 then
			i += 1
		end
		self.PhysicsComponent:AddForce(-i*math.random(3, 8), 0)
		self:setImage(self.kickImage)
		pd.frameTimer.performAfterDelay(5, function()
			self:setImage(self.stillImage)
		end)
	end)
	self.moveTimer.repeats = true
end

function PondSkater:update()
	self.bUnderwater = self.y + 16 > self.water.Height
	self.bOnSurface = math.abs(self.y + 16 - self.water.Height) < 2

	-- Gravity
	self.PhysicsComponent:AddForce(0, 2)

	-- TODO: This is probably a dumb way for this to be, fix it PLEASE
	if self.bOnSurface then
		self.PhysicsComponent.Acceleration.y = 0
		self.PhysicsComponent.Velocity.y = 0
	elseif self.bUnderwater then
		self.PhysicsComponent.Acceleration.y = 0
		self.PhysicsComponent:AddForce(0, -4)
		self.PhysicsComponent.Velocity.y = 0
	end

	-- Sideways Friction
	self.PhysicsComponent:AddForce(0.06*-self.PhysicsComponent.Velocity.x, 0)
	self.PhysicsComponent:Move(self)

end

function PondSkater:collisionResponse(other)
	if other:isa(Player) then
		return "overlap"
	elseif other:isa(Water) then
		return "slide"
	end
end

