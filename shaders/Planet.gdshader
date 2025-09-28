shader_type canvas_item;
render_mode blend_mix, unshaded;

#include "shader_helpers.gdshaderinc"

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform float pixels = 100.0;
uniform sampler2D colorscheme;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform vec2 light_origin;


vec2 spherify(vec2 uv) {
	vec2 centered = uv * 2.0 - 1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	z = clamp(z, 0.0, 1.0);
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}


void fragment() {
	// pixelzing
	vec2 uv = floor(UV * pixels) / pixels;

	// distance from center, to create a circle
	float d_to_center = distance(uv, vec2(0.5));

	uv = spherify(uv);
	// distance from light source, to create shading
	float d_to_light = distance(uv, light_origin);
	// bit of contrast
	d_to_light += pow(d_to_center * 3.0, 4.0) * 0.02;

	// noise for the planet
	float n = fbm(uv * size, OCTAVES, seed);
	float n2 = fbm(uv * size + n*3.0, OCTAVES, seed);
	float mixed = n2 * d_to_light;

	// apply dithering
	bool dith = dither_grid(UV, pixels);
	if (dith) {
		mixed *= 0.95;
	}

	// choose and apply colors
	mixed = pow(mixed, 1.0 / brightness) * brightness;
	float col_val = floor(mixed * 14.0) / 7.0;
	vec3 col = texture(colorscheme, vec2(col_val, 0.0)).rgb;

	// apply alpha
	float a = step(d_to_center, 0.5);
	COLOR = vec4(col, a);
}