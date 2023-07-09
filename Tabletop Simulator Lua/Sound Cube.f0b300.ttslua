MUTED = false

SOUND_INFO = {
    BUTTON = 0,
    PLOP = 1,
    SWOOSH = 2,
    UNHOLY = 3,
    WRONG = 4,
    LAUGH = 5,
    HOLY = 6,
    DEATH = 7
}

function onLoad(saved_data)

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.muted then
            MUTED = loaded_data.muted
        end
    end
end

function onSave()
    return JSON.encode({muted = MUTED})
end

local function play(effectID)
    if not MUTED then
        self.AssetBundle.playTriggerEffect(effectID)
    end
end

function mute()
    MUTED = true
end

function unmute()
    MUTED = false
end

function switchMute()
    if MUTED then
        MUTED = false
    else
        MUTED = true
    end
end

function playButton()
    play(SOUND_INFO.BUTTON)
end

function playPlop()
    play(SOUND_INFO.PLOP)
end

function playSwoosh()
    play(SOUND_INFO.SWOOSH)
end

function playUnholy()
    play(SOUND_INFO.UNHOLY)
end

function playWrong()
    play(SOUND_INFO.WRONG)
end

function playLaugh()
    play(SOUND_INFO.LAUGH)
end

function playHoly()
    play(SOUND_INFO.HOLY)
end

function playDeath()
    play(SOUND_INFO.DEATH)
end