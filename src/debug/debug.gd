extends Node

@onready var vp := get_viewport()

func _ready() -> void:
	EventListener.debug.connect(debug)

func debug(state: bool):
	if state:
		vp.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	else:
		vp.debug_draw = Viewport.DEBUG_DRAW_DISABLED