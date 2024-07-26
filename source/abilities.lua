local pd <const> = playdate
import "bullet"

function Jump(player)
	player:AddForce(pd.geometry.vector2D.new(0, -8))
	player.bCanJump = false
end

function Shoot(player)
	Bullet(player.PhysicsComponent.Position.x + player.direction * 40, player.PhysicsComponent.Position.y - 5, pd.geometry.vector2D.new(player.direction * 15, 0))
end

Abilities = {["Jump"] = Jump, ["Shoot"] = Shoot}
