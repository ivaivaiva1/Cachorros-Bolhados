extends Node2D

@export var multiplier = 2
var SFX_COIN = "res://Audio/Dredge/coin.wav"
var SFX_DUPLICATE = "res://Audio/Dredge/duplicate.wav"

#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if area.is_in_group("dog"):
		#var cachorros: Cachorros = area.get_parent()
		#if cachorros.is_a_copy:
			#return
	#
		#var rigidbody: RigidBody2D = cachorros as RigidBody2D
		#if rigidbody.linear_velocity.y > 0:
			#var dog_id = cachorros.dog_id
			#var dog_pos = cachorros.global_position
			#var dog_velocity = rigidbody.linear_velocity
			#var dog_rotation = cachorros.rotation
			#
			#print("passou")
			#phantom_effect(cachorros, dog_id, dog_pos, dog_velocity, dog_rotation)
			#SpawnText.display_text(str("X", multiplier), dog_pos)

func _on_area_2d_body_entered(body: Node2D) -> void:
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
				
				print("passou")
				phantom_effect(cachorros, dog_id, dog_pos, dog_velocity, dog_rotation)
				
				SfxManager.play_sfx(SFX_COIN, -4)
				SpawnText.display_text(str("X", multiplier), dog_pos)
				
				await hit_freeze(0.3)

func phantom_effect(cachorros: Cachorros, dog_id: int, dog_pos: Vector2, dog_velocity: Vector2, dog_rotation: float) -> void:
	# Desativa colisões
	if cachorros.has_node("CollisionShape2D"):
		cachorros.get_node("CollisionShape2D").disabled = true
	if cachorros.has_node("Area2D"):
		cachorros.get_node("Area2D").monitoring = false
	
	# Reduz velocidade vertical
	var rb: RigidBody2D = cachorros as RigidBody2D
	rb.linear_velocity.y *= 0.3
	
	# Cria o tween no próprio cachorro
	var tween = cachorros.create_tween()
	tween.tween_property(cachorros.sprite, "scale", Vector2.ZERO, 0.7)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	
	# Duplica o material só para este cachorro
	var new_shader: ShaderMaterial = cachorros.shader_mat.duplicate() as ShaderMaterial
	cachorros.sprite.material = new_shader
	# Tween do parâmetro flash_pct do shader
	# Tween do shader flash_pct
	tween.parallel().tween_property(new_shader, "shader_parameter/flash_pct", 0.8, 0.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.3).timeout
	var dog_pos2 = cachorros.global_position
	
	await get_tree().create_timer(0.2).timeout
	create_two_copies(dog_id, dog_pos2, dog_velocity, dog_rotation)
	
	tween.finished.connect(func():
		cachorros.queue_free()
	)




func create_two_copies(dog_id: int, spawn_position: Vector2, inherit_velocity: Vector2, inherit_rotation: float) -> void:
	var dog_scene: PackedScene = DogsList.dog_scenes[dog_id]
	SfxManager.play_sfx(SFX_DUPLICATE, -6)
	
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


func hit_freeze(time_scale: float = 0.0, duration: float = 0.1) -> void:
	var original_time_scale = Engine.time_scale
	Engine.time_scale = time_scale
	
	# Timer para voltar ao tempo normal
	var t = get_tree().create_timer(duration, false)
	await t.timeout
	Engine.time_scale = original_time_scale
