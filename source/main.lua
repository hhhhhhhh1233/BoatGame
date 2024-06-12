import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"

import "camera"
import "player"
import "water"
import "mine"

local pd <const> = playdate
local gfx <const> = pd.graphics

PlayerInstance = Player(200, 120, gfx.image.new("images/Boat"), 2)
PlayerInstance:add()

MineInstance = Mine(300, 120, gfx.image.new("images/Mine"))
MineInstance:add()

WaterInstance = Water(100, 20, pd.display.getHeight() + 120, 0.05)


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
	8,7,7,7,7,7,7,7,7,7,7,7,7,6,0,0,0,0,0,0,8,6,
	8,7,7,7,7,7,7,7,7,7,7,7,7,6,0,0,0,0,0,0,8,6,
	8,7,7,7,7,7,7,7,7,7,7,7,7,11,12,12,12,12,12,12,13,6,
	9,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,10,
}
tilemap:setTiles(data, 22)

-- Limit camera to the map size
local mapPixelWidth, mapPixelHeight = tilemap:getPixelSize()
CameraInstance = Camera(PlayerInstance.x, PlayerInstance.y, 0, 0, mapPixelWidth, mapPixelHeight)

-- Adds collisions for the tilemap
gfx.sprite.addWallSprites(tilemap, {})

local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

-- NOTE: Returns the buoyancy force and the water drag in that order
local function CalculateBuoyancy(WaterHeight, ObjectHeight, WaterPixelDepth, WaterDrag, buoyantForce)
	-- Deals with player buoyancy
	local DesiredHeight = WaterHeight - 13
	local DirectionToWater = (ObjectHeight - DesiredHeight)
	local DirectionToWaterNormalized = DirectionToWater / math.abs(DirectionToWater)
	if DirectionToWater == 0 then
		DirectionToWaterNormalized = 0
	end

	-- Buoyancy values
	local displacementNum = clamp(math.abs(DirectionToWater), 0, WaterPixelDepth) / WaterPixelDepth

	-- Applies buoyancy forces and water drag
	if DirectionToWater > 0 then
		return pd.geometry.vector2D.new(0, -DirectionToWaterNormalized * buoyantForce * displacementNum), pd.geometry.vector2D.new(0, -PlayerInstance.Velocity.y * WaterDrag)
	end

	return pd.geometry.vector2D.new(0, 0), pd.geometry.vector2D.new(0, 0)
end

function pd.update()
	-- Check the crank and move the water based on input
	WaterInstance:Update()

	-- Player Gravity
	local Gravity = 0.5
	PlayerInstance:AddForce(pd.geometry.vector2D.new(0, Gravity))

	local buoyancyForce, waterDrag =  CalculateBuoyancy(WaterInstance.Height, PlayerInstance.y, 50, 0.3, 5.5)
	PlayerInstance:AddForce(buoyancyForce + waterDrag)


	-- Make the camera track the boat
	CameraInstance:lerp(PlayerInstance.x, PlayerInstance.y, 0.2)

	gfx.sprite.update()
	pd.timer.updateTimers()

	WaterInstance:Draw()

	tilemap:draw(0, 0)
end
