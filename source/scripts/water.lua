import "CoreLibs/crank"

import "scripts/utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends(gfx.sprite)

function Water:init(Height, Width, LowerBound, UpperBound, RateOfChange)
	self.Height = Height
	self.Width = Width
	self.LowerBound = LowerBound
	self.UpperBound = UpperBound
	self.RateOfChange = RateOfChange
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
		self.Height -= change * self.RateOfChange
		self.Height = Clamp(self.Height, self.LowerBound, self.UpperBound)
	end
	-- self:moveTo(0, self.Height - 145)

	-- Draw the water height to screen
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, self.Height, self.Width, 2)
end
