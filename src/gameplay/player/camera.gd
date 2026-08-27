extends SpringArm3D

@onready var camera: Camera3D = $Camera
@onready var player: CharacterBody3D = $'..'

@export var sensitivity: float = 0.005
@export var min_zoom: float = 0.0
@export var max_zoom: float = 50.0
@export var zoom_step = 3
@export var zoom_speed = 5

@onready var target_zoom: float = spring_length

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("right_click"):
			rotation.y -= event.relative.x * sensitivity
		else:
			player.rotation.y -= event.relative.x * sensitivity
		rotation.x -= event.relative.y * sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if event.is_action_pressed("mouse_wheel_up"):
		target_zoom = clamp(target_zoom - zoom_step, min_zoom, max_zoom)
	if event.is_action_pressed("mouse_wheel_down"):
		target_zoom = clamp(target_zoom + zoom_step, min_zoom, max_zoom)
	

func _process(delta: float) -> void:
	spring_length = lerp(spring_length, target_zoom, zoom_speed * delta)

	if spring_length < 0.6:
		player.hide()
	else:
		if not Input.is_action_pressed("right_click"):
			rotation.y = lerp_angle(rotation.y, 0.0, delta * 5)
		player.show()
