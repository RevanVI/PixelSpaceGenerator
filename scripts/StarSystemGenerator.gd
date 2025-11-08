extends Control
class_name StarSystemGenerator




@onready var background_generator: BackgroundGenerator = $BackgroundGenerator
@onready var planetcontainer : ObjectPool = $PlanetContainer
@onready var system_star_scene : PackedScene = preload("res://scenes/SystemStar.tscn")


@export var planet_types: Dictionary[PlanetBase.PlanetType, PackedScene]
@export var color_mode: ColorHelpers.COLOR_MODE = ColorHelpers.COLOR_MODE.PREDETERMINED:
	set(value): 
		color_mode = value
		set_color_mode(value)
	
@export var color_palette: GradientTexture2D

var planets: Array[PlanetBase] = []
var star: SystemStar
var rand_generator: RandomNumberGenerator

var lighting_enabled: bool = true
var brightness: float = 1.0

#planet generator constants
const PLANET_COUNT_MAX: int = 5


func _ready() -> void:
	rand_generator = RandomNumberGenerator.new()
	background_generator.color_mode = color_mode
	#planetcontainer.init(planet_scene, PLANET_COUNT_MAX)


func generate_new(iseed: int) -> void:
	background_generator.generate_new(iseed, false)
	rand_generator.seed = iseed
	make_system_star()
	make_planets()


func make_system_star() -> void:
	if star == null:
		star = system_star_scene.instantiate()
		add_child(star)

	star.hide()
	var rand_size: float = min(size.x, size.y) * rand_generator.randf_range(0.4, 0.8) * 0.01
	var star_radius: float = 0.5 * rand_size * star.texture.get_height()
	star.position = Vector2(-0.33 * star_radius, 0.5 * size.y)
	star.scale = Vector2(1, 1) * rand_size
	star.set_values(rand_generator.randi())


func make_planets() -> void:
	for planet: PlanetBase in planets:
		planet.queue_free()
		#planetcontainer.return_object(planet)
		planets = []

	var planet_amount: int = int(rand_generator.randi() % (PLANET_COUNT_MAX + 1));
	print(planet_amount)
	for i: int in range(planet_amount):
		place_planet(i, planet_amount)


func place_planet(planet_id: int, planet_amount: int) -> void:
	# choose planet type
	var planet_type: PlanetBase.PlanetType = rand_generator.randi_range(0, PlanetBase.PlanetType.keys().size() - 1)	as PlanetBase.PlanetType
	var planet: PlanetBase = planet_types[planet_type].instantiate()
	planetcontainer.add_child(planet)
	planets.append(planet)
	
	var rand_size: float = min(size.x, size.y) * rand_generator.randf_range(0.15, 1.15) * 0.002
	planet.scale = Vector2(1, 1) * rand_size

	# basic idea - divide free space on equal parts and place each planet randomly inside its part
	# global offsets from system start and edge
	var min_limit: float = 0.3
	var max_limit: float = 0.9
	# calculate planet radius relative to generator size and move max and min radiuses to avoid planet intersections
	var planet_rel_rad: float = 0.5 * rand_size * planet.texture.get_height() / size.x
	var radius_low: float = min_limit + (max_limit - min_limit) / planet_amount * planet_id + planet_rel_rad
	var radius_high: float = min_limit + (max_limit - min_limit) / planet_amount * (planet_id + 1) - planet_rel_rad
	var radius: float = rand_generator.randf_range(radius_low, radius_high)
	planet.position = Vector2(int(radius * size.x), int(0.5 * size.y))

	planet.set_values(planet_id, rand_generator.randi(), color_mode, color_palette)
	planet.set_light_dir((star.position - planet.position).normalized())

	#make moons here


func set_render_size(new_size: Vector2) -> void:
	custom_minimum_size = new_size
	size = new_size
	background_generator.set_render_size(new_size)


#visual settings
func get_current_settings() -> VisualSettings:
	var current_settings: VisualSettings = VisualSettings.new()
	current_settings.background_color = background_generator.background.color
	current_settings.dust_enabled = background_generator.dust.visible
	current_settings.nebulae_enabled = background_generator.nebulae.visible
	current_settings.background_stars_enabled = background_generator.starcontainer.visible
	current_settings.planets_enabled = planetcontainer.visible
	current_settings.planet_lighting_enabled = lighting_enabled
	current_settings.transparancy_enabled = !background_generator.background.visible
	current_settings.brightness = brightness
	current_settings.color_mode = color_mode
	return current_settings


func toggle_dust() -> void:
	background_generator.toggle_dust()


func toggle_background_stars() -> void:
	background_generator.toggle_background_stars()


func toggle_nebulae() -> void:
	background_generator.toggle_nebulae()


func toggle_planets() -> void:
	planetcontainer.visible = !planetcontainer.visible


func toggle_transparancy() -> void:
	background_generator.toggle_transparancy()


func toggle_lighting(value: bool) -> void:
	lighting_enabled = value
	for p: PlanetBase in planets:
		p.set_lighting(lighting_enabled)


func set_brightness(value: float = 1.0) -> void:
	brightness = value
	background_generator.set_brightness(value)
	for pl: PlanetBase in planets:
		pl.set_brightness(value)
	star.set_brightness(value)


# Colors methods
func set_color_mode(mode: ColorHelpers.COLOR_MODE) -> void:
	background_generator.set_color_mode(mode)
	for pl: PlanetBase in planets:
		pl.set_color_mode(mode)	


func update_color_palette(scheme: PackedColorArray) -> void:
	print("StarSystemGenerator update_color_palette")
	color_palette.gradient.colors = scheme.slice(0,8)
	background_generator.update_color_palette(scheme)
	if color_mode == ColorHelpers.COLOR_MODE.PALETTE:
		set_color_mode(color_mode)
