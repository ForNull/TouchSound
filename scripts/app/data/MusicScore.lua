--
-- Author: ejian
-- Date: 2014-05-29 22:48:39
--
local MusicScore = {}

local musicData = {}

--洋娃娃和小熊跳舞（波兰）
musicData[1] = {1,2,3,4,5,5,5,4,3,4,4,4,3,2,1,3,5,1,2,3,4,5,5,5,4,3,4,4,4,3,2,1,3,1,6,6,6,5,4,5,5,5,4,3,4,4,4,3,2,1,3,5,6,6,6,5,4,5,5,5,4,3,4,4,4,3,2,1,3,1}

--女人花
musicData[2] = {3,5,5,6,5,3,5,5,6,5,1,2,3,8,6,3,5,5,6,8,8,9,8,6,5,6,3,2,1,-1,1,2,5,3,2,1,3,5,10,10,10,9,9,8,5,3,5,8,8,8,6,6,5,3,3,5,10,10,10,9,9,8,6,6,8,9,9,8,9,10,7,6,5,5,3,5,5,6,5,3,5,5,6,5,1,2,3,8,6,3,5,5,6,8,8,9,8,6,5,6,3,2,1,-1,1,2,5,3,2,3,2,1,1}

--《天鹅湖》序曲
musicData[3] = {3,-1,0,1,2,3,1,3,1,3,-1,1,-1,-3,1,-1,-1,2,1,0,3,-1,0,1,2,3,1,3,1,3,-1,1,-1,-3,1,-1,0,1,2,3,4,5,4,3,4,5,6,5,4,5,6,7,6,3,1,0,-1,0,1,2,3,4,5,4,3,4,5,6,5,4,1,5,6,6,5,2,4,6,7,4,7,10,-1,0,1,2,3,1,3,1,3,-1,1,-1,-3,1,-1,-1,2,1,0,3,-1,0,1,2,3,1,3,1,3,-1,1,-1,-3,1,-1,3,2,1,0,-1,-4,-1,1,3,-1,1,3,6}

function MusicScore.num()
	return #musicData
end

function MusicScore.getMusic(index)	
    assert(index >= 1 and index <= #musicData, string.format("MusicScore.getMusic() - invalid index %s", tostring(index)))
    return clone(musicData[index])
end

function MusicScore.getToneNum(index)	
    assert(index >= 1 and index <= #musicData, string.format("MusicScore.getMusic() - invalid index %s", tostring(index)))
    return #musicData[index]
end

function MusicScore.getTone(musicIndex, toneIndex)
	local music = MusicScore.getMusic(musicIndex)
    assert(toneIndex >= 1 and toneIndex <= #music, string.format("MusicScore.getTone() - invalid toneIndex %s", tostring(toneIndex)))
	return music[toneIndex]
end



return MusicScore