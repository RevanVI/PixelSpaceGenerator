@abstract
class_name PlanetBase
extends Sprite2D

enum PlanetType {
	COMMON = 0,
	ICE = 1,
	BARREN = 2,
	LAVA = 3,
	GAS_LAYERED = 4,
}

@export var planet_type: PlanetType
@export_range(0.0, 1.0) var cloud_threshold: float = 0.8
@export var defined_colors: ColorDataArray

var rand_generator: RandomNumberGenerator
var planet_id: int
var color_mode: ColorHelpers.ColorMode
var defined_colors_ind: int
var rand_colors_1: PackedColorArray
var rand_colors_2: PackedColorArray
var color_palette: GradientTexture2D


func _ready() -> void:
	material.set_shader_parameter("pixels", _calc_pixel_size())
	rand_generator = RandomNumberGenerator.new()


func set_values(id: int, gen_seed: int, mode: ColorHelpers.ColorMode, palette: GradientTexture2D, pixel_scale: int) -> void:
	print("Planet id " + str(id) + " set_values start, seed: " + str(gen_seed))

	planet_id = id
	rand_generator.seed = gen_seed
	material.set_shader_parameter("seed", rand_generator.randi_range(0, 1_500_000))
	material.set_shader_parameter("pixels", _calc_pixel_size())
	set_pixel_scale(pixel_scale)

	defined_colors_ind = rand_generator.randi_range(0, defined_colors.get_type_count() - 1)
	var defined_colors_data: ColorData = defined_colors.get_data(defined_colors_ind)
	material.set_shader_parameter("defined_colors_1", defined_colors_data.colors_1)
	material.set_shader_parameter("defined_colors_2", defined_colors_data.colors_2)

	var light_x: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0
	var light_y: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0
	var light_z: float = light_y * 0.5 + 0.5
	material.set_shader_parameter("light_dir", Vector3(light_x, light_y, light_z))

	# define by shader if noise textures are needed
	if material.get_shader_parameter("noise3d") != null: 
		var noise_tex_1: NoiseTexture3D = material.get_shader_parameter("noise3d")
		var noise_tex_2: NoiseTexture3D = material.get_shader_parameter("noise3d2")
		noise_tex_1.noise.seed = gen_seed
		await noise_tex_1.changed
		noise_tex_2.noise.seed = gen_seed
		await noise_tex_2.changed

	var clouds: float = rand_generator.randf()
	material.set_shader_parameter("clouds", clouds > cloud_threshold)

	var planet_rotation: float = rand_generator.randf()
	material.set_shader_parameter("angles", [planet_rotation, 0.0, 0.0])

	color_palette = palette
	_randomize_colors()
	set_color_mode(mode)
	show()
	print("Planet id " + str(id) + " set_values end")


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("global_brightness", value)


func set_dither_status(value: bool) -> void:
	material.set_shader_parameter("dither_enabled", value)


func set_lighting(value: bool) -> void:
	material.set_shader_parameter("light_enabled", value)


func set_light_dir(dir: Vector2) -> void:
	material.set_shader_parameter("light_dir", Vector3(dir.x, dir.y, 0.2))


func set_pixel_scale(value: int) -> void:
	material.set_shader_parameter("pixel_scale", value)


func set_color_mode(mode: ColorHelpers.ColorMode) -> void:
	print("Planet id " + str(planet_id) + " set_color_mode " + str(mode))
	color_mode = mode
	if mode == ColorHelpers.ColorMode.PALETTE:
		var palette_colors: Array[PackedColorArray] = [PackedColorArray(), PackedColorArray()]
		var points: PackedFloat32Array = material.get_shader_parameter("colors_1").gradient.offsets
		for i: float in points:
			var color: Color = color_palette.gradient.sample(i)
			palette_colors[0].append(color)

		points = material.get_shader_parameter("colors_2").gradient.offsets
		for i: float in points:
			var color: Color = color_palette.gradient.sample(i)
			palette_colors[1].append(color)

		material.set_shader_parameter("use_defined_colors", false)
		set_colors(palette_colors[0], palette_colors[1])
	elif mode == ColorHelpers.ColorMode.DEFINED:
		material.set_shader_parameter("use_defined_colors", true)
	else: # mode == ColorHelpers.COLOR_MODE.RANDOM
		material.set_shader_parameter("use_defined_colors", false)
		set_colors(rand_colors_1, rand_colors_2)


func set_colors(colors_1: PackedColorArray, colors_2: PackedColorArray) -> void:
	print("Planet id " + str(planet_id) + " set_colors")
	var tex: GradientTexture2D = material.get_shader_parameter("colors_1")
	tex.gradient.colors = colors_1
	tex = material.get_shader_parameter("colors_2")
	tex.gradient.colors = colors_2


## Randomly generates colors and set values to rand_colors_1, rand_colors_2
@abstract func _randomize_colors() -> void


func _calc_pixel_size() -> int:
	var pixels: int = int(scale.x * texture.get_height())
	assert(pixels > 0)
	return pixels
