
require("framework.scheduler")
local Keys = import("..sprites.Keys")
local MusicScore = import("..data.MusicScore")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local waitTime = 120
local textFont = "Tahoma"
local textFont_bold = "Tahoma"
local textColor = ccc3(248, 243, 223)

function MainScene:ctor()
    -- touchLayer 用于接收触摸事件
    -- self.touchLayer = display.newColorLayer(ccc4(247,247,239,255))
    self.touchLayer = display.newColorLayer(ccc4(0,0,0,255))
    self.touchLayer:addTouchEventListener(function(event, points)
        return self:onTouch(event, points)
    end, true)
    self.touchLayer:setTouchEnabled(true)
    self:addChild(self.touchLayer, -20)

    local mainBg = display.newSprite("pic/main_bg3.png")
    mainBg:setAnchorPoint(ccp(0.5, 0))
    mainBg:setPosition(display.cx, 0)
    self:addChild(mainBg, -10)

    --批渲染
    self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE)
    self:addChild(self.batch, -9)

    self:initLabels()
    self:initProgress()

    --添加菜单按钮
    self.menu = display.newSprite("#menu1.png", display.right - 70, display.top - 65)
    self:addChild(self.menu,100)
    -- self.menu:setTouchEnabled(true)
    -- self.menu:addTouchEventListener(function(event, x, y)
    --     return self:onTouchMenu(event, x, y)
    -- end)

    --添加键盘背景
    self.bg = display.newSprite("#bg.png", display.cx, display.bottom + 388)
    self.batch:addChild(self.bg)

    --菜单层
    self.menuBg = display.newSprite()
    self.menuBg:setPosition(display.cx, display.cy)
    self.menuBg:setTextureRect(CCRect(0, 0, 640, 1140))
    self.menuBg:setColor(ccc3(123, 123, 123))
    self.menuBg:setOpacity(200)
    self:addChild(self.menuBg, 0)
    self.menuBg:setVisible(false)

    self.keysUp = {}
    for i=0,15 do
        local key = Keys.new("#up.png")
        key:setPlace(i, display.cx, display.bottom + 388)
        self.batch:addChild(key)
        self.keysUp[#self.keysUp + 1] = key
        key.tag = i + 1 --从左往右，从下往上
    end

    self.waitTag = 0
    self.waitKeys = {}
    self.lastKeys = {}
    self.playStatus = {"dead", "waitToPlay", "playing", "splash"}
    self.status = self.playStatus[1]
    self.musicScoresPlayed = {}
    self.musicScoresPlaying = 0
    self.musicScorePos = 0
    self.level = 1
end

function MainScene:initProgress()
    local progress = display.newSprite("pic/progress.png")
    -- self:addChild(progress, -9)
    self.progressTime = CCProgressTimer:create(progress)
    self.progressTime:setPercentage(100.0)
    -- self.progressTime:setMidpoint(ccp(1,0))
    self.progressTime:setBarChangeRate(ccp(1,0))
    self.progressTime:setType(kCCProgressTimerTypeBar)
    self.progressTime:setPosition(display.cx, display.top - 230)

    self:addChild(self.progressTime)
    -- local a = CCProgressTo:create(2,100)
    -- self.progressTime:runAction(CCRepeatForever:create(a))
end

function MainScene:initLabels()
    self.score = 0
    self.scoreTxtLabel = ui.newTTFLabel({
            text  = "SCORE",
            font  = textFont,
            x     = display.left + 150,
            y     = display.top - 60,
            align = ui.TEXT_ALIGN_CENTER,
            size  = 50,
        })
    self:addChild(self.scoreTxtLabel,100)
    self.scoreLabel = ui.newTTFLabel({
            text  = "0",
            font  = textFont,
            x     = display.left + 150,
            y     = display.top - 140,
            align = ui.TEXT_ALIGN_CENTER,
            size  = 100,
        })
    self:addChild(self.scoreLabel,100)

    local highScoreBg = display.newSprite("#score_bg.png", display.right - 220, display.top - 80)
    self:addChild(highScoreBg, 100)
    self.high_score_txt = ui.newTTFLabel({
            text  = "BEST",
            font  = textFont_bold,
            x     = display.right - 220,
            y     = display.top - 65,
            align = ui.TEXT_ALIGN_CENTER,
            size  = 26,
            color = ccc3(115, 109, 99),
        })
    self:addChild(self.high_score_txt,100)
    self.highScoreLabel = ui.newTTFLabel({
            text  = highScore,
            font  = textFont,
            x     = display.right - 220,
            y     = display.top - 95,
            align = ui.TEXT_ALIGN_CENTER,
            size  = 32,
            color = ccc3(115, 109, 99),
        })
    self:addChild(self.highScoreLabel,100)
end

function MainScene:keyPressed(key, p)
    for i,v in ipairs(self.waitKeys) do
        if v.tag == key.tag then
            self.lastKeys[#self.lastKeys + 1] = v
            table.remove(self.waitKeys, i)                    
            key:keyDown()

            -- local i = math.random(26)

            audio.playSound(PIANO_SOUND[key.tone], false)
            self:performWithDelay(function()
                key:keyUp()
            end, 0.03)
            -- key:keyUp()

            if self.status == self.playStatus[2] then
                self.status = self.playStatus[3]
                self.waitTag = waitTime
            end

            self.score = self.score + 1
            self.scoreLabel:setString(self.score)
            if highScore < self.score then
                highScore = self.score
                self.highScoreLabel:setString(highScore)
            end

            break
        end
    end

    if #self.waitKeys == 0 then
        -- self:performWithDelay(function()
        --     self:genWaitKeys()
        -- end, 0.3)
        self:genWaitKeys()
    end
end

function MainScene:onTouch(event, points)
    -- print(11111111111111111111)
    -- print(event)
    local tp = {}
    for i=1, #points, 3 do
        -- print(points[i+2].." "..points[i].." "..points[i+1])
        local p = ccp(points[i], points[i + 1])
        tp[#tp + 1] = p
    end

    if event == "began" then
        --playing
        if self.status == self.playStatus[3] then
            for i,v in ipairs(tp) do
                for _i,_v in ipairs(self.keysUp) do
                    if _v:getBoundingBox():containsPoint(v) then
                        if _v.type == "wait" then
                            self:keyPressed(_v, v)
                        else
                            self:gameEnded()
                        end
                    end
                end
            end
        --wait to play
        elseif self.status == self.playStatus[2] then
            for i,v in ipairs(tp) do
                for _i,_v in ipairs(self.keysUp) do
                    if _v:getBoundingBox():containsPoint(v) then
                        if _v.type == "wait" then
                            self:keyPressed(_v, v)
                        end
                    end
                end
            end
        -- dead
        elseif self.status == self.playStatus[1] then
            for i,v in ipairs(tp) do
                if self.tryAgainLabel:getBoundingBox():containsPoint(v) then
                    self:restart()
                end
            end
        end
    elseif event == "moved" then

    elseif event == "ended" then

    else -- cancled

    end

    return true
end

function MainScene:restart()
    self.score = 0
    self.scoreLabel:setString("0")
    self:removeChild(self.gameOverLabel,true)
    self:removeChild(self.yourScoreLabel,true)
    self:removeChild(self.getScoreLabel,true)
    self:removeChild(self.pointsLabel,true)
    self:removeChild(self.tryAgainLabel,true)
    self.menuBg:setVisible(false)
    self.progressTime:setPercentage(100.0)
    self:enableMenu()
    waitTime = 120
    self.level = 1

    --重置琴键
    for i = 1, #self.waitKeys do
        self.waitKeys[1]:keyUp()
        table.remove(self.waitKeys, 1)
    end

    for i = 1, #self.lastKeys do
        table.remove(self.lastKeys, 1)
    end

    --重置乐谱
    for i = 1, #self.musicScoresPlayed do
        table.remove(self.musicScoresPlayed, 1)
    end

    self.musicScoresPlaying = 0
    self.musicScorePos = 0

    self.status = self.playStatus[2]
    self:genWaitKeys()
end

function MainScene:onTouchTryAgain(event, x, y)
    self:restart()
end

function MainScene:onTouchMenu(event, x, y)
    return true
end

function MainScene:genWaitKeys()
    if #self.waitKeys == 0 then
        if self.level == 1 or self.level == 2 or self.level == 3  then
            self:genWaitKey(1)
        elseif self.level >= 4 then
            local num = math.random(2)
            if num == 1 then
                self:genWaitKey(1)
            else
                self:genWaitKey(1)
                -- self:genWaitKey(1)
                self:genWaitKey(1, self.waitKeys[#self.waitKeys].tone)
            end
        end

        while #self.lastKeys > 0 do
            table.remove(self.lastKeys)
        end
        
        self.progressTime:setPercentage(100.0)
    end    
end

function MainScene:genWaitKey(type, tone)
    local num
    while true do
        num = math.random(16)
        local flag = true
        for i,v in ipairs(self.lastKeys) do
            if v.tag == num then
                flag = false
            end
        end

        for i,v in ipairs(self.waitKeys) do
            if v.tag == num then
                flag = false
            end
        end

        if flag then
            break
        end
    end

    for i,v in ipairs(self.keysUp) do
        if v.tag == num then
            self.waitKeys[#self.waitKeys + 1] = v
            if tone then
                v.tone = tone
            else
                v.tone = self:getMusicScore()
            end

            if self.status == self.playStatus[3] then
                if type == 1 then
                    v:keyWait()
                end
                self.waitTag = waitTime
            elseif self.status == self.playStatus[2] then
                v:keyFirstWait()
            end
        end
    end
end

--获取当前音调
function MainScene:getMusicScore()
    --如果还没有生成乐谱，则随机生成一个
    if self.musicScoresPlaying == 0 then
        self.musicScoresPlaying = math.random(1, MusicScore.num())
        self.musicScoresPlayed[#self.musicScoresPlayed + 1]  = self.musicScoresPlaying
        self.musicScorePos = 1
    end

    --记录当前乐谱音调
    local music = MusicScore.getTone(self.musicScoresPlaying, self.musicScorePos) + 7

    --如果已到当前乐谱的最后一个音
    if self.musicScorePos == MusicScore.getToneNum(self.musicScoresPlaying) then
        --如果还有乐谱没有生成
        if #self.musicScoresPlayed < MusicScore.num() then
            local index = 0
            while true do
                local j = math.random(1, MusicScore.num())
                local flag = true
                for i,v in ipairs(self.musicScoresPlayed) do
                    if v == j then
                        flag = false
                    end
                end

                if flag then
                    index = j
                    break
                end
            end

            self.musicScoresPlayed[#self.musicScoresPlayed + 1] = index
            self.musicScoresPlaying = index
            self.musicScorePos = 1
        --如果乐谱都已耗尽
        else
            --重置乐谱
            for _i,_v in ipairs(self.musicScoresPlayed) do
                table.remove(self.musicScoresPlayed, _i)
            end
            self.musicScoresPlaying = 0
            self.musicScorePos = 0

            return self:getMusicScore()
        end
    else
        self.musicScorePos = self.musicScorePos + 1
    end

    return music
end

function MainScene:gameEnded()    
    self.status = self.playStatus[4]
    for i,v in ipairs(self.waitKeys) do
        if i == 1 then
            v:keySplash(handler(self,self.gameEnded2))
        else
            v:keySplash()
        end
    end

    
end

function MainScene:gameEnded2()
    if self.status == self.playStatus[4] then
        self.menuBg:setVisible(true)
        self:addGameOverLabel()
        self:addScoreLabel()
        self:addTryAgainLabel()
        self:disableMenu()

        if highScore > GameData.highScore then
            GameData.highScore  = highScore 
            GameState.save(GameData)
        end

        self.status = self.playStatus[1]
    end
end

function MainScene:addGameOverLabel()
    self.gameOverLabel = ui.newTTFLabel({
            text  = "Game Over",
            font  = textFont,
            x     = display.cx,
            y     = display.bottom + 500,
            align = ui.TEXT_ALIGN_CENTER,
            size  = 80,
            color = textColor,
        })
    self:addChild(self.gameOverLabel,100)
end

function MainScene:addScoreLabel()
    self.yourScoreLabel = ui.newTTFLabel({
            text  = "Your score",
            font  = textFont,
            x     = display.cx,
            y     = display.bottom + 430,
            align = ui.TEXT_ALIGN_RIGHT,
            size  = 30,
            color = textColor,
        })
    self:addChild(self.yourScoreLabel,100)

    self.getScoreLabel = ui.newTTFLabel({
            text  = self.score,
            font  = textFont,
            x     = display.cx + 10,
            y     = display.bottom + 430,
            align = ui.TEXT_ALIGN_LEFT,
            size  = 30,
            color = ccc3(255,0,0),
        })
    self:addChild(self.getScoreLabel,100)

    self.pointsLabel = ui.newTTFLabel({
            text  = "points",
            font  = textFont,
            x     = display.cx + 10 + self.getScoreLabel:getContentSize().width + 10,
            y     = display.bottom + 430,
            align = ui.TEXT_ALIGN_LEFT,
            size  = 30,
            color = textColor,
        })
    self:addChild(self.pointsLabel,100)
end

function MainScene:addTryAgainLabel()
    self.tryAgainLabel = ui.newTTFLabel({
            text  = "Try Again",
            font  = textFont,
            x     = display.cx,
            y     = display.bottom + 300,
            align = ui.TEXT_ALIGN_CENTER,
            size  = 50,
            color = textColor,
        })
    self:addChild(self.tryAgainLabel,100)
    -- self.tryAgainLabel:setTouchEnabled(true)
    -- self.tryAgainLabel:addTouchEventListener(function(event, x, y)
    --     return self:onTouchTryAgain(event, x, y)
    -- end)
end

function MainScene:enableMenu()
    local spriteFrame = display.newSpriteFrame("menu1.png")
    self.menu:setDisplayFrame(spriteFrame)
end

function MainScene:disableMenu()
    local spriteFrame = display.newSpriteFrame("menu2.png")
    self.menu:setDisplayFrame(spriteFrame)
end

function MainScene:levelUpdate()
    if self.level == 1 and self.score == 5 then
        waitTime = waitTime - 20
        self.level = self.level + 1
    elseif self.level == 2 and self.score == 10 then
        waitTime = waitTime - 20
        self.level = self.level + 1
    elseif self.level == 3 and self.score == 15 then
        waitTime = waitTime - 20
        self.level = self.level + 1
    elseif self.level == 4 and self.score == 20 then
    --     waitTime = waitTime - 10
    --     self.level = self.level + 1
    -- elseif self.level == 5 and self.score == 25 then
    --     waitTime = waitTime - 10
    --     self.level = self.level + 1
    -- elseif self.level == 6 and self.score == 30 then
        self.level = self.level + 1
        waitTime = 90
    end
end

function MainScene:updateFrame(dt)
    if self.status == self.playStatus[3] then
        if self.waitTag == 0 and #self.waitKeys > 0 then
            self:gameEnded()
        else
            self:levelUpdate()
            self.waitTag = self.waitTag - 1
            self.progressTime:setPercentage(self.progressTime:getPercentage() - 100 / waitTime)
        end
    end
    
end

function MainScene:onEnter()
    -- self.status = self.playStatus[2]
    -- self:genWaitKeys()
    self:restart()

    self:scheduleUpdate(function(dt) self:updateFrame(dt) end)

    if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then CCDirector:sharedDirector():endToLua() end
            end)
            self:addChild(layer)

            layer:setKeypadEnabled(true)
        end, 0.5)
    end
end

function MainScene:onExit()
end

return MainScene
