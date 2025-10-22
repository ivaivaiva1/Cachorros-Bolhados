extends Node2D

@export var bubble_objects: Array[PackedScene]
@export var spawn_points: Array[Marker2D]

@export var max_bubbles: int = 50

var spawn_timer: float = 0.0
var alive_bubbles: Array = []  # ← lista de bolhas vivas

@onready var label: Label = $"../cooldown spawn label"

func _ready() -> void:
	spawn_timer = 1.0  # começa com 1s de cooldown


func _process(delta: float) -> void:
	if GameManager.game_state != "Play":
		return

	# --- Calcula cooldown baseado na dificuldade adaptativa ---
	var difficulty = clamp(GameManager.adaptive_difficulty, 0.0, 20.0)
	var spawn_cooldown: float

	if difficulty <= 10.0:
		spawn_cooldown = lerp(1.0, 0.3, difficulty / 10.0)
	else:
		spawn_cooldown = lerp(0.3, 0.1, (difficulty - 10.0) / 10.0)

	# --- Timer de spawn ---
	if spawn_timer > 0:
		spawn_timer -= delta
	else:
		spawn_bubble()
		spawn_timer = spawn_cooldown

	# --- Atualiza label ---
	if label:
		label.text = "Spawn cooldown: %.2f s | Timer: %.2f s | Bolhas: %d" % [
			spawn_cooldown, spawn_timer, alive_bubbles.size()
		]


func spawn_bubble() -> void:
	var random_bubble = randi_range(0, bubble_objects.size() - 1)
	var random_position = randi_range(0, spawn_points.size() - 1)
	var instance = bubble_objects[random_bubble].instantiate()
	instance.global_position = spawn_points[random_position].global_position
	
	# Adiciona na cena e na lista
	add_child(instance)
	alive_bubbles.append(instance)
	
	# Remove automaticamente da lista quando for destruída
	instance.connect("tree_exited", Callable(self, "_on_bubble_removed").bind(instance))


func _on_bubble_removed(bubble: Node) -> void:
	# Garante que a bolha seja removida da lista quando sair da árvore
	if bubble in alive_bubbles:
		alive_bubbles.erase(bubble)


func destroy_all_bubbles() -> void:
	for bubble in alive_bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	alive_bubbles.clear()
