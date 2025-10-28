extends Node2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("dog"):
		var cachorros: Cachorros = area.get_parent()
		if cachorros.is_a_copy: 
			return
		
		var rigidbody: RigidBody2D = cachorros as RigidBody2D
		if rigidbody.linear_velocity.y > 0:
			# Armazena os parâmetros
			var dog_id = cachorros.dog_id
			var dog_pos: Vector2 = cachorros.global_position
			var dog_velocity: Vector2 = rigidbody.linear_velocity  # velocidade do original
			
			# Remove o cachorro original
			cachorros.queue_free()
			
			# Cria os dois clones na mesma posição, passando a velocidade
			create_two_copies(dog_id, dog_pos, dog_velocity)



func create_two_copies(dog_id: int, spawn_position: Vector2, inherit_velocity: Vector2) -> void:
	var dog_scene: PackedScene = DogsList.dog_scenes[dog_id]
	var lateral_speed: float = 150  # velocidade horizontal para empurrar os clones

	for i in range(2):
		var new_dog: Cachorros = dog_scene.instantiate() as Cachorros
		new_dog.is_a_copy = true
		
		# Spawn inicial ligeiramente deslocado
		new_dog.global_position = spawn_position
		
		get_tree().current_scene.add_child(new_dog)
		
		# Reduz 30% da velocidade vertical original
		var new_rigidbody: RigidBody2D = new_dog as RigidBody2D
		new_rigidbody.linear_velocity = inherit_velocity * 0.7
		
		# Aplica velocidade horizontal para empurrar os clones para os lados
		new_rigidbody.linear_velocity.x = (i * 2 - 1) * lateral_speed
		
		# Libera para começar a cair
		if new_dog.has_method("set_free"):
			new_dog.set_free()
