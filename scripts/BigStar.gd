extends Sprite2D
class_name Star


func set_random_values(random_image: Image, star_id: int) -> void:
	var rand_row: int = star_id / random_image.get_width()
	var rand_col: int = star_id % random_image.get_width()
	frame = int(random_image.get_pixel(rand_col, rand_row).r * (hframes - 1))