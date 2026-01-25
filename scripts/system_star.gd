class_name SystemStar
extends Sprite2D

@export var defined_colors: ColorDataArray

var rand_generator: RandomNumberGenerator
var color_mode: ColorHelpers.ColorMode
var defined_colors_ind: int
var rand_colors: PackedColorArray
var color_palette: GradientTexture2D


func _ready() -> void:
	material.set_shader_parameter("pixels", calc_pixel_size())
	rand_generator = RandomNumberGenerator.new()


func set_values(iseed: int, icolor_mode: ColorHelpers.ColorMode, ipalette: GradientTexture2D, pixel_scale: int) -> void:
	rand_generator.seed = iseed
	material.set_shader_parameter("seed", iseed)
	material.set_shader_parameter("pixels", calc_pixel_size())
	set_pixel_scale(pixel_scale)

	defined_colors_ind = rand_generator.randi_range(0, defined_colors.get_type_count() - 1)
	var defined_colors_data: ColorData = defined_colors.get_data(defined_colors_ind)
	material.set_shader_parameter("defined_colors", defined_colors_data.colors_1)

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
	material.set_shader_parameter("global_brightness", value)


func set_dither_status(value: bool) -> void:
	material.set_shader_parameter("dither_enabled", value)


func calc_pixel_size() -> int:
	var pixels: int = int(scale.x * texture.get_height())
	assert(pixels > 0)
	return pixels


func set_pixel_scale(value: int) -> void:
	material.set_shader_parameter("pixel_scale", value)


func set_color_mode(mode: ColorHelpers.ColorMode) -> void:
	Log.info(self, "set_color_mode " + str(mode))
	color_mode = mode
	if mode == ColorHelpers.ColorMode.PALETTE:
		var points: PackedFloat32Array = material.get_shader_parameter("palette").gradient.offsets
		var palette_colors: PackedColorArray = []
		for i: float in points:
			var color: Color = color_palette.gradient.sample(i)
			palette_colors.append(color)
		material.set_shader_parameter("use_defined_colors", false)
		set_colors(palette_colors)
	elif mode == ColorHelpers.ColorMode.DEFINED:
		material.set_shader_parameter("use_defined_colors", true)
	else: # mode == ColorHelpers.COLOR_MODE.RANDOM
		material.set_shader_parameter("use_defined_colors", false)
		set_colors(rand_colors)


func set_colors(colors: PackedColorArray) -> void:
	Log.info(self, "set_colors")
	var tex: GradientTexture2D = material.get_shader_parameter("palette")
	tex.gradient.colors = colors


func randomize_colors() -> void:
	var colors: PackedColorArray = ColorHelpers.generate_new_colors(8, rand_generator)

	var new_colors: PackedColorArray = PackedColorArray()
	for i: int in 8:
		var col: Color = colors[0].darkened(0.6)
		col = col.lightened(i / 8.0)
		new_colors.append(col)
	rand_colors = new_colors
