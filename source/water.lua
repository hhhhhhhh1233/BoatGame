import "CoreLibs/crank"

import "utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends()

function Water:init(Height, Width, LowerBound, UpperBound, RateOfChange)
	self.Height = Height
	self.Width = Width
	self.LowerBound = LowerBound
	self.UpperBound = UpperBound
	self.RateOfChange = RateOfChange
	self.bActive = false
end

function Water:Update()
	if self.bActive then
		local change, _ = pd.getCrankChange()
		self.Height -= change * self.RateOfChange
		self.Height = Clamp(self.Height, self.LowerBound, self.UpperBound)
	end

	-- Draw the water height to screen
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, self.Height, self.Width, 2)
end
