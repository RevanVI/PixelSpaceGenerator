extends Sprite2D
class_name Planet

var _random_image: Image = null


const PLANET_RAND_RANGE: int = 8

const PLANET_LIGHT_X: int = 0
const PLANET_LIGHT_Y: int = 1
const PLANET_SIZE: int = 2
const PLANET_CLOUD: int = 3
const PLANET_ROTATION: int = 4
const PLANET_VALUES_COUNT: int = 5 #count of values calculated per planet


func _ready() -> void:
	var _pixels : int = int(scale.x*256)
	_pixels = clamp(_pixels, 128, 2048)
	material.set_shader_parameter("pixels", _pixels)


func set_random_values(random_image: Image, planet_id: int, iseed: int) -> void:
	var _pixels : int = int(scale.x*256)
	_pixels = clamp(_pixels, 128, 2048)
	material.set_shader_parameter("pixels", _pixels)

	_random_image = random_image

	#generate two noise textures for variation
	var noise_tex_1: NoiseTexture3D = material.get_shader_parameter("noise3d")
	var noise_tex_2: NoiseTexture3D = material.get_shader_parameter("noise3d2")
	noise_tex_1.noise.seed = iseed
	await noise_tex_1.changed
	noise_tex_2.noise.seed = iseed
	await noise_tex_2.changed

	var planet_val: int = planet_id * PLANET_VALUES_COUNT;
	var light_x: float = random_image.get_pixel(planet_val + PLANET_LIGHT_X, PLANET_RAND_RANGE).r
	var light_y: float = random_image.get_pixel(planet_val + PLANET_LIGHT_Y, PLANET_RAND_RANGE).r
	material.set_shader_parameter("light_origin", Vector2(light_x, light_y))

	#planet size already randomized in generator so no need do it here again.
	#var radius: float = max(random_image.get_pixel(planet_val + PLANET_SIZE, PLANET_RAND_RANGE).r * 0.5, 0.3)
	#material.set_shader_parameter("radius" , radius)

	var clouds: float = random_image.get_pixel(planet_val + PLANET_CLOUD, PLANET_RAND_RANGE).r
	material.set_shader_parameter("clouds", clouds > 0.8)

	var planet_rotation : float = random_image.get_pixel(planet_val + PLANET_ROTATION, PLANET_RAND_RANGE).r
	material.set_shader_parameter("angle_x", planet_rotation)

	show()


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("brightness", value)
