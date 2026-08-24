extends Control
@onready var pause_column: Control = $'../PauseColumn'

func _on_back_button_pressed() -> void:
	visible = false
	pause_column.visible = true
