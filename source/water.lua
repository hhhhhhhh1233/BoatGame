import "CoreLibs/crank"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends()

local DisplayHeight = pd.display.getHeight()
local DisplayWidth = pd.display.getWidth()

local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

function Water:init(Height, Bound, RateOfChange)
	self.Height = Height
	self.Bound = Bound
	self.HeightY = DisplayHeight - self.Height
	self.RateOfChange = RateOfChange
end


function Water:Update()
	local change, acceleratedChange = pd.getCrankChange()
	self.Height += change * self.RateOfChange
	self.Height = clamp(self.Height, self.Bound, DisplayHeight - self.Bound)
end

function Water:Draw()
	self.HeightY = DisplayHeight - self.Height
	gfx.fillRect(0, self.HeightY, DisplayWidth, self.Height)
end

