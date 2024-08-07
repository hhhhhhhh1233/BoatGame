local pd <const> = playdate
local gfx <const> = pd.graphics

class('AnimatedSprite').extends(gfx.sprite)

function AnimatedSprite:init(x, y, frameTime, anim, loop)
	self:moveTo(x, y)
	local anim = gfx.imagetable.new(anim)
	self.animationLoop = gfx.animation.loop.new(frameTime, anim, loop)

	self:setImage(self.animationLoop:image())
	self:add()
	self:setZIndex(10000)
	print("Created Animation")
end

function AnimatedSprite:update()
	self:setImage(self.animationLoop:image())
	if not self.animationLoop:isValid() then
		self:remove()
	end
end
