COLLISION_GROUPS = {
	PLAYER = 1,
	ENEMY = 2,
	PROJECTILE = 3,
	WALL = 4,
	EXPLOSIVE = 5,
	TRIGGER = 6
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

local scene = Scene(200, 120)
local PlayerInstance = scene.player

MineInstance = Mine(300, 120, gfx.image.new("images/Mine"))
MineInstance:add()

gfx.setBackgroundColor(gfx.kColorClear)

function pd.update()
	gfx.clear(gfx.kColorWhite)
	-- Check the crank and move the water based on input
	scene.water:Update()

	-- Player Gravity
	local Gravity = 0.5
	PlayerInstance:AddForce(vector2D_new(0, Gravity))

	local buoyancyForces = CalculateBuoyancy(scene.water.Height, PlayerInstance.y, 50, 0.3, 5.5, PlayerInstance.PhysicsComponent)
	PlayerInstance:AddForce(buoyancyForces)

	buoyancyForces = CalculateBuoyancy(scene.water.Height, MineInstance.y, 50, 0.5, 3.5, MineInstance.PhysicsComponent)
	MineInstance.PhysicsComponent:AddForce(buoyancyForces)

	-- NOTE: This sucks
	PlayerInstance.bUnderwater = (PlayerInstance.PhysicsComponent.Position.y) > scene.water.Height

	-- Make the camera track the boat
	scene.camera:lerp(PlayerInstance.x, PlayerInstance.y, 0.2)

	sprite_update()
	update_timers()
end
