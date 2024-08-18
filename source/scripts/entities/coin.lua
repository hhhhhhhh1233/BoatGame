local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/popupTextBox"
import "scripts/textBox"
import "scripts/optionBox"

class('Coin').extends(gfx.sprite)

function Coin:init(x, y, entity)
	self.entity = entity
	self:moveTo(x + 8, y + 8)
	self:setImage(gfx.image.new("images/Coin"))
	self:setCollideRect(0, 0, 16, 16)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
	self.coinPickupSound = pd.sound.sampleplayer.new("sounds/CoinPickup")
end

function Coin:update()
	self:moveTo(self.x, self.y + 0.1 * math.cos(5 * pd.getElapsedTime()))
end

function Coin:pickup(player)
	player.coins += 1
	OptionBox("Accept coin?", {"Yes", "No", "IDK"}, function (index, selectionString)
		TextBox("Huh. So you're the type of person to\n like "..selectionString.."? A number "..index.." kinda guy?", 10)
	end)
	player.GameManager:collect(self.entity.iid)
	self.entity.fields.Collected = true
	self.coinPickupSound:play()
	self:remove()
end
