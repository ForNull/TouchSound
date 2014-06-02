--
-- Author: ejian
-- Date: 2014-05-22 22:24:42
--
local StartScene = class("StartScene", function()
    return display.newScene("StartScene")
end)

function StartScene:ctor()
	local bg = display.newTilesSprite("pic/start_bg.png")
    self:addChild(bg)

    self.startMenu = ui.newTTFLabelWithShadow({
            text  = "Start",
            font  = "High Tower Text",
            x     = display.cx,
            y     = display.cy,
            align = ui.TEXT_ALIGN_CENTER,
            size  = 70,
        })
    self:addChild(self.startMenu)
    self.startMenu:setTouchEnabled(true)
    self.startMenu:addTouchEventListener(function(event, x, y)
    	app:enterMainScene()
    end)
end


return StartScene