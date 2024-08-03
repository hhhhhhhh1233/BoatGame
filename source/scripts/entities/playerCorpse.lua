local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerCorpse').extends(gfx.sprite)

function PlayerCorpse:init(x, y, level, coins)
	self:moveTo(x, y)
	self.level = level
	self.coins = coins
	self:setImage(gfx.image.new("images/BoatCorpse"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function PlayerCorpse:update()
	self:moveTo(self.x, self.y + 0.1 * math.cos(5 * pd.getElapsedTime()))
end

function PlayerCorpse:pickup(player)
	player.coins += self.coins
	self:remove()
end
