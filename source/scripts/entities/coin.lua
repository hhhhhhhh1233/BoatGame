local pd <const> = playdate
local gfx <const> = pd.graphics

class('Coin').extends(gfx.sprite)

function Coin:init(x, y, entity)
	self.entity = entity
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/Coin"))
	self:setCollideRect(0, 0, 16, 16)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function Coin:update()
	self:moveTo(self.x, self.y + 0.1 * math.cos(5 * pd.getElapsedTime()))

end

function Coin:pickup(player)
	player.coins += 1
	self.entity.fields.Collected = true
	self:remove()
end
