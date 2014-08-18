--
-- Author: ejian
-- Date: 2014-05-19 22:25:07
--
local Keys = class("Keys", function(type)
	if type == 1 then
    	return display.newSprite("#wait.png")
    elseif type == 2 then
    	return display.newSprite("#wait_down.png")
    elseif type == 3 then
    	return display.newSprite("#wait_left.png")
    elseif type == 4 then
    	return display.newSprite("#wait_right.png")
    elseif type == 5 then
    	return display.newSprite("#wait_up.png")
	end
end)

local keyWidth = 140
local dis = 6

function Keys:ctor(type)
	self.type = type

	if type == 1 then
		self.pic = "wait.png"
    elseif type == 2 then
		self.pic = "wait_down.png"
    elseif type == 3 then
		self.pic = "wait_left.png"
    elseif type == 4 then
		self.pic = "wait_right.png"
    elseif type == 5 then
		self.pic = "wait_up.png"
	end
end

function Keys:setPlace(order, bgx, bgy)
	local a = order % 4
	local b = math.floor(order / 4)

	self.x = bgx + (a - 2) * (keyWidth + dis) + (keyWidth + dis) / 2
	self.y = bgy + (b - 2) * (keyWidth + dis) + (keyWidth + dis) / 2

	self:setPosition(self.x, self.y)
end

-- function Keys:keyDown()
-- 	self.status = "busy"
-- 	-- local spriteFrame = display.newSpriteFrame("down.png")
-- 	-- self:setDisplayFrame(spriteFrame)
-- end

-- function Keys:keyUp()
-- 	self.status = "free"
-- 	local spriteFrame = display.newSpriteFrame("up.png")
-- 	self:setDisplayFrame(spriteFrame)
-- end

-- function Keys:keyWait()
	-- self.status = "wait"
	-- local spriteFrame = display.newSpriteFrame("wait.png")
	-- self:setDisplayFrame(spriteFrame)
-- end

function Keys:keyFirstWait()
	self.type = 1
	local spriteFrame = display.newSpriteFrame("wait1.png")
	self:setDisplayFrame(spriteFrame)
end

function Keys:keySplash(funcCall)
	local keyUp = display.newSpriteFrame("up.png")
	local keyWait = display.newSpriteFrame(self.pic)
	local frames = {keyUp, keyWait, keyUp, keyWait, keyUp, keyWait}
	local animation = display.newAnimation(frames, 1 / 6)

	transition.playAnimationOnce(self,animation,false,funcCall)
end

return Keys