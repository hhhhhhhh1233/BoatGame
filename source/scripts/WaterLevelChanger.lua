local pd <const> = playdate
local gfx <const> = pd.graphics

class('WaterLevelChanger').extends(gfx.sprite)

function WaterLevelChanger:init(x, y, Entity)
	self:setCenter(0, 0)
	self:moveTo(x - 32, y - 32)

    self.minHeight = Entity.fields.MinHeight.cy * 16
    self.maxHeight = Entity.fields.MaxHeight.cy * 16
    self.rateOfChange = Entity.fields.RateOfChange

    self.downImage = gfx.image.new("images/WaterDown")
    self.upImage = gfx.image.new("images/WaterUp")

    if self.rateOfChange < 0 then
        self:setImage(self.upImage)
    else
        self:setImage(self.downImage)
    end

	self:setZIndex(-1)

	self:add()
end

function WaterLevelChanger:update()
    if SceneManager.water.bActive then
        return
    end

    SceneManager.water.height += self.rateOfChange
    
    if SceneManager.water.height > self.minHeight or SceneManager.water.height < self.maxHeight then
        print(SceneManager.water.height.." "..self.minHeight.." "..self.maxHeight)
        self.rateOfChange *= -1
        if self.rateOfChange < 0 then
            self:setImage(self.upImage)
        else
            self:setImage(self.downImage)
        end
    end
end
