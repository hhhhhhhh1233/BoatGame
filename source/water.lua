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
end


function Water:Update()
	local change, _ = pd.getCrankChange()
	self.Height -= change * self.RateOfChange
	self.Height = Clamp(self.Height, self.LowerBound, self.UpperBound)
	-- Draw the water height to screen
	gfx.fillRect(0, self.Height, self.Width, 2)
end
