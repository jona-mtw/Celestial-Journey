shader_type spatial;

uniform sampler2D heightmap : filter_nearest, repeat_disable;

void vertex() {
    ivec2 size = textureSize(heightmap, 0);
    
    int x = int(clamp(UV.x * float(size.x - 1) + 0.5, 0.0, float(size.x - 1)));
    int z = int(clamp(UV.y * float(size.y - 1) + 0.5, 0.0, float(size.y - 1)));

    float height = texelFetch(heightmap, ivec2(x, z), 0).r;
    VERTEX.y += height;
}
