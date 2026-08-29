@tool
extends Control

@onready var vp := get_viewport()
@onready var player: CharacterBody3D = $"../../World/EntityRoot/Player"

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
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
	stats.text = "Performance:\nFPS: %d\nCPU: %.2f ms\nMemory: %.2f MB\n\nCoordinates: (%d, %d, %d)\nChunk: (%d, %d)" % [
		Engine.get_frames_per_second(),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		OS.get_static_memory_usage() / 1048576.0,
		player.global_position.x,
		player.global_position.y,
		player.global_position.z,
		player.global_position.x / 16,
		player.global_position.z / 16
	]