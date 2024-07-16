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

	if pd.buttonJustPressed(pd.kButtonA) then
		Bullet(self.PhysicsComponent.Position.x +  direction * 20, self.PhysicsComponent.Position.y - 5, direction * 15)
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

	self.PhysicsComponent:AddForce(pd.geometry.vector2D.new(-self.PhysicsComponent.Velocity.x * 0.2, 0))

	self.PhysicsComponent:Move(self)
end
