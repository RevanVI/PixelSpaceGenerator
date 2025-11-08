shader_type canvas_item;
render_mode blend_mix;

#include "shader_helpers.gdshaderinc"

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform float pixels = 200.0;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform sampler2D palette;
uniform vec2 uv_correct = vec2(1.0);


float cloud_alpha(vec2 uv) {
	float c_noise = 0.0;

	// more iterations for more turbulence
	int iters = 2;
	for (int i = 0; i < iters; i++) {
		c_noise += circleNoise(uv * 0.6 + (float(i+1)) + vec2(-0.3, -0.1), seed);
	}
	float fbm = fbm(uv+c_noise, OCTAVES, seed);

	return fbm;
}


void fragment() {
	// pixelizing
	vec2 uv = floor(UV * pixels) / pixels * uv_correct;

	// noise for the dust
	float n_dust = cloud_alpha(uv * size);
	float n_dust2 = fbm(uv * ceil(size * 0.2) - vec2(2,2), OCTAVES, seed);
	float n_dust_lerp = n_dust2 * n_dust;

	// apply dithering
	bool dith = dither_grid(UV, pixels);
	if (dith) {
		n_dust_lerp *= 0.95;
	}

	// choose alpha value
	float n_alpha = fbm(uv * ceil(size * 0.5) + vec2(2,2), OCTAVES, seed);
	float a_dust = step(n_alpha, n_dust_lerp * 1.8);

	// choose & apply colors
	n_dust_lerp = pow(n_dust_lerp, 3.2) * 56.0;
	n_dust_lerp = pow(n_dust_lerp, brightness) * brightness;

	float col_value = floor(n_dust_lerp) / 7.0;
	vec3 col = texture(palette, vec2(col_value, 0.0)).rgb;
	COLOR = vec4(col, a_dust);
}