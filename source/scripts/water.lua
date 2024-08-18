import "CoreLibs/crank"

import "scripts/utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends(gfx.sprite)

function Water:init(Height, Width, LowerBound, UpperBound, RateOfChange)
	print(Height)
	self.height = Height
	self.width = Width
	self.lowerBound = LowerBound
	self.upperBound = UpperBound
	self.rateOfChange = RateOfChange
	self.bActive = false
	-- self:setGroups(COLLISION_GROUPS.WATER)
	-- self:setCollidesWithGroups(COLLISION_GROUPS.ENEMY)
	-- self:setCollideRect(0, self.Height, self.Width, 3)
	self:add()
end

-- function Water:collisionResponse(other)
-- 	return "overlap"
-- 	-- if other:isa(PondSkater) then
-- 	-- 	return "slide"
-- 	-- else
-- 	-- 	return "overlap"
-- 	-- end
-- end

function Water:update()
	if self.bActive then
		local change, _ = pd.getCrankChange()
		self.height -= change * self.rateOfChange
		self.height = Clamp(self.height, self.lowerBound, self.upperBound)
	end
	-- self:moveTo(0, self.Height - 145)

	-- Draw the water height to screen
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, self.height, self.width, 2)
end
