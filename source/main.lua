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

PlayerInstance = Player(200, 120, gfx.image.new("images/Boat"), 1)
PlayerInstance:add()

MineInstance = Mine(300, 120, gfx.image.new("images/Mine"))
MineInstance:add()

WaterInstance = Water(100, 20, pd.display.getHeight() - 20, 0.05)

-- Playing around with a tilemap
local tileset,err = gfx.imagetable.new("images/tileset")
assert(err == nil)
local tilemap = gfx.tilemap.new()
tilemap:setImageTable(tileset)

-- TILE MAP OF MY OWN DESIGN
local data = {
	1,2,3,4,5,
	6,7,8,9,10,
	11,12,13,0,0
}
tilemap:setTiles(data, 5)

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
