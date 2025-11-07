extends Node2D

@export var bloon_scene: PackedScene
@export var basket_father: Node2D 

var basket_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("invoke_basquete"):
		if !basket_active:
			print("é false")
			basket_active = true
			basket_father.global_position = Vector2(0.0, 0.0)
		elif basket_active:
			print("é false")
			basket_active = false
			basket_father.global_position = Vector2(10000.0, 10000.0)
	
	
	if Input.is_action_just_pressed("invoke_bloon"):
		get_tree().current_scene.add_child(bloon_scene.instantiate())
		await get_tree().create_timer(15.0).timeout
		get_tree().current_scene.add_child(bloon_scene.instantiate())
		await get_tree().create_timer(15.0).timeout
		get_tree().current_scene.add_child(bloon_scene.instantiate())
