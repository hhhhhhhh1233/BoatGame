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
import "scripts/entities/projectileButton"
import "scripts/entities/door"
import "scripts/entities/mooredMine"
import "scripts/entities/playerCorpse"
import "scripts/entities/savePoint"
import "scripts/entities/ui"
import "scripts/entities/foliage"

local pd <const> = playdate
local gfx <const> = pd.graphics

LDtk.load("levels/world.ldtk", false)

class('Scene').extends()

function Scene:init(spawnX, spawnY)
	self.ui = UISystem
	local SaveData = LoadGame(self)
	if SaveData then
		print("LOADING SAVE")
		self.collectedEntities = SaveData["CollectedEntities"]
		self.player = Player(SaveData["PlayerX"], SaveData["PlayerY"], gfx.image.new("images/Boat"), 5, self)
		self.player.coins = SaveData["PlayerCoins"]
		self.player.AbilityA = Abilities[SaveData["PlayerAbilityAName"]]
		self.player.AbilityAName = SaveData["PlayerAbilityAName"]
		self.player.AbilityB = Abilities[SaveData["PlayerAbilityBName"]]
		self.player.AbilityBName = SaveData["PlayerAbilityBName"]
		self.player.PassiveAbility = Abilities[SaveData["PlayerPassiveAbilityName"]]
		self.player.PassiveAbilityName = SaveData["PlayerPassiveAbilityName"]
		if SaveData["PlayerDirection"] == -1 then
			self.player:setImageFlip(gfx.kImageFlippedX)
		end
		local level_rect = LDtk.get_rect(SaveData["CurrentLevel"])
		if not level_rect then
			print("INVALID LEVEL IN SAVE FILE")
			SaveData["CurrentLevel"] = "Level_0"
			level_rect = LDtk.get_rect(SaveData["CurrentLevel"])
		end
		self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
		self.water = Water(SaveData["WaterHeight"], self.LevelWidth, 0, self.LevelHeight, 1.1)
		self.water.bActive = SaveData["WaterWheelCollected"]
		self:goToLevel(SaveData["CurrentLevel"])
		if SaveData["PlayerCorpseX"] then
			self.playerCorpse = PlayerCorpse(SaveData["PlayerCorpseX"], SaveData["PlayerCorpseY"], SaveData["PlayerCorpseLevel"], self, SaveData["PlayerCorpseCoins"], SaveData["PlayerCorpseDirection"])
		end
	else
		self.collectedEntities = {}
		self.player = Player(spawnX, spawnY, gfx.image.new("images/Boat"), 5, self)
		local level_rect = LDtk.get_rect("Level_0")
		self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
		self.water = Water(100, self.LevelWidth, 0, self.LevelHeight, 1.1)
		self:goToLevel("Level_0")
		self.player:moveTo(self.SpawnX, self.SpawnY)
		self.water.Height = self.SpawnY
	end
end

function Scene:collect(entityIid)
	self.collectedEntities[entityIid] = true
	table.insert(self.collectedEntities, entityIid)
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
		self.water.Height = 32
		self.player.y = 32
		self.player.PhysicsComponent.Position.y = 32
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
	self.ui:add()
	if self.playerCorpse and self.playerCorpse.level == level_name then
		self.playerCorpse:add()
	end

	self.entityInstance = {}

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
	-- TODO: THE DOOR RELIES ON THE BUTTON BEING ALREADY SPAWNED IN; MAKE IT SO THAT THE ORDER DOESN'T MATTER
	for _, entity in ipairs(LDtk.get_entities(level_name)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name

		if entityName == "RoomTransition" then
			self.entityInstance[entity.iid] = DoorTrigger(entityX, entityY, entity)
		elseif entityName == "Mine" then
			local MineInstance = Mine(entityX, entityY, gfx.image.new("images/Mine"))
			table.insert(self.ActivePhysicsComponents, MineInstance.PhysicsComponent)
			self.entityInstance[entity.iid] = MineInstance
		elseif entityName == "MooredMine" then
			local MineInstance = MooredMine(entityX, entityY, gfx.image.new("images/Mine"), entity)
			table.insert(self.ActivePhysicsComponents, MineInstance.PhysicsComponent)
			self.entityInstance[entity.iid] = MineInstance
		elseif entityName == "FloatingEnemy" then
			local FloaterInstance = FloatingEnemy(entityX, entityY, self.player)
			table.insert(self.ActivePhysicsComponents, FloaterInstance.PhysicsComponent)
			self.entityInstance[entity.iid] = FloaterInstance
		elseif entityName == "SpawnPoint" then
			self.SpawnX = entityX
			self.SpawnY = entityY
		elseif entityName == "SimpleEnemy" then
			self.entityInstance[entity.iid] = SimpleEnemy(entityX, entityY, self.player)
		elseif entityName == "AbilityPickup" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = AbilityPickup(entityX, entityY, entity)
		elseif entityName == "WaterWheel" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = WaterWheel(entityX, entityY, entity, self.water)
		elseif entityName == "Coin" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = Coin(entityX, entityY, entity)
		elseif entityName == "BlockedWall" and not entity.fields.Cleared then
			self.entityInstance[entity.iid] = BlockedWall(entityX, entityY, entity)
		elseif entityName == "OneWayDoor" then
			self.entityInstance[entity.iid] = OneWayDoor(entityX, entityY, entity, 0)
		elseif entityName == "Button" then
			self.entityInstance[entity.iid] = Button(entityX, entityY, entity)
		elseif entityName == "ProjectileButton" then
			self.entityInstance[entity.iid] = ProjectileButton(entityX, entityY, entity)
		elseif entityName == "Door" then
			self.entityInstance[entity.iid] = Door(entityX, entityY, entity, self.entityInstance[entity.fields.Button.entityIid])
		elseif entityName == "SavePoint" then
			self.entityInstance[entity.iid] = SavePoint(entityX, entityY, self.currentLevel)
		elseif entityName == "Foliage" then
			self.entityInstance[entity.iid] = Foliage(entityX, entityY, self)
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
