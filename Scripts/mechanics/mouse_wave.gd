extends Node2D

@onready var wave_area: Area2D = %wave_area
@onready var bump_player: AudioStreamPlayer2D = %BumpAudio

@export var min_force_y: float = 400.0
@export var max_force_y: float = 700.0
@export var min_force_x: float = 0.0
@export var max_force_x: float = 800.0  # reduzido pra controle melhor

func _process(delta: float) -> void:
	wave_area.global_position = get_global_mouse_position()

	if Input.is_action_just_pressed("change_bg"):
		do_mouse_wave()


func do_mouse_wave() -> void:
	bump_player.play()
	ScreenShake.screen_shake(4, 0.2)
	var mouse_pos: Vector2 = get_global_mouse_position()
	var collision_shape: CollisionShape2D = wave_area.get_node("CollisionShape2D")
	var shape: CircleShape2D = collision_shape.shape as CircleShape2D
	var radius: float = shape.radius

	for area in wave_area.get_overlapping_areas():
		if area.is_in_group("dog"):
			var cachorro: Cachorros = area.get_parent()
			if not cachorro.is_released:
				continue

			var force_y: float = get_vertical_push(mouse_pos, cachorro.global_position, radius)
			var force_x: float = get_horizontal_push(mouse_pos, cachorro.global_position, radius)

			var body: RigidBody2D = cachorro as RigidBody2D
			if body:
				# Zera a velocidade atual antes de aplicar a nova força
				body.linear_velocity = Vector2.ZERO

				# Calcula direção Y
				var direction_y: float = sign(cachorro.global_position.y - mouse_pos.y)
				body.linear_velocity.y += force_y * direction_y

				# Aplica força horizontal somente se delta X for relevante
				body.linear_velocity.x += force_x


func get_vertical_push(mouse_pos: Vector2, dog_pos: Vector2, radius: float) -> float:
	var delta_y: float = dog_pos.y - mouse_pos.y
	var proximity_y: float = clamp(1.0 - abs(delta_y) / radius, 0.0, 1.0)
	return lerp(min_force_y, max_force_y, proximity_y)


func get_horizontal_push(mouse_pos: Vector2, dog_pos: Vector2, radius: float) -> float:
	var delta_x: float = dog_pos.x - mouse_pos.x
	var distance_x: float = abs(delta_x)

	# Threshold para evitar força lateral quando alinhado
	if distance_x < 1.0:
		return 0.0

	var direction_x: float = sign(delta_x)
	var proximity_x: float = clamp(distance_x / radius, 0.0, 1.0)
	var force: float = lerp(min_force_x, max_force_x, proximity_x)
	return force * direction_x
