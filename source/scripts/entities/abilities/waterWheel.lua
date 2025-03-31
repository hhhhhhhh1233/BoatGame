local pd <const> = playdate
local gfx <const> = pd.graphics

local PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

class('WaterWheel').extends(gfx.sprite)

function WaterWheel:init(x, y, entity, water)
	self.water = water
	self.entity = entity
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/WaterWheel"))
	self:setCollideRect(0, 0, 64, 64)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function WaterWheel:pickup(player)
	PopupTextBox("*WATER WHEEL*\nCrank to change the water level", 3000, 20)
	PickupSound:play()
	self.water.bActive = true
	self.entity.fields.PickedUp = true
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
