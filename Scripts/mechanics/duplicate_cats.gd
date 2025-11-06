extends Node2D

var SFX_COIN = "res://Audio/Dredge/coin.wav"
var SFX_DUPLICATE = "res://Audio/Dredge/duplicate.wav"


func do_duplication(cachorros: Cachorros, dog_id: int, dog_pos: Vector2, dog_velocity: Vector2, dog_rotation: float, dog_multi: int) -> void:
	if cachorros.has_node("CollisionShape2D"):
		cachorros.get_node("CollisionShape2D").disabled = true
	if cachorros.has_node("Area2D"):
		cachorros.get_node("Area2D").monitoring = false

	var rb: RigidBody2D = cachorros as RigidBody2D
	rb.linear_velocity.y *= 0.3

	var tween = cachorros.create_tween()
	tween.tween_property(cachorros.sprite, "scale", Vector2.ZERO, 0.7)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	var new_shader: ShaderMaterial = cachorros.shader_mat.duplicate() as ShaderMaterial
	cachorros.sprite.material = new_shader

	tween.parallel().tween_property(new_shader, "shader_parameter/flash_pct", 0.8, 0.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.3).timeout
	var dog_pos2
	if cachorros!=null: 
		dog_pos2 = cachorros.global_position 
	else: 
		dog_pos2 = global_position

	await get_tree().create_timer(0.2).timeout
	copy_cat(dog_id, dog_pos2, dog_velocity, dog_rotation, dog_multi)

	tween.finished.connect(func(): cachorros.queue_free())


func copy_cat(dog_id: int, spawn_position: Vector2, inherit_velocity: Vector2, inherit_rotation: float, dog_multi: int) -> void:
	var dog_scene: PackedScene = DogsList.dog_scenes[dog_id]
	SfxManager.play_sfx(SFX_DUPLICATE, -6)
	var lateral_speed: float = 200
	
	for i in range(dog_multi):
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
