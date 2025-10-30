extends Node2D

@onready var game_over_ui: Control = %game_over_ui
@onready var score_label: Label = %actual_score
@onready var recorde_label: Label = %recorde_score
@onready var game_mode_label: Label = %game_mode
@onready var bump_player: AudioStreamPlayer2D = %BumpAudio
@onready var adaptive_difficulty_controller = %AdaptiveDifficulty
@onready var bubble_spawner_controller = %BubbleSpawner

func _ready() -> void:
	GameManager.game_state = "Play"
	GameManager.actual_score = 0

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("change_bg"):
		#bump_player.play()


func _on_game_over_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("bubble"):
		#GameManager.icon_container.add_icon(1)
		adaptive_difficulty_controller.on_dog_escaped()
		bubble_spawner_controller.destroy_all_bubbles()
		area.queue_free()
	#if area.is_in_group("bubble"):
		##if GameManager.actual_score > SaveScore.easy_score:
			##SaveScore.easy_score = GameManager.actual_score
		##SaveScore.save_score()
		#game_over_ui.visible = true
		#score_label.text = str(GameManager.actual_score)
		##recorde_label.text = str(SaveScore.load_score())
		#game_mode_label.text = GameManager.game_mode
		#GameManager.game_state = "GameOver"


func _on_play_again_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_main_menu_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
