local pd <const> = playdate
import "scripts/bullet"

function Jump(player)
	player:AddForce(pd.geometry.vector2D.new(0, -8))
	player.bCanJump = false
end

function Shoot(player)
	Bullet(player.PhysicsComponent.Position.x + player.direction * 40, player.PhysicsComponent.Position.y - 5, pd.geometry.vector2D.new(player.direction * 15, 0))
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

Abilities = {["Jump"] = Jump, ["Shoot"] = Shoot, ["Submerge"] = Submerge}
