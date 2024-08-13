local pd <const> = playdate
local gfx <const> = pd.graphics

class('SincosEnemy').extends(gfx.sprite)

function SincosEnemy:init(x, y)
	self:moveTo(x + 16, y + 8)
	self:setImage(gfx.image.new("images/SincosEnemy"))
	self:setCollideRect(0, 0, 32, 16)
	self:add()
end

function SincosEnemy:update()

end
