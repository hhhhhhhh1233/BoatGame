local pd <const> = playdate
local gfx <const> = pd.graphics

class('SwayGun').extends(gfx.sprite)

function SwayGun:init(x, y)
	self:moveTo(x + 32, y + 16)
	self:setImage(gfx.image.new("images/GunBody"))
	self.angle = 0
	self.angleSpeed = 1.5
	self.maxAngle = 40
	self.range = 500
	self.shootDelay = 10
	self.bCanShoot = true
	self:setCollideRect(0, 0, 64, 64)
	self:add()
end

function SwayGun:update()
	local radAngle = self.angle * math.pi/180
	local hitTarget, hitPoint = Raycast(self.x, self.y, -self.range * math.cos(radAngle), -self.range * math.sin(radAngle), {self}, {"Bullet"})
	local bSeeingPlayer
	if hitTarget then
		bSeeingPlayer = hitTarget:isa(Player)
		gfx.drawLine(self.x, self.y, hitPoint.x, hitPoint.y)
	else
		gfx.drawLine(self.x, self.y, self.x - self.range * math.cos(radAngle), self.y - self.range * math.sin(radAngle))
	end

	if not bSeeingPlayer then
		self.angle += self.angleSpeed
		self:setRotation(self.angle)
		if math.abs(self.angle) > math.abs(self.maxAngle) then
			if self.angle < 0 then
				self.angle = -self.maxAngle
			else
				self.angle = self.maxAngle
			end
			self.angleSpeed *= -1
		end
	else
		if self.bCanShoot then
			Bullet(self.x, self.y, pd.geometry.vector2D.new(10*-math.cos(radAngle),10*-math.sin(radAngle)))
			self.bCanShoot = false
			pd.frameTimer.performAfterDelay(self.shootDelay, function ()
				self.bCanShoot = true
			end)
		end
		local playerCheck, _ = Raycast(self.x, self.y, hitTarget.x - self.x, hitTarget.y - 8 - self.y, {self}, {"Bullet"})
		-- gfx.drawLine(self.x, self.y, hitTarget.x, hitTarget.y - 8)
		-- printTable(playerCheck)
		if playerCheck and playerCheck:isa(Player) then
			local toPlayer = pd.geometry.vector2D.new(hitTarget.x - self.x, hitTarget.y - 8 - self.y)
			local currentDirection = pd.geometry.vector2D.new(self.range*-math.cos(radAngle), self.range*-math.sin(radAngle))
			local angleDiff = toPlayer:angleBetween(currentDirection)
			self.angle -= angleDiff
		end
		self:setRotation(self.angle)
	end
end
