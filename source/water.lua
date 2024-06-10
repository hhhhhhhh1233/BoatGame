import "CoreLibs/crank"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends()

local DisplayHeight = pd.display.getHeight()
local DisplayWidth = pd.display.getWidth()

local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

function Water:init(Height, LowerBound, UpperBound, RateOfChange)
	self.Height = Height
	self.LowerBound = LowerBound
	self.UpperBound = UpperBound
	self.RateOfChange = RateOfChange
end


function Water:Update()
	local change, acceleratedChange = pd.getCrankChange()
	self.Height -= change * self.RateOfChange
	self.Height = clamp(self.Height, self.LowerBound, self.UpperBound)
end

function Water:Draw()
	gfx.fillRect(0, self.Height, DisplayWidth * 1.6, (self.UpperBound - self.LowerBound) - self.Height)
end

