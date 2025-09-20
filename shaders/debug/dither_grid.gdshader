shader_type canvas_item;
render_mode blend_mix;

#include "res://shaders/shader_helpers.gdshaderinc"


void fragment() {
	bool dith = dither_grid(UV, 10.0);
	vec3 color = vec3(float(dith));
	COLOR = vec4(color, 1.0);
}
