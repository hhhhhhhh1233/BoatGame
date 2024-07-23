import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "physicsComponent"
import "mine"
import "bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init(x, y, image, speed, gameManager)
	self.GameManager = gameManager

	self:moveTo(x,y)
	self:setImage(image)

	-- NOTE: Smaller collision size to cover the boat more snugly
	self:setCollideRect(4, 10, 26, 22)
	self.Speed = speed

	self.PhysicsComponent = PhysicsComponent(x, y)

	self.bUnderwater = false
	self.bCanJump = true

	self:setCenter(0.5,1)

	self:setGroups(COLLISION_GROUPS.PLAYER)
	self:setCollidesWithGroups({COLLISION_GROUPS.WALL, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.TRIGGER})

	self.Health = 100
	self.Invincible = 0

	self.bActive = true
end

function Player:Damage(amount, iFrames)
	if self.Invincible > 0 then
		return
	end

	self.Health -= amount
	print(self.Health)
	self.Invincible = iFrames
	if self.Health <= 0 then
		self:setVisible(false)
		self:Respawn()
	end
end

function Player:Respawn()
	self.Health = 100

	self:moveTo(self.GameManager.SpawnX, self.GameManager.SpawnY)
	self.PhysicsComponent.Position = pd.geometry.vector2D.new(self.x, self.y)
	self.PhysicsComponent.Velocity = pd.geometry.vector2D.new(0, 0)

	self.GameManager.water.Height = self.y

	self.GameManager.camera:center(self.x, self.y)


	self:setVisible(true)

	-- self.GameManager:reloadLevel()
end

function Player:DrawHealthBar()
	local aX, aY = gfx.getDrawOffset()

	-- TODO: This should be used instead of the magic numbers below
	local textWidth = gfx.getSystemFont():getTextWidth(self.Health)

	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(-aX + 10 - 3, -aY + 10 - 3, 30 + 3 * 2, 20 + 3 * 2)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(-aX + 10 - 2, -aY + 10 - 2, 30 + 2 * 2, 20 + 2 * 2)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(-aX + 10, -aY + 10, 30, 20)
	gfx.drawText(self.Health, -aX + 13, -aY + 12)
end

function Player:AddForce(Force)
	self.PhysicsComponent:AddForce(Force)
end

function Player:collisionResponse(other)
	if other:isa(DoorTrigger) then
		self.Door = other
		return "overlap"
	end

	if other:isa(Mine) then
		return "overlap"
	else
		return "slide"
	end
end

local direction = 1

function Player:update()
	-- NOTE: Since I moved the center of the player it checks from the bottom of the sprite, should probably check from center
	if self.x > self.GameManager.LevelWidth and self.PhysicsComponent.Velocity.x > 0 then
		self.GameManager:enterRoom(self.Door, "EAST")
	elseif self.x < 0 and self.PhysicsComponent.Velocity.x < 0 then
		self.GameManager:enterRoom(self.Door, "WEST")
	elseif self.y - 16 > self.GameManager.LevelHeight and self.PhysicsComponent.Velocity.y > 0 then
		self.GameManager:enterRoom(self.Door, "SOUTH")
	elseif self.y - 16 < 0 and self.PhysicsComponent.Velocity.y < 0 then
		self.GameManager:enterRoom(self.Door, "NORTH")
	end

	if self.bUnderwater then
		self.bCanJump = true
	end

	if self.bActive then
		if pd.buttonJustPressed(pd.kButtonA) then
			Bullet(self.PhysicsComponent.Position.x + direction * 40, self.PhysicsComponent.Position.y - 5, pd.geometry.vector2D.new(direction * 15, 0))
		end

		if pd.buttonJustPressed(pd.kButtonB) then
			self:AddForce(pd.geometry.vector2D.new(0, -8))
			self.bCanJump = false
		end

		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:setImageFlip(gfx.kImageFlippedX)
			self:AddForce(pd.geometry.vector2D.new(-self.Speed, 0))
			direction = -1
		end

		if pd.buttonIsPressed(pd.kButtonRight) then
			self:setImageFlip(gfx.kImageUnflipped)
			self:AddForce(pd.geometry.vector2D.new(self.Speed, 0))
			direction = 1
		end
	end

	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(-self.PhysicsComponent.Velocity.x * 0.2, 0))

	self.PhysicsComponent:Move(self)

	if self.Invincible > 0 then
		self.Invincible -= 1
	end

end
