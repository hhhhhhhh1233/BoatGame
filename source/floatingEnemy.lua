import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "bullet"
import "physicsComponent"

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
	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(0, 0.5))
	self.PhysicsComponent:Move(self)
	local toPlayer = self.player.PhysicsComponent.Position - self.PhysicsComponent.Position
	if toPlayer:magnitude() < 250 and self.cooldown >= 15 then
		local _, _, _, n = self:checkCollisions(self.player.x, self.player.y)
		if n < 1 and self.player.bActive then
			Bullet(self.x + toPlayer:normalized().x * 30, self.y + toPlayer:normalized().y * 30, toPlayer:normalized() * 5)
			self.cooldown = 0
		end
	end
	self.cooldown += 1
end

function FloatingEnemy:Damage(amount, iFrame)
	self:remove()
end