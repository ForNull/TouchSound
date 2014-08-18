
require("framework.scheduler")
local Keys = import("..sprites.Keys")
local KeysBack = import("..sprites.KeysBack")
local MusicScore = import("..data.MusicScore")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local waitTimeValue = 50
local waitTime = waitTimeValue
local textFont = "Tahoma"
local textFont_bold = "Tahoma"
local textColor = ccc3(248, 243, 223)
local playStatus = {"dead", "waitToPlay", "playing", "splash"}
local px, py = display.cx, display.bottom + 388
local keyAreaWidth, keyAreaHeight = 590, 590
local keyWidth = 140
local dragThreshold = 40

function MainScene:ctor()
    -- touchLayer 用于接收触摸事件
    -- self.touchLayer = display.newColorLayer(ccc4(247,247,239,255))
    self.touchLayer = display.newColorLayer(ccc4(0,0,0,255))
    self.touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouches(event)
    end)
    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    self:addChild(self.touchLayer, -20)

    local mainBg = display.newSprite("pic/main_bg3.png")
    mainBg:setAnchorPoint(ccp(0.5, 0))
    mainBg:setPosition(display.cx, 0)
    self:addChild(mainBg, -10)

    --批渲染
    self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE)
    self:addChild(self.batch, -9)

    self:initLabels()
    -- self:initProgress()

    --添加菜单按钮
    self.menu = display.newSprite("#menu1.png", display.right - 70, display.top - 65)
    self:addChild(self.menu,100)
    -- self.menu:setTouchEnabled(true)
    -- self.menu:addTouchEventListener(function(event, x, y)
    --     return self:onTouchMenu(event, x, y)
    -- end)

    
    -- self.keyArea = display.newClippingRegionNode(CCRect(px - keyAreaWidth / 2, py - keyAreaHeight / 2, px + keyAreaWidth / 2, py + keyAreaHeight / 2))
    self.keyArea = display.newClippingRegionNode(CCRect(px - keyAreaWidth / 2, py - keyAreaHeight / 2, keyAreaWidth, keyAreaHeight))
    self:addChild(self.keyArea, -8)

    --添加键盘区底色
    self.bg = display.newSprite("#bg.png", px, py)
    self.keyArea:addChild(self.bg)

    --菜单层
    self.menuBg = display.newSprite()
    self.menuBg:setPosition(display.cx, display.cy)
    self.menuBg:setTextureRect(CCRect(0, 0, 640, 1140))
    self.menuBg:setColor(ccc3(123, 123, 123))
    self.menuBg:setOpacity(200)
    self:addChild(self.menuBg, 0)
    self.menuBg:setVisible(false)

    --按键背景
    self.keysBacks = {}
    self.positions = {}
    for i=0,15 do
        local key = KeysBack.new()
        key:setPlace(i, px, py)
        self.keyArea:addChild(key)
        self.keysBacks[#self.keysBacks + 1] = key
        key.tag = i + 1 --从左往右，从下往上

        self.positions[#self.positions + 1] = {x = key:getPositionX(), y = key:getPositionY()}
    end

    self.waitTag = waitTime
    self.waitKeys = {}
    self.dragKeys = {}
    self.status = "dead"
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

function MainScene:keyPressed(key)
    -- for i,v in ipairs(self.waitKeys) do
    --     if v.tag == key.tag then
    --         table.remove(self.waitKeys, i)                    
            -- key:keyDown()

            -- local i = math.random(26)

            audio.playSound(PIANO_SOUND[self:getMusicScore()], false)
            self:performWithDelay(function()
                -- key:keyUp()
                self.keyArea:removeChild(key, true)
            end, 0.03)
            -- key:keyUp()

            if self.status == "waitToPlay" then
                self.status = "playing"
                -- self.waitTag = waitTime
            end

            self.score = self.score + 1
            self.scoreLabel:setString(self.score)
            if highScore < self.score then
                highScore = self.score
                self.highScoreLabel:setString(highScore)
            end

    --         break
    --     end
    -- end

    -- if #self.waitKeys == 0 then
        -- self:performWithDelay(function()
        --     self:genWaitKeys()
        -- end, 0.3)
    --     self:genWaitKeys()
    -- end
end

function MainScene:keyDragBegan(keyWait, id, x, y)
    local key = {}
    key.id = id
    key.x = x
    key.y = y
    key.tag = keyWait.tag
    key.type = keyWait.type
    self.dragKeys[#self.dragKeys + 1] = key
end

function MainScene:keyDragMoved(keyDrag, id, x, y)
    local startX = keyDrag.x
    local startY = keyDrag.y
    local num, keyWait, keyX, keyY
    local dragNum

    for i,v in ipairs(self.waitKeys) do
        if v.tag == keyDrag.tag then
            num = i
            keyWait = v
            keyX = v:getPositionX()
            keyY = v:getPositionY()
        end
    end

    -- for i,v in ipairs(self.dragKeys) do
    --     if v.tag == keyDrag.tag then
    --         dragNum = i
    --     end
    -- end
    if num then
        if keyDrag.type == 1 and ((math.abs(startY - y) >= dragThreshold) or (math.abs(startX - x) >= dragThreshold)) then
            self:gameEnded(keyWait)
        elseif (keyDrag.type == 2 and y - startY >= dragThreshold) or (keyDrag.type == 3 and x - startX >= dragThreshold)
            or (keyDrag.type == 4 and startX - x >= dragThreshold) or (keyDrag.type == 5 and startY - y >= dragThreshold) then
            self:gameEnded(keyWait)
        elseif keyDrag.type == 2 and startY - y >= dragThreshold then
            table.remove(self.waitKeys, num)

            audio.playSound(PIANO_SOUND[self:getMusicScore()], false)
            local action = CCMoveTo:create(0.15, ccp(keyX, py - keyAreaHeight / 2 - keyWidth))
            local action2 = CCCallFuncN:create(handler(self, self.removeKey))
            local action3 = CCRotateBy:create(0.15, 360)
            local action4 = CCScaleBy:create(0.15, 0.5)
            keyWait:runAction(transition.sequence({action,action2,}))
            keyWait:runAction(action3)
            keyWait:runAction(action4)

            self.score = self.score + 1
            self.scoreLabel:setString(self.score)
            if highScore < self.score then
                highScore = self.score
                self.highScoreLabel:setString(highScore)
            end

            return false

        elseif keyDrag.type == 3 and startX - x >= dragThreshold then
            table.remove(self.waitKeys, num)

            audio.playSound(PIANO_SOUND[self:getMusicScore()], false)
            local action = CCMoveTo:create(0.15, ccp(px - keyAreaHeight / 2 - keyWidth, keyY))
            local action2 = CCCallFuncN:create(handler(self, self.removeKey))
            local action3 = CCRotateBy:create(0.15, 360)
            local action4 = CCScaleBy:create(0.15, 0.5)
            keyWait:runAction(transition.sequence({action,action2,}))
            keyWait:runAction(action3)
            keyWait:runAction(action4)

            self.score = self.score + 1
            self.scoreLabel:setString(self.score)
            if highScore < self.score then
                highScore = self.score
                self.highScoreLabel:setString(highScore)
            end

            return false

        elseif keyDrag.type == 4 and x - startX >= dragThreshold then
            table.remove(self.waitKeys, num)

            audio.playSound(PIANO_SOUND[self:getMusicScore()], false)
            local action = CCMoveTo:create(0.15, ccp(px + keyAreaHeight / 2 + keyWidth, keyY))
            local action2 = CCCallFuncN:create(handler(self, self.removeKey))
            local action3 = CCRotateBy:create(0.15, 360)
            local action4 = CCScaleBy:create(0.15, 0.5)
            keyWait:runAction(transition.sequence({action,action2,}))
            keyWait:runAction(action3)
            keyWait:runAction(action4)

            self.score = self.score + 1
            self.scoreLabel:setString(self.score)
            if highScore < self.score then
                highScore = self.score
                self.highScoreLabel:setString(highScore)
            end

            return false

        elseif keyDrag.type == 5 and y - startY >= dragThreshold then
            table.remove(self.waitKeys, num)

            audio.playSound(PIANO_SOUND[self:getMusicScore()], false)
            local action = CCMoveTo:create(0.15, ccp(keyX, py + keyAreaHeight / 2 + keyWidth))
            local action2 = CCCallFuncN:create(handler(self, self.removeKey))
            local action3 = CCRotateBy:create(0.15, 360)
            local action4 = CCScaleBy:create(0.15, 0.5)
            keyWait:runAction(transition.sequence({action,action2,}))
            keyWait:runAction(action3)
            keyWait:runAction(action4)

            self.score = self.score + 1
            self.scoreLabel:setString(self.score)
            if highScore < self.score then
                highScore = self.score
                self.highScoreLabel:setString(highScore)
            end

            return false
            
        end
    end
    
end

function MainScene:keyDragEnded(keyDrag, id, x, y)
    for i,v in ipairs(self.waitKeys) do
        if v.tag == keyDrag.tag then
            if keyDrag.type == 1 then
                table.remove(self.waitKeys, i)
                self:keyPressed(v)
            else
                self:gameEnded(v)
            end
        end
    end
end

function MainScene:removeKey(key)
    self.keyArea:removeChild(key, true)
end

function MainScene:onTouches(event)
    for id, point in pairs(event.points) do
        self:onTouch(event.name, point.id, point.x, point.y)
    end
end

function MainScene:onTouch(eventName, id, x, y)
    if eventName == "began" then
        self:onTouchBegan(eventName, id, x, y)
    elseif eventName == "moved" then
        self:onTouchMoved(eventName, id, x, y)
    elseif eventName == "ended" then
        self:onTouchEnded(eventName, id, x, y)
    else -- cancled
        self:onTouchCancelled(eventName, id, x, y)
    end
end

function MainScene:onTouchBegan(eventName, id, x, y)
    local p = ccp(x, y)
    
    --playing
    if self.status == "playing" then
        for i,keysback in ipairs(self.keysBacks) do --背景按键循环
            if keysback:getBoundingBox():containsPoint(p) then --如果按到了按键
                local isWaitKey = false
                for ii,keyWait in ipairs(self.waitKeys) do --等待按键循环
                    if keyWait:getBoundingBox():containsPoint(p) then
                        isWaitKey = true
                        self:keyDragBegan(keyWait, id, x, y)

                        return true

                        -- if keyWait.type == 1 then
                        --     table.remove(self.waitKeys, ii)
                        --     self:keyPressed(keyWait)
                        --     return false
                        -- else
                        --     self:keyDragBegan(keyWait, id, x, y)
                        --     return true
                        -- end
                        -- break
                    end
                end

                if not isWaitKey then --按到了其他按键上
                    self:gameEnded(keysback)
                    return false
                end
            end
        end  
    --wait to play
    elseif self.status == "waitToPlay" then
        for i,v in ipairs(self.waitKeys) do
            if v:getBoundingBox():containsPoint(p) then
                if v.type == 1 then
                    table.remove(self.waitKeys, i)  
                    self:keyPressed(v, p)
                    return false
                end
            end
        end
    -- dead
    elseif self.status == "dead" then
        if self.tryAgainLabel:getBoundingBox():containsPoint(p) then
            self:restart()
        end
    end
end

function MainScene:onTouchMoved(eventName, id, x, y)
    if self.status == "playing" then
        for i,v in ipairs(self.dragKeys) do
            if v.id == id then
                self:keyDragMoved(v, id, x, y)
            end
        end
    end
end

function MainScene:onTouchEnded(eventName, id, x, y)
    if self.status == "playing" then
        for i,v in ipairs(self.dragKeys) do
            if v.id == id then
                self:keyDragEnded(v, id, x, y)
                table.remove(self.dragKeys, i)
            end
        end
    end
end

function MainScene:onTouchCancelled(eventName, id, x, y)
    -- self.drag = nil
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
    -- self.progressTime:setPercentage(100.0)
    self:enableMenu()
    waitTime = waitTimeValue
    self.level = 1

    --重置琴键
    for i = 1, #self.waitKeys do
        -- self.waitKeys[1]:keyUp()
        self.keyArea:removeChild(self.waitKeys[1], true)
        table.remove(self.waitKeys, 1)
    end

    for i = 1, #self.dragKeys do
        table.remove(self.dragKeys, 1)
    end

    --重置乐谱
    for i = 1, #self.musicScoresPlayed do
        table.remove(self.musicScoresPlayed, 1)
    end

    self.musicScoresPlaying = 0
    self.musicScorePos = 0

    self.status = "waitToPlay"
    self:genWaitKeys()
end

function MainScene:onTouchTryAgain(event, x, y)
    self:restart()
end

function MainScene:onTouchMenu(event, x, y)
    return true
end

function MainScene:genWaitKeys()
    if (self.status == "playing" and self.waitTag <= 0) or (self.status == "waitToPlay") then
        local i = math.random(5)
        self:genWaitKey(i)
        
        -- self.progressTime:setPercentage(100.0)
        self.waitTag = waitTime
    end    
end   

function MainScene:genWaitKey(type)
    local num
    while true do
        num = math.random(16)
        local flag = true

        for i,v in ipairs(self.waitKeys) do
            if v.tag == num then
                flag = false
                break
            end
        end

        if (type == 2 and (num == 1 or num == 2 or num == 3 or num == 4))
            or (type == 3 and (num == 1 or num == 5 or num == 9 or num == 13))
            or (type == 4 and (num == 4 or num == 8 or num == 12 or num == 16))
            or (type == 5 and (num == 13 or num == 14 or num == 15 or num == 16)) then
            flag = false

        end

        if flag then
            break
        end
    end

    local genedKey = Keys.new(type)
    genedKey.tag = num
    genedKey:setPosition(self.positions[num].x, self.positions[num].y)
    -- self:addChild(genedKey, -8)
    self.keyArea:addChild(genedKey)
    self.waitKeys[#self.waitKeys + 1] = genedKey
    -- genedKey:setTouchEnabled(true)
    -- genedKey:setTouchSwallowEnabled(true)
    -- genedKey:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    --     return self:keyOnTouch(event)
    -- end)

    if self.status == "playing" then        
        self.waitTag = waitTime
    elseif self.status == "waitToPlay" then
        genedKey:keyFirstWait()
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

function MainScene:gameEnded(key)    
    self.status = "splash"
    if key then
        key:keySplash(handler(self,self.gameEnded2))
    else
        for i,v in ipairs(self.waitKeys) do
            if i == 1 then
                v:keySplash(handler(self,self.gameEnded2))
            else
                v:keySplash()
            end
        end
    end   
end

function MainScene:gameEnded2()
    if self.status == "splash" then
        self.menuBg:setVisible(true)
        self:addGameOverLabel()
        self:addScoreLabel()
        self:addTryAgainLabel()
        self:disableMenu()

        if highScore > GameData.highScore then
            GameData.highScore  = highScore 
            GameState.save(GameData)
        end

        self.status = "dead"
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
        waitTime = waitTime - 10
        self.level = self.level + 1
    elseif self.level == 2 and self.score == 10 then
        waitTime = waitTime - 10
        self.level = self.level + 1
    elseif self.level == 3 and self.score == 30 then
        waitTime = waitTime - 5
        self.level = self.level + 1
    elseif self.level == 4 and self.score == 80 then
        waitTime = waitTime - 5
        self.level = self.level + 1
    elseif self.level == 5 and self.score == 110 then
        waitTime = waitTime - 1
        self.level = self.level + 1
    elseif self.level == 6 and self.score == 140 then
        waitTime = waitTime - 1
        self.level = self.level + 1
    elseif self.level == 7 and self.score == 170 then
        waitTime = waitTime - 1
        self.level = self.level + 1
    elseif self.level == 8 and self.score == 200 then
        waitTime = waitTime - 1
        self.level = self.level + 1
    elseif self.level == 8 and self.score == 250 then
        waitTime = waitTime - 1
        self.level = self.level + 1
    end
end

function MainScene:updateFrame(dt)
    if self.status == "playing" then
        self:levelUpdate()
        self.waitTag = self.waitTag - 1
        if #self.waitKeys >= 3 and self.waitTag <= 0 then
            self:gameEnded()
        else
            self:genWaitKeys()
            -- self.progressTime:setPercentage(self.progressTime:getPercentage() - 100 / waitTime)
        end
    end
    
end

function MainScene:onEnter()
    -- self.status = "waitToPlay"
    -- self:genWaitKeys()
    self:restart()

    -- self:scheduleUpdate(function(dt) self:updateFrame(dt) end)
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:updateFrame(dt) end)
    self:scheduleUpdate()

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
