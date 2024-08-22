import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scripts/bullet"
import "scripts/physicsComponent"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("FloatingEnemy").extends(gfx.sprite)

function FloatingEnemy:init(x, y, player)
	self.player = player
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/FloatingEnemy"))
	self:setCollideRect(0, 0, self:getSize())

	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.WALL})
	self:add()
	self.PhysicsComponent = PhysicsComponent(x, y, 10)

	self.cooldown = 0
end

function FloatingEnemy:update()
	self.PhysicsComponent:addForce(pd.geometry.vector2D.new(0, 0.5))
	self.PhysicsComponent:move(self)
	local toPlayer = self.player.PhysicsComponent.position - self.PhysicsComponent.position
	-- if toPlayer:magnitude() < 250 and self.cooldown >= 15 and not self.player.invisible then
	-- 	local _, _, _, n = self:checkCollisions(self.player.x, self.player.y)
	-- 	if n < 1 and self.player.bActive then
	-- 		Bullet(self.x + toPlayer:normalized().x * 30, self.y + toPlayer:normalized().y * 30, toPlayer:normalized() * 5)
	-- 		self.cooldown = 0
	-- 	end
	-- end
	if toPlayer:magnitude() < 250 then
		gfx.drawLine(self.x, self.y, self.player.x, self.player.y)
		if self.cooldown >= 15 and not self.player.invisible then
			local sprites = gfx.sprite.querySpritesAlongLine(self.x, self.y, self.player.x, self.player.y)
			local blockingObjects = 0
			for _, sprite in ipairs(sprites) do
				if not (sprite:isa(Player) or sprite:isa(Bullet) or sprite:isa(FloatingEnemy)) then
					blockingObjects += 1
				end
			end
			if blockingObjects == 0 then
				Bullet(self.x + toPlayer:normalized().x * 30, self.y + toPlayer:normalized().y * 30, toPlayer:normalized() * 5)
				self.cooldown = 0
			end
		end
	end
	self.cooldown += 1
end

function FloatingEnemy:damage(amount, iFrame)
	self:remove()
end
