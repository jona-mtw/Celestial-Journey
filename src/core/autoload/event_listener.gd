extends Node

signal escape_key_pressed()

signal settings_button_pressed()

signal player_chunk_changed(position: Vector2i)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		escape_key_pressed.emit()
