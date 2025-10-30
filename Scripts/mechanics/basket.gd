extends Node2D

@export var multiplier = 2

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("dog"):
		var cachorros: Cachorros = area.get_parent()
		if cachorros.is_a_copy:
			return
	
		var rigidbody: RigidBody2D = cachorros as RigidBody2D
		if rigidbody.linear_velocity.y > 0:
			var dog_id = cachorros.dog_id
			var dog_pos = cachorros.global_position
			var dog_velocity = rigidbody.linear_velocity
			var dog_rotation = cachorros.rotation
	
			phantom_effect(cachorros, dog_id, dog_pos, dog_velocity, dog_rotation)
			SpawnText.display_text(str("X", multiplier), dog_pos)


func phantom_effect(cachorros: Cachorros, dog_id: int, dog_pos: Vector2, dog_velocity: Vector2, dog_rotation: float) -> void:
	# Desativa colisões e área pra evitar bugs durante o efeito
	if cachorros.has_node("CollisionShape2D"):
		cachorros.get_node("CollisionShape2D").disabled = true
	if cachorros.has_node("Area2D"):
		cachorros.get_node("Area2D").monitoring = false
	
	# Reduz velocidade vertical em 90% pra dar leveza na descida
	var rb: RigidBody2D = cachorros as RigidBody2D
	rb.linear_velocity.y *= 0.3
	
	# Garante cor inicial
	if cachorros.modulate == null:
		cachorros.modulate = Color(1, 1, 1, 1)
	
	# Efeito visual: ficar branco e desaparecer
	var tween = cachorros.create_tween()
	tween.tween_property(cachorros, "modulate", Color(1, 1, 1, 0.0), 0.5)
	tween.parallel().tween_property(cachorros.sprite, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Pega a posição um pouco antes do final do tween (pra ser mais natural)
	await get_tree().create_timer(0.3).timeout
	var dog_pos2 = cachorros.global_position

	# Ao terminar o tween, faz o shake e cria as cópias
	tween.finished.connect(func():
		ScreenShake.screen_shake(multiplier, 0.4)
		create_two_copies(dog_id, dog_pos2, dog_velocity, dog_rotation)
		cachorros.queue_free()
	)


func create_two_copies(dog_id: int, spawn_position: Vector2, inherit_velocity: Vector2, inherit_rotation: float) -> void:
	var dog_scene: PackedScene = DogsList.dog_scenes[dog_id]
	
	# 🔹 Aumentamos a velocidade lateral (antes era 150)
	var lateral_speed: float = 200
	
	for i in range(multiplier):
		var new_dog: Cachorros = dog_scene.instantiate() as Cachorros
		new_dog.is_a_copy = true
		new_dog.global_position = spawn_position
		new_dog.rotation = inherit_rotation
		get_tree().current_scene.add_child(new_dog)
		
		# --- Configuração da velocidade do novo cachorro ---
		var new_rigidbody: RigidBody2D = new_dog as RigidBody2D
		
		# Começa com 70% da velocidade do cachorro original
		#new_rigidbody.linear_velocity = inherit_velocity * 0.7
		
		# Aplica impulso horizontal (empurra pros lados)
		# (i * 2 - 1) → -1 pro primeiro, +1 pro segundo cachorro
		new_rigidbody.linear_velocity.x += (i * 2 - 1) * lateral_speed
		
		# Mantém a velocidade vertical original (sem alterar)
		
		# Libera o cachorro pra cair normalmente
		if new_dog.has_method("set_free"):
			new_dog.set_free()
