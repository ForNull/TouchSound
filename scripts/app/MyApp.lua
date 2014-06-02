
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")
require("framework.scheduler")
GameState=require(cc.PACKAGE_NAME .. ".api.GameState")

GameData={}   
highScore = 0

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    display.addSpriteFramesWithFile(GAME_TEXTURE_DATA, GAME_TEXTURE_IMAGE)

    -- preload all sounds
    for k, v in pairs(PIANO_SOUND) do
        audio.preloadSound(v)
    end

    --init GameState
    GameState.init(function(param)
        local returnValue = nil
        if param.errorCode then
            print("GameState error")
        else
        -- crypto
        if param.name=="save" then
            local str=json.encode(param.values)
            str=crypto.encryptXXTEA(str, "fornull")
            returnValue={data=str}
        elseif param.name=="load" then
            local str=crypto.decryptXXTEA(param.values.data, "fornull")
            returnValue=json.decode(str)
        end
        -- returnValue=param.values
    end
    return returnValue
    end, "data.txt","1234")

    GameData = GameState.load()
    if not GameData then
        GameData={}         
        GameData.highScore = 0
        GameState.save(GameData)
    end

    highScore = GameData.highScore
    
    self:enterScene("MainScene")
end

function MyApp:enterMainScene()
    self:enterScene("MainScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:enterStartScene()
    self:enterScene("StartScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

return MyApp
