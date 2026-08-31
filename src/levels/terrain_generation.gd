@tool
extends Node3D

@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 5:
	set(value):
		render_distance = value
@export var lod_dist := [1, 4, 9, 16, 25]
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
var lods := [
	#TerrainLOD.new(4),
	TerrainLOD.new(2),
	TerrainLOD.new(1),
	TerrainLOD.new(0.5),
	TerrainLOD.new(0.25),
	TerrainLOD.new(0.125)
]

func init_lods():
	for lod in lods:
		var terrain := MeshInstance3D.new()
		terrain.mesh = lod.mesh
		terrain.name = "template_lod_%" % [lods.find(lod)]
		add_child(terrain)
		terrain.hide()

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

func get_chunk_ring(distance: int) -> PackedVector2Array:
	var chunk_ring := PackedVector2Array()
	var chunk_ring_length = distance + 1
	for x_chunk in range(-chunk_ring_length, chunk_ring_length + 1, 1):
		if abs(x_chunk) == chunk_ring_length:
			for y_chunk in range(-chunk_ring_length, chunk_ring_length + 1, 1):
				chunk_ring.push_back(Vector2(x_chunk, y_chunk))
		else:
			chunk_ring.push_back(Vector2(x_chunk, -chunk_ring_length))
			chunk_ring.push_back(Vector2(x_chunk, chunk_ring_length))

	return chunk_ring

func generate_terrain_mesh(player_pos: Vector2i) -> void:
	generate_chunk_mesh(0, player_pos)
	var outskirts = false
	var lod: int

	for distance in range(render_distance):
		var chunk_ring := get_chunk_ring(distance)

		if not outskirts:
			if distance == lod_dist[-1]:
					outskirts = true
					lod = lod_dist.find(lod_dist[-1])
			if not outskirts:
				for i in lod_dist:
					if distance < i:
						lod = lod_dist.find(i)
						break

		for chunk: Vector2i in chunk_ring:
			chunk += player_pos
			generate_chunk_mesh(lod, chunk)
			loaded_chunks.push_back(chunk)

func update_terrain(player_pos: Vector2i) -> void:
	for child in get_children():
		child.free()
		loaded_chunks = PackedVector2Array()
	generate_terrain_mesh(player_pos)

func _ready() -> void:
	EventListener.player_chunk_changed.connect(update_terrain)
	generate_terrain_mesh(Vector2i(0, 0))
