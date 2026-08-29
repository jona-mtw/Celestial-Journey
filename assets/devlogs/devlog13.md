# Devlog 13 - LOD template

I basically deleted all the old code, and started over, by making a function where the noise will be given to the vertex shader, and one that will generate the actual flat mesh for it (which is going to be changed by the vertex shader).

I made the template for making flat planes with different levels of detail (LOD), which will be changed by the vertex shaders, applying the noise to the mesh.

I created a new script called `lod.gd` and gave it a class name, so that I can call multiple instances of it in the main terrain generation program. Every time the program wants to make another chunk, I have to pass the arguements:
- `resolution` - what ive defined as a synoymn of LOD
- `chunk_pos` - where the chunk is

The function then loads an `ArrayMesh` from a pre-generated list of possible meshes and creates a new `MeshInstance3D` node to display it.


## Extra stuff

I also added player coords and chunk position in the debug_screen :)