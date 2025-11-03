shader_type canvas_item;

uniform vec3 a = vec3(0.5);
uniform vec3 b = vec3(0.5);
uniform vec3 c = vec3(0.5);
uniform vec3 d = vec3(0.5);


void fragment() {
	vec3 col = a + b * cos(2.0 * PI * (c * UV.x + d));
	COLOR.rgb = col;
}