extends Node2D

# min y = 30.0 --- max = 200.0

@onready var sprite: Sprite2D = %Sprite
var multiplier: int = 3
var SFX_COIN = "res://Audio/Dredge/coin.wav"
var SFX_DUPLICATE = "res://Audio/Dredge/duplicate.wav"
var sprite_mat

var original_color: Color = Color("#ff52bf")
var can_duplicate: bool = false
var times_to_move: int = 4
var max_y: float = 250
var min_y: float = 100
var tween_time: float = 6.0
var wait_time: float = 1.0


func do_move() -> void:
	global_position.y = max_y
	
	for i in range(times_to_move):
		# 🔹 TWEEN DE SUBIDA
		var tween_up = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
		tween_up.tween_property(self, "position:y", min_y, tween_time)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		await tween_up.finished
		
		# Espera 2 segundos
		await get_tree().create_timer(wait_time).timeout
	
		# 🔹 TWEEN DE DESCIDA
		var tween_down = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
		tween_down.tween_property(self, "position:y", max_y, tween_time)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		await tween_down.finished
	
		# Espera 2 segundos
		await get_tree().create_timer(wait_time).timeout
	
	print("✅ Movimento finalizado — hora do tween do shader")
	if sprite_mat:
		var tween_flash = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
		tween_flash.tween_property(sprite_mat, "shader_parameter/flash_color", Color.WHITE, 1.5)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
		await tween_flash.finished
	
	queue_free()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		start()


func start():
	print("we are here")
	
	global_position = Vector2(0, max_y)
	
	# duplica o material (pra não alterar o recurso original)
	var mat := sprite.material
	if mat:
		sprite.material = mat.duplicate()
	sprite_mat = sprite.material
	
	
	sprite_mat.set_shader_parameter("flash_color", Color.WHITE)
	
	# espera um frame pra garantir que engine aplicou os valores iniciais
	await get_tree().process_frame
	
	# cria tween e força processo em IDLE (mais estável para durações longas)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	
	# roda os tweens em paralelo
	tween.parallel()
	
	# tween do alpha (0.0 → 0.5)
	tween.tween_property(sprite, "modulate:a", 0.5, 0.1)\
		.from(0.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	# tween da cor do shader (de branco → original_color)
	if sprite_mat:
		tween.tween_property(sprite_mat, "shader_parameter/flash_color", original_color, 1.5)\
			.from(Color.WHITE)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
	
	## quando o tween terminar, define can_duplicate como true
	#tween.finished.connect(func():
		#can_duplicate = true
		#print("✅ Tween finalizado — can_duplicate = true")
	#)
	
	# fallback: se o tween for interrompido, garante o estado final também
	await tween.finished
	can_duplicate = true
	do_move()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !can_duplicate: return
	if body.is_in_group("dog"):
		var cachorros: Cachorros = body
		if cachorros.is_a_copy:
			return
		
		var rigidbody: RigidBody2D = cachorros as RigidBody2D
		if rigidbody.linear_velocity.y > 0:
			var dog_id = cachorros.dog_id
			var dog_pos = cachorros.global_position
			var dog_velocity = rigidbody.linear_velocity
			var dog_rotation = cachorros.rotation
			
			DuplicateCats.do_duplication(cachorros, dog_id, dog_pos, dog_velocity, dog_rotation, multiplier)
			
			SfxManager.play_sfx(SFX_COIN, -4)
			SpawnText.display_text(str("X", multiplier), dog_pos, original_color)
			HitFreeze.hit_freeze(0.3, 0.015)
