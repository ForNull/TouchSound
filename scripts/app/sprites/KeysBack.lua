--
-- Author: Fornull Studio
-- Date: 2014-07-15 22:14:27
--
local KeysBack = class("KeysBack", function()
    return display.newSprite("#up.png")
end)

local keyWidht = 140
local dis = 6

function KeysBack:ctor()
	self.type = "free"
end

function KeysBack:setPlace(order, bgx, bgy)
	local a = order % 4
	local b = math.floor(order / 4)

	self:setPosition(bgx + (a - 2) * (keyWidht + dis) + (keyWidht + dis) / 2, bgy + (b - 2) * (keyWidht + dis) + (keyWidht + dis) / 2)
end

function KeysBack:keySplash(funcCall)
	local keyUp = display.newSpriteFrame("down.png")
	local keyWait = display.newSpriteFrame("up.png")
	local frames = {keyUp, keyWait, keyUp, keyWait, keyUp, keyWait}
	local animation = display.newAnimation(frames, 1 / 6)

	transition.playAnimationOnce(self,animation,false,funcCall)
end

return KeysBack