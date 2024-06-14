import "CoreLibs/crank"

import "utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends()

local DisplayWidth = pd.display.getWidth()

function Water:init(Height, Width, LowerBound, UpperBound, RateOfChange)
	self.Height = Height
	self.Width = Width
	self.LowerBound = LowerBound
	self.UpperBound = UpperBound
	self.RateOfChange = RateOfChange
end


function Water:Update()
	local change, acceleratedChange = pd.getCrankChange()
	self.Height -= change * self.RateOfChange
	self.Height = Clamp(self.Height, self.LowerBound, self.UpperBound)
end

function Water:Draw()
	gfx.fillRect(0, self.Height, DisplayWidth * 1.6, 2)
end

