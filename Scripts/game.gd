extends Node2D
class_name game_controller

var game_state: String 
var actual_score: float 
var current_level: int
var farm_time: float

func _ready() -> void:
	GameManager.game = self
	GameManager.current_scene = GameManager.SCENES.GAME
	game_state = GAME_STATE.FARM
	farm_time = 0
	actual_score = 0
	current_level = 1



func _process(delta: float) -> void:
	
	if game_state == GAME_STATE.FARM:
		farm_time += delta
		
		if farm_time > 10:
			call_boss()
	
	
	
	if Input.is_action_just_pressed("reload_scene"):
		get_tree().reload_current_scene() 
	
	if Input.is_action_just_pressed("auto_play"):
		if GameManager.auto_play == true:
			GameManager.auto_play = false
		else:
			GameManager.auto_play = true


func call_boss():
	game_state = GAME_STATE.BOSS
	MusicManager.fade_out(5)
	await get_tree().create_timer(8).timeout
	MusicManager.play_instant(SOUNDS_LIST.LEVEL01_BOSS_MUSIC)



# Game states
const GAME_STATE = {
	FARM = "farm",
	BOSS = "boss",
	BONUS = "bonus"
}
