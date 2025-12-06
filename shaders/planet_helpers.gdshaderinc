vec2 spherify(vec2 uv, float r) {
	vec2 centered = uv * 2.0 - 1.0;
	float z = sqrt(pow(r, 2.0) - dot(centered, centered));
	z = clamp(z, 0.0, 1.0);
	vec2 sphere = centered/(z + 0.5);
	return sphere * 0.5+0.5;
}


mat3 rotate_3d_x(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(vec3(1, 0, 0),
		        vec3(0, c, -s),
		        vec3(0, s, c));
}


mat3 rotate_3d_y(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(vec3(c, 0, s),
		        vec3(0, 1, 0),
		        vec3(-s, 0, c));
}


mat3 rotate_3d_z(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(vec3(c, -s, 0),
		        vec3(s, c, 0),
		        vec3(0, 0, 1));
}


vec3 sphere_coord(vec2 uv, float r, vec3 ang) {
	vec2 centered = uv * 2.0 - 1.0;
	//calculate z coordinates for sphere in coordinate center
	//x^2 + y^2 + z^2 = radius^2
	float z = max(0.0, sqrt(pow(r * 2.0, 2.0) - dot(centered, centered)));
	vec3 sphere = vec3(centered.x, centered.y, z);
	//now we have 3d coordinate of point on sphere
	//rotate it as needed
	sphere = rotate_3d_x(ang.x) * rotate_3d_y(ang.y) *
			 rotate_3d_z(ang.z) * sphere;
	//move coordinates back to [0, 1]
	sphere = sphere * 0.5 + 0.5;
	return sphere;
}
