extends Node2D




func _ready() -> void:
	bubble_attack()


@onready var bubble_bullet_pos: Node2D = %bubble_bullet_pos
@export var bubble_bullet: PackedScene
var wave_count: int = 10
var bullet_count: int = 10
var wave_delay: float = 3
var bullet_delay: float = 0.3
var tween_duration: float = 0.5
var target_speed: float = 1000.0


func bubble_attack():
	var wave_index: int = wave_count
	for w in range(wave_index):
		bubble_wave()
		if wave_delay != 0:
			await get_tree().create_timer(wave_delay).timeout
		wave_index -= 1


func bubble_wave() -> void:
	var bullet_index: int = bullet_count
	for i in range(bullet_index):
		# espera um pouco antes de spawnar a próxima bala
		await get_tree().create_timer(bullet_delay).timeout
		
		# instancia a bala
		var bullet: Bullet = bubble_bullet.instantiate()
		get_parent().add_child(bullet)
		
		# coloca a bala na posição de spawn
		bullet.global_position = bubble_bullet_pos.global_position
		
		bullet.look_at(get_global_mouse_position())
		
		# calcula o delay inverso — primeira bala espera mais pra acelerar
		bullet_index -= 1
		
		var bubble_behaviour := bullet.get_node_or_null("bubble_bullet_behaviour") as BubbleBulletBehaviour
		if bubble_behaviour == null: return
		
		bubble_behaviour.start_bubble_bullet(bullet_delay * (bullet_index*1.5), tween_duration, target_speed) 
