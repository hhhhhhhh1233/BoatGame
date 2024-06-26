COLLISION_GROUPS = {
	PLAYER = 1,
	ENEMY = 2,
	PROJECTILE = 3,
	WALL = 4,
	EXPLOSIVE = 5
}

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"

-- Utilities
import "camera"
import "buoyancy"

-- Game Objects
import "player"
import "water"
import "mine"
import "scene"

local pd <const> = playdate
local gfx <const> = pd.graphics

local vector2D_new <const> = pd.geometry.vector2D.new
local sprite_update <const> = gfx.sprite.update
local update_timers <const> = pd.timer.updateTimers

-- Playing around with a tilemap
local tileset,err = gfx.imagetable.new("images/tileset")
assert(err == nil)

-- TILE MAP OF MY OWN DESIGN
local data = {
	7,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,7,
	7,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,7,
	7,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,7,
	7,6,0,0,0,0,0,0,0,0,0,0,4,5,0,0,4,12,5,0,8,7,
	7,6,0,0,0,0,0,0,0,0,0,0,8,6,0,0,9,2,10,0,8,7,
	7,6,0,0,0,0,0,0,0,0,0,0,8,6,0,0,0,0,0,0,8,7,
	7,11,12,12,12,12,12,12,12,12,12,12,13,6,0,0,0,0,0,0,8,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7,6,0,0,0,0,0,0,8,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7,6,0,0,0,0,0,0,8,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7,11,12,12,12,12,12,12,13,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
}

local data2 = {
	7,7,0,0,0,0,0,0,0,0,0,7,7,
	7,7,0,0,0,0,0,0,0,0,0,7,7,
	7,7,0,0,0,0,0,0,0,0,0,7,7,
	7,7,0,0,0,0,0,0,0,0,0,7,7,
	7,7,0,0,0,0,0,0,0,0,0,7,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7,
	7,7,7,7,7,7,7,7,7,7,7,7,7
}

local scene = Scene(tileset, data, 22, 200, 120)
local PlayerInstance = scene.player

MineInstance = Mine(300, 120, gfx.image.new("images/Mine"))
MineInstance:add()

local mapPixelWidth, mapPixelHeight = scene.tilemap:getPixelSize()
WaterInstance = Water(100, mapPixelWidth, 20, mapPixelHeight, 0.05)

-- Limit camera to the map size
-- CameraInstance = Camera(PlayerInstance.x, PlayerInstance.y, 0, 0, mapPixelWidth, mapPixelHeight)

gfx.setBackgroundColor(gfx.kColorClear)

function pd.update()
	gfx.clear(gfx.kColorWhite)
	-- Check the crank and move the water based on input
	WaterInstance:Update()

	-- Player Gravity
	local Gravity = 0.5
	PlayerInstance:AddForce(vector2D_new(0, Gravity))

	local buoyancyForces = CalculateBuoyancy(WaterInstance.Height, PlayerInstance.y, 50, 0.3, 5.5, PlayerInstance.PhysicsComponent)
	PlayerInstance:AddForce(buoyancyForces)

	buoyancyForces = CalculateBuoyancy(WaterInstance.Height, MineInstance.y, 50, 0.5, 3.5, MineInstance.PhysicsComponent)
	MineInstance.PhysicsComponent:AddForce(buoyancyForces)

	-- NOTE: This sucks
	PlayerInstance.bUnderwater = (PlayerInstance.PhysicsComponent.Position.y) > WaterInstance.Height

	-- Make the camera track the boat
	scene.camera:lerp(PlayerInstance.x, PlayerInstance.y, 0.2)

	sprite_update()
	update_timers()

	if pd.buttonJustPressed(pd.kButtonB) then
		scene:loadLevel(data2, 13)
	end
	if pd.buttonJustPressed(pd.kButtonA) then
		scene:loadLevel(data, 22)
	end

	scene:draw()
end
