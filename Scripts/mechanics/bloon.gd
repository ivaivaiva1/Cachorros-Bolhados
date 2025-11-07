extends CharacterBody2D
class_name Bloon

@export var cat_explosion_scene: PackedScene
@onready var sprite: Sprite2D = %Sprite
@onready var fly_speed: float = 16.0

var life: float = 10
var _breathing_tween: Tween = null
var _base_scale: Vector2

var original_flash_color: Color = Color("ff637b")
var original_flash_pct: float = 0.632

var damage_alto: float = 1.0
var damage_medium: float = 0.3
var damage_low: float = 0.1

# rotation vars
@onready var initial_rotation: float = randf_range(0.0, 360.0)
@onready var rotation_direction: int = 1
@onready var rotation_speed: float = 3


var SFX_Estouro = "res://Audio/Bloons/31_Pop1.mp3"



func _ready() -> void:
	global_position = Vector2(randf_range(120.0, 1258.0), 950.0)
	_base_scale = scale
	sprite.rotation_degrees = initial_rotation
	#start_breathing()
	do_movement()


func _process(delta: float) -> void:
	sprite.rotation_degrees += rotation_speed * rotation_direction * delta


func _physics_process(delta: float) -> void:
	sprite.rotation_degrees += rotation_speed * rotation_direction * delta
	velocity.y = -fly_speed
	move_and_slide()


func start_breathing() -> void:
	var scale_min := 0.95
	var scale_max := 1.05
	var breath_time := 2.5
	
	if _breathing_tween:
		_breathing_tween.kill()
	
	_breathing_tween = create_tween()
	_breathing_tween.set_loops()
	_breathing_tween.set_trans(Tween.TRANS_SINE)
	_breathing_tween.set_ease(Tween.EASE_IN_OUT)
	
	_breathing_tween.tween_property(self, "scale", _base_scale * scale_max, breath_time)
	_breathing_tween.tween_property(self, "scale", _base_scale * scale_min, breath_time * 1.5)

func lose_life():
	if global_position.y < 384.0:
		life -= damage_alto
	elif global_position.y < 576.0:
		life -= damage_medium
	else:
		life -= damage_low

func get_hit() -> void:
	lose_life()
	if life <= 0:
		die()
		return
	
	
	var mat := sprite.material
	if not (mat is ShaderMaterial):
		return
	
	# 🔹 Duplicar o material pra não afetar outros balões
	mat = mat.duplicate()
	sprite.material = mat
	
	# 🔹 Tween principal
	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)
	t.set_ease(Tween.EASE_IN_OUT)
	
	# --- FLASH ---
	var flash_tween := create_tween()
	flash_tween.set_trans(Tween.TRANS_LINEAR)
	flash_tween.set_ease(Tween.EASE_IN_OUT)
	
	flash_tween.tween_method(func(v):
		mat.set_shader_parameter("flash_color", original_flash_color.lerp(Color.WHITE, v))
		mat.set_shader_parameter("flash_pct", lerp(original_flash_pct, 1.0, v))
	, 0.0, 1.0, 0.08*1)
	
	flash_tween.tween_method(func(v):
		mat.set_shader_parameter("flash_color", Color.WHITE.lerp(original_flash_color, v))
		mat.set_shader_parameter("flash_pct", lerp(1.0, original_flash_pct, v))
	, 0.0, 1.0, 0.12*1)
	
	# --- MOLA / IMPACTO ---
	var s := _base_scale
	var seq := [
		s * 0.9,   # contrai rápido
		s * 1.2,   # expande forte
		s * 0.95,  # volta e passa um pouco
		s * 1.1,   # leve rebote
		s          # volta ao normal
	]
	
	for i in seq.size() - 1:
		var dur := 0.08 + i * 0.04
		t.tween_property(sprite, "scale", seq[i], dur)
	
	t.tween_property(sprite, "scale", s, 0.15)


@onready var static_body: StaticBody2D = %StaticBody2D

func die():
	SfxManager.play_sfx(SOUNDS_LIST.BLOONEXPLODE_SFX)
	static_body.queue_free()
	sprite.visible = false
	var cat_explosion: Node2D = cat_explosion_scene.instantiate()
	cat_explosion.global_position = global_position
	get_tree().current_scene.add_child(cat_explosion)
	queue_free()


var movement_tween: Tween
var tween_duration: float = 8.0
var tween_distance: float = 100.0
var moviment_timer: float = 0.0
@onready var moviment_cooldown: float = tween_duration


func do_movement():
	await get_tree().create_timer(1).timeout
	var direction
	if global_position.x < 120:
		direction = 1
	elif global_position.x > 1258.0:
		direction = -1
	else:
		direction = [-1, 1].pick_random()
	rotation_direction = direction;
	
	movement_tween = get_tree().create_tween()
	movement_tween.set_ease(Tween.EASE_IN_OUT)
	#movement_tween.set_trans(Tween.TRANS_QUINT)
	
	movement_tween.tween_property(self, "global_position:x", global_position.x + (randf_range(tween_distance - 20, tween_distance + 20) * direction) , randf_range(tween_duration / 0.8, tween_duration))
	movement_tween.tween_callback(Callable(self, "do_movement"))
