import "player"
import "libraries/LDtk"
import "DoorTrigger"

local pd <const> = playdate
local gfx <const> = pd.graphics

LDtk.load("levels/world.ldtk", false)

class('Scene').extends()

function Scene:init(spawnX, spawnY)
	self.player = Player(spawnX, spawnY, gfx.image.new("images/Boat"), 2, self)
	self:goToLevel("Level_0")
	local level_rect = LDtk.get_rect("Level_0")
	self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
	self.water = Water(100, self.LevelWidth, 0, self.LevelHeight, 0.1)
end

function Scene:enterRoom(door, direction)

	local xDiff, yDiff
	if direction == "EAST" or direction == "WEST" then
		xDiff = 0
		yDiff = door.TargetY - door.y
		self.player:moveTo(door.TargetX, self.player.y + yDiff)
		self.water.Height += yDiff
	elseif direction == "NORTH" or direction == "SOUTH" then
		xDiff = door.TargetX - door.x
		yDiff = 0
		self.player:moveTo(self.player.x + xDiff, door.TargetY)
	end


	local WaterPlayerDiff = self.water.Height - self.player.y

	self:goToLevel(door.TargetLevel)
	-- self.player:moveTo(door.TargetX, self.player.y + yDiff)
	self.player.PhysicsComponent.velocity = playdate.geometry.vector2D.new(0, 0)
	print(yDiff)

	-- self.water.Height = WaterPlayerDiff + self.player.y + 16
	if direction == "NORTH" then
		self.water.Height = self.LevelHeight - 32
	elseif direction == "SOUTH" then
		self.water.Height = 32
	else
		self.water.Height += yDiff
	end
	self.water.Width = self.LevelWidth

	-- NOTE: Updating the physics component's position so it doesn't get confused and freak out
	self.player.PhysicsComponent.Position = playdate.geometry.vector2D.new(door.TargetX, door.TargetY)
	-- NOTE: Bypass the lerp so the camera snaps to place when going to new level
	self.camera:center(door.TargetX, door.TargetY)

	print("Warped to ", door.TargetX, door.TargetY)
end

function Scene:goToLevel(level_name)
	self.currentLevel = level_name
	gfx.sprite.removeAll()
	self.player:add()

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
		end
	end

	-- NOTE: Keeps the camera in the level bounds
	local level_rect = LDtk.get_rect(level_name)
	self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
	self.camera = Camera(self.player.x, self.player.y, 0, 0, self.LevelWidth, self.LevelHeight)
end