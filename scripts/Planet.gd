extends Sprite2D
class_name Planet

var _random_image: Image = null


const PLANET_RAND_RANGE: int = 8
const PLANET_LIGHT_X: int = 0
const PLANET_LIGHT_Y: int = 1
const PLANET_SIZE: int = 2
const PLANET_SEED_MOD: int = 3
const PLANET_VALUES_COUNT: int = 4 #count of values calculated per planet


func _ready() -> void:
	var _pixels : int = int(scale.x*256)
	if _pixels < 128:
		_pixels = 128
	elif _pixels > 2048:
		_pixels = 2048
	material.set_shader_parameter("pixels", _pixels)


func set_random_values(random_image: Image, planet_id: int) -> void:
	_random_image = random_image

	var light_x: float = random_image.get_pixel(planet_id * PLANET_VALUES_COUNT + PLANET_LIGHT_X,
												PLANET_RAND_RANGE).r
	var light_y: float = random_image.get_pixel(planet_id * PLANET_VALUES_COUNT + PLANET_LIGHT_Y,
												PLANET_RAND_RANGE).r
	material.set_shader_parameter("light_origin", Vector2(light_x, light_y))

	var _size : float = max(random_image.get_pixel(planet_id * PLANET_VALUES_COUNT + PLANET_SIZE,
												PLANET_VALUES_COUNT).r * 10.0, 0.1)
	material.set_shader_parameter("size" , _size)

	var _seed : float = random_image.get_pixel(planet_id * PLANET_VALUES_COUNT + PLANET_SEED_MOD,
												PLANET_VALUES_COUNT).r
	material.set_shader_parameter("seed", _seed)

