extends Node3D
class_name TerrainLOD

var mesh: ArrayMesh

func _init(lod_level: float = 1, chunk_size: int = 16) -> void:
	var vert_num = int(chunk_size * lod_level + 1)
	mesh = generate_mesh(lod_level, vert_num)

func generate_verts(lod_level: float, vert_num: int) -> PackedVector3Array:
	var verts := PackedVector3Array()

	for x in vert_num:
		for z in vert_num:
			var vert: Vector3 = Vector3(x / lod_level, 0.0, z / lod_level)
			verts.push_back(vert)

	return verts

func generate_indices(vert_num: int) -> PackedInt32Array:
	var indices := PackedInt32Array()

	for x in range(vert_num - 1):
		for z in range(vert_num - 1):
			var i := x * vert_num + z

			indices.append_array([
				i + vert_num,
				i + 1,
				i
			])

			indices.append_array([
				i + 1,
				i + vert_num,
				i + vert_num + 1
			])

	return indices

func generate_mesh(lod_level: float, vert_num: int) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	var vertices := generate_verts(lod_level, vert_num)
	var indices := generate_indices(vert_num)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return array_mesh
