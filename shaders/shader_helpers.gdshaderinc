//simple rand from -1 to 1
float rand(vec2 coord, float seed) {
	coord = mod(coord, 10000.0); //TODO: to avoid artifacts in noise, research later
	float res = fract(sin(dot(coord.xy, vec2(12.9898, 78.233))) *
					(43758.5453123 + seed));
	return res;
}


//simple value noise
float noise(vec2 coord, float seed) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	float a = rand(i, seed);
	float b = rand(i + vec2(1.0, 0.0), seed);
	float c = rand(i + vec2(0.0, 1.0), seed);
	float d = rand(i + vec2(1.0, 1.0), seed);

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) +
            (c - a) * cubic.y * (1.0 - cubic.x) +
            (d - b) * cubic.x * cubic.y;
}


float fbm(vec2 coord, int octaves, float seed) {
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < octaves ; i++) {
		value += noise(coord, seed) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}


float circleNoise(vec2 uv, float seed) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)), seed);
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}


//simple dither checker
bool dither_grid(vec2 uv, float grid_pixel_size) {
	//calculate x coordinate offset for each row to create checker pattern
	float offset = floor(uv.y * grid_pixel_size) / grid_pixel_size;
	return mod(offset + uv.x,2.0/grid_pixel_size) <= 1.0 / grid_pixel_size;
}


vec2 rotate(vec2 vec, float angle) {
	vec -= vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
}