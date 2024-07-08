local gfx <const> = playdate.graphics

-- NOTE: This is a sprite so that it gets wiped out by the gamemanager, it doesn't use anything only inherent to sprites but it means I could avoid adding an additional method for deleting doortriggers
class('DoorTrigger').extends(gfx.sprite)

function DoorTrigger:init(x, y, entity)
	self:moveTo(x, y)
	self:setCenter(0, 0)
	self:setCollideRect(-16, -16, 32, 32)
	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER})
	self:add()
	local fields = entity.fields
	self.TargetLevel = LDtk.get_level_name(fields.Target.levelIid)

	for _, e in ipairs(LDtk.get_entities(self.TargetLevel)) do
		if e.iid == fields.Target.entityIid then
			self.TargetX = e.position.x
			self.TargetY = e.position.y
			break
		end
	end
end

function DoorTrigger:Act(GameManager, direction)
	local WaterPlayerDiff = GameManager.water.Height - GameManager.player.y

	GameManager:goToLevel(self.TargetLevel)
	GameManager.player:moveTo(self.TargetX, self.TargetY)

	GameManager.water.Height = WaterPlayerDiff + GameManager.player.y + 16

	-- NOTE: Updating the physics component's position so it doesn't get confused and freak out
	GameManager.player.PhysicsComponent.Position = playdate.geometry.vector2D.new(self.TargetX, self.TargetY)
	-- NOTE: Bypass the lerp so the camera snaps to place when going to new level
	GameManager.camera:center(self.TargetX, self.TargetY)

	print("Warped to ", self.TargetX, self.TargetY)
end
