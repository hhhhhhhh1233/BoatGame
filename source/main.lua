import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "player"
import "water"
import "mine"

local pd <const> = playdate
local gfx <const> = pd.graphics

PlayerInstance = Player(200, 120, gfx.image.new("images/Boat"), 1)
PlayerInstance:add()

MineInstance = Mine(300, 120, gfx.image.new("images/Mine"))
MineInstance:add()

WaterInstance = Water(100, 20, 0.05)

function pd.update()
	-- Check the crank and move the water based on input
	WaterInstance:Update()

	-- Set the boat's height to match the water
	PlayerInstance:moveTo(PlayerInstance.x, WaterInstance.HeightY - 13)

	gfx.sprite.update()
	pd.timer.updateTimers()

	WaterInstance:Draw()
end
