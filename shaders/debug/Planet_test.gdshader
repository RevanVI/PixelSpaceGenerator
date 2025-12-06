shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"

uniform sampler2D palette;
uniform float offset = 0.0;


vec2 spherify(vec2 uv) {
	vec2 centered = uv * 2.0 - 1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	z = clamp(z, 0.0, 1.0);
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}


void fragment() {
	float pixels = 100.0;
	vec2 uv = floor(UV * pixels) / pixels;
	
	// distance from center, to create a circle
	float d_to_center = distance(uv, vec2(0.5));
	
	uv = spherify(uv);
	
	float band_count = 6.0;
	
	float f = fbm(vec2(0.0, uv.y * 15.0), 6, 130.0);
	f = pow(f, 1.5) * 1.5;
	float circle = circleNoise(uv * 3.0 + vec2(offset, 0.0), 135.0);
	float f2 = fbm(uv * 3.0 + circle + vec2(offset, 0.0), 4, 136.0);
	float f3 = fbm(uv * 3.0 + f2 * 3.0 + circle * 2.0 + vec2(-offset / 2.0, 0.0), 6, 137.0) * 1.2;
	
	bool dith = dither_grid(UV, pixels);
	if (dith) {
		f3 *= 0.98;
		f *= 0.98;
	}
	
	vec3 color = vec3(f * f3 * circle); 
	color = texture(palette, vec2(color.r, 0.0)).rgb;
	
	// apply alpha
	float a = step(d_to_center, 0.5);
	COLOR = vec4(color, a);
}


