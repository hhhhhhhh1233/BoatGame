local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/abilities"
import "CoreLibs/nineslice"

class('OptionBox').extends(gfx.sprite)

function OptionBox:init(prompt, options, callback)
	SceneManager.player.bActive = false
	SceneManager.water.bActive = false

	self:setIgnoresDrawOffset(true)
	self:moveTo(200, 120)

	self.options = options
	self.prompt = prompt
	self.callback = callback

	self:setImage(gfx.image.new(340, 180))

	self.grid = pd.ui.gridview.new((400 - 60 - 20 - 4 * #options)/#options, 60)
	self.grid:setNumberOfColumns(#options)
	self.grid:setNumberOfRows(1)
	self.grid:setCellPadding(2, 2, 2, 2)
	self.grid:setContentInset(10, 10, 10, 10)

	self.grid.backgroundImage = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)

	local option = options
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	local nsBlank = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)

	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		if selected then
			ns:drawInRect(x, y + 50, width, height)
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawTextInRect(option[column], x, y + (height/2) - 10 + 50 + 3 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			nsBlank:drawInRect(x, y + 50, width, height)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			gfx.drawTextInRect(option[column], x, y + (height/2) - 10 + 50, width, height, nil, nil, kTextAlignment.center)
		end
	end
	self:setZIndex(10)
	self:add()
end

function OptionBox:update()
	if pd.buttonJustPressed(pd.kButtonRight) then
		self.grid:selectNextColumn(true)
	elseif pd.buttonJustPressed(pd.kButtonLeft) then
		self.grid:selectPreviousColumn(true)
	elseif pd.buttonJustReleased(pd.kButtonA) then
		local _, _, column = self.grid:getSelection()
		SceneManager.player.bActive = true
		SceneManager.water.bActive = true
		self:remove()
		self.selection = column
		self.callback(self.selection, self.options[column])
	end

	gfx.lockFocus(self:getImage())
	self.grid:drawInRect(0, 0, 400 - 60, 240 - 60)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned(self.prompt, (400 - 60)/2, 20, kTextAlignment.center)
	-- self.grid:drawInRect(30 - offsetX, 30 - offsetY, 400 - 60, 240 - 60)
	gfx.unlockFocus()
end
