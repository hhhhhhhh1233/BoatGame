import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "player"
import "water"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- local WaterHeight = 100

PlayerInstance = Player(200, 120, gfx.image.new("images/Boat"), 1)
PlayerInstance:add()

WaterInstance = Water(100, 20, 0.05)

-- local function clamp(value, min, max)
-- 	return math.min(math.max(value, min), max)
-- end

-- local DisplayHeight = pd.display.getHeight()
-- local DisplayWidth = pd.display.getWidth()

-- How close the water can get to the edge of the screen
-- local WaterBound = 20

function pd.update()
	-- Gets input from crank and changes water height and boat y position
	-- local change, acceleratedChange = pd.getCrankChange()
	-- WaterHeight += change/10

	-- Limit the Water to a specific range
	-- WaterHeight = clamp(WaterHeight, WaterBound, DisplayHeight - WaterBound)
	-- local WaterLevelYPosition = DisplayHeight - WaterHeight

	-- Set the boat's height to match the water
	WaterInstance:Update()
	PlayerInstance:moveTo(PlayerInstance.x, WaterInstance.HeightY - 13)

	gfx.sprite.update()
	pd.timer.updateTimers()

	WaterInstance:Draw()

	-- Draws the water
	-- gfx.fillRect(0, WaterLevelYPosition, DisplayWidth, WaterHeight)
end
