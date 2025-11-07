extends Node2D

@export var force_strength: float = 800.0
@export var torque_multiplier: float = 30.0
@export var torque_limit: float = 20000.0

func _ready() -> void:
	apply_explosion()


func apply_explosion() -> void:
	var cats: Array = get_children()
	if cats.is_empty():
		return

	# ordena os gatos do mais distante pro mais próximo
	cats.sort_custom(func(a, b):
		return a.global_position.distance_to(global_position) > b.global_position.distance_to(global_position)
	)

	# aplica a força e o torque
	for cat in cats:
		
		var cachorro: Cachorros = cat
		cachorro.set_free()
		
		var dir = (cat.global_position - global_position).normalized()
		cat.linear_velocity = dir * force_strength
		
		# torque baseado na direção do empurrão
		var torque_from_push = clamp(dir.x * torque_multiplier * force_strength, -torque_limit, torque_limit)
		cat.apply_torque_impulse(torque_from_push)
