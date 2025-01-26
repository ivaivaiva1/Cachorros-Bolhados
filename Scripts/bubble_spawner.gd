extends Node2D

@export var bubble_objects: Array[PackedScene]
@export var spawn_points: Array[Marker2D]

var max_bubbles: int = 50

var spawn_cooldown
var spawn_timer: float

func _ready() -> void:
	spawn_cooldown = GameManager.spawn_cooldown
	spawn_timer = spawn_cooldown

func _process(delta: float) -> void:
	if GameManager.game_state != "Play": return
	if spawn_timer > 0:
		spawn_timer -= delta
	else:
		var random_bubble = randi_range(0, 4)
		var random_position = randi_range(0, 8)
		var instance = bubble_objects[random_bubble].instantiate()
		instance.global_position = spawn_points[random_position].global_position
		add_child(instance)
		spawn_timer = spawn_cooldown
