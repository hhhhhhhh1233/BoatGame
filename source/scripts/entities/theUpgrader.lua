local pd <const> = playdate
local gfx <const> = pd.graphics

class('TheUpgrader').extends(gfx.sprite)

function TheUpgrader:init(x, y)
	self:setCollideRect(0, 0, 64, 48)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x + 32, y + 24)
	local anim = gfx.imagetable.new("images/TheUpgrader")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(400, anim, true)

	self:setImage(self.animationLoop:image())
	self:add()
	self.coinPickupSound = pd.sound.sampleplayer.new("sounds/BigCoinPickup")
end

function TheUpgrader:update()
	self:setImage(self.animationLoop:image())
end

function TheUpgrader:interact(player)
	player.coins += 100
	TextBox("*UPGRADER*\nHere, take some cash", 10)
	self.coinPickupSound:play()
end
