shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"


void fragment() {
	vec2 uv = floor(UV * 200.0) / 200.0;
	float c_noise = circleNoise(uv * 10.0);
	COLOR.rgb = vec3(c_noise);
}

