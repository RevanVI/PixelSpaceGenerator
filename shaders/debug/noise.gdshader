shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"


void fragment() {
	float seed = 0.0;
	vec3 color = vec3(noise(UV * 5.0, seed));
	COLOR = vec4(color, 1.0);
}
