extends Node

@export var sprite: Sprite2D 

var time_radius := 0.0
var time_amount := 0.0
var mat: ShaderMaterial

# Frequências e fases individuais para cada parâmetro
var radius_speed := randf_range(1.0, 2.0)
var amount_speed := randf_range(1.5, 3.0)
var radius_phase := randf_range(0.0, TAU)
var amount_phase := randf_range(0.0, TAU)

# Valores-base lidos do shader
var base_radius := 0.0
var base_amount := 0.0

func _ready() -> void:
	if sprite.material:
		# Duplica o material para não afetar outros nós que o compartilham
		sprite.material = sprite.material.duplicate()
		mat = sprite.material

		# --- Captura os valores iniciais do shader ---
		base_radius = mat.get_shader_parameter("radius")
		base_amount = mat.get_shader_parameter("amount")
	else:
		push_warning("Sprite sem material no gold_effect_controller!")

func _process(delta: float) -> void:
	if not mat:
		return

	time_radius += delta * radius_speed
	time_amount += delta * amount_speed

	# --- Oscilação dinâmica baseada no valor atual ---
	# Varia entre base_value e base_value * 1.2 (ou seja, +20%)
	# Quando o seno = -1 → base_value
	# Quando o seno = +1 → base_value * 1.2
	var radius = base_radius * (1.1 + sin(time_radius + radius_phase) * 0.1)
	var amount = base_amount * (1.1 + sin(time_amount + amount_phase) * 0.1)

	mat.set_shader_parameter("radius", radius)
	mat.set_shader_parameter("amount", amount)
