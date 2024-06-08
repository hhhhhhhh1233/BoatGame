import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"

import "player"
import "water"
import "mine"

local pd <const> = playdate
local gfx <const> = pd.graphics

PlayerInstance = Player(200, 120, gfx.image.new("images/Boat"), 5)
PlayerInstance:add()

MineInstance = Mine(300, 120, gfx.image.new("images/Mine"))
MineInstance:add()

WaterInstance = Water(100, -60, pd.display.getHeight() - 20, 0.05)

-- Playing around with a tilemap
local tileset,err = gfx.imagetable.new("images/tileset")
assert(err == nil)
local tilemap = gfx.tilemap.new()
tilemap:setImageTable(tileset)

-- TILE MAP OF MY OWN DESIGN
local data = {
	4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,5,
	8,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,6,
	8,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,6,
	8,6,0,0,0,0,0,0,0,0,0,0,4,5,0,0,0,0,0,0,8,6,
	8,6,0,0,0,0,0,0,0,0,0,0,8,6,0,0,0,0,0,0,8,6,
	8,6,0,0,0,0,0,0,0,0,0,0,8,6,0,0,0,0,0,0,8,6,
	8,11,12,12,12,12,12,12,12,12,12,12,13,6,0,0,0,0,0,0,8,6,
	9,2,2,2,2,2,2,2,2,2,2,2,3,6,0,0,0,0,0,0,8,6,
	0,0,0,0,0,0,0,0,0,0,0,0,8,6,0,0,0,0,0,0,8,6,
	0,0,0,0,0,0,0,0,0,0,0,0,8,11,12,12,12,12,12,12,13,6,
	0,0,0,0,0,0,0,0,0,0,0,0,9,2,2,2,2,2,2,2,2,10,
}
tilemap:setTiles(data, 22)

-- Adds collisions for the tilemap
gfx.sprite.addWallSprites(tilemap, {})

-- DEBUG
local width, height = tilemap:getSize()
print(width .. ", " .. height)

function pd.update()
	-- Check the crank and move the water based on input
	WaterInstance:Update()

	-- Set the boat's height to match the water
	-- TODO: Add gravity and make the water push the boat up
	PlayerInstance:moveTo(PlayerInstance.x, WaterInstance.HeightY - 13)

	-- Make the camera track the boat
	gfx.setDrawOffset(pd.display.getWidth()/2 - PlayerInstance.x, pd.display.getHeight()/2 - PlayerInstance.y)

	gfx.sprite.update()
	pd.timer.updateTimers()

	WaterInstance:Draw()

	tilemap:draw(0, 0)
end
