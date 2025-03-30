local pd <const> = playdate
local gfx <const> = pd.graphics

class("DpadNotif").extends(gfx.sprite)

function DpadNotif:init(x, y)
	self:setCollideRect(0, 0, 64, 64)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x - 16, y - 16)
	local anim = gfx.imagetable.new("images/d-pad-notif")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(300, anim, true)

	self:add()

	self.bCollected = false
end

function DpadNotif:update()
	local spritesInArea = self:overlappingSprites()
	local bPlayerInRect = false
	for _, value in ipairs(spritesInArea) do
		if value:isa(Player) then
			bPlayerInRect = true
		end
	end

	if bPlayerInRect then
		-- self.animationLoop:draw(self.x + 16, self.y - 16)
		UISystem:drawImageAtWorld(self.animationLoop:image(), self.x + 16, self.y - 16)
	end
end
