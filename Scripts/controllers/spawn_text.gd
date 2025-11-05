extends Node

func display_text(value: String, position: Vector2, color: Color = Color("FFFF00")):
	var number = Label.new()
	number.global_position = position
	number.text = value
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 25
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 3
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	# Subida rápida no início e desacelera no final
	tween.tween_property(
		number, "position:y", number.position.y - 200, 0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Fade começando 0.4s depois
	tween.tween_property(
		number, "modulate:a", 0, 0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(0.4)

	await tween.finished
	number.queue_free()
