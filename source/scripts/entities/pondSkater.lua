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
	self:moveWithCollisions(x, self.water.height - 30)
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 20)
	self.moveTimer = pd.frameTimer.performAfterDelay(150, function ()
		local i = math.random(-1, 1)
		if i == 0 then
			i += 1
		end
		self.PhysicsComponent:addForce(-i*math.random(3, 8), 0)
		self:setImage(self.kickImage)
		pd.frameTimer.performAfterDelay(5, function()
			self:setImage(self.stillImage)
		end)
	end)
	self.moveTimer.repeats = true
end

function PondSkater:update()
	self.bUnderwater = self.y + 16 > self.water.height
	self.bOnSurface = math.abs(self.y + 16 - self.water.height) < 2

	-- Gravity
	self.PhysicsComponent:addForce(0, 0.5)

	-- TODO: This is probably a dumb way for this to be, fix it PLEASE
	if self.bOnSurface then
		self.PhysicsComponent.acceleration.y = 0
		self.PhysicsComponent.velocity.y = 0
	elseif self.bUnderwater then
		self.PhysicsComponent.acceleration.y = 0
		local upwardsForce = Clamp((self.y + 16 - self.water.height), 0, 10)
		self.PhysicsComponent:addForce(0, -upwardsForce)
		-- Upwards Friction
		self.PhysicsComponent:addForce(0, 0.02*-self.PhysicsComponent.velocity.y)
		self.PhysicsComponent.velocity.y = 0
	end

	-- Sideways Friction
	self.PhysicsComponent:addForce(0.06*-self.PhysicsComponent.velocity.x, 0)
	self.PhysicsComponent:move(self)

	local collisions = gfx.sprite.querySpritesInRect(self.x - 10, self.y - 10, 30, 30)
	gfx.fillRect(self.x - 16, self.y - 10, 30, 30)

	for _, collision in ipairs(collisions) do
		if collision:isa(Player) then
			collision:Damage(10, 10)
			collision.PhysicsComponent:addForce((collision.x - self.x), (collision.y - self.y - 16))
		end
	end
end

function PondSkater:Damage(amount)
	self:remove()
end

function PondSkater:collisionResponse(other)
	if other:isa(Player) then
		return "overlap"
	elseif other:isa(Water) then
		return "slide"
	end
end

