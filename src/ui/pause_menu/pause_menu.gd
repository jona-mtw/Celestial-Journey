extends CanvasLayer

func _ready() -> void:
	toggle_pause()
	toggle_pause()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and !$Settings.visible:
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused

	visible = get_tree().paused

	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_settings_button_pressed() -> void:
	hide()
	$Settings.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()
