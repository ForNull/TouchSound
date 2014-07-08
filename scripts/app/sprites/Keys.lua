--
-- Author: ejian
-- Date: 2014-05-19 22:25:07
--
local Keys = class("Keys", function(pic)
    return display.newSprite(pic)
end)

local keyWidht = 140
local dis = 6

function Keys:ctor()
	self.type = "free"
end

function Keys:setPlace(order, bgx, bgy)
	local a = order % 4
	local b = math.floor(order / 4)

	self:setPosition(bgx + (a - 2) * (keyWidht + dis) + (keyWidht + dis) / 2, bgy + (b - 2) * (keyWidht + dis) + (keyWidht + dis) / 2)
end

function Keys:keyDown()
	self.type = "busy"
	local spriteFrame = display.newSpriteFrame("down.png")
	self:setDisplayFrame(spriteFrame)
end

function Keys:keyUp()
	self.type = "free"
	local spriteFrame = display.newSpriteFrame("up.png")
	self:setDisplayFrame(spriteFrame)
end

function Keys:keyWait()
	self.type = "wait"
	local spriteFrame = display.newSpriteFrame("wait.png")
	self:setDisplayFrame(spriteFrame)
end

function Keys:keyFirstWait()
	self.type = "wait"
	local spriteFrame = display.newSpriteFrame("wait1.png")
	self:setDisplayFrame(spriteFrame)
end

function Keys:keySplash(funcCall)
	self.type = "free"
	local keyUp = display.newSpriteFrame("up.png")
	local keyWait = display.newSpriteFrame("wait.png")
	local frames = {keyUp, keyWait, keyUp, keyWait, keyUp, keyWait}
	local animation = display.newAnimation(frames, 1 / 6)

	transition.playAnimationOnce(self,animation,false,funcCall)
end

return Keys