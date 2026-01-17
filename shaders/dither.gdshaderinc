const float bayer2x2[4] = float[4](
	0.0 / 4.0, 2.0 / 4.0,
	3.0 / 4.0, 1.0 / 4.0
);

const float bayer4x4[16] = float[16](
	 0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
	12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
	 3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
	15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
);

const float bayer8x8[64] = float[64](
   0.0/ 64.0, 48.0/ 64.0, 12.0/ 64.0, 60.0/ 64.0,  3.0/ 64.0, 51.0/ 64.0, 15.0/ 64.0, 63.0/ 64.0,
  32.0/ 64.0, 16.0/ 64.0, 44.0/ 64.0, 28.0/ 64.0, 35.0/ 64.0, 19.0/ 64.0, 47.0/ 64.0, 31.0/ 64.0,
   8.0/ 64.0, 56.0/ 64.0,  4.0/ 64.0, 52.0/ 64.0, 11.0/ 64.0, 59.0/ 64.0,  7.0/ 64.0, 55.0/ 64.0,
  40.0/ 64.0, 24.0/ 64.0, 36.0/ 64.0, 20.0/ 64.0, 43.0/ 64.0, 27.0/ 64.0, 39.0/ 64.0, 23.0/ 64.0,
   2.0/ 64.0, 50.0/ 64.0, 14.0/ 64.0, 62.0/ 64.0,  1.0/ 64.0, 49.0/ 64.0, 13.0/ 64.0, 61.0/ 64.0,
  34.0/ 64.0, 18.0/ 64.0, 46.0/ 64.0, 30.0/ 64.0, 33.0/ 64.0, 17.0/ 64.0, 45.0/ 64.0, 29.0/ 64.0,
  10.0/ 64.0, 58.0/ 64.0,  6.0/ 64.0, 54.0/ 64.0,  9.0/ 64.0, 57.0/ 64.0,  5.0/ 64.0, 53.0/ 64.0,
  42.0/ 64.0, 26.0/ 64.0, 38.0/ 64.0, 22.0/ 64.0, 41.0/ 64.0, 25.0/ 64.0, 37.0/ 64.0, 21.0/ 64.0
);


float luma(vec3 color) {
	return dot(vec3(0.2126, 0.7152, 0.0722), color);
}


float get_bayer_shift(vec2 pixel_coord, int level) {
	float values[3] = float[3](0.0, 0.0, 0.0);
	values[0] = bayer2x2[int(mod(pixel_coord.x, 2.0)) +
						int(mod(pixel_coord.y, 2.0)) * 2];
	values[1] = bayer4x4[int(mod(pixel_coord.x, 4.0)) +
						int(mod(pixel_coord.y, 4.0)) * 4];
	values[2] = bayer8x8[int(mod(pixel_coord.x, 8.0)) +
						int(mod(pixel_coord.y, 8.0)) * 8];

	return values[level];
}


vec3 dither_vec3(vec3 color, float color_count, vec2 pixel_coord, float dither_shift, int dither_level) {
	vec3 actual_value = color * (color_count - 1.0);
	vec3 floor_value = floor(actual_value);

	vec3 delta = actual_value - floor_value;
	float bayer_shift = get_bayer_shift(pixel_coord, dither_level);
	vec3 dither_values = step(vec3(bayer_shift), delta + dither_shift);

	return (floor_value + dither_values) / (color_count - 1.0);
}


float dither_float(float color, float color_count, vec2 pixel_coord, float dither_shift, int dither_level) {
	float actual_value = color * (color_count - 1.0);
	float floor_value = floor(actual_value);

	float delta = actual_value - floor_value;
	float bayer_shift = get_bayer_shift(pixel_coord, dither_level);
	float dither_values = step(bayer_shift, delta + dither_shift);

	return (floor_value + dither_values) / (color_count - 1.0);
}
