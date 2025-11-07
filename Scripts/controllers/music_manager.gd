extends Node

@export var base_bus := "Music"

var current_player: AudioStreamPlayer = null

# --- TOCAR música instantaneamente (com delay opcional) ---
func play_instant(music_data: Dictionary, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	# Cria e configura um novo player
	var player := AudioStreamPlayer.new()
	player.bus = base_bus
	player.stream = music_data["stream"]
	player.volume_db = music_data["volume"]
	add_child(player)
	player.play()
	
	current_player = player


# --- TOCAR música com FADE-IN (com delay opcional) ---
func play_with_fade_in(music_data: Dictionary, fade_time: float = 1.5, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	# Cria e configura um novo player
	var player := AudioStreamPlayer.new()
	player.bus = base_bus
	player.stream = music_data["stream"]
	player.volume_db = -30.0  # começa silencioso
	add_child(player)
	player.play()
	
	# Fade in
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(player, "volume_db", music_data["volume"], fade_time)
	
	
	current_player = player
	await tween.finished


# --- FADE OUT da música atual ---
func fade_out(duration: float = 1.5) -> void:
	if current_player == null: return
	
	var player: AudioStreamPlayer = current_player
	var tween := get_tree().create_tween()
	tween.tween_property(player, "volume_db", -30.0, duration)
	await tween.finished
	
	if current_player == player:
		current_player = null
	player.stop()
	player.queue_free()
