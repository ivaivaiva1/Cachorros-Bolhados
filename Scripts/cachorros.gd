extends RigidBody2D
class_name Cachorros

@onready var sprite: Sprite2D = %Sprite2D
@export var dog_id: int
@export var jump_force: float = 600.0
@export var gravity: float = 1100.0
var shader_mat: ShaderMaterial

var is_released: bool = false
var is_a_copy: bool = false

func _ready() -> void:
	# Evita que ele caia antes da hora
	sleeping = true
	gravity_scale = 0.0
	shader_mat = sprite.material


func jump():
	linear_velocity.y = -jump_force

func set_free():
	is_released = true
	sleeping = false
	gravity_scale = 1.0
	if is_a_copy: return
	jump()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("death"):
		queue_free()
	elif area.is_in_group("icon"):
		if not is_released:
			return
		GameManager.icon_container.add_icon(dog_id)

#func start_phantom_tween() -> void:
	#if sprite == null:
		#print("⚠️ sprite é null em", name)
		#return
	#
	#var tween = create_tween()
	#tween.tween_property(sprite, "scale", Vector2.ZERO, 0.5)\
		#.set_trans(Tween.TRANS_SINE)\
		#.set_ease(Tween.EASE_IN)
