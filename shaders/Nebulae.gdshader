shader_type canvas_item;
render_mode blend_mix,unshaded;

#include "shader_helpers.gdshaderinc"


uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform float pixels = 100.0;
uniform sampler2D palette;
uniform vec4 background_color : source_color;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform vec2 uv_correct = vec2(1.0);


float cloud_alpha(vec2 uv) {
	float c_noise = 0.0;

	// more iterations for more turbulence
	int iters = 2;
	for (int i = 0; i < iters; i++) {
		c_noise += circleNoise(uv * 0.5 + float(i+1) + vec2(-0.3, 0.0), seed);
	}
	float fbm = fbm(uv+c_noise, OCTAVES, seed);
	return fbm;
}

void fragment() {
	// pixelizing
	vec2 uv = floor(UV * pixels) / pixels * uv_correct;

	// distance from center
	float d =  distance(uv, vec2(0.5) * uv_correct) * 0.4;

	// noise for the inside of the nebulae
	float n = cloud_alpha(uv * size);
	float n2 = fbm(uv * size + vec2(1, 1), OCTAVES, seed);
	float n_dust_lerp = n2 * n * n;

	// apply dithering
	bool dith = dither_grid(UV, pixels);
	if (dith) {
		n_dust_lerp *= 0.95;
		d*= 0.98;
	}

	// slightly offset alpha values to create thin bands around the nebulae
	float a = step(n2, 0.1 + d);
	float a2 = step(n2, 0.115 + d);

	// choose colors
	n_dust_lerp = pow(n_dust_lerp, 1.0 / brightness) * brightness;
	float col_value = 0.0;
	if (a2 > a) {
		col_value = floor(n_dust_lerp * 40.0) / 7.0;
	} else {
		col_value = floor(n_dust_lerp * 18.0) / 7.0;
	}

	// apply colors
	vec3 col = texture(palette, vec2(col_value, 0.0)).rgb;
	if (col_value < 0.1) {
		col = background_color.rgb;
	}

	COLOR = vec4(col, a2);
}