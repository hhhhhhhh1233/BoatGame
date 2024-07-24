local pd <const> = playdate
local gfx <const> = pd.graphics

class('AbilitySelectionMenu').extends(gfx.sprite)

function AbilitySelectionMenu:init(player)
	self.grid = pd.ui.gridview.new(100, 200)
	self.grid:setNumberOfColumns(3)
	self.grid:setNumberOfRows(1)
	self.grid:setCellPadding(2, 2, 2, 2)
	local Upgrades = {"Jumping", "Shooting", "Flying"}
	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		local offsetX, offsetY = gfx.getDrawOffset()
		gfx.setColor(gfx.kColorBlack)
		if selected then
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.fillRect(x - offsetX, y - offsetY, width, height)
			gfx.setColor(gfx.kColorWhite)
		else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			gfx.drawRect(x - offsetX, y - offsetY, width, height)
		end
		gfx.drawTextInRect(Upgrades[column], x - offsetX, y + (height/2) - offsetY, width, height, nil, nil, kTextAlignment.center)
	end
	self:setZIndex(1000)
	self:add()
	self.player = player
end

function AbilitySelectionMenu:update()
	if pd.buttonJustPressed(pd.kButtonRight) then
		self.grid:selectNextColumn(false)
	elseif pd.buttonJustPressed(pd.kButtonLeft) then
		self.grid:selectPreviousColumn(false)
	elseif pd.buttonJustPressed(pd.kButtonA) then
		self.player.bActive = true
		self:remove()
	end
	self.grid:drawInRect(30,30,1000,1000)
end
