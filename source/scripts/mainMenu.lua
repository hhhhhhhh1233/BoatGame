local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"
import "scripts/saves"

class('MainMenu').extends(gfx.sprite)

function MainMenu:init()

	self:setImage(gfx.image.new(400 - 60, 240 - 60))
	-- self:setCenter(0, 0)
	self:moveTo(200, 120)

	if LoadGame() then
		self.options = {"Continue", "New Game"}
	else
		self.options = {"New Game"}
	end

	self.grid = pd.ui.gridview.new(150, 75)
	self.grid:setNumberOfColumns(1)
	self.grid:setNumberOfRows(#self.options)
	self.grid:setCellPadding(2, 2, 2, 2)
	self.grid.backgroundImage = gfx.nineSlice.new("images/gridBackground", 8, 8, 47, 47)
	self.grid:setContentInset(10, 10, 10, 10)
	local options= self.options
	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		if selected then
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawTextInRect(options[row], x, y + (height/2) + 3 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			gfx.drawRect(x, y, width, height)
			gfx.drawTextInRect(options[row], x, y + (height/2), width, height, nil, nil, kTextAlignment.center)
		end
	end
	self:setZIndex(10)
	self:add()
end

function MainMenu:update()
	if pd.buttonJustPressed(pd.kButtonDown) then
		self.grid:selectNextRow(false)
	elseif pd.buttonJustPressed(pd.kButtonUp) then
		self.grid:selectPreviousRow(false)
	elseif pd.buttonJustPressed(pd.kButtonA) then
		local _, row, column = self.grid:getSelection()
		self:remove()
		self.done = true
		self.loadGame = self.options[row] == "Continue"
	end
	gfx.lockFocus(self:getImage())
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 400 - 60, 240 - 60)
	self.grid:drawInRect(0, 0, 235 - 60, 240 - 60)
	gfx.unlockFocus()
end
