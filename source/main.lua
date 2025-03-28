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

	-- NOTE: Moves the player to a new room if they leave the bounds
	-- This used to be in the player but lead to some weird behavior 
	-- with other sprites having one more frame to update even though 
	-- they should have been deleted
	if SceneManager.player.x > SceneManager.LevelWidth and SceneManager.player.PhysicsComponent.velocity.x > 0 then
		SceneManager:enterRoom(SceneManager.player.Door, "EAST")
	elseif SceneManager.player.x < 0 and SceneManager.player.PhysicsComponent.velocity.x < 0 then
		SceneManager:enterRoom(SceneManager.player.Door, "WEST")
	elseif SceneManager.player.y - 16 > SceneManager.LevelHeight and SceneManager.player.PhysicsComponent.velocity.y > 0 then
		SceneManager:enterRoom(SceneManager.player.Door, "SOUTH")
	elseif SceneManager.player.y - 16 < 0 and SceneManager.player.PhysicsComponent.velocity.y < 0 then
		SceneManager:enterRoom(SceneManager.player.Door, "NORTH")
	end

	SceneManager:UpdatePhysicsComponentsBuoyancy()

	update_timers()
	sprite_update()
	pd.frameTimer.updateTimers()

	pd.drawFPS(0, 0)
end

-- NOTE: In the simulator load the ldtk instantly so that the lua files exist without having to do anything
if pd.isSimulator then
	LDtk.load("levels/world.ldtk", false)
	LDtk.export_to_lua_files()
end

function MainMenuLoop()
	gfx.clear(gfx.kColorWhite)

	update_timers()
	sprite_update()
	pd.frameTimer.updateTimers()

	if mainMenu.done then
		-- NOTE: On real hardware don't bother loading until someone starts the game
		if not pd.isSimulator then
			LDtk.load("levels/world.ldtk", true)
		end
		SceneManager = Scene(mainMenu.loadGame)
		pd.update = MainGameLoop
	end
end

pd.update = MainMenuLoop

