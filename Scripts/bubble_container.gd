extends CharacterBody2D
class_name bubble_containers

@export var catioro_scene: PackedScene

@onready var catioro: Cachorros = %cachorro
@onready var catioro_sprite_container: Node2D = catioro.get_node("sprite_container")
@onready var bubble_moviment: bubble_moviment = %bubble_moviment
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var bubble_object: Object = %bolha


var is_alive: bool = true
var auto_kill_timer := 1.0
var need_death: bool = false

var auto_destruction_y

func _ready() -> void:
	if GameManager.auto_play:
		auto_destruction_y = randf_range(30.0, 590.0)

func _process(delta: float) -> void:
	if !is_alive:
		auto_kill_timer -= delta
		if auto_kill_timer <= 0:
			queue_free()
		return

	# 🔹 Mantém sincronização visual
	catioro_sprite_container.scale = scale
	catioro_sprite_container.skew = skew

	# 🔹 Auto-destruição automática em modo auto_play
	if auto_destruction_y != null:
		if global_position.y < auto_destruction_y:
			pop()


func _on_button_button_down() -> void:
	pop()

func pop():
	print("actual_pos: ", global_position, "|| auto_destruction_y: ",auto_destruction_y)
	if !is_alive:
		return
	is_alive = false
	var bubble_pos = global_position
	var mouse_pos = get_global_mouse_position()
	ScreenShake.screen_shake(1.5, 0.2)
	pop_audio()
	anim_player.set_speed_scale(0.0)
	bubble_object.queue_free()
	var instance = catioro_scene.instantiate()
	get_parent().add_child(instance)
	instance.rotation_degrees = rotation_degrees
	instance.global_position = bubble_pos
	instance.set_free()
	catioro.visible = false
	GameManager.game.actual_score += 1

func pop_audio():
	SfxManager.play_sfx(SOUNDS_LIST.get_random_bubble())
