local pd <const> = playdate
local gfx <const> = pd.graphics
import "abilities"

class('AbilitySelectionMenu').extends(gfx.sprite)

function AbilitySelectionMenu:init(player, entity)
	self.fields = entity.fields
	self.upgrades = self.fields.Abilities

	if self.fields.AbilityType == "AButton" then
		self.func = player.setAbilityA
	elseif self.fields.AbilityType == "BButton" then
		self.func = player.setAbilityB
	elseif self.fields.AbilityType == "Passive" then
		self.func = player.setPassive
	end

	self.grid = pd.ui.gridview.new(100, 200)
	self.grid:setNumberOfColumns(#self.upgrades)
	self.grid:setNumberOfRows(1)
	self.grid:setCellPadding(2, 2, 2, 2)
	local upgrades = self.upgrades
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
		gfx.drawTextInRect(upgrades[column], x - offsetX, y + (height/2) - offsetY, width, height, nil, nil, kTextAlignment.center)
	end
	self:setZIndex(-1000)
	self:add()
	self.player = player
end

function AbilitySelectionMenu:update()
	if pd.buttonJustPressed(pd.kButtonRight) then
		self.grid:selectNextColumn(false)
	elseif pd.buttonJustPressed(pd.kButtonLeft) then
		self.grid:selectPreviousColumn(false)
	elseif pd.buttonJustPressed(pd.kButtonA) then
		local _, _, column = self.grid:getSelection()
		self.func(self.player, Abilities[self.upgrades[column]])
		self.player.bActive = true
		self:remove()
	end
	self.grid:drawInRect(30,30,1000,1000)
end
