extends CharacterBody3D

const SPEED: float = 10
const JUMP_VELOCITY: float = 4.5

var coord: Vector2i
func get_chunk_from_position(player_position: Vector3):
	coord.x = floor(player_position.x / 16)
	coord.y = floor(player_position.z / 16)

	return coord

var current_chunk: Vector2i
var last_chunk: Vector2i
func _physics_process(delta: float) -> void:
	current_chunk = get_chunk_from_position(position)

	if current_chunk != last_chunk:
		last_chunk = current_chunk
		EventListener.player_chunk_changed.emit(current_chunk)

	#if not is_on_floor():
		#velocity += get_gravity() * delta
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
