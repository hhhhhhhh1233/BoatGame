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

function Scene:enterRoom(direction)
	print("HEHEREHRHE")
	local level = LDtk.get_neighbours(self.currentLevel, direction)[1]
	local WaterPlayerDiff = self.water.Height - self.player.y
	self:goToLevel(level)
	self.water.Height = WaterPlayerDiff + self.player.y
	-- NOTE: The water should always cover the level width-wise
	self.water.width = self.LevelWidth
	self.player.PhysicsComponent.velocity = playdate.geometry.vector2D.new(0, 0)
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
			-- TODO: IMPLEMENT THIS CLASS FORREAL, AND FETCH WHICH ROOM THE TARGET IS IN
			-- printTable(entity)
			DoorTrigger(entityX, entityY, entity)
		end
	end

	-- NOTE: Keeps the camera in the level bounds
	local level_rect = LDtk.get_rect(level_name)
	self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
	self.camera = Camera(self.player.x, self.player.y, 0, 0, self.LevelWidth, self.LevelHeight)
end
