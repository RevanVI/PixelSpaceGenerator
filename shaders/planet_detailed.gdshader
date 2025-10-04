shader_type canvas_item;
render_mode blend_mix, unshaded;

#include "res://shaders/shader_helpers.gdshaderinc"

uniform float seed = 123.0;
uniform float pixels = 200.0;
uniform sampler2D colorscheme;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform vec2 light_origin;
uniform vec3 angles = vec3(0.0, 0.0, 0.0);

uniform sampler3D noise3d;
uniform sampler3D noise3d2;

uniform bool clouds = false;
uniform float radius: hint_range(0.2, 0.5) = 0.5;


mat3 rotate_3d_x(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(vec3(1, 0, 0),
		        vec3(0, c, -s),
		        vec3(0, s, c));
}


mat3 rotate_3d_y(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(vec3(c, 0, s),
		        vec3(0, 1, 0),
		        vec3(-s, 0, c));
}


mat3 rotate_3d_z(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(vec3(c, -s, 0),
		        vec3(s, c, 0),
		        vec3(0, 0, 1));
}


vec3 sphere_coord(vec2 uv, float r, vec3 ang) {
	vec2 centered = uv * 2.0 - 1.0;
	//calculate z coordinates for sphere in coordinate center
	//x^2 + y^2 + z^2 = radius^2
	float z = max(0.0, sqrt(pow(r * 2.0, 2.0) - dot(centered, centered)));
	vec3 sphere = vec3(centered.x, centered.y, z);
	//now we have 3d coordinate of point on sphere
	//rotate it as needed
	sphere = rotate_3d_x(ang.x) * rotate_3d_y(ang.y) *
			 rotate_3d_z(ang.z) * sphere;
	//move coordinates back to [0, 1]
	sphere = sphere * 0.5 + 0.5;
	return sphere;
}


void fragment() {
	// pixelzing
	vec2 uv = floor(UV * pixels) / pixels;

	// distance from center
	float d_to_center = distance(uv, vec2(0.5));
	float d_to_light = distance(uv, light_origin);
	d_to_light += pow(d_to_center * 3.0, 4.0) * 0.02;

	COLOR = vec4(0.0);
	if (d_to_center <= radius) {
		vec3 sphere = sphere_coord(uv, radius, angles);
		
		//combine two different noises for more variations
		//basic form
		float noise_val = texture(noise3d, sphere).r * 0.4;
		//landmasses
		float noise_val_2 = texture(noise3d2, sphere).r;
		noise_val_2 = step(0.45, noise_val_2) * noise_val_2;
		noise_val += noise_val_2 * 0.5;
		//light one side for more contast 
		noise_val *= d_to_light;
		
		// apply dithering
		bool dith = dither_grid(UV, pixels);
		if (dith) {
			noise_val *= 0.95;
		}

		noise_val = pow(noise_val, 1.0 / brightness) * brightness;
		float col_val = floor(noise_val * 14.0) / 7.0;
		vec3 col = texture(colorscheme, vec2(col_val, 0.0)).rgb;
		COLOR = vec4(col, 1.0);
	}
	if (clouds && d_to_center <= radius * 1.02) {
		vec3 sphere = sphere_coord(uv, radius * 1.02, vec3(0.0));
		sphere.xy = (sphere.xy * 2.0 - 1.0) / sphere.z;
		sphere.xy = sphere.xy * 0.5 + 0.5;
		
		float n = fbm(sphere.xy * 4.0, 6, seed);
		float n2 = fbm(sphere.xy * 4.0 + n*2.0 + angles.x + angles.y, 6, seed);
		
		bool dith = dither_grid(UV, pixels);
		if (dith) {
			n2 *= 0.955;
		}
		//make clouds more blocky by reducing color palette
		n2 = floor(n2 * 8.0) / 8.0;
		float cloud = step(0.5, n2);
		n2 *= cloud;
		n2 *= d_to_light;
		COLOR += vec4(vec3(n2), cloud);
	}
}