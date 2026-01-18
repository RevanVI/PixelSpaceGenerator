shader_type canvas_item;
render_mode blend_mix, unshaded;

#include "pixelization.gdshaderinc"


uniform float pixels;
uniform int pixel_scale: hint_range(1, 32, 1) = 4;
uniform int frame_count;

uniform sampler2D palette: filter_nearest;
uniform float global_brightness: hint_range(0.5, 2.0, 0.01) = 1.0;
uniform float brightness_rand: hint_range(0.0, 1.0, 0.05) = 1.0;


void fragment() {
	// UV is not in range [0, 1] with animation frames active
	// we can rescale UV by multiplying it with frame count
	vec2 uv = UV * vec2(float(frame_count), 1.0);
	vec2 pix_id = pixelize(uv, pixels, pixel_scale);
	uv.x /= float(frame_count);
	
	float col_val = texture(TEXTURE, uv).r;
	float a = texture(TEXTURE, uv).a;
	float brightness_mod = global_brightness + (brightness_rand - 0.5) / 2.0;
	col_val = pow(col_val, 1.0 / brightness_mod) * brightness_mod;

	vec4 replace_col = texture(palette, vec2(round(col_val * 7.0) / 7.0, 0.0));
	COLOR = vec4(replace_col.rgb, a);
}