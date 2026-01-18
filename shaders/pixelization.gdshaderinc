vec2 pixelize(inout vec2 uv, float pixels, int pixel_scale) {
	// two ways of doing this
	// split this texture in whole pixels
	float corrected_pixel_scale = floor(pixels / float(pixel_scale));
	// split this texture by pixel size
	//corrected_pixel_scale = pixels / float(pixel_scale);
	vec2 pix_id = floor(uv * corrected_pixel_scale);
	uv = pix_id / corrected_pixel_scale;
	return pix_id;
}


vec2 pixelize_corrected(inout vec2 uv, float pixels, int pixel_scale, vec2 uv_correction) {
	vec2 corrected_uv = uv * uv_correction;
	vec2 pix_id = pixelize(corrected_uv, pixels, pixel_scale);
	uv = corrected_uv / uv_correction;
	return pix_id;
}


vec2 pixelize_2(inout vec2 uv, vec2 pixels, int pixel_scale) {
	// two ways of doing this
	// split this texture in whole pixels
	vec2 corrected_pixel_scale = floor(pixels / float(pixel_scale));
	// split this texture by pixel size
	//corrected_pixel_scale = pixels / float(pixel_scale);
	vec2 pix_id = floor(uv * corrected_pixel_scale);
	uv = pix_id / corrected_pixel_scale;
	return pix_id;
}