class_name StarSystemGenerator
extends Control

#planet generator constants
const PLANET_COUNT_MAX: int = 5

@export var planet_types: Dictionary[PlanetBase.PlanetType, PackedScene]
@export var color_mode: ColorHelpers.ColorMode = ColorHelpers.ColorMode.DEFINED:
	set(value):
		color_mode = value
		set_color_mode(value)
@export var color_palette: GradientTexture2D

var planets: Array[PlanetBase] = []
var star: SystemStar
var rand_generator: RandomNumberGenerator
var lighting_enabled: bool = true
var dither_enabled: bool = true
var pixelization_scale: int = 1
var brightness: float = 1.0

@onready var background_generator: BackgroundGenerator = $BackgroundGenerator
@onready var planetcontainer: ObjectPool = $PlanetContainer
@onready var system_star_scene: PackedScene = preload("res://scenes/system_star.tscn")


func _ready() -> void:
	rand_generator = RandomNumberGenerator.new()
	background_generator.color_mode = color_mode
	#planetcontainer.init(planet_scene, PLANET_COUNT_MAX)


func generate_new(iseed: int) -> void:
	background_generator.generate_new(iseed, false)
	rand_generator.seed = iseed
	_make_system_star()
	_make_planets()


func set_render_size(new_size: Vector2) -> void:
	custom_minimum_size = new_size
	size = new_size
	background_generator.set_render_size(new_size)


func get_current_settings() -> VisualSettings:
	var current_settings: VisualSettings = VisualSettings.new()
	current_settings.pixelization_scale = pixelization_scale
	current_settings.background_color = background_generator.background.color
	current_settings.dust_enabled = background_generator.dust.visible
	current_settings.nebulae_enabled = background_generator.nebulae.visible
	current_settings.background_stars_enabled = background_generator.star_container.visible
	current_settings.planets_enabled = planetcontainer.visible
	current_settings.planet_lighting_enabled = lighting_enabled
	current_settings.transparancy_enabled = !background_generator.background.visible
	current_settings.dither_enabled = dither_enabled
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


func set_pixelization_scale(value: int) -> void:
	pixelization_scale = value
	background_generator.set_pixelization_scale(value)
	for pl: PlanetBase in planets:
		pl.set_pixel_scale(pixelization_scale)
	star.set_pixel_scale(pixelization_scale)


func set_dither_status(value: bool) -> void:
	dither_enabled = value
	background_generator.set_dither_status(value)
	for pl: PlanetBase in planets:
		pl.set_dither_status(value)
	star.set_dither_status(value)


func set_brightness(value: float = 1.0) -> void:
	brightness = value
	background_generator.set_brightness(value)
	for pl: PlanetBase in planets:
		pl.set_brightness(value)
	star.set_brightness(value)


func set_color_mode(mode: ColorHelpers.ColorMode) -> void:
	background_generator.color_mode = mode
	star.set_color_mode(mode)
	for pl: PlanetBase in planets:
		pl.set_color_mode(mode)


func update_color_palette(scheme: PackedColorArray) -> void:
	print("StarSystemGenerator update_color_palette")
	color_palette.gradient.colors = scheme.slice(0, 8)
	background_generator.update_color_palette(scheme)
	if color_mode == ColorHelpers.ColorMode.PALETTE:
		set_color_mode(color_mode)


func _make_system_star() -> void:
	if star == null:
		star = system_star_scene.instantiate()
		add_child(star)

	star.hide()
	var rand_size: float = min(size.x, size.y) * rand_generator.randf_range(0.4, 0.8) * 0.01
	var star_radius: float = 0.5 * rand_size * star.texture.get_height()
	star.position = Vector2(-0.33 * star_radius, 0.5 * size.y)
	star.scale = Vector2(1, 1) * rand_size
	star.set_values(rand_generator.randi(), color_mode, color_palette, pixelization_scale)


func _make_planets() -> void:
	for planet: PlanetBase in planets:
		planet.queue_free()
		#planetcontainer.return_object(planet)
		planets = []

	var planet_amount: int = int(rand_generator.randi() % (PLANET_COUNT_MAX + 1))
	print(planet_amount)
	for i: int in range(planet_amount):
		_place_planet(i, planet_amount)


func _place_planet(planet_id: int, planet_amount: int) -> void:
	# choose planet type
	var planet_type: PlanetBase.PlanetType = rand_generator.randi_range(0, planet_types.size() - 1) as PlanetBase.PlanetType
	var planet: PlanetBase = planet_types[planet_type].instantiate()
	planetcontainer.add_child(planet)
	planets.append(planet)

	# planet sprite should be at least 1 pixel after this
	# floor(rand_size * planet_texture_height) > 0
	var rand_size: float = min(size.x, size.y) * rand_generator.randf_range(0.2, 1.15) * 0.002
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

	planet.set_values(planet_id, rand_generator.randi(), color_mode, color_palette, pixelization_scale)
	planet.set_light_dir((star.position - planet.position).normalized())

	#make moons here
