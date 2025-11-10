extends Node

@export var sprite: Sprite2D = get_parent()

var time_radius := 0.0
var time_amount := 0.0
var mat: ShaderMaterial

# Frequências e fases individuais para cada parâmetro
var radius_speed := randf_range(1.0, 2.0)
var amount_speed := randf_range(1.5, 3.0)
var radius_phase := randf_range(0.0, TAU)
var amount_phase := randf_range(0.0, TAU)

func _ready() -> void:
	if sprite.material:
		sprite.material = sprite.material.duplicate()
		mat = sprite.material
	else:
		push_warning("Sprite sem material no gold_effect_controller!")

func _process(delta: float) -> void:
	if not mat:
		return

	time_radius += delta * radius_speed
	time_amount += delta * amount_speed

	# Oscilação do radius (1.0 → 3.0)
	var radius = 2.0 + sin(time_radius + radius_phase) * 1.0

	# Oscilação do amount (0.65 → 1.0)
	var amount = 0.825 + sin(time_amount + amount_phase) * 0.175

	mat.set_shader_parameter("radius", radius)
	mat.set_shader_parameter("amount", amount)
