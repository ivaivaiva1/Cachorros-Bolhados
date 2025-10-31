extends Node

# Cada freeze será um dicionário: { "time_scale": float, "time_left": float }
var active_freezes: Array = []

@export var default_duration: float = 0.01
@export var default_time_scale: float = 0.1

func _process(delta: float) -> void:
	if active_freezes.is_empty():
		return

	# Atualiza tempos e remove os que acabaram
	for i in range(active_freezes.size() - 1, -1, -1):
		active_freezes[i].time_left -= delta
		if active_freezes[i].time_left <= 0.0:
			active_freezes.remove_at(i)

	# Aplica o menor time_scale ativo (freeze mais forte)
	if active_freezes.is_empty():
		Engine.time_scale = 1.0
	else:
		var min_scale = 1.0
		for f in active_freezes:
			min_scale = min(min_scale, f.time_scale)
		Engine.time_scale = min_scale

func hit_freeze(time_scale: float = default_time_scale, duration: float = default_duration) -> void:
	active_freezes.append({
		"time_scale": time_scale,
		"time_left": duration
	})
