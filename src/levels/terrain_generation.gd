@tool
extends Node3D

@onready var player: CharacterBody3D = $"../../EntityRoot/Player"

#region chunk settings
@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 128:
	set(value):
		render_distance = value
		lod_lookup()
		loaded_chunks = {}
		init_required_chunks()
		if is_inside_tree():
			update_terrain(get_chunk_from_position(player.global_position))
		else:
			update_terrain(Vector2i(0, 0))
		print(lod_lookup_table)
@export var lod_distance_arr := [1, 4, 9, 16, 25, 30]
@export_color_no_alpha var colour := Color(0.5, 0.5, 0.5):
	set(value):
		colour = value
#endregion

#region noise settings
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
#endregion

var noise = FastNoiseLite.new()
var chunk_size = 16
var collision_chunk_size = 3
var loaded_chunks: Dictionary[Vector2i, Dictionary]
var lods := [
	#TerrainLOD.new(4),
	TerrainLOD.new(2),
	TerrainLOD.new(1),
	TerrainLOD.new(0.5),
	TerrainLOD.new(0.25),
	TerrainLOD.new(0.125),
	TerrainLOD.new(0.0625),
]
var lod_lookup_table := PackedInt32Array()
var required_relative_chunks: Dictionary[Vector2i, int]

#region player position
func get_chunk_from_position(player_position: Vector3):
	return Vector2i(
		floori(player_position.x / chunk_size),
		floori(player_position.z / chunk_size)
	)

var last_chunk: Vector2i = Vector2i(0, 0)
func _process(_delta: float) -> void:
	var current_chunk: Vector2i = get_chunk_from_position(Vector3(0, 0, 0)) # player.global_position)

	if current_chunk != last_chunk:
		update_terrain(current_chunk)
		last_chunk = current_chunk
#endregion


#region noise
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
#endregion


#region lookups tables
func lod_lookup() -> void:
	lod_lookup_table.clear()
	var lod: int
	for i in render_distance + 1:
		for lod_distance in lod_distance_arr:
			if i <= lod_distance:
				lod = lod_distance_arr.find(lod_distance)
				break
		lod_lookup_table.append(lod)

func get_lod(distance: int) -> int:
	return lod_lookup_table[distance]

func init_required_chunks() -> void:
	required_relative_chunks = {}
	for x in range(-render_distance, render_distance + 1):
		for y in range(-render_distance, render_distance + 1):
			var chunk := Vector2i(x, y)
			var distance: int = max(abs(x), abs(y))
			required_relative_chunks[chunk] = get_lod(distance)
#endregion


#region mesh
func generate_chunk_mesh(resolution, chunk_pos: Vector2i) -> MeshInstance3D:
	var lod = lods[resolution]
	var terrain := MeshInstance3D.new()
	terrain.mesh = lod.mesh
	terrain.name = "chunk_%d_%d" % [chunk_pos.x, chunk_pos.y]
	add_child(terrain)
	var global_pos: Vector3
	global_pos.x = chunk_pos.x * chunk_size
	global_pos.z = chunk_pos.y * chunk_size
	terrain.position = global_pos
	return terrain

func add_loaded_chunk(lod: int, pos: Vector2i) -> void:
	var node := generate_chunk_mesh(lod, pos)
	loaded_chunks[pos] = {
		"node": node,
		"lod": lod,
	}
#endregion


#region update terrain
func update_terrain(player_pos: Vector2i) -> void:
	for chunk in loaded_chunks.keys():
		var relative: Vector2i = chunk - player_pos

		if not required_relative_chunks.has(relative):
			loaded_chunks[chunk]["node"].queue_free()
			loaded_chunks.erase(chunk)
			continue

		var required_lod: int = required_relative_chunks[relative]

		if loaded_chunks[chunk]["lod"] != required_lod:
			loaded_chunks[chunk]["node"].queue_free()
			add_loaded_chunk(required_lod, chunk)

	for relative_chunk in required_relative_chunks:
		var chunk := relative_chunk + player_pos
		if not loaded_chunks.has(chunk):
			add_loaded_chunk(required_relative_chunks[relative_chunk], chunk)
#endregion


func _ready() -> void:
	lod_lookup()
	init_required_chunks()
	if is_inside_tree():
		update_terrain(Vector2i(0, 0)) # get_chunk_from_position(player.global_position))
	else:
		update_terrain(Vector2i(0, 0))
