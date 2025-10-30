extends RigidBody2D
class_name Cachorros

@export var dog_id: int
@export var jump_force: float = 600.0
@export var gravity: float = 1100.0

var is_released: bool = false
var is_a_copy: bool = false

func _ready() -> void:
	# Evita que ele caia antes da hora
	sleeping = true
	gravity_scale = 0.0
#
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("change_bg"):
		#jump()

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#if not is_released:
		#return
	## Aplicar gravidade manualmente (ou usar gravity_scale = 1)
	##state.apply_central_force(Vector2(0, gravity))

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
