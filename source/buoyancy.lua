-- Clamp
import "utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- NOTE: Returns the buoyancy force and the water drag in that order
function CalculateBuoyancy(WaterHeight, ObjectHeight, WaterPixelDepth, WaterDrag, buoyantForce, physicsObject, waterDepth)
	-- Deals with player buoyancy
	local DesiredHeight = WaterHeight - waterDepth
	local DirectionToWater = (ObjectHeight - DesiredHeight)
	local DirectionToWaterNormalized = DirectionToWater / math.abs(DirectionToWater)
	if DirectionToWater == 0 then
		DirectionToWaterNormalized = 0
	end

	-- Buoyancy values
	local displacementNum = Clamp(math.abs(DirectionToWater), 0, WaterPixelDepth) / WaterPixelDepth

	-- Applies buoyancy forces and water drag
	if DirectionToWater > 0 then
		return pd.geometry.vector2D.new(0, -DirectionToWaterNormalized * buoyantForce * displacementNum), pd.geometry.vector2D.new(0, -physicsObject.Velocity.y * WaterDrag)
	end

	return pd.geometry.vector2D.new(0, 0), pd.geometry.vector2D.new(0, 0)
end
