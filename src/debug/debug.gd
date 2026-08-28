@tool
extends Control

@onready var vp := get_viewport()

var stats
func _ready() -> void:
	EventListener.debug.connect(debug)
	stats = get_node_or_null("Stats")
	stats.hide()
	
func debug(state: bool):
	if state:
		vp.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		stats.show()
	else:
		vp.debug_draw = Viewport.DEBUG_DRAW_DISABLED
		stats.hide()

func _process(_delta: float) -> void:
	stats.text = "FPS: %d\nCPU: %.2f ms\nMemory: %.2f MB" % [
		Engine.get_frames_per_second(),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		OS.get_static_memory_usage() / 1048576.0
	]
