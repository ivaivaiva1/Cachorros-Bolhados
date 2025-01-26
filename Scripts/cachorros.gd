extends CharacterBody2D
class_name Cachorros

@export var dog_id: int

var is_released: bool = false

@export var gravity = 1100
@export var jump_force = 500


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_bg"):
		jump()

func _physics_process(delta):
	if is_released == false: return
	velocity.y += gravity * delta
	move_and_slide()

func jump():
	velocity.y = -jump_force

func set_free():
	jump()
	is_released = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("death"):
		queue_free()
	if area.is_in_group("icon"):
		if is_released == false: return
		GameManager.icon_container.add_icon(dog_id)
