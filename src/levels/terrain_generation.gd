@tool
extends Node3D

@export_category("Terrain Settings")
@export_range(2, 265, 1) var size := 10:
	set(value):
		size = value
		generate_terrain()
@export var terrain_seed := randi():
	set(value):
		terrain_seed = value
		generate_terrain()
@export var freq := 0.01:
	set(value):
		freq = value
		generate_terrain()
@export_range(1, 8, 1) var fractal_octaves := 5:
	set(value):
		fractal_octaves = value
		generate_terrain()
@export var fractal_gain := 0.5:
	set(value):
		fractal_gain = value
		generate_terrain()
@export var fractal_lacunarity := 2.0:
	set(value):
		fractal_lacunarity = value
		generate_terrain()
@export var strength := 5:
	set(value):
		strength = value
		generate_terrain()

var noise = FastNoiseLite.new()

func _ready() -> void:
	generate_terrain()

func generate_verts() -> Array:
	noise.seed = terrain_seed
	noise.frequency = freq
    
	var vertices := PackedVector3Array()
	var vert := Vector3(0, 0, 0)

	for x in size + 1:
		vert.x = float(x) / size * size
		for z in size + 1:
			vert.y = noise.get_noise_2d(x, z) * strength
			vert.z = float(z) / size * size
			vertices.push_back(vert)

	return vertices

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

func generate_terrain() -> void:
	for child in get_children():
		if child.name.begins_with("GeneratedTerrain"):
			child.free()

	var vertices: PackedVector3Array = generate_verts()
	var indices: PackedInt32Array = generate_indices(len(vertices))

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var terrain := MeshInstance3D.new()
	terrain.mesh = arr_mesh
	terrain.name = "GeneratedTerrain"

	add_child(terrain)
	terrain.create_trimesh_collision()
