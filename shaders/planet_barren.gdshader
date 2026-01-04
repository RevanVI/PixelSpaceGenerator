shader_type canvas_item;
render_mode blend_mix, unshaded;

#include "res://shaders/shader_helpers.gdshaderinc"
#include "res://shaders/planet_helpers.gdshaderinc"


uniform float seed = 123.0;
uniform float pixels = 200.0;
uniform float radius: hint_range(0.2, 0.5) = 0.5;
uniform vec3 angles = vec3(0.0, 0.0, 0.0);

uniform bool use_defined_colors = true;
uniform sampler2D defined_colors_1;
uniform sampler2D defined_colors_2;
uniform sampler2D colors_1;
uniform sampler2D colors_2;

uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform sampler3D noise3d;
uniform sampler3D noise3d2;
uniform bool clouds = false;

group_uniforms Light;
uniform bool light_enabled = true;
uniform vec3 light_dir = vec3(1.0, -0.5, 0.3);
uniform float light_strenght: hint_range(0.0, 4.0, 0.05) = 3.0;
uniform float light_noise_strenght = 0.15;
group_uniforms;


vec3[2] get_color(vec2 coords) {
	vec3 colors[2] = vec3[2](vec3(0.0), vec3(0.0));
	if (use_defined_colors) {
		colors[0] = texture(defined_colors_1, coords).rgb;
		colors[1] = texture(defined_colors_2, coords).rgb;
	}
	else {
		colors[0] = texture(colors_1, coords).rgb;
		colors[1] = texture(colors_2, coords).rgb;
	}
	return colors;
}


void fragment() {
	vec2 uv = floor(UV * pixels) / pixels;

	float d_to_center = distance(uv, vec2(0.5));

	COLOR = vec4(get_color(vec2(0.0))[0], 0.0);
	if (d_to_center <= radius) {
		vec3 sphere = sphere_coord(uv, radius, angles);

		// base planet surface
		float noise_val = texture(noise3d, sphere).r * 0.4;

		// craters
		float noise_val_2 = texture(noise3d2, sphere).r;
		noise_val_2 = step(0.45, noise_val_2) * noise_val_2;
		noise_val += noise_val_2 * 0.1;

		// emulate edge of craters
		// slightly offset texture sample
		sphere = (sphere * 2.0 - 1.0) + normalize(light_dir) * 0.02;
		float noise_val_3 = texture(noise3d2, sphere * 0.5 + 0.5).r;
		noise_val_3 = step(0.45, noise_val_3);
		// calculate edge and subtract it from global color
		float edge = clamp(noise_val_2 - noise_val_3, 0.0, 1.0) * 0.2;
		//vec3 col = vec3(edge);
		noise_val = noise_val - edge;

		//calculate light
		float light = 1.0;
		if (light_enabled) {
			//calc new sphere point without rotation
			//so lighting is consistent regardless of planet rotation
			sphere = sphere_coord(uv, radius, vec3(0.0));
			light = dot(normalize(sphere * 2.0 - 1.0),
							normalize(light_dir));
			//smooth straight light steps with noise
			//landscape noise looks good enough
			//but could use anything really
			//clamp it so there is no negative values
			light = clamp(light + (noise_val - 0.45) * light_noise_strenght,
							0.0, 1.0);
			light *= light_strenght;
		}

		// apply dithering
		bool dith = dither_grid(UV, pixels);
		if (dith) {
			light *= 0.9;
			noise_val *= 0.95;
		}

		noise_val *= light;
		noise_val = pow(noise_val, 1.0 / brightness) * brightness;
		float col_val = floor(noise_val * 14.0) / 7.0;
		vec3 colors[2] = get_color(vec2(col_val, 0.0));
		vec3 col = colors[0];
		if (step(0.45, noise_val_2) > 0.0) {
			col = colors[1];
		}
		COLOR = vec4(col, 1.0);
	}
}