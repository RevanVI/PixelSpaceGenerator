extends Sprite2D
class_name Star


var rand_generator: RandomNumberGenerator


func _ready() -> void:
	rand_generator = RandomNumberGenerator.new()


func set_random_values(star_id: int, iseed: int) -> void:
	rand_generator.seed = iseed

	frame = rand_generator.randi_range(0, hframes - 1)
	var brightness: float = rand_generator.randf()
	material.set_shader_parameter("brightness_rand", brightness)


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("brightness", value)
