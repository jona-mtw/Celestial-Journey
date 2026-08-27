shader_type spatial;

float hash(vec2 p, int seed) {
	int last_two_digits = seed % 100;
	int remaining_digits = seed / 100;

	float hash_value = dot(p.yx * float(remaining_digits + seed), p * (float(last_two_digits) + 43758.5453));
	hash_value = sin(hash_value);
	hash_value *= 79.82977;0;
	return fract(hash_value);
}

float perlin_noise(vec2 position, int seed) {
	float height;

	// get corner positions and vectors
	vec2 a = floor(position);
	vec2 b = a + vec2(1.0, 0.0);
	vec2 c = a + vec2(1.0, 1.0);
	vec2 d = a + vec2(0.0, 1.0);

	float angle_a = hash(a, seed) * TAU;
	float angle_b = hash(b, seed) * TAU;
	float angle_c = hash(c, seed) * TAU;
	float angle_d = hash(d, seed) * TAU;

	vec2 A = vec2(cos(angle_a), sin(angle_a));
	vec2 B = vec2(cos(angle_b), sin(angle_b));
	vec2 C = vec2(cos(angle_c), sin(angle_c));
	vec2 D = vec2(cos(angle_d), sin(angle_d));

	

	return height;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
