local pd <const> = playdate
local gfx <const> = pd.graphics

class('Fish').extends(gfx.sprite)

function Fish:init(x, y, water)
	self:moveTo(x, y)
	self.water = water
	self:setImage(gfx.image.new("images/Fish"))
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups(COLLISION_GROUPS.WALL)
	self:setCollideRect(0, 10, 32, 16)
	self.direction = -1
	self.desiredHeight = self.y
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 10)
	self:add()
end

function Fish:collisionResponse(other)
	if other:isa(Mine) or other:isa(Player) then
		return "overlap"
	else
		return "slide"
	end
end

function Fish:Damage(amount)
	self:remove()
end

function Fish:update()
	local sprites, player
	if self.direction == 1 then
		-- gfx.fillRect(self.x, self.y - 50, 200, 100)
		sprites = gfx.sprite.querySpritesInRect(self.x, self.y - 50, 200, 100)
	else
		-- gfx.fillRect(self.x - 200, self.y - 50, 200, 100)
		sprites = gfx.sprite.querySpritesInRect(self.x - 200, self.y - 50, 200, 100)
	end
	for _, sprite in ipairs(sprites) do
		if sprite:isa(Player) then
			player = sprite
		end
	end
	self.PhysicsComponent:addForce(0, 5)
	if self.y > self.water.height then
		self.PhysicsComponent:addForce(0, -5)
		if math.abs(self.desiredHeight - self.y) > 10 then
			self.PhysicsComponent:addForce(0, 0.2*(self.desiredHeight - self.y)/math.abs(self.desiredHeight - self.y))
		end
		self.PhysicsComponent:addForce(0, 0.4*-self.PhysicsComponent.velocity.y)
	end

	if player then
		self.PhysicsComponent:addForce(pd.geometry.vector2D.new(player.x - self.x, player.y - self.y):normalized())
		sprites = gfx.sprite.querySpritesInRect(self.x - 16, self.y - 16, 64, 64)
		for _, sprite in ipairs(sprites) do
			if sprite:isa(Player) then
				sprite:Damage(10, 20)
			end
		end
	else
		self.PhysicsComponent:addForce(1 * self.direction, 0)
		self.PhysicsComponent:addForce(0.4*-self.PhysicsComponent.velocity.x, 0)
		local col = gfx.sprite.querySpritesAlongLine(self.x, self.y, self.x + self.direction*50, self.y)
		if #col > 1 then
			self.direction *= -1
		end
	end
	local c, n = self.PhysicsComponent:move(self)
	for i = 1, n do
		if c[i].type ~= 2 then
			if c[i].normal.y == -1 then
				self:Damage()
			end
		end
	end
	if self.direction == 1 then
		self:setImageFlip(gfx.kImageFlippedX)
	else
		self:setImageFlip(gfx.kImageUnflipped)
	end
end
