extends Sprite2D
class_name SystemStar


var rand_generator: RandomNumberGenerator

@export var star_type: Dictionary[String, GradientTexture2D]
var color_mode: ColorHelpers.COLOR_MODE
var predetermined_color: GradientTexture2D
var rand_colors: PackedColorArray
var color_palette: GradientTexture2D


func _ready() -> void:
	material.set_shader_parameter("pixels", calc_pixel_size())
	rand_generator = RandomNumberGenerator.new()


func set_values(iseed: int, icolor_mode: ColorHelpers.COLOR_MODE, ipalette: GradientTexture2D) -> void:
	rand_generator.seed = iseed
	material.set_shader_parameter("seed", iseed)
	material.set_shader_parameter("pixels", calc_pixel_size())

	var star_type_ind: int = rand_generator.randi_range(0, star_type.size() - 1)
	predetermined_color = star_type.values()[star_type_ind]
	material.set_shader_parameter("defined_colors", predetermined_color)

	var brightness_mod: float = rand_generator.randf_range(0.85, 1.2)
	material.set_shader_parameter("brightness_mod", brightness_mod)

	#generate two noise textures for variation
	var noise_tex_1: NoiseTexture3D = material.get_shader_parameter("noise3d")
	var noise_tex_2: NoiseTexture3D = material.get_shader_parameter("noise3d2")
	var seed_mod: float = rand_generator.randf() + 0.05
	noise_tex_1.noise.seed = iseed * seed_mod
	await noise_tex_1.changed
	noise_tex_2.noise.seed = iseed * seed_mod
	await noise_tex_2.changed

	color_palette = ipalette
	randomize_colors()
	set_color_mode(icolor_mode)

	show()


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("brightness", value)


func calc_pixel_size() -> int:
	var pixels: int = int(scale.x * texture.get_height())
	pixels = clamp(pixels, 40, 2048)
	return pixels


# Colors methods
func set_color_mode(mode: ColorHelpers.COLOR_MODE) -> void:
	print("SystemStar set_color_mode " + str(mode))
	color_mode = mode
	if mode == ColorHelpers.COLOR_MODE.PALETTE:
		var points_1: PackedFloat32Array = material.get_shader_parameter("palette").gradient.offsets
		var palette_colors_1: PackedColorArray = []
		for i: float in points_1:
			var color: Color = color_palette.gradient.sample(i)
			palette_colors_1.append(color)
		material.set_shader_parameter("use_defined_colors", false)
		set_colors(palette_colors_1)
	elif mode == ColorHelpers.COLOR_MODE.PREDETERMINED:
		material.set_shader_parameter("use_defined_colors", true)
	else: 
		material.set_shader_parameter("use_defined_colors", false)
		set_colors(rand_colors)


func set_colors(colors: PackedColorArray) -> void:
	print("SystemStar set_colors")
	var tex: GradientTexture2D = material.get_shader_parameter("palette")
	tex.gradient.colors = colors


func randomize_colors() -> void:
	print("SystemStar randomize_colors")
	var colors: PackedColorArray = ColorHelpers.generate_new_colors(8, rand_generator)

	var new_colors: PackedColorArray = PackedColorArray()
	for i: int in 8:
		var col: Color = colors[0].darkened(0.6)
		col = col.lightened(i / 8.0)
		new_colors.append(col)
	rand_colors = new_colors
