extends Node2D

var is_visible: bool = true

func _ready() -> void:
	self.visible = true

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("change_bg"):
		#if is_visible:
			#is_visible = false
			#self.visible = false
		#else:  
			#is_visible = true
			#self.visible = true
