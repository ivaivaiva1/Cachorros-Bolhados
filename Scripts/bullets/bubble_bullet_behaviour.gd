extends Node2D
class_name BubbleBulletBehaviour

@onready var bullet: Bullet = get_parent()

func _ready() -> void:
	bullet.bullet_speed = 10
	#start_bubble_bullet(2, 2.0, 10000.0) # exemplo


func start_bubble_bullet(delay_time: float, tween_duration: float = 2.0, target_speed: float = 10000.0) -> void:
	await get_tree().create_timer(delay_time).timeout
	
	bullet.look_at(get_global_mouse_position())
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN) # começa rápido e desacelera
	tween.set_trans(Tween.TRANS_SINE) # curva de transição suave (pode trocar por QUAD, CUBIC etc.)
	tween.tween_property(bullet, "bullet_speed", target_speed, tween_duration)
