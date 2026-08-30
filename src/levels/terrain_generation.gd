@tool
extends Node3D

@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 5:
	set(value):
		render_distance = value
@export_color_no_alpha var colour := Color(0.5, 0.5, 0.5):
	set(value):
		colour = value

@export_category("Noise Settings")
@export var terrain_seed := randi():
	set(value):
		terrain_seed = value
		noise.seed = terrain_seed
@export var freq := 0.01:
	set(value):
		freq = value
		noise.frequency = freq
@export var octaves := 5:
	set(value):
		octaves = value
		noise.fractal_octaves = octaves
@export var persistence := 0.5:
	set(value):
		persistence = value
		noise.fractal_gain = persistence
@export var lacunarity := 2.0:
	set(value):
		lacunarity = value
		noise.fractal_lacunarity = lacunarity
@export var strength := 10:
	set(value):
		strength = value


var noise = FastNoiseLite.new()
var chunk_size = 16
var collision_chunk_size = 3
var loaded_chunks: PackedVector2Array
var debug_state := false


# noise
func _init() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = terrain_seed
	noise.frequency = freq
	noise.fractal_octaves = octaves
	noise.fractal_gain = persistence
	noise.fractal_lacunarity = lacunarity

func get_noise(vert: Vector3) -> float:
	var height = noise.get_noise_2d(vert.x, vert.z) * strength
	return height

func generate_chunk_verts(chunk_pos: Vector2i, lod: float) -> Array:
	var vertices := PackedVector3Array()

	var x_offset = floor(chunk_pos.x * chunk_size) - 1
	var z_offset = floor(chunk_pos.y * chunk_size) - 1

	for x in chunk_size * lod + 3:
		for z in chunk_size * lod + 3:
			var vert := Vector3(
				x / lod + x_offset,
				0.0,
				z / lod + z_offset
			)
			vert.y = get_noise(vert)
			vertices.push_back(vert)

	return vertices


# mesh
var lods: Dictionary[int, TerrainLOD] = { # power of 2s
	-3: TerrainLOD.new(0.125),
	-2: TerrainLOD.new(0.25),
	-1: TerrainLOD.new(0.5),
	0: TerrainLOD.new(1),
	1: TerrainLOD.new(2),
	2: TerrainLOD.new(4),
}

func generate_chunk_mesh(resolution, chunk_pos: Vector2i) -> void:
	var lod = lods[resolution]
	var terrain := MeshInstance3D.new()
	terrain.mesh = lod.mesh
	terrain.name = "chunk_%d_%d" % [chunk_pos.x, chunk_pos.y]
	add_child(terrain)
	var global_pos: Vector3
	global_pos.x = chunk_pos.x * chunk_size
	global_pos.z = chunk_pos.y * chunk_size
	terrain.position = global_pos


# terrain generation

func get_chunk_ring(distance: int) -> Array:
	var chunk_ring := PackedVector2Array()
	var chunk_ring_length = distance + 1
	print(chunk_ring_length)
	for x_chunk in range(-chunk_ring_length, chunk_ring_length + 1, 1):
		if abs(x_chunk) == chunk_ring_length:
			for y_chunk in range(-chunk_ring_length, chunk_ring_length + 1, 1):
				chunk_ring.push_back(Vector2(x_chunk, y_chunk))
		else:
			chunk_ring.push_back(Vector2(x_chunk, -chunk_ring_length))
			chunk_ring.push_back(Vector2(x_chunk, chunk_ring_length))

	return chunk_ring

func chunks_to_render() -> Array: # relative to player
	var chunks_to_render_arr := PackedVector2Array()
	chunks_to_render_arr.append(Vector2(0, 0))

	for distance in range(render_distance + 1):
		chunks_to_render_arr.append_array(get_chunk_ring(distance))
		print(get_chunk_ring(distance))

	return chunks_to_render_arr


func generate_terrain_mesh(player_pos: Vector3) -> void:
	for chunk in chunks_to_render():
		generate_chunk_mesh(1, chunk)

func _ready() -> void:
	generate_terrain_mesh(Vector3(0, 0, 0))
