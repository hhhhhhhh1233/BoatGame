local pd <const> = playdate
local gfx <const> = pd.graphics

class('Darkness').extends(gfx.sprite)

function Darkness:init(player)
	self.player = player
	self:setImage(gfx.image.new(400, 240, gfx.kColorBlack))
	self:setIgnoresDrawOffset(true)
	self:setCenter(0, 0)

	self:setZIndex(500)
	self:add()
end

function Darkness:update()
	self:setImage(gfx.image.new(400, 240, gfx.kColorBlack))

	gfx.setColor(gfx.kColorBlack)
	local stencilImage = gfx.image.new(400, 240, gfx.kColorWhite)
	local ox, oy = gfx.getDrawOffset()
	gfx.lockFocus(stencilImage)
	gfx.fillCircleAtPoint(ox + self.player.x, oy + self.player.y, 50)
	gfx.unlockFocus()
	self:setStencilImage(stencilImage)
end
