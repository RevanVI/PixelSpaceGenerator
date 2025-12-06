shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"
#include "res://shaders/planet_helpers.gdshaderinc"

uniform float seed = 123.0;
uniform float pixels = 200.0;
uniform float radius: hint_range(0.2, 0.5) = 0.5;
uniform vec3 angles = vec3(0.0, 0.0, 0.0);

uniform sampler2D colors_1;
uniform sampler2D colors_2;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;

group_uniforms Light;
uniform bool light_enabled = true;
uniform vec3 light_dir = vec3(1.0, -0.5, 0.3);
uniform float light_strenght: hint_range(0.0, 4.0, 0.05) = 3.0;
uniform float light_noise_strenght = 0.15;
group_uniforms;


void fragment() {
	vec2 uv = floor(UV * pixels) / pixels;

	// distance from center, to create a circle
	float d_to_center = distance(uv, vec2(0.5));

	//uv = ((uv * 2.0 - 1.0) / (radius + 0.5)) * 0.5 + 0.5;
	uv = spherify(uv, radius * 2.0);
	vec2 uv_rotated = rotate(uv, angles.z);

	float f = fbm(vec2(0.0, uv_rotated.y * 12.0), 6, seed);
	f = pow(f, 1.5) * 1.5;
	float circle = circleNoise(uv_rotated * 3.0 + vec2(angles.y, 0.0), seed);
	float f2 = fbm(uv_rotated * 3.0 + circle + vec2(angles.y, 0.0), 4, seed);
	float f3 = fbm(uv_rotated * 3.0 + f2 * 3.0 + circle * 2.0 +
			vec2(-angles.y / 2.0, 0.0), 6, 137.0) * 1.2;

	//calculate light
	float light = 1.0;
	if (light_enabled) {
		//calc new sphere point without rotation
		//so lighting is consistent regardless of planet rotation
		vec3 sphere = sphere_coord(uv, radius, vec3(0.0));
		light = dot(normalize(sphere * 2.0 - 1.0),
						normalize(light_dir));
		//smooth straight light steps with noise
		//landscape noise looks good enough
		//but could use anything really
		//clamp it so there is no negative values
		light = clamp(light + (f2 - 0.45) * light_noise_strenght,
						0.0, 1.0);
		light *= light_strenght;
	}

	bool dith = dither_grid(UV, pixels);
	if (dith) {
		light *= 0.95;
		f3 *= 0.98;
		f *= 0.98;
		circle *= 0.98;
	}

	float val = f * f3 * circle * light;
	val = pow(val, 1.0 / brightness) * brightness;
	float col_val = floor(val * 8.0) / 6.0;
	vec3 color = texture(colors_1, vec2(col_val, 0.0)).rgb;
	float a = step(d_to_center, radius);
	COLOR = vec4(color, a);
}