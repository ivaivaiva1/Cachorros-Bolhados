extends Node2D


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
