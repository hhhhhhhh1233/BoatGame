local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/entities/flyingBug"

class('Hive').extends(gfx.sprite)

function Hive:init(x, y, water)
	self.water = water
	self:setImage(gfx.image.new("images/Hive"))
	self:moveTo(x + 16, y + 16)
	self.bugsActive = 0
	self:add()
	self.bCanAddBug = true
end

function Hive:removeBug()
	self.bugsActive -= 1
end

function Hive:update()
	local bUnderwater = self.y > self.water.height
	if self.bugsActive < 3 and self.bCanAddBug and not bUnderwater then
		FlyingBug(self.x, self.y, self, self.water)
		self.bugsActive += 1
		self.bCanAddBug = false
		pd.frameTimer.performAfterDelay(60, function ()
			self.bCanAddBug = true
		end)
	end
end

