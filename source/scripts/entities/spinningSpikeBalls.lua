local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/entities/spikeBall"

class('SpinningSpikeBalls').extends(gfx.sprite)

function SpinningSpikeBalls:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self:setImage(gfx.image.new("images/SpinningSpikeBallRoot"))
	assert(self:getImage())
	self.spikes = {}
	for i = 1, entity.fields.NumberOfSpikes do
		table.insert(self.spikes, SpikeBall(self.x, self.y + 32 * i))
	end
	self:add()
end

local angle = 0
function SpinningSpikeBalls:update()
	for index, spike in ipairs(self.spikes) do
		spike:moveTo(self.x + 26 * index * math.cos(angle), self.y + 26 * index * math.sin(angle))
	end
	angle += 0.05
end
