COLLISION_GROUPS = {
	PLAYER = 1,
	ENEMY = 2,
	PROJECTILE = 3,
	WALL = 4,
	EXPLOSIVE = 5,
	TRIGGER = 6,
	PICKUPS = 7,
	WATER = 8
}

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"
import "CoreLibs/ui"

-- Utilities
import "scripts/camera"
import "scripts/buoyancy"
import "scripts/saves"

-- Game Objects
import "scripts/entities/player"
import "scripts/water"
import "scripts/entities/mine"
import "scripts/scene"
import "scripts/entities/ui"
import "scripts/miniMapViewer"
import "scripts/mainMenu"


local pd <const> = playdate
local gfx <const> = pd.graphics

local sprite_update <const> = gfx.sprite.update
local update_timers <const> = pd.timer.updateTimers

UISystem = UI()
SceneManager = nil

math.randomseed(playdate.getSecondsSinceEpoch())

gfx.setBackgroundColor(gfx.kColorClear)

local i = 0
pd.timer.keyRepeatTimerWithDelay(0, 800, function ()
	i += 1
	if i > 1 then
		i = 0
	end
end)

local menu = pd.getSystemMenu()
local menuItem, error = menu:addMenuItem("Clear Save", ClearSave)
local menuItem2, error = menu:addMenuItem("View Map", function ()
	SceneManager:DeactivatePhysicsComponents()
	MiniMapViewer(SceneManager)
end)
local menuItem3, error = menu:addMenuItem("Debug Rooms", function ()
	SceneManager:goToLevel("DebugRoom_MPlatform")
end)


local mainMenu = MainMenu()

function MainGameLoop()
	gfx.clear(gfx.kColorWhite)

	UISystem:clear()

	SceneManager:UpdatePhysicsComponentsBuoyancy()

	update_timers()
	sprite_update()
	pd.frameTimer.updateTimers()

	pd.drawFPS(0, 0)

	-- local ox, oy = gfx.getDrawOffset()
	-- if SceneManager.player.bActive then -- NOTE: This is so the text is still legible when choosing ability, make the water blur per sprite instead of the whole image to solve this better
	-- 	local blurred = gfx.getWorkingImage():blurredImage(1, 1, gfx.image.kDitherTypeBayer4x4, true)
	-- 	local ix, iy = blurred:getSize()
	-- 	local waterMask = gfx.image.new(ix, iy)
	-- 	gfx.pushContext(waterMask)
	-- 	gfx.setColor(gfx.kColorWhite)
	-- 	gfx.fillRect(2, SceneManager.water.height + oy + 2 - i, 400 - 2, 400)
	-- 	gfx.popContext()
	-- 	blurred:setMaskImage(waterMask)
	-- 	local width = pd.display.getWidth()
	-- 	local xOffset = (ix - width) / 2
	-- 	blurred:drawAnchored(-ox - xOffset, -oy + i, 0, 0)
	-- end

	-- UISystem:update()
	-- gfx.fillRect(2, SceneManager.water.height + oy + 2 - i, 400 - 2, 400)

end


function MainMenuLoop()
	gfx.clear(gfx.kColorWhite)

	update_timers()
	sprite_update()
	pd.frameTimer.updateTimers()

	if mainMenu.done then
		LDtk.load("levels/world.ldtk", true)
		SceneManager = Scene(mainMenu.loadGame)
		pd.update = MainGameLoop
	end
end

pd.update = MainMenuLoop

