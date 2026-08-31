extends CharacterBody3D

@export var SPEED: float = 3
const JUMP_VELOCITY: float = 4.5
@onready var animation_player = $player_model/AnimationPlayer


func _physics_process(_delta: float) -> void:
	# if not is_on_floor():
	# 	velocity += get_gravity() * delta
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if is_on_floor() and velocity != Vector3.ZERO:
		animation_player.play("Walk")
	elif is_on_floor():
		animation_player.play("Idle1")

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
