local pd <const> = playdate
local gfx <const> = pd.graphics

class('CrabBoss').extends(gfx.sprite)

function CrabBoss:init(x, y, gameManager)
	self.gameManager = gameManager
	self:setImage(gfx.image.new('images/CrabMushroomBoss'))
	self.songManager = pd.sound.fileplayer.new("sounds/songs/FinalBossIntro")
	self.songManager:play(1)
	self.songManager:setFinishCallback(function ()
		self.gameManager.songManager = pd.sound.fileplayer.new("sounds/songs/FinalBossLoop")
		self.gameManager.songManager:play(0)
	end)
	self:setCollideRect(0, 0, 256, 128)
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.PROJECTILE})
	self:setScale(2)
	self:moveTo(x + 64, y + 64)
	self:add()
	self.health = 1000
	self.bActive = true
end

function CrabBoss:Damage(amount)
	self.health -= amount
	if self.health <= 0 then
		if self.bActive then
			self.bActive = false
			self.gameManager.songManager:stop()
			self.songManager = pd.sound.fileplayer.new("sounds/songs/FinalBossOutro")
			self.songManager:play(1)
			self.songManager:setFinishCallback(function ()
				self:remove()
			end)
		end
	end
	print(self.health)
end

function CrabBoss:update()
	print("Here")
end
