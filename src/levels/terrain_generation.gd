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

func generate_verts(chunk_pos: Vector2i, lod: float) -> Array:
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
var lod_neg3 := TerrainLOD.new(0.125)
var lod_neg2 := TerrainLOD.new(0.25)
var lod_neg1 := TerrainLOD.new(0.5)
var lod_0 := TerrainLOD.new(1)
var lod_1 := TerrainLOD.new(2)
var lod_2 := TerrainLOD.new(4)

var lods := {
	-3: lod_neg3,
	-2: lod_neg2,
	-1: lod_neg1,
	0: lod_0,
	1: lod_1,
	2: lod_2,
}

func get_lod(resolution, chunk_pos: Vector2i) -> void:
	var lod = lods[resolution]
	var terrain := MeshInstance3D.new()
	terrain.mesh = lod.mesh
	add_child(terrain)
	var global_pos: Vector3
	global_pos.x = chunk_pos.x * chunk_size
	global_pos.z = chunk_pos.y * chunk_size
	terrain.position = global_pos
