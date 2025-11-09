extends PlanetBase
class_name PlanetBarren


func randomize_colors() -> void:
	print("Planet id " + str(planet_id) + " randomize_colors")
	var colors: PackedColorArray = ColorHelpers.generate_new_colors(4, rand_generator)

	# base surface
	var new_colors: PackedColorArray = PackedColorArray()
	for i: int  in 4:
		var col: Color = colors[0].darkened(0.5)
		col = col.lightened(i / 4.0)
		new_colors.append(col)
	colors_1 = new_colors
	
	# craters. Using darker colors and shift hue a little bit
	new_colors = PackedColorArray()
	for i: int in 3:
		var col: Color = colors[0].darkened(0.7)
		col.h = col.h + (1.0 - i / 3.0) * 0.1
		col = col.lightened(i / 4.0)
		new_colors.append(col)
	colors_2 = new_colors