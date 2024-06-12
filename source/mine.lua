import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Mine').extends(gfx.sprite)

function Mine:init(x, y, image)
	self:moveTo(x, y)
	self:setImage(image)
	self:setCollideRect(0, 0, self:getSize())
end
