import "player"
import "libraries/LDtk"

local pd <const> = playdate
local gfx <const> = pd.graphics

LDtk.load("levels/world.ldtk", false)

class('Scene').extends()

function Scene:init(spawnX, spawnY)
	self.player = Player(spawnX, spawnY, gfx.image.new("images/Boat"), 2)
	self:goToLevel("Level_0")
end

function Scene:enterRoom(direction)
	local level = LDtk.get_neighbours(self.currentLevel, direction)[1]
	self:goToLevel(level)
end

function Scene:goToLevel(level_name)
	self.currentLevel = level_name
	gfx.sprite.removeAll()
	self.player:add()

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

	-- NOTE: Keeps the camera in the level bounds
	local level_rect = LDtk.get_rect(level_name)
	local mapPixelWidth, mapPixelHeight = level_rect.width, level_rect.height
	self.camera = Camera(self.player.x, self.player.y, 0, 0, mapPixelWidth, mapPixelHeight)
end
