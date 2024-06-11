local pd <const> = playdate
local gfx <const> = pd.graphics

class('Camera').extends()

-- TODO: DEFINITELY MAKE THIS IN A GENERAL FILE INSTEAD OF DEFINING IT ALL OVER THE PLACE
local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

function Camera:init(x, y, xMin, yMin, xMax, yMax)
	self.x = x
	self.y = y

	self.xMin = xMin
	self.yMin = yMin

	self.xMax = xMax
	self.yMax = yMax
end

local screenHalfWidth = pd.display.getWidth()/2
local screenHalfHeight = pd.display.getHeight()/2

-- TODO: Incorporate the camera bounds
function Camera:center(x, y)
	-- local targetX = clamp(screenHalfWidth - x, self.xMin, self.xMax)
	-- local targetY = clamp(screenHalfHeight - y, self.yMin, self.yMax)

	gfx.setDrawOffset(screenHalfWidth - x, screenHalfHeight - y)
	-- gfx.setDrawOffset(targetX, targetY)

	self.x = x
	self.y = y
end

function Camera:lerp(x, y, speed)
	local dx = pd.math.lerp(self.x, x, speed)
	local dy = pd.math.lerp(self.y, y, speed)

	self:center(dx, dy)
end
