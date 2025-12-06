shader_type canvas_item;

#include "shader_helpers.gdshaderinc"


void fragment() {
	vec2 uv = UV;
	uv.y *= 2.0;
	uv.y -= 0.5;
	float d_to_center = distance(uv, vec2(0.5));
	//basic circle around planet
	float radius = 0.35;
	float width = 0.1;
	float f = (fbm(uv * 10.0, 6, 132.0) - 0.5) * 0.15;
	float c1 = smoothstep(radius, radius + 0.02, d_to_center + f);
	float c2 = smoothstep(radius + width, radius + width + 0.02, d_to_center + f);

	COLOR.rgb = vec3(c1 - c2);
	COLOR.a = c1 - c2;

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
