import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Bullet').extends(gfx.sprite)

function Bullet:init(x, y, direction)
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/Bullet"))
	self:setCollideRect(4, 4, 8, 8)

	self.x = x
	self.y = y
	self.direction = direction

	self:setGroups(COLLISION_GROUPS.PROJECTILE)
	self:setCollidesWithGroups({COLLISION_GROUPS.WALL, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.ENEMY})

	self:add()
end

function Bullet:update()
	local x, y, c, n = self:moveWithCollisions(self.x + self.direction, self.y)

	if n >= 1 then
		print("Hit")
		self:remove()
	end
end
