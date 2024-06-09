import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init(x, y, image, speed)
	self:moveTo(x,y)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
	self.Speed = speed
end

function Player:update()
	if pd.buttonIsPressed(pd.kButtonLeft) then
		self:moveWithCollisions(self.x - self.Speed, self.y)
		self:setImageFlip(gfx.kImageFlippedX)
	end

	if pd.buttonIsPressed(pd.kButtonRight) then
		self:moveWithCollisions(self.x + self.Speed, self.y)
		self:setImageFlip(gfx.kImageUnflipped)
	end
end
