extends Control

@onready var settings_menu: Control = $SettingsMenu
@onready var pause_column: Control = $PauseColumn

func _ready() -> void:
	escape_key_pressed()
	EventListener.escape_key_pressed.connect(escape_key_pressed)

func escape_key_pressed() -> void:
	if settings_menu.visible:
		settings_menu._on_back_button_pressed()
	else:
		get_tree().paused = !get_tree().paused

		visible = get_tree().paused

		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_button_pressed() -> void:
	escape_key_pressed()

func _on_settings_button_pressed() -> void:
	settings_menu.show()
	pause_column.hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
