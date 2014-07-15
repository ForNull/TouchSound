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

return KeysBack