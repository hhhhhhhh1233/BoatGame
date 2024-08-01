local pd <const> = playdate
local gfx <const> = pd.graphics

class('BlockedWall').extends(gfx.sprite)

function BlockedWall:init(x, y, entity)
	self.entity = entity
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/BlockedWall"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end


function BlockedWall:clear(player)
	if player.coins >= self.entity.fields.Cost then
		player.coins -= self.entity.fields.Cost
		self.entity.fields.Cleared = true
		self:remove()
		return true
	else
		print("Come back when you're a little, mmm... richer")
		return false
	end
end
