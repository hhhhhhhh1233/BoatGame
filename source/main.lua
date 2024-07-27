COLLISION_GROUPS = {
	PLAYER = 1,
	ENEMY = 2,
	PROJECTILE = 3,
	WALL = 4,
	EXPLOSIVE = 5,
	TRIGGER = 6,
	PICKUPS = 7
}

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"
import "CoreLibs/ui"

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

local SceneManager = Scene(200, 120)
local PlayerInstance = SceneManager.player

gfx.setBackgroundColor(gfx.kColorClear)

local i = 0
pd.timer.keyRepeatTimerWithDelay(0, 800, function ()
	i += 1
	if i > 1 then
		i = 0
	end
end)

for index, value in ipairs(gfx.sprite.getAllSprites()) do
	print(value.className..", z-index: "..value:getZIndex())
end

function pd.update()
	gfx.clear(gfx.kColorWhite)

	-- Check the crank and move the water based on input
	SceneManager.water:Update()

	-- Player Gravity
	local Gravity = 0.5
	if PlayerInstance.PhysicsComponent.bBuoyant or not PlayerInstance.bUnderwater then
		PlayerInstance:AddForce(vector2D_new(0, Gravity))
	end

	SceneManager:UpdatePhysicsComponentsBuoyancy()

	-- NOTE: This sucks
	PlayerInstance.bUnderwater = (PlayerInstance.PhysicsComponent.Position.y) > SceneManager.water.Height

	-- Make the camera track the boat
	SceneManager.camera:lerp(PlayerInstance.x, PlayerInstance.y, 0.2)

	sprite_update()
	update_timers()

	SceneManager.player:DrawHealthBar()

	-- NOTE: This blurs the image at the bottom, but I think this might have terrible performance on the actual playdate so keep that in mind if you ever get your hands on one
	if PlayerInstance.bActive then -- NOTE: This is so the text is still legible when choosing ability, make the water blur per sprite instead of the whole image to solve this better
		local ox, oy = gfx.getDrawOffset()
		local blurred = gfx.getWorkingImage():blurredImage(1, 1, gfx.image.kDitherTypeBayer4x4, true)
		local ix, iy = blurred:getSize()
		local waterMask = gfx.image.new(ix, iy)
		gfx.pushContext(waterMask)
		gfx.fillRect(2, SceneManager.water.Height + oy + 2 - i, 400 - 2, 400)
		gfx.popContext()
		blurred:setMaskImage(waterMask)
		local width = pd.display.getWidth()
		local xOffset = (ix - width) / 2
		blurred:drawAnchored(-ox - xOffset, -oy + i, 0, 0)
	end
end
