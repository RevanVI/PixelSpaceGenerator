shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"


void fragment() {
	float seed = 123456.0;
	vec3 color = vec3(fbm(UV * 5.0, 6, seed));
	COLOR = vec4(color, 1.0);
}

