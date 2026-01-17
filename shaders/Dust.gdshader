shader_type canvas_item;
render_mode blend_mix;

#include "shader_helpers.gdshaderinc"
#include "dither.gdshaderinc"

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform float pixels = 200.0;
uniform float brightness_mod: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform float global_brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform sampler2D palette;
uniform vec2 uv_correct = vec2(1.0);
uniform bool dither_enabled = false;

const int BAYER_LEVEL = 2;
const float DITHER_COLOR_COUNT = 8.0;


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
	vec2 pix_id = floor(UV * pixels * uv_correct);
	vec2 uv = pix_id / pixels / uv_correct;

	// noise for the dust
	float n_dust = cloud_alpha(uv * size);
	float n_dust2 = fbm(uv * ceil(size * 0.2) - vec2(2,2), OCTAVES, seed);
	float n_dust_lerp = n_dust2 * n_dust;

	// choose alpha value
	float noise_alpha = fbm(uv * ceil(size * 0.5) + vec2(2,2), OCTAVES, seed);
	float alpha = step(noise_alpha, n_dust_lerp * 1.85);

	// choose & apply colors
	n_dust_lerp = pow(n_dust_lerp, 3.2) * 8.0;
	float final_brightness = brightness_mod * global_brightness;
	n_dust_lerp = pow(n_dust_lerp, 1.0 / final_brightness) * final_brightness;
	
	if (dither_enabled) {
		n_dust_lerp = dither_float(n_dust_lerp, DITHER_COLOR_COUNT, pix_id, 0.0,  BAYER_LEVEL);
	}
	
	n_dust_lerp = floor(n_dust_lerp * 8.0) / 8.0;
	vec3 col = texture(palette, vec2(n_dust_lerp, 0.0)).rgb;

	COLOR = vec4(col, alpha);
}