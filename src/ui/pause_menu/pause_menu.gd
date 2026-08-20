extends CanvasLayer

func _ready() -> void:
	escape_key_pressed()
	EventListener.escape_key_pressed.connect(escape_key_pressed)

func escape_key_pressed() -> void:
	if $SettingsMenu.visible:
		print("hooray")
		$SettingsMenu._on_back_button_pressed()
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
	hide()
	$SettingsMenu.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()
