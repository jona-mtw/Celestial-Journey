@tool
extends Node3D

@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 10:
	set(value):
		render_distance = value
		#generate_terrain()

@export_category("Terrain Settings")
@export var terrain_seed := randi():
	set(value):
		terrain_seed = value
		#generate_terrain()
@export var freq := 0.01:
	set(value):
		freq = value
		#generate_terrain()
@export_range(1, 8, 1) var octaves := 5:
	set(value):
		octaves = value
		#generate_terrain()
@export var gain := 0.5:
	set(value):
		gain = value
		#generate_terrain()
@export var lacunarity := 2.0:
	set(value):
		lacunarity = value
		#generate_terrain()
@export var strength := 5:
	set(value):
		strength = value
		#generate_terrain()

var noise = FastNoiseLite.new()
var chunk_size = 16
var collision_chunk_size = 1

func generate_verts(chunk_pos: Vector2i) -> Array:
	noise.seed = terrain_seed
	noise.frequency = freq
	noise.fractal_octaves = octaves
	noise.fractal_gain = gain
	noise.fractal_lacunarity = lacunarity
	
	var vertices := PackedVector3Array()
	var vert := Vector3(0, 0, 0)

	var x_offset = chunk_pos.x * chunk_size
	var z_offset = chunk_pos.y * chunk_size

	for x in chunk_size + 1:
		vert.x = x + x_offset
		for z in chunk_size + 1:
			vert.z = z + z_offset
			vert.y = noise.get_noise_2d(vert.x, vert.z) * strength
			vertices.push_back(vert)

	return vertices

func calculate_normals(vertices, indices) -> Array:
	var normals := PackedVector3Array()
	normals.resize(vertices.size())

	for index in range(0, indices.size(), 3):
		var index_a = indices[index]
		var index_b = indices[index + 1]
		var index_c = indices[index + 2]

		var vertex_A = vertices[index_a]
		var vertex_B = vertices[index_b]
		var vertex_C = vertices[index_c]

		var vector_BA = vertex_B - vertex_A
		var vector_CA = vertex_C - vertex_A

		var face_normal = vector_CA.cross(vector_BA)

		normals[index_a] += face_normal
		normals[index_b] += face_normal
		normals[index_c] += face_normal

	for i in normals.size():
		normals[i] = normals[i].normalized()

	return normals

func generate_indices(length) -> Array:
	var indices := PackedInt32Array()

	for index in length:
		if fmod(index + 1, sqrt(length)) == 0:
			continue
		elif index >= length - sqrt(length):
			break
			
		var triangle1 := [
			index + sqrt(length), # point 1
			index + 1, # point 2
			index # point 3
		]
		indices.append_array(triangle1)

		var triangle2 := [
			index + 1, # point 1
			index + sqrt(length), # point 2
			index + sqrt(length) + 1 # point 3
		]
		indices.append_array(triangle2)

	return indices

func generate_chunk(chunk_pos: Vector2i, collision: bool) -> void:
	for child in get_children():
		if child.name.contains("chunk_pos_%s_%s" % [chunk_pos.x, chunk_pos.y]):
			child.free()

	var arrays := []
	var vertices: PackedVector3Array = generate_verts(chunk_pos)
	var indices: PackedInt32Array = generate_indices(vertices.size())
	var normals: PackedVector3Array = calculate_normals(vertices, indices)

	arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices

	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var terrain := MeshInstance3D.new()
	terrain.mesh = arr_mesh
	terrain.name = "chunk_pos_%s_%s" % [chunk_pos.x, chunk_pos.y]

	add_child(terrain)

	if collision:
		terrain.create_trimesh_collision()

func generate_terrain(player_coord: Vector2i) -> void:
	var chunk: Vector2i
	var collision: bool
	for chunk_x in range(player_coord.x - render_distance, player_coord.x + render_distance + 1):
		chunk.x = chunk_x
		for chunk_y in range(player_coord.y - render_distance, player_coord.y + render_distance + 1):
			chunk.y = chunk_y
			if (abs(player_coord.x - chunk.x) > collision_chunk_size and abs(player_coord.y - chunk.y) > collision_chunk_size):
				collision = false
			else:
				collision = true
			print(chunk_x, chunk_y)
			generate_chunk(chunk, collision)

			await get_tree().process_frame

func _on_player_moved(player_position: Vector2i) -> void:
	generate_terrain(player_position)

func _ready() -> void:
	generate_terrain(Vector2i(0, 0))
	EventListener.player_chunk_changed.connect(_on_player_moved)
