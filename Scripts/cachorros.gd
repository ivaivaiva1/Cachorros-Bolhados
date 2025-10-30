extends RigidBody2D
class_name Cachorros

@onready var sprite: Sprite2D = %Sprite2D
@export var dog_id: int
@export var jump_force: float = 600.0
@export var gravity: float = 1100.0

var is_released: bool = false
var is_a_copy: bool = false

func _ready() -> void:
	# Evita que ele caia antes da hora
	sleeping = true
	gravity_scale = 0.0
#
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("change_bg"):
		#jump()

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#if not is_released:
		#return
	## Aplicar gravidade manualmente (ou usar gravity_scale = 1)
	##state.apply_central_force(Vector2(0, gravity))

func jump():
	linear_velocity.y = -jump_force

func set_free():
	is_released = true
	sleeping = false
	gravity_scale = 1.0
	if is_a_copy: return
	jump()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("death"):
		queue_free()
	elif area.is_in_group("icon"):
		if not is_released:
			return
		GameManager.icon_container.add_icon(dog_id)

func panthom_effect():
	# Impede o cachorro de interagir mais
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true
	if has_node("Area2D"):
		$Area2D.monitoring = false
	
	# Cria o tween
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.0), 0.5)  # Fica branco e desaparece
	tween.parallel().tween_property(self, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	#
	## Quando o tween terminar:
	#tween.finished.connect(func():
		#ScreenShake.screen_shake(multiplier, 0.4)
		#SpawnText.display_text(str("X", multiplier), dog_pos)
		##create_two_copies(dog_id, dog_pos, dog_velocity, dog_rotation, multiplier)
		#queue_free()
	#)
