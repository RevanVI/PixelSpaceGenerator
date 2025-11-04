extends PlanetBase
class_name PlanetLava


func randomize_colors() -> void:
	print("Planet id " + str(planet_id) + " randomize_colors")
	var colors: PackedColorArray = generate_new_colors(6)

	var new_colors: PackedColorArray = PackedColorArray()
	for i: int  in 3:
		var col: Color = colors[0].darkened(0.6)
		col = col.lightened(i / 4.0)
		new_colors.append(col)
	colors_1 = new_colors
	
	new_colors = PackedColorArray()
	for i: int in 4:
		var col: Color = colors[2].darkened(0.4)
		col.h = col.h + (1.0 - i / 4.0) * 0.1
		col = col.lightened(i / 4.0)
		new_colors.append(col)
	colors_2 = new_colors
