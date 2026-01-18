extends Sprite2D
class_name PlanetBase


enum PlanetType {
	COMMON = 0,
	ICE = 1,
	BARREN = 2,
	LAVA = 3,
	GAS_LAYERED = 4,
}


var planet_id: int
var rand_generator: RandomNumberGenerator
@export var planet_type: PlanetType
@export_range(0.0, 1.0) var cloud_threshold: float = 0.8
#Color parameters
@export var defined_colors: ColorDataArray
var defined_colors_ind: int
var rand_colors_1: PackedColorArray
var rand_colors_2: PackedColorArray
var color_palette: GradientTexture2D
var color_mode: ColorHelpers.COLOR_MODE



func _ready() -> void:
	material.set_shader_parameter("pixels", calc_pixel_size())
	rand_generator = RandomNumberGenerator.new()


func set_values(iplanet_id: int, iseed: int, icolor_mode: ColorHelpers.COLOR_MODE, palette: GradientTexture2D, pixel_scale: int) -> void:
	print("Planet id " + str(iplanet_id) + " set_values start, seed: " + str(iseed))

	planet_id = iplanet_id
	rand_generator.seed = iseed
	material.set_shader_parameter("seed", rand_generator.randi_range(0, 1_500_000))
	material.set_shader_parameter("pixels", calc_pixel_size())
	set_pixel_scale(pixel_scale)

	defined_colors_ind = rand_generator.randi_range(0, defined_colors.get_type_count() - 1)
	var defined_colors_data: ColorData = defined_colors.get_data(defined_colors_ind)
	material.set_shader_parameter("defined_colors_1", defined_colors_data.colors_1)
	material.set_shader_parameter("defined_colors_2", defined_colors_data.colors_2)

	var light_x: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0;
	var light_y: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0;
	var light_z: float = light_y * 0.5  + 0.5;
	material.set_shader_parameter("light_dir", Vector3(light_x, light_y, light_z))

	#generate two noise textures for variation
	var noise_tex_1: NoiseTexture3D = material.get_shader_parameter("noise3d")
	var noise_tex_2: NoiseTexture3D = material.get_shader_parameter("noise3d2")
	noise_tex_1.noise.seed = iseed
	await noise_tex_1.changed
	noise_tex_2.noise.seed = iseed
	await noise_tex_2.changed

	var clouds: float = rand_generator.randf()
	material.set_shader_parameter("clouds", clouds > cloud_threshold)

	var planet_rotation : float = rand_generator.randf()
	material.set_shader_parameter("angles", [planet_rotation, 0.0, 0.0])

	color_palette = palette
	randomize_colors()	
	set_color_mode(icolor_mode)
	show()
	print("Planet id " + str(planet_id) + " set_values end")


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("global_brightness", value)


func set_dither_status(value: bool) -> void:
	material.set_shader_parameter("dither_enabled", value)


func set_lighting(value: bool) -> void:
	material.set_shader_parameter("light_enabled", value)


func set_light_dir(dir: Vector2) -> void:
	material.set_shader_parameter("light_dir", Vector3(dir.x, dir.y, 0.2))


func calc_pixel_size() -> int:
	var pixels: int = int(scale.x * texture.get_height())
	assert(pixels > 0)
	return pixels


func set_pixel_scale(value: int) -> void:
	material.set_shader_parameter("pixel_scale", value)


# Colors methods
func set_color_mode(mode: ColorHelpers.COLOR_MODE) -> void:
	print("Planet id " + str(planet_id) + " set_color_mode " + str(mode))
	color_mode = mode
	if mode == ColorHelpers.COLOR_MODE.PALETTE:
		var points_1: PackedFloat32Array = material.get_shader_parameter("colors_1").gradient.offsets
		var palette_colors_1: PackedColorArray = []
		for i: float in points_1:
			var color: Color = color_palette.gradient.sample(i)
			palette_colors_1.append(color)

		var points_2: PackedFloat32Array = material.get_shader_parameter("colors_2").gradient.offsets
		var palette_colors_2: PackedColorArray = []
		for i: float in points_2:
			var color: Color = color_palette.gradient.sample(i)
			palette_colors_2.append(color)

		material.set_shader_parameter("use_defined_colors", false)
		set_colors(palette_colors_1, palette_colors_2)
	elif mode == ColorHelpers.COLOR_MODE.DEFINED:
		material.set_shader_parameter("use_defined_colors", true)
	else: # mode == ColorHelpers.COLOR_MODE.RANDOM
		material.set_shader_parameter("use_defined_colors", false)
		set_colors(rand_colors_1, rand_colors_2)


func set_colors(colors1: PackedColorArray, colors2: PackedColorArray) -> void:
	print("Planet id " + str(planet_id) + " set_colors")
	var tex: GradientTexture2D = material.get_shader_parameter("colors_1")
	tex.gradient.colors = colors1
	tex = material.get_shader_parameter("colors_2")
	tex.gradient.colors = colors2


# Generate random color for planet. 
# Should be overriden for different planet types
func randomize_colors() -> void:
	print("Planet id " + str(planet_id) + " randomize_colors ")
	var colors: PackedColorArray = ColorHelpers.generate_new_colors(8, rand_generator)
	rand_colors_1 = colors.slice(0, 4)
	rand_colors_2 = colors.slice(4, 8)
