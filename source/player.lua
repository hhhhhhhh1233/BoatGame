import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init(x, y, image, speed)
	self:setImage(image)
	self:moveTo(x,y)

	self.Speed = speed
end

function Player:update()
	if pd.buttonIsPressed(pd.kButtonLeft) then
		self:moveBy(-self.Speed, 0)
		self:setImageFlip(gfx.kImageFlippedX)
	end
	if pd.buttonIsPressed(pd.kButtonRight) then
		self:moveBy(self.Speed, 0)
		self:setImageFlip(gfx.kImageUnflipped)
	end
end
