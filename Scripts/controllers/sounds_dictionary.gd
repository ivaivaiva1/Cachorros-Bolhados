extends Node
class_name SOUNDS_LIST

# 🔊 MUSIC 
const LEVEL01_MUSIC := {"stream": preload("res://Audio/Dredge/level01_music.mp3"), "volume": -2.0}
const LEVEL01_BOSS_MUSIC := {"stream": preload("res://Audio/Dredge/level01_boss_music.mp3"), "volume": 2.0}



# 🔊 SFX 
const COIN_SFX := {"stream": preload("res://Audio/Dredge/coin_sfx.wav"), "volume": 0.0}
const DUPLICATE_SFX := {"stream": preload("res://Audio/Dredge/duplicate_sfx.wav"), "volume": -2.0}
const CATLOST_SFX := {"stream": preload("res://Audio/Dredge/catlost_sfx.wav"), "volume": 8.0}
const BUBBLE01_SFX := {"stream": preload("res://Audio/Dredge/bubble01_sfx.mp3"), "volume": 8.0}
const BUBBLE02_SFX := {"stream": preload("res://Audio/Dredge/bubble02_sfx.mp3"), "volume": 8.0}
const BUBBLE03_SFX := {"stream": preload("res://Audio/Dredge/bubble03_sfx.mp3"), "volume": 12.0}
const BUBBLE04_SFX := {"stream": preload("res://Audio/Dredge/bubble04_sfx.mp3"), "volume": 10.0}
const BLOONEXPLODE_SFX := {"stream": preload("res://Audio/Dredge/bloonexplode_sfx.mp3"), "volume": 14.0}
const MOUSEBULLET_SFX := {"stream": preload("res://Audio/Dredge/mousebullet_sfx.wav"), "volume": 0.0}





# Func choose random bubble sound
static var _last_bubble: Dictionary = {}
static func get_random_bubble() -> Dictionary:
	var options = [BUBBLE01_SFX, BUBBLE02_SFX, BUBBLE03_SFX, BUBBLE04_SFX]
	
	var choice: Dictionary = options.pick_random()
	while choice == _last_bubble:
		choice = options.pick_random()
	
	_last_bubble = choice
	return choice
