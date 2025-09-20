shader_type canvas_item;
render_mode blend_mix;

#include "shader_helpers.gdshaderinc"

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform float pixels = 100.0;
uniform bool reduce_background = false;
uniform sampler2D colorscheme;
uniform vec2 uv_correct = vec2(1.0);


float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}


float cloud_alpha(vec2 uv) {
	float c_noise = 0.0;

	// more iterations for more turbulence
	int iters = 2;
	for (int i = 0; i < iters; i++) {
		c_noise += circleNoise(uv * 0.5 + (float(i+1)) + vec2(-0.3, 0.0));
	}
	float fbm = fbm(uv+c_noise, OCTAVES);

	return fbm;
}


void fragment() {
	// pixelizing
	vec2 uv = floor(UV * pixels) / pixels * uv_correct;

	// noise for the dust
	float n_dust = cloud_alpha(uv * size);
	float n_dust2 = fbm(uv * ceil(size * 0.2) - vec2(2,2), OCTAVES);
	float n_dust_lerp = n_dust2 * n_dust;

	// apply dithering
	bool dith = dither_grid(UV, pixels);
	if (dith) {
		n_dust_lerp *= 0.95;
	}

	// choose alpha value
	float n_alpha = fbm(uv * ceil(size * 0.5) + vec2(2,2), OCTAVES);
	float a_dust = step(n_alpha, n_dust_lerp * 1.8);

	// choose & apply colors
	n_dust_lerp = pow(n_dust_lerp, 3.2) * 56.0;
	if (dith) {
		n_dust_lerp *= 1.3;
	}
	if (reduce_background) {
		n_dust_lerp = pow(n_dust_lerp, 0.8) * 0.7;
	}

	float col_value = floor(n_dust_lerp) / 7.0;
	vec3 col = texture(colorscheme, vec2(col_value, 0.0)).rgb;
	COLOR = vec4(col, a_dust);
}