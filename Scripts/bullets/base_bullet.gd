extends CharacterBody2D
class_name Bullet

var bullet_speed: float
var dir: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if bullet_speed == 0 || bullet_speed == null: return
	dir = rotation
	velocity = Vector2(bullet_speed, 0).rotated(dir)
	move_and_slide()
