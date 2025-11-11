extends CanvasLayer

@export var shockwave_scene: PackedScene

func do_shockwave(pos: Vector2):
	if not shockwave_scene:
		push_error("shockwave_scene não está configurada!")
		return null
	
	var shockwave_instance = shockwave_scene.instantiate()
	add_child(shockwave_instance)
	
	const pos_offset = Vector2(3000.0, 3000.0)
	shockwave_instance.global_position = pos - pos_offset
	
	# Duplicar o material do ColorRect
	var mat: ShaderMaterial = shockwave_instance.material
	if not mat:
		push_error("Shockwave não tem material configurado!")
		return
	
	# Faz uma cópia independente do material (para cada instância)
	var new_mat := mat.duplicate() as ShaderMaterial
	shockwave_instance.material = new_mat
	
	# Define os parâmetros iniciais do shader
	new_mat.set_shader_parameter("center", Vector2(0.5, 0.5))
	new_mat.set_shader_parameter("force", 1.0)
	new_mat.set_shader_parameter("size", 0.0)
	new_mat.set_shader_parameter("thickness", 0.1)
	
	# Cria o tween de animação
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Os dois tweens principais começam ao mesmo tempo
	# Crescimento do raio (0 → 1)
	tween.parallel().tween_method(
		func(value):
			if is_instance_valid(new_mat):
				new_mat.set_shader_parameter("size", value)
	, 0.0, 0.6, 0.3)
	
	# Decaimento da força (1 → 0)
	tween.parallel().tween_method(
		func(value):
			if is_instance_valid(new_mat):
				new_mat.set_shader_parameter("force", value)
	, 1.0, 0, 0.3)
	
	tween.parallel().tween_method(
		func(value):
			if is_instance_valid(new_mat):
				new_mat.set_shader_parameter("thickness", value)
	, 0.1, 0.01, 0.3)
	
	## Depois de crescer e dissipar, faz o fade-out do ColorRect
	#tween.tween_interval(0.1)
	#tween.tween_property(shockwave_instance, "modulate:a", 0.0, 0.3)
	
	# Quando o tween terminar, remove a instância
	tween.finished.connect(func():
		if is_instance_valid(shockwave_instance):
			shockwave_instance.queue_free())
