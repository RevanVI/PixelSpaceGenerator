extends Sprite2D
class_name PlanetBase


enum PlanetType {
	COMMON = 0,
	ICE = 1,
	BARREN = 2,
	LAVA = 3,
}


var planet_id: int
var rand_generator: RandomNumberGenerator
@export var planet_type: PlanetType
@export var default_colors: PackedColorArray
var colors_1: PackedColorArray
var colors_2: PackedColorArray
var use_random_colors: bool = false
@export_range(0.0, 1.0) var cloud_threshold: float = 0.8;


func _ready() -> void:
	material.set_shader_parameter("pixels", calc_pixel_size())
	rand_generator = RandomNumberGenerator.new()


func set_values(iplanet_id: int, iseed: int, iuse_random_colors: bool) -> void:
	print("Planet id " + str(iplanet_id) + " set_values start, seed: " + str(iseed))

	planet_id = iplanet_id
	rand_generator.seed = iseed
	material.set_shader_parameter("seed", rand_generator.randi_range(0, 1_500_000))
	material.set_shader_parameter("pixels", calc_pixel_size())

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

	use_random_colors = iuse_random_colors
	randomize_colors()	
	if use_random_colors:
		set_colors(colors_1, colors_2)
	show()
	print("Planet id " + str(planet_id) + " set_values end")


func set_brightness(value: float = 1.0) -> void:
	material.set_shader_parameter("brightness", value)


func set_lighting(value: bool) -> void:
	material.set_shader_parameter("light_enabled", value)


func set_light_dir(dir: Vector2) -> void:
	material.set_shader_parameter("light_dir", Vector3(dir.x, dir.y, 0.2))


func calc_pixel_size() -> int:
	var pixels: int = int(scale.x * texture.get_height())
	pixels = clamp(pixels, 40, 2048)
	return pixels


func set_colors(colors1: PackedColorArray, colors2: PackedColorArray) -> void:
	print("Planet id " + str(planet_id) + " set_colors")
	var tex: GradientTexture2D = material.get_shader_parameter("colors_1")
	tex.gradient.colors = colors1
	tex = material.get_shader_parameter("colors_2")
	tex.gradient.colors = colors2


func set_use_random_colors(value: bool) -> void:
	print("Planet id " + str(planet_id) + " set_use_random_color " + str(value))
	if value:
		set_colors(colors_1, colors_2)
	else:
		var count_points_1: int = material.get_shader_parameter("colors_1").gradient.get_point_count()
		var count_points_2: int = material.get_shader_parameter("colors_2").gradient.get_point_count()
		assert(default_colors.size() >= (count_points_1 + count_points_2))
		set_colors(default_colors.slice(0, count_points_1), default_colors.slice(count_points_1, count_points_1 + count_points_2))


func generate_new_colors(count: int) -> PackedColorArray:
	# Simple color palette generation based on https://iquilezles.org/articles/palettes/

	# Use planet rand generator for colors too for now.
	# It gives consistency between generations (seed remains the same)
	# but user cannot randomly generate colors
	var a: Vector3 = Vector3(0.5, 0.5, 0.5)
	var b: Vector3 = Vector3(0.5, 0.5, 0.5)
	var c: Vector3 = Vector3(
		rand_generator.randf_range(0.4, 1.5), 
		rand_generator.randf_range(0.4, 1.5), 
		rand_generator.randf_range(0.4, 1.5))
	var d: Vector3 = Vector3(
		rand_generator.randf_range(0.4, 1.2), 
		rand_generator.randf_range(0.4, 1.2), 
		rand_generator.randf_range(0.4, 1.2))
	
	var colors: PackedColorArray = PackedColorArray()

	count = max(count, 1)
	for i: int in range(0, count):
		var modif: float = i / max(count - 1.0, 1.0)
		var x: float =  a.x + b.x * cos(6.28 * (c.x * modif + d.x))
		var y: float =  a.y + b.y * cos(6.28 * (c.y * modif + d.y))
		var z: float =  a.z + b.z * cos(6.28 * (c.z * modif + d.z))
		colors.append(Color(x, y, z))
	
	return colors


# Generate random color for planet. 
# Should be overriden for different planet types
func randomize_colors() -> void:
	print("Planet id " + str(planet_id) + " randomize_colors ")
	var colors: PackedColorArray = generate_new_colors(8)
	colors_1 = colors.slice(0, 4)
	colors_2 = colors.slice(4, 8)
