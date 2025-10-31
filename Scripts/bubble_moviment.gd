extends Node2D
class_name bubble_moviment

@onready var bubble: CharacterBody2D = get_parent()

@onready var fly_speed

var bubble_tween: Tween

var moviment_cooldown
var moviment_timer = 0
var tween_duration
var tween_distance: float = 80


func _ready() -> void:
	tween_duration = GameManager.tween_duration
	moviment_cooldown = tween_duration * 0.8
	fly_speed = randf_range(GameManager.fly_speed * 0.7, GameManager.fly_speed * 1.3)
	do_tween()

func _process(delta: float) -> void:
	if bubble.is_alive == false: return
	if moviment_timer > 0:
		moviment_timer -= delta
	else:
		moviment_timer = moviment_cooldown
		do_tween()


func _physics_process(delta: float) -> void:
	bubble.velocity.y = -fly_speed
	bubble.move_and_slide()

func do_tween():
	if bubble.is_alive == false: return
	var direction
	if bubble.global_position.x < 50:
		direction = 1
	elif bubble.global_position.x > 1316.0:
		direction = -1
	else:
		direction = [-1, 1].pick_random()
	
	
	bubble_tween = get_tree().create_tween()
	bubble_tween.set_ease(Tween.EASE_IN_OUT)
	bubble_tween.set_trans(Tween.TRANS_QUINT)
	
	bubble_tween.tween_property(bubble, "global_position:x", bubble.global_position.x + (randf_range(tween_distance - 20, tween_distance + 20) * direction) , randf_range(tween_duration / 0.8, tween_duration))
