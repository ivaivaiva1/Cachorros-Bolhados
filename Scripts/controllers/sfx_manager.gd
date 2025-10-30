extends Node

# Dicionário com os sons carregados (opcional, pra performance)
var sounds: Dictionary = {}

# Mixer global para todos os SFX
@export var base_bus := "SFX"  # opcional, se quiser enviar pra um AudioBus específico

func play_sfx(sound_path: String, volume_db: float = 0.0) -> void:
	# Verifica se já temos o som carregado
	var audio_stream: AudioStream
	if sound_path in sounds:
		audio_stream = sounds[sound_path]
	else:
		audio_stream = load(sound_path)
		sounds[sound_path] = audio_stream
	
	# Cria um AudioStreamPlayer2D temporário (ou 3D se quiser espacial)
	var player := AudioStreamPlayer.new()
	player.stream = audio_stream
	player.volume_db = volume_db
	player.bus = base_bus
	add_child(player)
	
	# Toca e destrói depois que terminar
	player.play()
	player.finished.connect(func(): player.queue_free())
