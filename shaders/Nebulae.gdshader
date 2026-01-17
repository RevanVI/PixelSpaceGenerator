shader_type canvas_item;
render_mode blend_mix,unshaded;

#include "shader_helpers.gdshaderinc"
#include "dither.gdshaderinc"


uniform float pixels = 100.0;
uniform int pixel_scale: hint_range(1, 32, 1) = 4;
uniform vec2 uv_correct = vec2(1.0);

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);

uniform sampler2D palette: filter_nearest;
uniform vec4 background_color : source_color;

uniform float brightness_mod: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform float global_brightness: hint_range(0.5, 2.0, 0.01) = 1.0;

uniform bool dither_enabled = false;

const int BAYER_LEVEL = 2;
const float DITHER_COLOR_COUNT = 8.0;


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
	// pixelizing - two ways of doing this
	// split this texture in whole pixels
	float corrected_pixel_scale = floor(pixels / float(pixel_scale));
	// split this texture by pixel size
	//corrected_pixel_scale = pixels / float(pixel_scale);
	vec2 pix_id = floor(UV * uv_correct * corrected_pixel_scale);
	vec2 uv = pix_id / uv_correct / corrected_pixel_scale;
	
	// distance from center
	float d =  distance(uv, vec2(0.5) * uv_correct) * 0.45;

	// noise for the inside of the nebulae
	float n = cloud_alpha(uv * size);
	float n2 = fbm(uv * size + vec2(1, 1), OCTAVES, seed);
	float n_dust_lerp = n2 * n;

	float final_brightness = brightness_mod * global_brightness;
	n_dust_lerp = pow(n_dust_lerp, 1.0 / final_brightness) * final_brightness;
	
	if (dither_enabled) {
		n_dust_lerp = dither_float(n_dust_lerp, DITHER_COLOR_COUNT, pix_id, 0.0, BAYER_LEVEL);
	}
	
	// slightly offset alpha values to create thin bands around the nebulae
	float a = step(n2, 0.1 + d);
	float a2 = step(n2, 0.115 + d);

	// choose colors
	float col_value = 0.0;
	if (a2 > a) {
		col_value = floor(n_dust_lerp * 24.0) / 8.0;
	} else {
		col_value = floor(n_dust_lerp * 8.0) / 8.0;
	}

	// apply colors
	vec3 col = texture(palette, vec2(col_value, 0.0)).rgb;
	COLOR = vec4(col, a2);
}