@tool
extends Node3D

@export_category("Chunk Settings")
@export_range(2, 128, 1) var render_distance := 30
@export_color_no_alpha var colour := Color(0.5, 0.5, 0.5)

var terrain_seed := randi()
var freq := 0.01
var octaves := 5
var gain := 0.5
var lacunarity := 2.0
var strength := 10
var resolution := 2.0

var noise = FastNoiseLite.new()
var chunk_size = 16
var collision_chunk_size = 3
var loaded_chunks: PackedVector2Array
var debug_state := false

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

	for x in chunk_size * resolution + 1:
		vert.x = x / resolution + x_offset
		for z in chunk_size * resolution + 1:
			vert.z = z / resolution + z_offset
			vert.y = get_noise(vert)
			vertices.push_back(vert)

	return vertices

func generate_normals(vertices: PackedVector3Array) -> PackedVector3Array:
	var index_offset = 1
	var world_offset = 1 / resolution

	var normals := PackedVector3Array()
	normals.resize(vertices.size())

	var width := int(sqrt(vertices.size()))

	var origin_x := vertices[0].x
	var origin_z := vertices[0].z

	for vertex_index in vertices.size():
		var local_x := vertex_index / width
		var local_z := vertex_index % width

		for cell_x in range(local_x - index_offset, local_x + index_offset):
			for cell_z in range(local_z - index_offset, local_z + index_offset):
				var world_x: float = origin_x + cell_x * world_offset
				var world_z: float = origin_z + cell_z * world_offset

				# Cell vertices:
				# A = (x, z)
				# B = (x+1, z)
				# C = (x, z+1)
				# D = (x+1, z+1)

				var A := Vector3(world_x, 0, world_z)
				A.y = get_noise(A)

				var B := Vector3(world_x + world_offset, 0, world_z)
				B.y = get_noise(B)

				var C := Vector3(world_x, 0, world_z + world_offset)
				C.y = get_noise(C)

				var D := Vector3(world_x + world_offset, 0, world_z + world_offset)
				D.y = get_noise(D)

				
				# triangle 1 - b, c, a

				if (local_x == cell_x + index_offset and local_z == cell_z) \
				or (local_x == cell_x and local_z == cell_z + index_offset) \
				or (local_x == cell_x and local_z == cell_z):
					var vertex_A := B
					var vertex_B := C
					var vertex_C := A

					var vector_BA := vertex_B - vertex_A
					var vector_CA := vertex_C - vertex_A

					var face_normal := vector_CA.cross(vector_BA)

					normals[vertex_index] += face_normal


				# triangle 2 - c, b, d

				if (local_x == cell_x and local_z == cell_z + index_offset) \
				or (local_x == cell_x + index_offset and local_z == cell_z) \
				or (local_x == cell_x + index_offset and local_z == cell_z + index_offset):
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
			else:
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
		if terrain and terrain.get_child_count() == 0:
			terrain.create_trimesh_collision()


# unloading terrain

func unload_terrain(player_position: Vector2i) -> void:
	var chunk: Vector2i
	for child in get_children():
		var child_name_array = child.name.split("_")
		if len(child_name_array) > 2:
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
			if child_name_array.size() < 2:
				continue
			else:
				chunk.x = int(child_name_array[2])
				chunk.y = int(child_name_array[3])

			if abs(player_position.x - chunk.x) > collision_chunk_size or abs(player_position.y - chunk.y) > collision_chunk_size:
				for childs_child in child.get_children():
					childs_child.queue_free()


# debug

func debug_terrain(player_position: Vector2i) -> void:
	for chunk_x in range(player_position.x - render_distance, player_position.x + render_distance + 1):
		for chunk_y in range(player_position.y - render_distance, player_position.y + render_distance + 1):
			var chunk_pos := Vector2i(chunk_x, chunk_y)

			var border := ImmediateMesh.new()
			border.surface_begin(Mesh.PRIMITIVE_LINES)

			var x: float = chunk_pos.x * chunk_size
			var z: float = chunk_pos.y * chunk_size

			var y_bottom := -10.0
			var y_top := 20.0

			var a := Vector3(x, y_bottom, z)
			var b := Vector3(x + chunk_size, y_bottom, z)
			var c := Vector3(x + chunk_size, y_bottom, z + chunk_size)
			var d := Vector3(x, y_bottom, z + chunk_size)

			var A := Vector3(x, y_top, z)
			var B := Vector3(x + chunk_size, y_top, z)
			var C := Vector3(x + chunk_size, y_top, z + chunk_size)
			var D := Vector3(x, y_top, z + chunk_size)

			# Bottom
			border.surface_add_vertex(a)
			border.surface_add_vertex(b)
			border.surface_add_vertex(b)
			border.surface_add_vertex(c)
			border.surface_add_vertex(c)
			border.surface_add_vertex(d)
			border.surface_add_vertex(d)
			border.surface_add_vertex(a)

			# Top
			border.surface_add_vertex(A)
			border.surface_add_vertex(B)
			border.surface_add_vertex(B)
			border.surface_add_vertex(C)
			border.surface_add_vertex(C)
			border.surface_add_vertex(D)
			border.surface_add_vertex(D)
			border.surface_add_vertex(A)

			# Vertical corners
			border.surface_add_vertex(a)
			border.surface_add_vertex(A)
			border.surface_add_vertex(b)
			border.surface_add_vertex(B)
			border.surface_add_vertex(c)
			border.surface_add_vertex(C)
			border.surface_add_vertex(d)
			border.surface_add_vertex(D)

			border.surface_end()

			var chunk_border := MeshInstance3D.new()
			chunk_border.mesh = border
			chunk_border.name = "border_%s_%s_border_border" % [chunk_pos.x, chunk_pos.y]
			$ChunkBorders.add_child(chunk_border)


# collector funcs

func update_terrain(player_position: Vector2i) -> void:
	await generate_terrain(player_position)
	generate_collisions(player_position)
	unload_collisions(player_position)
	unload_terrain(player_position)
	if debug_state:
		debug_terrain(player_position)

func init_terrain(player_position: Vector2i) -> void:
	await generate_terrain(player_position, true)
	generate_collisions(player_position)

func debug(state) -> void:
	debug_state = state
	print(debug_state)
	var player_position = $"/root/MainGame/World/EntityRoot/Player".get_chunk_from_position($"/root/MainGame/World/EntityRoot/Player".position)
	update_terrain(player_position)

	if !state:
		var chunk_borders = $ChunkBorders.get_children()
		for chunk_border in chunk_borders:
			chunk_border.queue_free()


# caller func

func _on_player_moved(player_position: Vector2i) -> void:
	print(player_position)
	await update_terrain(player_position)

func _ready() -> void:
	EventListener.player_chunk_changed.connect(_on_player_moved)
	EventListener.debug.connect(debug)
	init_terrain(Vector2i(0, 0))
