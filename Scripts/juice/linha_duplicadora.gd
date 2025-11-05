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

			phantom_effect(cachorros, dog_id, dog_pos, dog_velocity, dog_rotation)

			SfxManager.play_sfx(SFX_COIN, -4)
			SpawnText.display_text(str("X", multiplier), dog_pos, original_color)
			HitFreeze.hit_freeze(0.3, 0.015)


func phantom_effect(
	cachorros: Cachorros,
	dog_id: int,
	dog_pos: Vector2,
	dog_velocity: Vector2,
	dog_rotation: float
) -> void:
	if cachorros.has_node("CollisionShape2D"):
		cachorros.get_node("CollisionShape2D").disabled = true
	if cachorros.has_node("Area2D"):
		cachorros.get_node("Area2D").monitoring = false

	var rb: RigidBody2D = cachorros as RigidBody2D
	rb.linear_velocity.y *= 0.3

	var tween = cachorros.create_tween()
	tween.tween_property(
		cachorros.sprite,
		"scale",
		Vector2.ZERO,
		0.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	var new_shader: ShaderMaterial = cachorros.shader_mat.duplicate() as ShaderMaterial
	cachorros.sprite.material = new_shader

	tween.parallel().tween_property(
		new_shader,
		"shader_parameter/flash_pct",
		0.8,
		0.5
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.3).timeout

	var dog_pos2: Vector2
	if cachorros != null:
		dog_pos2 = cachorros.global_position
	else:
		dog_pos2 = global_position

	await get_tree().create_timer(0.2).timeout

	create_two_copies(dog_id, dog_pos2, dog_velocity, dog_rotation)

	tween.finished.connect(func():
		cachorros.queue_free()
	)


func create_two_copies(
	dog_id: int,
	spawn_position: Vector2,
	inherit_velocity: Vector2,
	inherit_rotation: float
) -> void:
	var dog_scene: PackedScene = DogsList.dog_scenes[dog_id]
	SfxManager.play_sfx(SFX_DUPLICATE, -6)
	var lateral_speed: float = 200

	for i in range(multiplier):
		var new_dog: Cachorros = dog_scene.instantiate() as Cachorros
		new_dog.is_a_copy = true
		new_dog.global_position = spawn_position
		new_dog.rotation = inherit_rotation
		get_tree().current_scene.add_child(new_dog)

		var new_rigidbody: RigidBody2D = new_dog as RigidBody2D
		var horizontal_push = (i * 2 - 1) * lateral_speed
		new_rigidbody.linear_velocity.x += horizontal_push

		var torque_from_push = clamp(horizontal_push * 100.0, -4000.0, 4000.0)
		new_rigidbody.apply_torque_impulse(torque_from_push)

		if new_dog.has_method("set_free"):
			new_dog.set_free()
