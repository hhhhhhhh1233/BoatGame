local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/entities/spikeRailPoint"

class('SpikeRail').extends(gfx.sprite)

function SpikeRail:init(x, y, entity)
	self.spikeBall = SpikeBall(x + 8, y + 8)
	self.spikeBallDirection = 1
	self.spikeBallSpeed = entity.fields.SpikeBallSpeed
	self.target = 2

	self.path = {}
	table.insert(self.path, SpikeRailPoint(x, y))
	for i = 1, #entity.fields.Path do
		table.insert(self.path, SpikeRailPoint(entity.fields.Path[i].cx * 16, entity.fields.Path[i].cy * 16))
	end
	self:add()
end

function SpikeRail:update()
	-- local toTarget = pd.geometry.vector2D.new(self.path[self.target].x - self.path[self.target - 1].x, self.path[self.target].y - self.path[self.target - 1].y)
	local toTarget = pd.geometry.vector2D.new(self.path[self.target].x - self.spikeBall.x, self.path[self.target].y - self.spikeBall.y)
	if toTarget:magnitude() > self.spikeBallSpeed then
		toTarget = toTarget:normalized() * self.spikeBallSpeed
	elseif toTarget:magnitude() == 0 then
		self.target += self.spikeBallDirection
		if self.target > #self.path then
			self.target -= 1
			self.spikeBallDirection = -1
		elseif self.target == 0 then
			self.target += 1
			self.spikeBallDirection = 1
		end
	end
	for i = 1, #self.path - 1 do
		gfx.drawLine(self.path[i].x, self.path[i].y, self.path[i + 1].x, self.path[i + 1].y)
	end
	self.spikeBall:moveTo(self.spikeBall.x + toTarget.x, self.spikeBall.y + toTarget.y)
end
