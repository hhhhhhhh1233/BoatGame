import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics

local playerSprite = nil

local function myGameSetUp()
	local playerImage = gfx.image.new("images/Boat")
	assert(playerImage)

	playerSprite = gfx.sprite.new(playerImage)
	playerSprite:moveTo(200,120)
	playerSprite:add()
end

myGameSetUp()

local BoatSpeed = 5
local WaterHeight = 100

function playdate.update()
	-- Gets input from crank and changes water height and boat y position
	local change, acceleratedChange = playdate.getCrankChange()
	WaterHeight += change
	local WaterYPosition = playdate.display.getHeight() - WaterHeight
	playerSprite:moveTo(playerSprite.x, WaterYPosition - 16)

	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		playerSprite:moveBy(-BoatSpeed, 0)
		playerSprite:setImageFlip(gfx.kImageFlippedX)
	end
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		playerSprite:moveBy(BoatSpeed, 0)
		playerSprite:setImageFlip(gfx.kImageUnflipped)
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()

	-- Draws the water
	local WaterWidth = playdate.display.getWidth()
	gfx.fillRect(0, WaterYPosition, WaterWidth, WaterHeight)
end
