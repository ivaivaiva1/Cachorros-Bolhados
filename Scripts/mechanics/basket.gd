extends Node2D

var multiplier: int
var random_multiplier: bool = false

@onready var label: Label = %Label
var SFX_COIN = "res://Audio/Dredge/coin.wav"
var SFX_DUPLICATE = "res://Audio/Dredge/duplicate.wav"

# 🔹 Timer interno para trocar o multiplicador quando random estiver ativo
var random_timer: float = 0.0
const RANDOM_INTERVAL: float = 0.3

func _ready() -> void:
	get_random_multiplier()
	label.text = str("X", multiplier)


func _process(delta: float) -> void:
	if random_multiplier:
		random_timer -= delta
		if random_timer <= 0.0:
			random_timer = RANDOM_INTERVAL
			change_random_multiplier()


func change_random_multiplier() -> void:
	var possible_multipliers = [2, 3, 4, 5, 10]
	var new_mult = possible_multipliers[randi() % possible_multipliers.size()]

	# Evita repetir o mesmo valor consecutivo (opcional)
	if new_mult == multiplier:
		new_mult = possible_multipliers[randi() % possible_multipliers.size()]

	multiplier = new_mult
	label.text = str("X", multiplier)


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
			
			var dog_multi = multiplier
			phantom_effect(cachorros, dog_id, dog_pos, dog_velocity, dog_rotation, dog_multi)
			
			SfxManager.play_sfx(SFX_COIN, -4)
			SpawnText.display_text(str("X", dog_multi), dog_pos)
			HitFreeze.hit_freeze(0.3, 0.015)


func phantom_effect(cachorros: Cachorros, dog_id: int, dog_pos: Vector2, dog_velocity: Vector2, dog_rotation: float, dog_multi: int) -> void:
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
	create_two_copies(dog_id, dog_pos2, dog_velocity, dog_rotation, dog_multi)

	tween.finished.connect(func(): cachorros.queue_free())


func create_two_copies(dog_id: int, spawn_position: Vector2, inherit_velocity: Vector2, inherit_rotation: float, dog_multi: int) -> void:
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


func get_random_multiplier():
	randomize()
	var chances = {
		2: 15,
		3: 40,
		4: 24,
		5: 10,
		10: 1,
		0: 10
	}
	
	var total_weight = 0
	for weight in chances.values():
		total_weight += weight
	
	var rand_pick = randf() * total_weight
	var current = 0
	
	for mult in chances.keys():
		current += chances[mult]
		if rand_pick <= current:
			multiplier = mult
			break
	
	if multiplier == null || multiplier == 0:
		# Se for 0X, ativa modo aleatório
		random_multiplier = true
		change_random_multiplier()
