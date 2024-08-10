local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/entities/flyingBug"

class('Hive').extends(gfx.sprite)

function Hive:init(x, y)
	self:setImage(gfx.image.new("images/Hive"))
	self:moveTo(x + 16, y + 16)
	self.bugs = {}
	self:add()
	self.bCanAddBug = true
end

function Hive:update()
	if #self.bugs < 3 and self.bCanAddBug then
		print("Added bug")
		local bug = FlyingBug(self.x, self.y)
		table.insert(self.bugs, bug)
		self.bCanAddBug = false
		pd.frameTimer.performAfterDelay(60, function ()
			self.bCanAddBug = true
		end)
	end
end

