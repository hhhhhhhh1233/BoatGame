local pd <const> = playdate
local gfx <const> = pd.graphics

class('Block16').extends(gfx.sprite)

function Block16:init(x, y)
	self:moveTo(x + 8, y + 8)
	self:setImage(gfx.image.new("images/16Block"))
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollideRect(0, 0, 16, 16)
	self:add()
end
