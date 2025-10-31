extends Node

# --- Configurações ---
@export var cursor_texture: Texture2D               # A textura original do cursor
@export var hotspot: Vector2 = Vector2(152.0, 127.0) # Hotspot original da imagem
@export var scale_factor: float = 0.3               # Fator de redução (0.5 = 50%)

func _ready():
	if not cursor_texture:
		print("⚠️ Nenhuma textura de cursor atribuída!")
		return

	# Pega a imagem da textura
	var img: Image = cursor_texture.get_image()

	# Calcula novo tamanho
	var new_width = int(img.get_width() * scale_factor)
	var new_height = int(img.get_height() * scale_factor)
	img.resize(new_width, new_height)

	# Cria nova textura redimensionada
	var new_texture = ImageTexture.create_from_image(img)

	# Ajusta o hotspot proporcionalmente
	var new_hotspot = hotspot * scale_factor

	# Aplica o cursor customizado
	Input.set_custom_mouse_cursor(new_texture, Input.CURSOR_ARROW, new_hotspot)

	print("✅ Cursor customizado aplicado! Tamanho ajustado:", new_width, "x", new_height)
