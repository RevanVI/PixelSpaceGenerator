extends Sprite2D
class_name Star

#per star indexes
const STAR_FRAME: int = 0
const STAR_BRIGHTNESS: int = 1
const STAR_VALUES_COUNT: int = 2 #count of values calculated per star


func set_random_values(random_image: Image, star_id: int) -> void:
	var rand_row: int = (star_id * STAR_VALUES_COUNT + STAR_FRAME) / random_image.get_width()
	var rand_col: int = (star_id * STAR_VALUES_COUNT + STAR_FRAME) % random_image.get_width()
	frame = int(random_image.get_pixel(rand_col, rand_row).r * (hframes - 1))

	rand_row = (star_id * STAR_VALUES_COUNT + STAR_BRIGHTNESS) / random_image.get_width()
	rand_col = (star_id * STAR_VALUES_COUNT + STAR_BRIGHTNESS) % random_image.get_width()
	var brightness: float = random_image.get_pixel(rand_col, rand_row).r
	material.set_shader_parameter("brightness_rand", brightness)


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("brightness", value)
