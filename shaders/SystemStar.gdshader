shader_type canvas_item;
render_mode blend_mix, unshaded;

#include "res://shaders/shader_helpers.gdshaderinc"

uniform float seed = 123.0;
uniform float pixels = 200.0;
uniform sampler2D colorscheme;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform vec3 angles = vec3(0.0, 0.0, 0.0);

uniform sampler3D noise3d;
uniform sampler3D noise3d2;

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
	
	COLOR = vec4(texture(colorscheme, vec2(0.0)).rgb, 0.0);
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
		
		noise_val = pow(noise_val, 1.0 / brightness) * brightness;
		float col_val = floor(noise_val * 14.0) / 7.0;
		vec3 col = texture(colorscheme, vec2(col_val, 0.0)).rgb;
		COLOR = vec4(col, 1.0);
	}
	if (d_to_center > radius) {
		float atm_radius = radius * 1.1;
		int bands = 4;
		vec4 atm = vec4(vec3(0.0), 0.0);
		vec3 base_color = texture(colorscheme, vec2(1.0, 0.0)).rgb;
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