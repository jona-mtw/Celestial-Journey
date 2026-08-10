@tool
extends Node3D

@export var size: int = 3:
    set(value):
        size = value
        generate_terrain()

func generate_verts() -> Array:
    var vertices := PackedVector3Array()
    var vert := Vector3(0, 0, 0)
    for x in size:
        vert.x = x
        for z in size:
            vert.z = z
            vertices.push_back(vert)
    return vertices

func generate_indices() -> Array:
    var indices := PackedInt32Array()

    for index in size * size:
        # if (index + 1) % size == 0:
        #     continue
        # elif index >= size * size - size:
        #     break
        var triangle1 := [
            index, # point 1
            index + 1, # point 2
            index + size # point 3
        ]
        indices.append_array(triangle1)

        var triangle2 := [
            index + 1, # point 1
            index + size, # point 2
            index + size + 1 # point 3
        ]
        indices.append_array(triangle2)

    return indices

func generate_terrain() -> void:
    var vertices: PackedVector3Array = generate_verts()
    var indices: PackedInt32Array = generate_indices()

    var arrays := []
    arrays.resize(Mesh.ARRAY_MAX)

    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices

    var arr_mesh := ArrayMesh.new()
    arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

    var terrain := MeshInstance3D.new()
    terrain.mesh = arr_mesh

    add_child(terrain)

func _ready() -> void:
    generate_terrain()