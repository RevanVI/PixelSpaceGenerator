shader_type canvas_item;

vec2 spherify(vec2 uv) {
	vec2 centered = uv * 2.0 - 1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	z = clamp(z, 0.0, 1.0);
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

void fragment() {
	vec2 uv = floor(UV * 100.0) / 100.0;
	COLOR.rgb = vec3(spherify(uv), 0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
