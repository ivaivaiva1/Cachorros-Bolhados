extends Node

# --- Configuração ---
@export var max_difficulty: float = 20.0
@export var base_growth_rate: float = 0.05       # Crescimento fixo base por segundo
@export var initial_bonus_growth: float = 0.001  # Antes de perder o primeiro cachorro
#@export var initial_bonus_growth: float = 1  # Antes de perder o primeiro cachorro
@export var normal_bonus_growth: float = 0.0003  # Depois da primeira perda
@export var difficulty_loss_cooldown: float = 0.0  # Tempo mínimo entre reduções de dificuldade (segundos)

# --- Variáveis internas ---
var time_since_loss: float = 0.0
var never_lost_dog: bool = true
var loss_cooldown_timer: float = 0.0   # Contagem desde a última redução real da dificuldade

# --- Label opcional ---
@onready var label: Label = $"../adaptive difficulty label"


func _process(delta: float) -> void:
	if GameManager.current_scene != GameManager.SCENES.GAME: return
	if GameManager.game.game_state != GameManager.game.GAME_STATE.FARM: return
	
	update_fly_speed()
	
	# Atualiza tempos
	time_since_loss += delta
	loss_cooldown_timer += delta
	
	# Escolhe o bônus de crescimento
	var current_bonus = initial_bonus_growth if never_lost_dog else normal_bonus_growth
	
	# Calcula taxa de crescimento
	var growth_rate = base_growth_rate + time_since_loss * current_bonus
	
	# Atualiza dificuldade
	GameManager.adaptive_difficulty += growth_rate * delta
	GameManager.adaptive_difficulty = clamp(GameManager.adaptive_difficulty, 0.0, max_difficulty)
	
	# Atualiza texto da label (se existir) mostrando também o current_bonus
	if label:
		label.text = "Adaptive Difficulty = %.2f | Current Bonus Growth = %.6f" % [
			GameManager.adaptive_difficulty, current_bonus
		]


func on_dog_escaped() -> void:
	# Sempre zera o tempo desde a perda
	time_since_loss = 0.0
	
	# Só reduz a dificuldade se o cooldown permitir
	if loss_cooldown_timer >= difficulty_loss_cooldown:
		GameManager.adaptive_difficulty -= 4.0
		GameManager.adaptive_difficulty = clamp(GameManager.adaptive_difficulty, 0.0, max_difficulty)
		loss_cooldown_timer = 0.0  # reinicia o cooldown
	
		# Primeira vez que perde cachorro → muda o bônus
		if never_lost_dog:
			never_lost_dog = false


func update_fly_speed() -> void:
	# Constantes locais para manter a lógica concentrada
	const MIN_DIFFICULTY := 0.0
	const MID_DIFFICULTY := 20.0
	const BASE_SPEED := 80.0
	const MAX_SPEED := 200.0
	const PEAK_SPEED := 300.0
	
	# Pega a dificuldade atual
	var difficulty = clamp(GameManager.adaptive_difficulty, MIN_DIFFICULTY, MID_DIFFICULTY)
	
	# Caso especial: dificuldade 20 → velocidade 300
	if difficulty >= MID_DIFFICULTY:
		GameManager.fly_speed = PEAK_SPEED
	else:
		# Interpola linearmente entre 80 e 200
		GameManager.fly_speed = lerp(BASE_SPEED, MAX_SPEED, difficulty / MID_DIFFICULTY)
