extends Node2D
class_name Icons_Container

@export var icon_scenes: Array[PackedScene]  # cachorros normais
@export var icon_gold: PackedScene          # gold

const MAX_PER_LINE: int = 34
const START_POS: Vector2 = Vector2(21, 14)
const OFFSET_X: int = 40
const OFFSET_Y: int = 27

# Cada linha é um Array de tamanho MAX_PER_LINE. Cada slot é null ou { "node": Node, "is_gold": bool }
var lines: Array = []

func _ready() -> void:
	GameManager.icon_container = self
	_ensure_line(0)


# --- API pública
func add_icon(icon_id: int) -> void:
	# tenta adicionar no último linha; se estiver cheia de golds, cria nova linha automaticamente
	var line_index = lines.size() - 1
	while true:
		var free_idx = _find_first_free_index(line_index)
		if free_idx != -1:
			# tem espaço: instancia o ícone normal
			var inst = icon_scenes[icon_id].instantiate()
			add_child(inst)
			_place_in_line(line_index, free_idx, inst, false)
			return
		else:
			# linha sem espaço. Se tem normais -> compacta (remove normais e adiciona 1 gold)
			var normal_count = _count_normals_in_line(line_index)
			if normal_count > 0:
				_compact_line(line_index)
				# após compactar haverá vagas; continua o loop e tentamos inserir
			else:
				# linha só com golds -> criar nova linha e continuar nela
				_ensure_line(lines.size())
				line_index += 1
				# loop continua e tentará inserir na nova linha


# --- helpers de linhas/colunas
func _create_empty_line() -> Array:
	var arr: Array = []
	for i in range(MAX_PER_LINE):
		arr.append(null)
	return arr

func _ensure_line(idx: int) -> void:
	while lines.size() <= idx:
		lines.append(_create_empty_line())

func _find_first_free_index(line_index: int) -> int:
	if line_index < 0 or line_index >= lines.size():
		return -1
	var line = lines[line_index]
	for i in range(MAX_PER_LINE):
		if line[i] == null:
			return i
	return -1

func _count_normals_in_line(line_index: int) -> int:
	if line_index < 0 or line_index >= lines.size():
		return 0
	var c = 0
	for i in range(MAX_PER_LINE):
		var item = lines[line_index][i]
		if item != null and not item["is_gold"]:
			c += 1
	return c

func _place_in_line(line_index: int, column_index: int, node: Node, is_gold: bool) -> void:
	lines[line_index][column_index] = { "node": node, "is_gold": is_gold }
	# usar position (local) para ficar relativo ao container
	node.position = START_POS + Vector2(column_index * OFFSET_X, line_index * OFFSET_Y)


# --- compacta a linha: remove normais, mantém golds e adiciona 1 gold novo à direita dos golds existentes
func _compact_line(line_index: int) -> void:
	if line_index < 0 or line_index >= lines.size():
		return
	var line = lines[line_index]

	# coletar golds existentes e remover normais
	var old_golds: Array = []
	for i in range(MAX_PER_LINE):
		var item = line[i]
		if item != null:
			if item["is_gold"]:
				old_golds.append(item["node"])
			else:
				# remove normal
				if is_instance_valid(item["node"]):
					item["node"].queue_free()

	# limpar a linha
	for i in range(MAX_PER_LINE):
		line[i] = null

	# recolocar os golds existentes nas posições iniciais
	for i in range(old_golds.size()):
		var g = old_golds[i]
		lines[line_index][i] = { "node": g, "is_gold": true }
		g.position = START_POS + Vector2(i * OFFSET_X, line_index * OFFSET_Y)

	# adicionar 1 novo gold imediatamente após os existentes (se couber)
	var new_index = old_golds.size()
	if new_index < MAX_PER_LINE:
		var new_gold = icon_gold.instantiate()
		add_child(new_gold)
		lines[line_index][new_index] = { "node": new_gold, "is_gold": true }
		new_gold.position = START_POS + Vector2(new_index * OFFSET_X, line_index * OFFSET_Y)
	else:
		# se já tiver MAX_PER_LINE de golds (caso extremo), não conseguimos adicionar mais aqui.
		# Isso só deve acontecer se a linha já estiver completamente preenchida por golds.
		# A lógica chamadora cria uma nova linha nesse caso.
		print_debug("compact_line: linha já cheia só com golds (improvável aqui).")
