local pd <const> = playdate
local gfx <const> = pd.graphics

class('UI').extends(gfx.sprite)

function UI:init()
	self:setImage(gfx.image.new(400, 240))
	self:setIgnoresDrawOffset(true)
	self:setCenter(0, 0)
	self:setZIndex(1000)
	self:add()
end

function UI:drawImageAt(image, x, y)
	gfx.lockFocus(self:getImage())
	image:draw(x, y)
	gfx.unlockFocus()
end

function UI:drawImageAtWorld(image, x, y)
	self:setIgnoresDrawOffset(false)
	gfx.lockFocus(self:getImage())
	image:draw(x, y)
	gfx.unlockFocus()
	self:setIgnoresDrawOffset(true)
end
