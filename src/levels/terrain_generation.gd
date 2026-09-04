@tool
extends Node3D

@onready var player: CharacterBody3D = $"../../EntityRoot/Player"

#region chunk settings
@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 30:
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

#region global vars
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
var terrain_material: ShaderMaterial
#endregion

func _init() -> void:
	var shader := load("res://src/shaders/terrain.gdshader")

	terrain_material = ShaderMaterial.new()
	terrain_material.shader = shader
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = terrain_seed
	noise.frequency = freq
	noise.fractal_octaves = octaves
	noise.fractal_gain = persistence
	noise.fractal_lacunarity = lacunarity

func _ready() -> void:
	lod_lookup()
	init_required_chunks()
	var player_chunk := get_chunk_from_position(player.global_position)
	last_chunk = player_chunk
	if is_inside_tree():
		update_terrain(get_chunk_from_position(player.global_position))
	else:
		update_terrain(Vector2i(0, 0))


#region player position
func get_chunk_from_position(player_position: Vector3) -> Vector2i:
	return Vector2i(
		floori(player_position.x / chunk_size),
		floori(player_position.z / chunk_size)
	)

var last_chunk: Vector2i = Vector2i(0, 0)
func _process(_delta: float) -> void:
	var current_chunk: Vector2i = get_chunk_from_position(player.global_position)

	if current_chunk != last_chunk:
		update_terrain(current_chunk)
		last_chunk = current_chunk
#endregion


#region noise
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

func generate_heightmap(chunk_pos: Vector2i, lod: float) -> Image:
	var resolution := int(chunk_size * lod + 1)

	var image := Image.create(
		resolution,
		resolution,
		false,
		Image.FORMAT_RF
	)

	for x in range(resolution):
		for z in range(resolution):
			var u := float(x) / float(resolution - 1)
			var v := float(z) / float(resolution - 1)

			var world_x: float = chunk_pos.x * chunk_size + u * chunk_size
			var world_z: float = chunk_pos.y * chunk_size + v * chunk_size

			var height := noise.get_noise_2d(world_x, world_z) * strength
			image.set_pixel(x, z, Color(height, 0.0, 0.0, 1.0))

	return image


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
func generate_chunk_mesh(resolution, chunk_pos: Vector2i, texture: ImageTexture) -> MeshInstance3D:
	var lod = lods[resolution]
	var terrain := MeshInstance3D.new()
	var global_pos: Vector3

	terrain.mesh = lod.mesh
	terrain.name = "chunk_%d_%d" % [chunk_pos.x, chunk_pos.y]
	
	var material := terrain_material.duplicate()
	material.set_shader_parameter("heightmap", texture)
	terrain.material_override = material
	
	add_child(terrain)
	
	global_pos.x = chunk_pos.x * chunk_size
	global_pos.z = chunk_pos.y * chunk_size

	terrain.position = global_pos
	
	return terrain

func add_loaded_chunk(lod: int, pos: Vector2i) -> void:
	var lod_level: float = lods[lod].level

	var heightmap := generate_heightmap(pos, lod_level)
	var texture := ImageTexture.create_from_image(heightmap)

	var mesh_node := generate_chunk_mesh(lod, pos, texture)

	var static_body := StaticBody3D.new()
	mesh_node.add_child(static_body)

	var collision_shape := CollisionShape3D.new()
	var heightmap_shape := HeightMapShape3D.new()

	var res := heightmap.get_width()
	heightmap_shape.map_width = res
	heightmap_shape.map_depth = res

	var raw_data := heightmap.get_data()
	var float_array := raw_data.to_float32_array()
	heightmap_shape.map_data = float_array

	collision_shape.shape = heightmap_shape
	var scale_factor = float(chunk_size) / float(res - 1)
	collision_shape.scale = Vector3(scale_factor, 1.0, scale_factor)

	static_body.add_child(collision_shape)

	loaded_chunks[pos] = {
		"node": mesh_node,
		"lod": lod,
		"heightmap": heightmap,
		"texture": texture
	}

#endregion


#region update terrain
func update_terrain(player_pos: Vector2i) -> void:
	for chunk in loaded_chunks.keys():
		var relative: Vector2i = chunk - player_pos

		if not required_relative_chunks.has(relative):
			var old_node: MeshInstance3D = loaded_chunks[chunk]["node"]

			remove_child(old_node)
			old_node.free()

			loaded_chunks.erase(chunk)
			continue

		var required_lod: int = required_relative_chunks[relative]

		if loaded_chunks[chunk]["lod"] != required_lod:
			var old_node: MeshInstance3D = loaded_chunks[chunk]["node"]

			remove_child(old_node)
			old_node.free()

			loaded_chunks.erase(chunk)
			add_loaded_chunk(required_lod, chunk)

	for relative_chunk in required_relative_chunks:
		var chunk := relative_chunk + player_pos
		if not loaded_chunks.has(chunk):
			add_loaded_chunk(required_relative_chunks[relative_chunk], chunk)
#endregion
