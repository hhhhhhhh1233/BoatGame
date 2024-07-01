import "player"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scene').extends()

function Scene:init(tileset, levelData, levelWidth, spawnX, spawnY)
	self.tilemap = gfx.tilemap.new()
	self.tilemap:setImageTable(tileset)
	self.player = Player(spawnX, spawnY, gfx.image.new("images/Boat"), 2)
	self:loadLevel(levelData, levelWidth)
end

function Scene:loadLevel(levelData, levelWidth)
	gfx.sprite.removeAll()
	self.player:add()

	self.tilemap:setTiles(levelData, levelWidth)

	local tileSprites = gfx.sprite.addWallSprites(self.tilemap, {})
	for i = 1, #tileSprites do
		tileSprites[i]:setGroups({COLLISION_GROUPS.WALL})
	end

	local mapPixelWidth, mapPixelHeight = self.tilemap:getPixelSize()
	print(mapPixelWidth)
	self.camera = Camera(self.player.x, self.player.y, 0, 0, mapPixelWidth, mapPixelHeight)
end

function Scene:draw()
	self.tilemap:draw(0, 0)
end

