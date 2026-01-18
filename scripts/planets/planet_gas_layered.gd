extends PlanetCommon


func set_values(iplanet_id: int, iseed: int, icolor_mode: ColorHelpers.COLOR_MODE, palette: GradientTexture2D, pixel_scale: int) -> void:
	print("Planet id " + str(iplanet_id) + " set_values start, seed: " + str(iseed))

	planet_id = iplanet_id
	rand_generator.seed = iseed
	material.set_shader_parameter("seed", rand_generator.randi_range(0, 1_500_000))
	material.set_shader_parameter("pixels", calc_pixel_size())
	set_pixel_scale(pixel_scale)

	var light_x: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0;
	var light_y: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0;
	var light_z: float = light_y * 0.5  + 0.5;
	material.set_shader_parameter("light_dir", Vector3(light_x, light_y, light_z))

	var planet_rotation : float = rand_generator.randf()
	material.set_shader_parameter("angles", [planet_rotation, 0.0, 0.0])

	color_palette = palette
	randomize_colors()	
	set_color_mode(icolor_mode)
	show()
	print("Planet id " + str(planet_id) + " set_values end")


func randomize_colors() -> void:
	print("Planet id " + str(planet_id) + " randomize_colors")
	var colors: PackedColorArray = ColorHelpers.generate_new_colors(6, rand_generator)

	var new_colors: PackedColorArray = PackedColorArray()
	for i: int  in 4:
		var col: Color = colors[0].darkened(0.6)
		col = col.lightened(i / 4.0)
		new_colors.append(col)
	rand_colors_1 = new_colors
	
	new_colors = PackedColorArray()
	for i: int in 2:
		var col: Color = colors[2].darkened(0.4)
		col.h = col.h + (1.0 - i / 4.0) * 0.1
		col = col.lightened(i / 4.0)
		new_colors.append(col)
	rand_colors_2 = new_colors