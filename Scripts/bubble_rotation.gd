extends Node2D

@onready var bubble: CharacterBody2D = self.get_parent()
@onready var rotation_direction: int = [-1, 1].pick_random()
@onready var rotation_speed: float = randf_range(-30, 30)


func _process(delta: float) -> void:
	if bubble.is_alive == false: return
	#bubble.rotation_degrees += rotation_speed * rotation_direction * delta
