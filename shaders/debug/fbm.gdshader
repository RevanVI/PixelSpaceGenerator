shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"


void fragment() {
	vec3 color = vec3(fbm(UV * 5.0, 6));
	COLOR = vec4(color, 1.0);
}

