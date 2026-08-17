@tool
extends Node3D

@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 5:
	set(value):
		render_distance = value
		#generate_terrain()
@export_color_no_alpha var colour := Color(0.5, 0.5, 0.5)


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
var collision_chunk_size = 3
var loaded_chunks: PackedVector2Array


# noise func

func get_noise(vert: Vector3) -> float:
	noise.seed = terrain_seed
	noise.frequency = freq
	noise.fractal_octaves = octaves
	noise.fractal_gain = gain
	noise.fractal_lacunarity = lacunarity

	var height = noise.get_noise_2d(vert.x, vert.z) * strength
	return height


# mesh array funcs

func generate_verts(chunk_pos: Vector2i) -> Array:
	var vertices := PackedVector3Array()
	var vert := Vector3(0, 0, 0)

	var x_offset = floor(chunk_pos.x * chunk_size)
	var z_offset = floor(chunk_pos.y * chunk_size)

	for x in chunk_size + 1:
		vert.x = x + x_offset
		for z in chunk_size + 1:
			vert.z = z + z_offset
			vert.y = get_noise(vert)
			vertices.push_back(vert)

	return vertices

func generate_normals(vertices: PackedVector3Array) -> PackedVector3Array:
	var normals := PackedVector3Array()
	normals.resize(vertices.size())

	var width := int(sqrt(vertices.size()))

	var origin_x := vertices[0].x
	var origin_z := vertices[0].z

	for vertex_index in vertices.size():
		var local_x := vertex_index / width
		var local_z := vertex_index % width

		for cell_x in range(local_x - 1, local_x + 1):
			for cell_z in range(local_z - 1, local_z + 1):
				var world_x := origin_x + cell_x
				var world_z := origin_z + cell_z

				# Cell vertices:
				# A = (x, z)
				# B = (x+1, z)
				# C = (x, z+1)
				# D = (x+1, z+1)

				var A := Vector3(world_x, 0, world_z)
				A.y = get_noise(A)

				var B := Vector3(world_x + 1, 0, world_z)
				B.y = get_noise(B)

				var C := Vector3(world_x, 0, world_z + 1)
				C.y = get_noise(C)

				var D := Vector3(world_x + 1, 0, world_z + 1)
				D.y = get_noise(D)

				
				# triangle 1 - b, c, a

				if (local_x == cell_x + 1 and local_z == cell_z) \
				or (local_x == cell_x and local_z == cell_z + 1) \
				or (local_x == cell_x and local_z == cell_z):
					var vertex_A := B
					var vertex_B := C
					var vertex_C := A

					var vector_BA := vertex_B - vertex_A
					var vector_CA := vertex_C - vertex_A

					var face_normal := vector_CA.cross(vector_BA)

					normals[vertex_index] += face_normal


				# triangle 2 - c, b, d

				if (local_x == cell_x and local_z == cell_z + 1) \
				or (local_x == cell_x + 1 and local_z == cell_z) \
				or (local_x == cell_x + 1 and local_z == cell_z + 1):
					var vertex_A := C
					var vertex_B := B
					var vertex_C := D

					var vector_BA := vertex_B - vertex_A
					var vector_CA := vertex_C - vertex_A

					var face_normal := vector_CA.cross(vector_BA)

					normals[vertex_index] += face_normal

	for i in normals.size():
		normals[i] = normals[i].normalized()

	return normals

func generate_indices(length: int) -> Array:
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

func generate_colours(length: int) -> PackedColorArray:
	var colours := PackedColorArray()
	for vert in length:
		colours.append(colour)

	return colours

# generating terrain

func generate_chunk(chunk_pos: Vector2i) -> void:
	var arrays := []
	var vertices: PackedVector3Array = generate_verts(chunk_pos)
	var normals: PackedVector3Array = generate_normals(vertices)
	var indices: PackedInt32Array = generate_indices(vertices.size())
	# var colours: PackedColorArray = generate_colours(vertices.size())

	arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	# arrays[Mesh.ARRAY_COLOR] = colours

	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var terrain := MeshInstance3D.new()
	terrain.mesh = arr_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	terrain.material_override = material

	terrain.name = "chunk_pos_%s_%s" % [chunk_pos.x, chunk_pos.y]

	add_child(terrain)

func generate_terrain(player_position: Vector2i, init: bool = false) -> void:
	var chunk: Vector2i
	for chunk_x in range(player_position.x - render_distance, player_position.x + render_distance + 1):
		chunk.x = chunk_x
		for chunk_y in range(player_position.y - render_distance, player_position.y + render_distance + 1):
			chunk.y = chunk_y
			if loaded_chunks.has(chunk):
				continue
			generate_chunk(chunk)

			loaded_chunks.append(chunk)

			if init:
				continue
			else:
				await get_tree().process_frame

func generate_collisions(player_position: Vector2i) -> void:
	var collision_chunks: PackedVector2Array
	var collision_chunk: Vector2i
	for chunk_x in range(player_position.x - collision_chunk_size, player_position.x + collision_chunk_size + 1, 1):
		for chunk_y in range(player_position.y - collision_chunk_size, player_position.y + collision_chunk_size + 1, 1):
			collision_chunk = Vector2i(chunk_x, chunk_y)
			collision_chunks.push_back(collision_chunk)

	for chunk in collision_chunks:
		var terrain: MeshInstance3D = get_node("chunk_pos_%s_%s" % [int(chunk.x), int(chunk.y)])
		terrain.create_trimesh_collision()


# unloading terrain

func unload_terrain(player_position: Vector2i) -> void:
	var chunk: Vector2i
	for child in get_children():
		var child_name_array = child.name.split("_")
		if len(child_name_array) < 2:
			chunk.x = int(child_name_array[2])
			chunk.y = int(child_name_array[3])

			if abs(player_position.x - chunk.x) > render_distance or abs(player_position.y - chunk.y) > render_distance:
				child.queue_free()
				loaded_chunks.erase(chunk)
	
func unload_collisions(player_position: Vector2i) -> void:
	var chunk: Vector2i
	for child in get_children():
		if child.get_child_count() == 0:
			continue
		else:
			var child_name_array = child.name.split("_")
			chunk.x = int(child_name_array[2])
			chunk.y = int(child_name_array[3])

			if abs(player_position.x - chunk.x) > collision_chunk_size or abs(player_position.y - chunk.y) > collision_chunk_size:
				for childs_child in child.get_children():
					childs_child.queue_free()


# collector funcs

func update_terrain(player_position: Vector2i) -> void:
	generate_collisions(player_position)
	generate_terrain(player_position)
	unload_collisions(player_position)
	unload_terrain(player_position)

func init_terrain(player_position: Vector2i) -> void:
	generate_terrain(player_position, true)
	generate_collisions(player_position)


# caller func
func _on_player_moved(player_position: Vector2i) -> void:
	print(player_position)
	update_terrain(player_position)

func _ready() -> void:
	EventListener.player_chunk_changed.connect(_on_player_moved)
	init_terrain(Vector2i(0, 0))
