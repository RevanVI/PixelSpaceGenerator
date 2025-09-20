shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"

void fragment() {
	vec3 color = vec3(noise(UV * 5.0));
	COLOR = vec4(color, 1.0);
}

