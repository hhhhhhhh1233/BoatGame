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
end

function MainMenuLoop()
	gfx.clear(gfx.kColorWhite)

	update_timers()
	sprite_update()
	pd.frameTimer.updateTimers()

	if mainMenu.done then
		SceneManager = Scene(mainMenu.loadGame)
		pd.update = MainGameLoop
	end
end

pd.update = MainMenuLoop

