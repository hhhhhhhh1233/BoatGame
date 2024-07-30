local pd <const> = playdate
local gfx <const> = pd.graphics

class('WaterWheel').extends(gfx.sprite)

function WaterWheel:init(x, y, entity, water)
	self.water = water
	self.entity = entity
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/WaterWheel"))
	self:setCollideRect(0, 0, 64, 64)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function WaterWheel:pickup(player)
	self.water.bActive = true
	self.entity.fields.PickedUp = true
	self:remove()
end
