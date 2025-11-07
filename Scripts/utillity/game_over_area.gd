extends Area2D

@onready var adaptive_difficulty_controller = %AdaptiveDifficulty
@onready var bubble_spawner_controller = %BubbleSpawner

func _on_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("bubble"):
		#GameManager.icon_container.add_icon(1)
		SfxManager.play_sfx(SOUNDS_LIST.CATLOST_SFX)
		ScreenShake.screen_shake(10, 0.7)
		adaptive_difficulty_controller.on_dog_escaped()
		bubble_spawner_controller.destroy_all_bubbles()
		area.get_parent().queue_free()
	
	
	if area.is_in_group("trampolim"):
		area.get_parent().queue_free()
