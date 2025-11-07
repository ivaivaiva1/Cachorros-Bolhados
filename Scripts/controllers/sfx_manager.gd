extends Node

# Cache dos sons carregados
var sounds: Dictionary = {}

# Mixer global (bus) — opcional
@export var base_bus := "SFX"

func play_sfx(sound_data: Dictionary) -> void:
	if not sound_data or not sound_data.has("stream"):
		push_error("SFX_Manager.play(): som inválido (faltando 'stream').")
		return
	
	var stream: AudioStream = sound_data["stream"]
	var volume: float = sound_data.get("volume", 0.0)

	# Caching opcional — útil se o stream não for preloaded
	var path := stream.resource_path
	if path != "" and not sounds.has(path):
		sounds[path] = stream
	elif path != "":
		stream = sounds[path]

	# Cria player temporário
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume
	player.bus = base_bus
	add_child(player)

	# Toca e libera ao terminar
	player.play()
	player.finished.connect(func(): player.queue_free())
