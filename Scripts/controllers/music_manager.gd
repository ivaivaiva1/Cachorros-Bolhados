extends Node

@export var base_bus := "Music"
var _player: AudioStreamPlayer 


func _ready():
	_player = AudioStreamPlayer.new()
	_player.bus = base_bus
	add_child(_player)


# --- FADE OUT da música atual ---
func fade_out(duration: float = 1.5) -> void:
	if not _player.playing:
		return
	
	var tween := get_tree().create_tween()
	tween.tween_property(_player, "volume_db", -80.0, duration)
	await tween.finished
	_player.stop()


# --- TOCAR música instantaneamente (com delay opcional) ---
func play_instant(music_data: Dictionary, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	_player.stop()
	_player.stream = music_data["stream"]
	_player.volume_db = music_data["volume"]
	_player.play()


# --- TOCAR música com FADE-IN (com delay opcional) ---
func play_with_fade_in(music_data: Dictionary, fade_time: float = 1.5, delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	_player.stop()
	_player.stream = music_data["stream"]
	_player.volume_db = -80.0
	_player.play()
	
	var tween := get_tree().create_tween()
	tween.tween_property(_player, "volume_db", music_data["volume"], fade_time)
	await tween.finished
