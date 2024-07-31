local pd <const> = playdate
local gfx <const> = pd.graphics
import "scripts/abilitySelectionMenu"

class('AbilityPickup').extends(gfx.sprite)

function AbilityPickup:init(x, y, entity)
	self.entity = entity
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/AbilityPickup"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function AbilityPickup:pickup(player)
	player.bActive = false
	self.entity.fields.PickedUp = true

	AbilitySelectionMenu(player, self.entity)

	self:remove()
end
