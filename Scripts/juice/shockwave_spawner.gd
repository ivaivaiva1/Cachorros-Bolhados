extends CanvasLayer

@export var shockwave_scene: PackedScene

func do_shockwave(pos: Vector2):
	if not shockwave_scene:
		push_error("shockwave_scene não está configurada!")
		return null
	
	var shockwave_instance = shockwave_scene.instantiate()
	add_child(shockwave_instance)
	
	# Duplicar o material do ColorRect
	var mat: ShaderMaterial = shockwave_instance.material
	if not mat:
		push_error("Shockwave não tem material configurado!")
		return
	
	# Faz uma cópia independente do material (para cada instância)
	var new_mat := mat.duplicate() as ShaderMaterial
	shockwave_instance.material = new_mat
	
	# Agora podemos alterar os parâmetros sem afetar as outras instâncias
	var viewport_size = get_viewport().get_visible_rect().size
	
	var center_normalized = Vector2(
		pos.x / viewport_size.x,
		1.0 - (pos.y / viewport_size.y)
	)
	
	new_mat.set_shader_parameter("Center", center_normalized)
	
	# Agora animamos esse shockwave individualmente
	#animate_shockwave(shockwave_instance)
	
	# 🔹 Debug: imprime o valor atual do parâmetro Center
	print("Center do shockwave:", shockwave_instance.material.get_shader_parameter("Center"))





#func animate_shockwave(shockwave_instance: Node) -> void:
	##var new_shader: ShaderMaterial = shockwave_instance.material.duplicate() as ShaderMaterial
	##shockwave_instance.material = new_shader 
	##var mat = shockwave_instance.material
	##
	### inicializa parâmetros
	##mat.set_shader_parameter("force", 0.0)
	##mat.set_shader_parameter("size", 0.0)
	##mat.set_shader_parameter("thickness", 0.1)
	#
	## cria o tween
	##var tween = shockwave_instance.create_tween()
	##tween.tween_property(mat, "shader_parameter/size", 0.5, 0.5)\
		##.set_trans(Tween.TRANS_SINE)\
		##.set_ease(Tween.EASE_IN)
	##
	##tween.parallel().tween_property(mat, "shader_parameter/force", 0.4, 0.5)\
		##.set_trans(Tween.TRANS_SINE)\
		##.set_ease(Tween.EASE_IN)
	#return
	## conecta o queue_free() no finished do tween
	##tween.finished.connect(func(): shockwave_instance.queue_free())
	#print("tamo aq")
	#
	#var tween = shockwave_instance.create_tween()
	#tween.tween_property(shockwave_instance, "modulate:a", 0.0, 0.5) # fade-out
	#
	#tween.finished.connect(func():
		#print("Tween finalizado — liberando!")
		#shockwave_instance.queue_free()
		#)
