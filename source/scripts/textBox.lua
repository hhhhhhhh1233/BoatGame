local pd <const> = playdate
local gfx <const> = playdate.graphics

class('TextBox').extends(gfx.sprite)

function TextBox:init(message, padding, callback)
	SceneManager.player.bActive = false
	SceneManager.water.bActive = false
	self.callback = callback

	self.width, self.height = gfx.getTextSize(message)
	local sprite = gfx.image.new(self.width + 2 * padding + 20, self.height + 2 * padding + 20)
	local sprite2

	self:setZIndex(100)
	self:setIgnoresDrawOffset(true)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	ns:drawInRect(0, 0, self.width + 2*padding, self.height + 2*padding)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned(message, self.width / 2 + padding, padding, kTextAlignment.center)
	gfx.unlockFocus()

	sprite2 = sprite:copy()

	-- DRAW BUTTON UP ON FIRST SPRITE
	gfx.lockFocus(sprite)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 17, 12)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 17, 10)
	gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	gfx.drawTextAligned('*A*', self.width + 17, self.height + 8, kTextAlignment.center)
	gfx.unlockFocus()

	-- DRAW BUTTON DOWN ON SECOND SPRITE
	gfx.lockFocus(sprite2)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 19, 12)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 19, 10)
	gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	gfx.drawTextAligned('*A*', self.width + 17, self.height + 10, kTextAlignment.center)
	gfx.unlockFocus()

	self.timer = pd.timer.keyRepeatTimerWithDelay(400, 400, function ()
		if self:getImage() == sprite2 then
			self:setImage(sprite)
		else
			self:setImage(sprite2)
		end
	end)

	self:moveTo(200, 120 + self.height / 2)
	self:setImage(sprite)
	self:add()
end

function TextBox:update()
	if pd.buttonJustReleased(pd.kButtonA) then
		self.timer:remove()
		SceneManager.player.bActive = true
		SceneManager.water.bActive = true
		self:remove()
		if self.callback then
			self.callback()
		end
	end
end
