@tool
extends Node

signal escape_key_pressed()

signal settings_button_pressed()

signal player_chunk_changed(position: Vector2i)

var debug_state := false
signal debug(state: bool)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event.is_action_pressed("escape"):
		escape_key_pressed.emit()

	if event.is_action_pressed("debug"):
		debug_state = !debug_state
		debug.emit(debug_state)
