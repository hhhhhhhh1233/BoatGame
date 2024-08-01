local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/entities/player"
import "CoreLibs/nineslice"

class('OneWayDoor').extends(gfx.sprite)

local Orientation = {
	["North"] = 2,
	["East"] = 2,
	["South"] = 2,
	["West"] = 2,
}

function OneWayDoor:init(x, y, entity, orientation)
	self.entity = entity
	self.Blocking = entity.fields.Blocking
	printTable(entity)
	-- NOTE: This says which way the one way door is oriented
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
	self:close()
end

function OneWayDoor:open()
	local sprite = gfx.image.new(self.entity.size.width, 32)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 21, 21)
	ns:drawInRect(0, 0, self.entity.size.width, 16)
	gfx.unlockFocus()
	self:setImage(sprite)
	self:clearCollideRect()
	self.bOpen = true
end

function OneWayDoor:close()
	local sprite = gfx.image.new(self.entity.size.width, 32)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/OneWayDoorSmall", 3, 3, 25, 25)
	if self.bBottomUp then
		ns:drawInRect(0, 16, self.entity.size.width, 5)
	else
		ns:drawInRect(0, 0, self.entity.size.width, 5)
	end
	gfx.unlockFocus()
	self:setImage(sprite)
	self:setCollideRect(0, 6, self.entity.size.width, 1)
	self.bOpen = false
end

function OneWayDoor:update()
	local width, _ = self:getSize()
	if not self.bOpen then
		local collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y, width, 6)
		if #collisionsInOpen > 0 then
			self:open()
		end
	else
		local collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y, width, 12)
		if #collisionsInOpen == 0 then
			self:close()
		end
	end
end
