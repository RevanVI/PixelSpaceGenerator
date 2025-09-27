shader_type canvas_item;
render_mode blend_mix;

#include "res://shaders/shader_helpers.gdshaderinc"


void fragment() {
	float seed = 123456.0;
	vec3 color = vec3(rand(UV, seed));
	COLOR = vec4(color, 1.0);
}
