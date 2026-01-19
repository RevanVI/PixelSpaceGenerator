class_name BigStar
extends Sprite2D

var rand_generator: RandomNumberGenerator


func _ready() -> void:
	rand_generator = RandomNumberGenerator.new()


func set_values(star_id: int, iseed: int, ipalette: GradientTexture2D, pixel_scale: int) -> void:
	rand_generator.seed = iseed

	frame = rand_generator.randi_range(0, hframes - 1)
	var brightness: float = rand_generator.randf()
	material.set_shader_parameter("brightness_rand", brightness)
	material.set_shader_parameter("palette", ipalette)
	material.set_shader_parameter("pixels", calc_pixel_size())
	material.set_shader_parameter("frame_count", hframes)
	set_pixel_scale(pixel_scale)


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("global_brightness", value)


func calc_pixel_size() -> int:
	var pixels: int = int(scale.x * texture.get_height())
	assert(pixels > 0)
	return pixels


func set_pixel_scale(value: int) -> void:
	material.set_shader_parameter("pixel_scale", value)
