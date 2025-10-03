extends Node2D
class_name Icons_Container

@export var icon_scenes: Array[PackedScene]
@export var icon_gold: PackedScene

var icon_position: Vector2 = Vector2(21, 14)

func _ready() -> void:
	GameManager.icon_container = self

func add_icon(icon_id: int):
	print("nasceu fi")
	var instance = icon_scenes[icon_id].instantiate()
	if icon_position.x > 1360:
		icon_position.x = 21
		icon_position.y += 27
	instance.global_position = icon_position
	icon_position.x += 40
	self.add_child(instance)
