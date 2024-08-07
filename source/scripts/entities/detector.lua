local pd <const> = playdate
local gfx <const> = pd.graphics

class('Detector').extends(gfx.sprite)

function Detector:init(x, y, entity)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	local sprite = gfx.image.new(entity.size.width, entity.size.height)
	local ns = gfx.nineSlice.new("images/Detector", 5, 8, 20, 16)
	gfx.lockFocus(sprite)
	ns:drawInRect(0, 0, entity.size.width, entity.size.height)
	gfx.unlockFocus()
	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:setCollideRect(0, 0, entity.size.width, entity.size.height)
	self:setImage(sprite)
	self:setZIndex(-10)
	self:add()
	self.bDetectedPlayer = false
end

function Detector:update()
	self.bDetectedPlayer = false
	local others = self:overlappingSprites()
	for _, other in ipairs(others) do
		if other:isa(Player) and not other.bInvisible then
			self.bDetectedPlayer = true
		end
	end
	print(self.bDetectedPlayer)
end
