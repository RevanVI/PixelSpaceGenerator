shader_type canvas_item;
render_mode blend_mix, unshaded;

#include "res://shaders/shader_helpers.gdshaderinc"
#include "res://shaders/planet_helpers.gdshaderinc"


uniform float seed = 123.0;
uniform float pixels = 200.0;
uniform bool use_defined_colors = true;
uniform sampler2D defined_colors;
uniform sampler2D palette;
uniform float brightness_mod: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform vec3 angles = vec3(0.0, 0.0, 0.0);

uniform sampler3D noise3d;
uniform sampler3D noise3d2;

uniform float radius: hint_range(0.2, 0.5) = 0.5;


vec3 get_color(vec2 coords) {
	vec3 color = vec3(0.0);
	if (use_defined_colors) {
		color = texture(defined_colors, coords).rgb;
	}
	else {
		color = texture(palette, coords).rgb;
	}
	return color;
}


void fragment() {
	// pixelzing
	vec2 uv = floor(UV * pixels) / pixels;

	// distance from center
	float d_to_center = distance(uv, vec2(0.5));

	COLOR = vec4(get_color(vec2(0.0)), 0.0);
	if (d_to_center <= radius) {
		vec3 sphere = sphere_coord(uv, radius, angles);

		float noise_val = texture(noise3d, sphere).r;
		float noise_val_2 = texture(noise3d2, sphere).r;
		noise_val *= noise_val_2 * 1.5;

		// apply dithering
		bool dith = dither_grid(UV, pixels);
		if (dith) {
			noise_val *= 0.95;
		}

		float final_brightness = brightness * brightness_mod;
		noise_val = pow(noise_val, 1.0 / final_brightness) * final_brightness;
		float col_val = floor(noise_val * 14.0) / 7.0;
		vec3 col = get_color(vec2(col_val, 0.0));
		COLOR = vec4(col, 1.0);
	}
	if (d_to_center > radius) {
		float atm_radius = radius * 1.1;
		int bands = 4;
		vec4 atm = vec4(vec3(0.0), 0.0);
		vec3 base_color = get_color(vec2(1.0, 0.0));
		float final_brightness = brightness * brightness_mod;
		base_color.r = pow(base_color.r, 1.0 / final_brightness) * final_brightness;
		base_color.g = pow(base_color.g, 1.0 / final_brightness) * final_brightness;
		base_color.b = pow(base_color.b, 1.0 / final_brightness) * final_brightness;

		for (int i = bands; i >= 1; --i) {
			float rad = radius + (atm_radius - radius) /
						float(bands) * float(i);
			if (d_to_center < rad) {
				atm = vec4(base_color / float(i), 1.0);
			}
		}

		COLOR += atm;
	}
}