shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D palette;
uniform float brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform float brightness_rand: hint_range(0.0, 1.0, 0.05) = 1.0;


void fragment() {
	float col_val = texture(TEXTURE, UV).r;
	float a = texture(TEXTURE, UV).a;
	float brightness_mod = brightness + (brightness_rand - 0.5) / 2.0;
	col_val = pow(col_val, 1.0 / brightness_mod) * brightness_mod;

	vec4 replace_col = texture(palette, vec2(round(col_val * 7.0) / 7.0, 0.0));
	COLOR = vec4(replace_col.rgb, a);
}