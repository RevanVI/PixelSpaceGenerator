extends Sprite2D
class_name Planet


var rand_generator: RandomNumberGenerator


func _ready() -> void:
	# 100 is size of stub texture for planet
	var _pixels : int = int(scale.x*100)
	_pixels = clamp(_pixels, 40, 2048)
	material.set_shader_parameter("pixels", _pixels)
	rand_generator = RandomNumberGenerator.new()


func set_values(planet_id: int, iseed: int) -> void:
	var _pixels : int = int(scale.x* 100)
	_pixels = clamp(_pixels, 40, 2048)
	material.set_shader_parameter("pixels", _pixels)

	rand_generator.seed = iseed

	var light_x: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0;
	var light_y: float = clamp(rand_generator.randf(), 0.2, 0.8) * 2.0 - 1.0;
	var light_z: float = light_y * 0.5  + 0.5;
	material.set_shader_parameter("light_dir", Vector3(light_x, light_y, light_z))

	#generate two noise textures for variation
	var noise_tex_1: NoiseTexture3D = material.get_shader_parameter("noise3d")
	var noise_tex_2: NoiseTexture3D = material.get_shader_parameter("noise3d2")
	var seed_mod: float = rand_generator.randf() + 0.05
	noise_tex_1.noise.seed = iseed * seed_mod
	await noise_tex_1.changed
	noise_tex_2.noise.seed = iseed * seed_mod
	await noise_tex_2.changed

	material.set_shader_parameter("seed", iseed)
	
	var clouds: float = rand_generator.randf()
	material.set_shader_parameter("clouds", clouds > 0.8)

	var planet_rotation : float = rand_generator.randf()
	material.set_shader_parameter("angles", [planet_rotation, 0.0, 0.0])

	show()


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("brightness", value)


func set_lighting(value: bool) -> void:
	material.set_shader_parameter("light_enabled", value)


func set_light_dir(dir: Vector2) -> void:
	material.set_shader_parameter("light_dir", Vector3(dir.x, dir.y, 0.2))