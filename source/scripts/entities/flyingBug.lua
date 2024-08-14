local pd <const> = playdate
local gfx <const> = pd.graphics

class('FlyingBug').extends(gfx.sprite)

function FlyingBug:init(x, y, hive, water)
	local animTable = gfx.imagetable.new("images/Bug")
	self.animationLoop = gfx.animation.loop.new(75, animTable, true)

	self.hive = hive
	self.water = water
	self:setImage(self.animationLoop:image())
	self:moveTo(x, y)
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.WALL})
	self:add()
	self.angle = math.random(0, 7)
	local angleUpdateTimer = pd.frameTimer.new(15, function ()
		self.angle = math.random(0, 7)
	end)
	angleUpdateTimer.repeats = true
end

function FlyingBug:collisionResponse(other)
	if other:isa(Player) then
		other:Damage(20, 10)
		return "overlap"
	else
		return "slide"
	end
end

function FlyingBug:update()
	self:setImage(self.animationLoop:image())

	local bUnderwater = self.y > self.water.Height
	if bUnderwater then
		self.hive:removeBug()
		self:remove()
	end

	-- TODO: Change the way the target is calculated so that they don't:
	-- Go into the water
	-- Leave the map
	-- Ram into the wall
	-- And make it so they do target the player if they're close enough to see them

	self.xTarget, self.yTarget = math.cos(self.angle), math.sin(self.angle)
	self:moveWithCollisions(self.x + self.xTarget * 2, self.y + self.yTarget * 2)
	-- Get random point in line of sight and above water and go there
	-- If player is visible then go to them
end

