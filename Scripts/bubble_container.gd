extends CharacterBody2D
class_name bubble_containers

@export var catioro_scene: PackedScene

@onready var catioro: Cachorros = %cachorro
@onready var bubble_moviment: bubble_moviment = %bubble_moviment
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var bubble_object: Object = %bolha
@onready var bubble_audio: AudioStreamPlayer2D = %BubbleAudio

var is_alive: bool = true

var auto_kill_timer = 1

var need_death: bool = false

func _process(delta: float) -> void:
	if need_death:
		auto_kill_timer -= delta
	if auto_kill_timer <= 0:
		queue_free()


func _on_button_button_down() -> void:
	if GameManager.game_state != "Play": return
	bubble_audio.play()
	is_alive = false
	anim_player.set_speed_scale(0.0)
	bubble_object.queue_free()
	var instance = catioro_scene.instantiate()
	get_parent().add_child(instance)
	instance.rotation_degrees = rotation_degrees
	instance.global_position = global_position
	instance.set_free()
	catioro.visible = false
	need_death = true
	GameManager.actual_score += 1
	print(GameManager.actual_score)
