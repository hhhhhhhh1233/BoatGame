local pd <const> = playdate
local gfx <const> = pd.graphics
import "scripts/bullet"
import "scripts/explosion"
import "CoreLibs/frameTimer"

function Jump(player, button)
	-- TODO: Add a cooldown
	if pd.buttonJustPressed(button) and player.bCanJump then
		local sprites = gfx.sprite.querySpritesInRect(player.x - 25, player.y - 8, 50, 50)
		gfx.fillRect(player.x - 25, player.y - 8, 50, 50)
		for _, sprite in ipairs(sprites) do
			if not sprite:isa(Player) and sprite.Damage then
				sprite:Damage(10, 10)
			end
			if sprite.PhysicsComponent then
				local blastDirection = (sprite.PhysicsComponent.Position - pd.geometry.vector2D.new(player.x, player.y + 25)):normalized()
				sprite.PhysicsComponent:AddForce(blastDirection * 8)
			end
		end
		player.bCanJump = false
		pd.frameTimer.new(30, function ()
			player.bCanJump = true
		end)
		-- player:AddForce(pd.geometry.vector2D.new(0, -8))
		-- player.bCanJump = false
	end
end

function Shoot(player, button)
	if pd.buttonJustPressed(button) then
		Bullet(player.PhysicsComponent.Position.x + player.direction * 40, player.PhysicsComponent.Position.y - 5, pd.geometry.vector2D.new(player.direction * 15, 0))
	end
end

function Submerge(player)
	if player.bUnderwater then
		player.PhysicsComponent.bBuoyant = false
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			-- player:AddForce(playdate.geometry.vector2D.new(0, 0.5 * player.Speed))
			player.PhysicsComponent.Velocity.y = player.Speed
		elseif playdate.buttonIsPressed(playdate.kButtonUp) then
			-- player:AddForce(playdate.geometry.vector2D.new(0, -0.5 * player.Speed))
			player.PhysicsComponent.Velocity.y = -player.Speed
		else
			player.PhysicsComponent.Velocity.y = 0
		end
	end
end


function Interest(player)
	player.coins *= 1.0005
	player.Health *= 1.0005
	player.Health = Clamp(player.Health, 0, 100)
end

function Dive(player, button)
	if pd.buttonJustPressed(button) then
		player.PhysicsComponent.Velocity = pd.geometry.vector2D.new(0, 300)
		player.bCanDive = false
	end
end

local explosionMeterMax = 100
local explosionMeterRateOfIncrease = 3
local explosionMeterRateOfDecrease = 1

function Overheat(player, button)
	if pd.buttonIsPressed(button) then
		local sprites = gfx.sprite.querySpritesInRect(player.x - 25, player.y - 25 - 8, 50, 50)
		-- NOTE: Visualization of the damage zone
		-- gfx.fillRect(player.x - 25, player.y - 25 - 8, 50, 50)
		for _, value in ipairs(sprites) do
			if not value:isa(Player) and value.Damage then
				value:Damage(10, 10)
			end
		end
		player.explosionMeter += explosionMeterRateOfIncrease
	else
		player.explosionMeter -= explosionMeterRateOfDecrease
	end

	player.explosionMeter = Clamp(player.explosionMeter, 0, explosionMeterMax)

	if player.explosionMeter > 0 then
		if player.explosionMeter == explosionMeterMax then
			player.explosionMeter = 0
			Explosion(player.x, player.y)
		end

		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(player.x - 2 - 16, player.y - 42 - 2, 34, 14)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(player.x - 1 - 16, player.y - 42 - 1, 32, 12)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(player.x - 16, player.y - 42, (player.explosionMeter/explosionMeterMax) * 30, 10)
	end
end

Abilities = {
	["Jump"] = Jump,
	["Shoot"] = Shoot,
	["Submerge"] = Submerge,
	["Interest"] = Interest,
	["Dive"] = Dive,
	["Overheat"] = Overheat
}
