local pd <const> = playdate
local gfx <const> = pd.graphics

class('FlyingBug').extends(gfx.sprite)

function FlyingBug:init(x, y)
	local animTable = gfx.imagetable.new("images/Bug")
	self.animationLoop = gfx.animation.loop.new(75, animTable, true)

	self:setImage(self.animationLoop:image())
	self:moveTo(x, y)
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.WALL})
	self:add()
end

function FlyingBug:collisionResponse(other)
	if other:isa(Player) then
		return "overlap"
	else
		return "slide"
	end
end

function FlyingBug:update()
	self:setImage(self.animationLoop:image())
	self:moveWithCollisions(self.x - 1, self.y)
	-- Get random point in line of sight and above water and go there
	-- If player is visible then go to them
end

