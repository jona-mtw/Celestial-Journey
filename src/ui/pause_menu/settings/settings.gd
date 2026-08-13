extends CanvasLayer
@onready var pause_menu: CanvasLayer = $'..'

func _on_back_button_pressed() -> void:
	visible = false
	pause_menu.visible = true
