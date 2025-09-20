shader_type canvas_item;

#include "res://shaders/shader_helpers.gdshaderinc"

float circleNoise(vec2 uv) {
    //offset x coordinate to break grid pattern
	float uv_y = floor(uv.y);
	uv.x += uv_y * 0.31;
	//random offset to grid center
	float h = rand(vec2(floor(uv.x), uv_y));
	vec2 f = fract(uv);
    float m = length(f-0.25-h*0.5);
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

void fragment() {
	vec2 uv = floor(UV * 200.0) / 200.0;
	float c_noise = circleNoise(uv * 10.0);
	COLOR.rgb = vec3(c_noise);
}

