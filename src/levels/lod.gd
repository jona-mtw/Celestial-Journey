extends Node3D
class_name TerrainLOD

var mesh: ArrayMesh

func _init(lod_level: float = 1, chunk_size: int = 16) -> void:
    var vert_num := int(chunk_size * lod_level + 1)
    mesh = generate_mesh(lod_level, vert_num)

func generate_mesh(lod_level: float, vert_num: int) -> ArrayMesh:
    var vertices := PackedVector3Array()
    vertices.resize(vert_num * vert_num)

    var indices := PackedInt32Array()
    indices.resize((vert_num - 1) * (vert_num - 1) * 6)

    var vertex_i := 0
    var index_i := 0

	# vertices
    for x in vert_num:
        for z in vert_num:
            vertices[vertex_i] = Vector3(
                x / lod_level,
                0.0,
                z / lod_level
            )
            vertex_i += 1

	# indices
    for x in range(vert_num - 1):
        for z in range(vert_num - 1):
            var i := x * vert_num + z

            indices[index_i] = i + vert_num
            indices[index_i + 1] = i + 1
            indices[index_i + 2] = i

            indices[index_i + 3] = i + 1
            indices[index_i + 4] = i + vert_num
            indices[index_i + 5] = i + vert_num + 1

            index_i += 6

    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)

    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices

    var array_mesh := ArrayMesh.new()
    array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

    return array_mesh