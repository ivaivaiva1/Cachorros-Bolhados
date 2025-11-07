extends Node2D

var multiplier: int
var random_multiplier: bool = false

@onready var label: Label = %Label
var SFX_COIN = "res://Audio/Dredge/coin.wav"
var SFX_DUPLICATE = "res://Audio/Dredge/duplicate.wav"

# 🔹 Timer interno para trocar o multiplicador quando random estiver ativo
var random_timer: float = 0.0
const RANDOM_INTERVAL: float = 0.3

func _ready() -> void:
	get_random_multiplier()
	label.text = str("X", multiplier)


func _process(delta: float) -> void:
	if random_multiplier:
		random_timer -= delta
		if random_timer <= 0.0:
			random_timer = RANDOM_INTERVAL
			change_random_multiplier()


func change_random_multiplier() -> void:
	var possible_multipliers = [2, 3, 4, 5, 10]
	var new_mult = possible_multipliers[randi() % possible_multipliers.size()]

	# Evita repetir o mesmo valor consecutivo (opcional)
	if new_mult == multiplier:
		new_mult = possible_multipliers[randi() % possible_multipliers.size()]

	multiplier = new_mult
	label.text = str("X", multiplier)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("dog"):
		var cachorros: Cachorros = body
		if cachorros.is_a_copy:
			return
		
		var rigidbody: RigidBody2D = cachorros as RigidBody2D
		if rigidbody.linear_velocity.y > 0:
			var dog_id = cachorros.dog_id
			var dog_pos = cachorros.global_position
			var dog_velocity = rigidbody.linear_velocity
			var dog_rotation = cachorros.rotation
			
			var dog_multi = multiplier
			DuplicateCats.do_duplication(cachorros, dog_id, dog_pos, dog_velocity, dog_rotation, dog_multi)
			
			SfxManager.play_sfx(SOUNDS_LIST.COIN_SFX)
			SpawnText.display_text(str("X", dog_multi), dog_pos)
			HitFreeze.hit_freeze(0.3, 0.015)

func get_random_multiplier():
	randomize()
	var chances = {
		2: 15,
		3: 40,
		4: 24,
		5: 10,
		10: 1,
		0: 10
	}
	
	var total_weight = 0
	for weight in chances.values():
		total_weight += weight
	
	var rand_pick = randf() * total_weight
	var current = 0
	
	for mult in chances.keys():
		current += chances[mult]
		if rand_pick <= current:
			multiplier = mult
			break
	
	if multiplier == null || multiplier == 0:
		# Se for 0X, ativa modo aleatório
		random_multiplier = true
		change_random_multiplier()
