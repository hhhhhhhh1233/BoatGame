local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"
import "scripts/saves"

class('MainMenu').extends(gfx.sprite)

function MainMenu:init()

	self:setImage(gfx.image.new(400, 240))
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
	-- self.grid.backgroundImage = gfx.nineSlice.new("images/gridBackground", 8, 8, 47, 47)
	self.grid:setContentInset(10, 10, 10, 10)

	local options = self.options
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	local nsBlank = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)
	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		if selected then
			-- gfx.fillRect(x, y, width, height)
			ns:drawInRect(x, y, width, height)
			-- TODO: This looks sort of cool but it's too big
			-- local boatImage = gfx.image.new("images/Boat")
			-- boatImage:setInverted(true)
			-- boatImage:draw(x + 10, y + height / 2 - 16)
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawTextInRect("*"..options[row].."*", x, y + (height/2) - 5 + 3 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			nsBlank:drawInRect(x, y, width, height)
			-- gfx.drawRect(x, y, width, height)
			gfx.drawTextInRect(options[row], x, y + (height/2) - 5, width, height, nil, nil, kTextAlignment.center)
		end
	end
	self:setZIndex(10)
	self:add()
end

local movingSound = pd.sound.sampleplayer.new("sounds/ChangingSelection")
local decisionSound = pd.sound.sampleplayer.new("sounds/SelectionMade")
local mainMenuTrack = pd.sound.fileplayer.new("sounds/songs/MainMenuLoop")
mainMenuTrack:play(0)
local waterHeightDiff = 0
function MainMenu:update()
	if pd.buttonJustPressed(pd.kButtonDown) then
		self.grid:selectNextRow(false)
		movingSound:play()
	elseif pd.buttonJustPressed(pd.kButtonUp) then
		self.grid:selectPreviousRow(false)
		movingSound:play()
	elseif pd.buttonJustPressed(pd.kButtonA) then
		local _, row, column = self.grid:getSelection()
		self:remove()
		mainMenuTrack:stop()
		-- decisionSound:play()
		self.done = true
		self.loadGame = self.options[row] == "Continue"
	end
	gfx.lockFocus(self:getImage())
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 400, 240)
	if #self.options == 2 then
		self.grid:drawInRect(0, 0, 235 - 60, 240 - 60)
	else
		self.grid:drawInRect(0, 50, 235 - 60, 240 - 60 - 50)
	end
	gfx.drawTextInRect("*BOAT GAME*", 220 + 10 * math.sin(pd.getElapsedTime()), 80, 100, 100, nil, nil, kTextAlignment.center)
	local boatImage = gfx.image.new("images/Boat")
	local change, _ = pd.getCrankChange()
	waterHeightDiff -= change/10
	waterHeightDiff = Clamp(waterHeightDiff, -20, 20)
	boatImage:setInverted(true)
	boatImage:drawScaled(230 + 30 * math.sin(0.3*pd.getElapsedTime()), waterHeightDiff + 160 + 5 * math.sin(1.7 * pd.getElapsedTime()), 1)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, waterHeightDiff + 190 + 5 * math.sin(1.7 * pd.getElapsedTime()), 400, 240)
	gfx.unlockFocus()
end
