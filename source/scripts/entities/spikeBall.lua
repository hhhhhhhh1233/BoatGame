local pd <const> = playdate
local gfx <const> = pd.graphics

class('SpikeBall').extends(gfx.sprite)

function SpikeBall:init(x, y)
	self:setImage(gfx.image.new("images/SpikeBall"))
	assert(self:getImage())
	self:moveTo(x, y)
	self:add()
end

function SpikeBall:update()
	local collisions = gfx.sprite.querySpritesInRect(self.x - 16, self.y - 16, 32, 32)
	for _, collision in ipairs(collisions) do
		if collision:isa(Player) then
			collision:Damage(20, 10)
			-- collision.PhysicsComponent:AddForce(collision.x - self.x, collision.y - self.y)
		end
	end
	-- gfx.fillRect(self.x - 16, self.y - 16, 32, 32)
end
