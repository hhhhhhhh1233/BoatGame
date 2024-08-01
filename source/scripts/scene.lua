import "scripts/entities/player"
import "libraries/LDtk"
import "scripts/entities/DoorTrigger"
import "scripts/entities/mine"
import "scripts/entities/simpleEnemy"
import "scripts/entities/floatingEnemy"
import "scripts/entities/abilityPickup"
import "scripts/entities/waterWheel"
import "scripts/entities/coin"
import "scripts/entities/blockedWall"
import "scripts/entities/oneWayDoor"
import "scripts/entities/button"

local pd <const> = playdate
local gfx <const> = pd.graphics

LDtk.load("levels/world.ldtk", false)

class('Scene').extends()

function Scene:init(spawnX, spawnY)
	self.player = Player(spawnX, spawnY, gfx.image.new("images/Boat"), 5, self)
	local level_rect = LDtk.get_rect("Level_0")
	self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
	self.water = Water(100, self.LevelWidth, 0, self.LevelHeight, 0.1)
	self:goToLevel("Level_0")
end

function Scene:enterRoom(door, direction)
	local xDiff, yDiff
	if direction == "EAST" or direction == "WEST" then
		xDiff = 0
		yDiff = door.TargetY - door.y
		self.player:moveTo(door.TargetX, self.player.y + yDiff)
	elseif direction == "NORTH" or direction == "SOUTH" then
		xDiff = door.TargetX - door.x
		yDiff = 0
		self.player:moveTo(self.player.x + xDiff, door.TargetY)
	end

	self:goToLevel(door.TargetLevel)
	self.player.PhysicsComponent.Velocity = playdate.geometry.vector2D.new(0, 0)

	if direction == "NORTH" then
		self.water.Height = self.LevelHeight - 16
	elseif direction == "SOUTH" then
		self.water.Height = 16
		self.player.y += 16
		self.player.PhysicsComponent.Position.y += 16
	else
		self.water.Height += yDiff
	end
	self.water.Width = self.LevelWidth

	-- NOTE: Updating the physics component's position so it doesn't get confused and freak out
	self.player.PhysicsComponent.Position = playdate.geometry.vector2D.new(self.player.x, self.player.y)

	-- NOTE: Bypass the lerp so the camera snaps to place when going to new level
	self.camera:center(self.player.x, self.player.y)

	local level_rect = LDtk.get_rect(door.TargetLevel)
	self.water.LowerBound = 0 - 20
	self.water.UpperBound = level_rect.height + 20
end

function Scene:reloadLevel()
	self:goToLevel(self.currentLevel)
end

function Scene:goToLevel(level_name)
	self.currentLevel = level_name
	gfx.sprite.removeAll()
	self.player:add()

	self.ActivePhysicsComponents = {}
	table.insert(self.ActivePhysicsComponents, self.player.PhysicsComponent)

	-- NOTE: This adds in all of the tiles and their collisions
	for layer_name, layer in pairs(LDtk.get_layers(level_name)) do
		if layer.tiles then
			local tilemap = LDtk.create_tilemap(level_name, layer_name)
			local layerSprite = gfx.sprite.new()
			layerSprite:setTilemap(tilemap)
			layerSprite:setCenter(0,0)
			layerSprite:moveTo(0,0)
			layerSprite:setZIndex(layer.zIndex)
			layerSprite:add()

			local emptyTiles = LDtk.get_empty_tileIDs(level_name, "Solid", layer_name)
			if emptyTiles then
				local tileSprites = gfx.sprite.addWallSprites(tilemap, emptyTiles)
				for i = 1, #tileSprites do
					tileSprites[i]:setGroups({COLLISION_GROUPS.WALL})
				end
			end
		end
	end

	-- NOTE: Spawns in all of the entities in the level
	for _, entity in ipairs(LDtk.get_entities(level_name)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name

		if entityName == "RoomTransition" then
			DoorTrigger(entityX, entityY, entity)
		elseif entityName == "Mine" then
			local MineInstance = Mine(entityX, entityY, gfx.image.new("images/Mine"))
			table.insert(self.ActivePhysicsComponents, MineInstance.PhysicsComponent)
		elseif entityName == "FloatingEnemy" then
			local FloaterInstance = FloatingEnemy(entityX, entityY, self.player)
			table.insert(self.ActivePhysicsComponents, FloaterInstance.PhysicsComponent)
		elseif entityName == "SpawnPoint" then
			self.SpawnX = entityX
			self.SpawnY = entityY
		elseif entityName == "SimpleEnemy" then
			SimpleEnemy(entityX, entityY, self.player)
		elseif entityName == "AbilityPickup" and not entity.fields.PickedUp then
			AbilityPickup(entityX, entityY, entity)
		elseif entityName == "WaterWheel" and not entity.fields.PickedUp then
			WaterWheel(entityX, entityY, entity, self.water)
		elseif entityName == "Coin" and not entity.fields.Collected then
			Coin(entityX, entityY, entity)
		elseif entityName == "BlockedWall" and not entity.fields.Cleared then
			BlockedWall(entityX, entityY, entity)
		elseif entityName == "OneWayDoor" then
			OneWayDoor(entityX, entityY, entity, 0)
		elseif entityName == "Button" then
			Button(entityX, entityY, entity)
		end
	end

	-- NOTE: Keeps the camera in the level bounds
	local level_rect = LDtk.get_rect(level_name)
	self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
	self.camera = Camera(self.player.x, self.player.y, 0, 0, self.LevelWidth, self.LevelHeight)
end

function Scene:UpdatePhysicsComponentsBuoyancy()
	for i = 1, #self.ActivePhysicsComponents do
		if self.ActivePhysicsComponents[i].bBuoyant then
			local buoyancyForces = CalculateBuoyancy(self.water.Height, self.ActivePhysicsComponents[i].Position.y, 50, 0.3, 5.5, self.ActivePhysicsComponents[i])
			self.ActivePhysicsComponents[i]:AddForce(buoyancyForces)
		end
	end
end
