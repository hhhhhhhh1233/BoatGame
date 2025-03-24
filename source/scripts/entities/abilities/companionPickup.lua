local pd <const> = playdate
local gfx <const> = pd.graphics

class('CompanionPickup').extends(gfx.sprite)

function CompanionPickup:init(x, y, entity)
	self:moveTo(x, y)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:setCollideRect(0, 0, 32, 32)
	self.entity = entity
	self:setImage(gfx.image.new("images/Companion"))
	self:add()
end

function CompanionPickup:pickup(player)
	PopupTextBox("*COMPANION*\nHelps you feel less lonely in these trying times", 3000, 20)
	player.companion = Companion(player.x, player.y, player)
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
