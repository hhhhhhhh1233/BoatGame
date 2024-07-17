import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("SimpleEnemy").extends(gfx.sprite)

function SimpleEnemy:init(x, y, player)
	self.player = player
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/SimpleEnemy"))
	self:setCollideRect(0, 0, self:getSize())

	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.WALL})
	self:add()

	self.cooldown = 0
end

function SimpleEnemy:update()
	self.position = pd.geometry.vector2D.new(self.x, self.y)
	local toPlayer = self.player.PhysicsComponent.Position - self.position
	if toPlayer:magnitude() < 250 and self.cooldown >= 15 then
		local _, _, _, n = self:checkCollisions(self.player.x, self.player.y)
		if n < 1 then
			Bullet(self.x + toPlayer:normalized().x * 30, self.y + toPlayer:normalized().y * 30, toPlayer:normalized() * 5)
			self.cooldown = 0
		end
	end
	self.cooldown += 1
end

function SimpleEnemy:Damage(amount, iFrame)
	self:remove()
end
