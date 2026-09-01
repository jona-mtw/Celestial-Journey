@tool
extends Node3D

@onready var player: CharacterBody3D = $"../../EntityRoot/Player"

#region chunk settings
@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 5:
	set(value):
		render_distance = value
@export var lod_distance_arr := [1, 4, 9, 16, 25]
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


#region player position
func get_chunk_from_position(player_position: Vector3):
	return Vector2i(
		floori(player_position.x / chunk_size),
		floori(player_position.z / chunk_size)
	)

var last_chunk := Vector2i(0, 0)
func _process(_delta: float) -> void:
	var current_chunk: Vector2i = get_chunk_from_position(player.global_position)

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


#region mesh
var lods := [
	#TerrainLOD.new(4),
	TerrainLOD.new(2),
	TerrainLOD.new(1),
	TerrainLOD.new(0.5),
	TerrainLOD.new(0.25),
	TerrainLOD.new(0.125)
]

func get_lod(distance: int) -> int:
	var lod: int
	if distance > lod_distance_arr[-1]:
		lod = lod_distance_arr.find(lod_distance_arr[-1])
	else:
		for lod_distance in lod_distance_arr:
			if distance <= lod_distance:
				lod = lod_distance_arr.find(lod_distance)
				break

	return lod

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
#endregion

func add_loaded_chunk(lod: int, pos: Vector2i) -> void:
	var node := generate_chunk_mesh(lod, pos)
	loaded_chunks[pos] = {
		"node": node,
		"lod": lod,
	}

#region terrain generation
func generate_terrain_mesh(player_pos: Vector2i) -> void:
	for x in range(-render_distance, render_distance + 1):
		for y in range(-render_distance, render_distance + 1):
			var chunk := Vector2i(x, y) + player_pos
			var distance := int(max(abs(x), abs(y)))
			var lod := get_lod(distance)

			add_loaded_chunk(lod, chunk)
#endregion


#region update terrain
func required_chunks(player_pos: Vector2i) -> Dictionary:
	var chunks: Dictionary[Vector2i, int]

	for x in range(-render_distance, render_distance + 1):
		for y in range(-render_distance, render_distance + 1):
			var chunk := Vector2i(x, y) + player_pos
			var distance := int(max(abs(x), abs(y)))
			chunks[chunk] = get_lod(distance)

	return chunks

func update_terrain(player_pos: Vector2i) -> void:
	var required_chunks_arr := required_chunks(player_pos)
	for chunk in loaded_chunks.keys():
		if not required_chunks_arr.has(chunk):
			loaded_chunks[chunk]["node"].queue_free()
			loaded_chunks.erase(chunk)
		
	for chunk in required_chunks_arr:
		var required_lod: int = required_chunks_arr[chunk]
		if loaded_chunks.has(chunk):
			if required_chunks_arr[chunk] == loaded_chunks[chunk]["lod"]:
				continue
			
			loaded_chunks[chunk]["node"].queue_free()
			
		add_loaded_chunk(required_lod, chunk)
#endregion


func _ready() -> void:
	generate_terrain_mesh(Vector2i(0, 0))
