import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "scripts/physicsComponent"

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

	self.PhysicsComponent = PhysicsComponent(x, y, 10)

	self.bUnderwater = false
	self.bCanJump = true

	self:setCenter(0.5,1)

	self:setGroups(COLLISION_GROUPS.PLAYER)
	self:setCollidesWithGroups({COLLISION_GROUPS.WALL, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.TRIGGER, COLLISION_GROUPS.PICKUPS})

	self.Health = 100
	self.Invincible = 0
	self.coins = 0
	self.explosionMeter = 0

	self.bActive = true

	self.direction = 1

	self.AbilityA = nil
	self.AbilityB = nil
	self.PassiveAbility = nil

	self.hurtSound = pd.sound.sampleplayer.new("sounds/Hurt")

	self.lightRadius = 50
end

function Player:Damage(amount, iFrames)
	if self.Invincible > 0 then
		return
	end

	self.hurtSound:play()

	self:getImage():setInverted(true)
	pd.timer.performAfterDelay(75, function ()
		self:getImage():setInverted(false)
	end)
	self.Health -= amount
	self.Invincible = iFrames
	if self.Health <= 0 then
		self:setVisible(false)
		self.bActive = false
		self:remove()
		pd.timer.performAfterDelay(1000, function ()
			self:Respawn()
		end)
	end
end

function Player:Respawn()
	self:add()
	self.Health = 100

	self.GameManager.playerCorpse = PlayerCorpse(self.x, self.y, self.GameManager.currentLevel, self.GameManager, self.coins, self.direction)
	self.coins = 0

	if self.savePoint then
		print(self.savePoint.x, self.savePoint.y)
		self.GameManager:goToLevel(self.savePoint.level)
		self:moveTo(self.savePoint.x, self.savePoint.y + 8)
	else
		self.GameManager:reloadLevel()
		self:moveTo(self.GameManager.SpawnX, self.GameManager.SpawnY)
	end

	self.PhysicsComponent.Position = pd.geometry.vector2D.new(self.x, self.y)
	self.PhysicsComponent.Velocity = pd.geometry.vector2D.new(0, 0)
	self.PhysicsComponent.Acceleration = pd.geometry.vector2D.new(0, 0)

	self.GameManager.water.Height = self.y
	self.GameManager.water.Width = self.GameManager.LevelWidth

	self.GameManager.camera:center(self.x, self.y)

	self:setVisible(true)
	self.bActive = true

end

function Player:DrawHealthBar()
	-- TODO: This should be used instead of the magic numbers below
	-- local textWidth = gfx.getSystemFont():getTextWidth(self.Health)

	local img = gfx.image.new(100, 100)
	gfx.lockFocus(img)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(10 - 3,10 - 3, 30 + 3 * 2, 20 + 3 * 2)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(10 - 2, 10 - 2, 30 + 2 * 2, 20 + 2 * 2)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(10, 10, 30, 20)
	gfx.drawText(math.floor(self.Health), 13, 12)

	-- NOTE: This will draw how many coins you have
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(10 - 3, 50 - 3, 30 + 3 * 2, 20 + 3 * 2)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(10 - 2, 50 - 2, 30 + 2 * 2, 20 + 2 * 2)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(10, 50, 30, 20)
	gfx.drawText(math.floor(self.coins), 20, 52)
	gfx.unlockFocus()
	UISystem:drawImageAt(img, 0, 0)
end

function Player:AddForce(Force)
	self.PhysicsComponent:AddForce(Force)
end

function Player:collisionResponse(other)
	if other:isa(DoorTrigger) then
		self.Door = other
		return "overlap"
	end

	if other:isa(SavePoint) then
		return "overlap"
	end

	if other:isa(Fish) then
		return "overlap"
	elseif other:isa(PondSkater) then
		return "overlap"
	elseif other:isa(FlyingBug) then
		return "overlap"
	end

	if other:isa(MovingPlatform) then
		return "overlap"
	end

	if other:isa(AbilityPickup) then
		other:pickup(self)
		self.GameManager:collect(other.entity.iid)
		return "overlap"
	end

	if other:isa(Lantern) then
		other:pickup(self)
		self.GameManager:collect(other.entity.iid)
		return "overlap"
	end

	if other:isa(WaterWheel) then
		other:pickup(self)
		self.GameManager:collect(other.entity.iid)
		return "overlap"
	end
	if other:isa(Coin) then
		other:pickup(self)
		self.GameManager:collect(other.entity.iid)
		return "overlap"
	end
	if other:isa(PlayerCorpse) then
		other:pickup(self)
		return "overlap"
	end

	if other:isa(Detector) then
		return "overlap"
	end

	if other:isa(SincosEnemy) then
		return "overlap"
	end

	if other:isa(BlockedWall) then
		if other:clear(self) then
			return "overlap"
		else
			return "slide"
		end
	end

	if other:isa(Mine) or other:isa(MooredMine) then
		return "overlap"
	else
		return "slide"
	end
end

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

	local Gravity = 0.5
	if self.PhysicsComponent.bBuoyant or not self.bUnderwater then
		self.PhysicsComponent:AddForce(0, Gravity)
	end

	if self.bActive then
		if self.AbilityA then
			self.AbilityA(self, pd.kButtonA)
		end

		if self.AbilityB then
			self.AbilityB(self, pd.kButtonB)
		end

		if self.PassiveAbility then
			self:PassiveAbility()
		end

		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:setImageFlip(gfx.kImageFlippedX)
			self.PhysicsComponent.Velocity.x = -self.Speed
			self.direction = -1
		end

		if pd.buttonIsPressed(pd.kButtonRight) then
			self:setImageFlip(gfx.kImageUnflipped)
			self.PhysicsComponent.Velocity.x = self.Speed
			self.direction = 1
		end
	end

	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(-self.PhysicsComponent.Velocity.x * 0.2, 0))

	self.PhysicsComponent:Move(self)

	if self.Invincible > 0 then
		self.Invincible -= 1
	end
end

function Player:setAbilityA(func, name)
	self.AbilityA = func
	self.AbilityAName = name
	print(self.AbilityA)
end

function Player:setAbilityB(func, name)
	self.AbilityB = func
	self.AbilityBName = name
	print(self.AbilityB)
end

function Player:setPassive(func, name)
	self.PassiveAbility = func
	self.PassiveAbilityName = name
	print(self.PassiveAbility)
end
