extends Sprite2D
class_name SystemStar


var rand_generator: RandomNumberGenerator

@export var star_type: Dictionary[String, GradientTexture2D]


func _ready() -> void:
	material.set_shader_parameter("pixels", calc_pixel_size())
	rand_generator = RandomNumberGenerator.new()


func set_values(iseed: int) -> void:
	rand_generator.seed = iseed
	material.set_shader_parameter("seed", iseed)
	material.set_shader_parameter("pixels", calc_pixel_size())

	var star_type_ind: int = rand_generator.randi_range(0, star_type.size() - 1)
	material.set_shader_parameter("colorscheme", star_type.values()[star_type_ind])

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

	show()


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("brightness", value)


func calc_pixel_size() -> int:
	var pixels: int = int(scale.x * texture.get_height())
	pixels = clamp(pixels, 40, 2048)
	return pixels
