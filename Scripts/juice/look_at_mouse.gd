extends Node2D

@onready var sprite: Sprite2D = get_parent()
@export var tilt_strength: float = 0.05

var base_scale: Vector2

func _ready() -> void:
	if sprite:
		base_scale = sprite.scale

func _process(delta: float) -> void:
	if not sprite:
		return
	
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - sprite.global_position).normalized()
	
	# Inclina o sprite em torno do scale original
	sprite.scale.x = base_scale.x * (1.0 + dir.x * tilt_strength)
	sprite.scale.y = base_scale.y * (1.0 - dir.y * tilt_strength)
	
	# Desloca levemente o offset pra sensação de profundidade
	sprite.offset = Vector2(dir.x * 10.0, -dir.y * 10.0)
