extends Node2D

func _ready() -> void:
	MusicManager.play_instant(SOUNDS_LIST.LEVEL01_MUSIC)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("auto_play"):
		if GameManager.auto_play == true:
			GameManager.auto_play = false
		else:
			GameManager.auto_play = true


func _on_easy_button_button_down() -> void:
	GameManager.game_mode = "Fácil"
	GameManager.spawn_cooldown = 0.7
	GameManager.fly_speed = 300
	GameManager.tween_duration = 2.5
	GameManager.tween_distance = 80
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_medium_button_button_down() -> void:
	GameManager.game_mode = "Médio"
	GameManager.spawn_cooldown = 0.4
	GameManager.fly_speed = 100
	GameManager.tween_duration = 2.5
	GameManager.tween_distance = 80
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_hard_button_button_down() -> void:
	GameManager.game_mode = "Difícil"
	GameManager.spawn_cooldown = 0.3
	GameManager.fly_speed = 300
	GameManager.tween_duration = 2.5
	GameManager.tween_distance = 80
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_extreme_button_down() -> void:
	GameManager.game_mode = "Extremo"
	GameManager.spawn_cooldown = 0.1
	GameManager.fly_speed = 120
	GameManager.tween_duration = 0.5
	GameManager.tween_distance = 120
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_exit_button_button_down() -> void:
	get_tree().quit()
