class_name StarSystemGenerator
extends GeneratorBase

@export var planet_types: Dictionary[PlanetBase.PlanetType, PackedScene]

var _planets: Array[PlanetBase] = []
var _star: SystemStar

@onready var background_generator: BackgroundGenerator = $BackgroundGenerator
@onready var planet_container: Node = $PlanetContainer
@onready var system_star_scene: PackedScene = preload("res://scenes/system_star.tscn")


func set_dust_visibility(value: bool) -> void:
	background_generator.set_dust_visibility(value)


func set_stars_visibility(value: bool) -> void:
	background_generator.set_stars_visibility(value)


func set_nebulae_visibility(value: bool) -> void:
	background_generator.set_nebulae_visibility(value)


func set_planets_visibility(value: bool) -> void:
	planet_container.visible = value


func set_background_visibility(value: bool) -> void:
	background_generator.set_background_visibility(value)


func set_lighting(value: bool) -> void:
	super.set_lighting(value)
	for p: PlanetBase in _planets:
		p.set_lighting(value)


func set_pixelization_scale(value: int) -> void:
	super.set_pixelization_scale(value)
	background_generator.set_pixelization_scale(value)
	for pl: PlanetBase in _planets:
		pl.set_pixel_scale(value)
	_star.set_pixel_scale(value)


func set_dither_status(value: bool) -> void:
	super.set_dither_status(value)
	background_generator.set_dither_status(value)
	for pl: PlanetBase in _planets:
		pl.set_dither_status(value)
	_star.set_dither_status(value)


func set_brightness(value: float = 1.0) -> void:
	super.set_brightness(value)
	background_generator.set_brightness(value)
	for pl: PlanetBase in _planets:
		pl.set_brightness(value)
	_star.set_brightness(value)


func set_color_mode(mode: ColorHelpers.ColorMode) -> void:
	super.set_color_mode(mode)
	background_generator.color_mode = mode
	_star.set_color_mode(mode)
	for pl: PlanetBase in _planets:
		pl.set_color_mode(mode)


func update_color_palette(scheme: PackedColorArray) -> void:
	super.update_color_palette(scheme)
	background_generator.update_color_palette(scheme)


func generate_new(iseed: int) -> void:
	Log.info(name, "generate_new. Seed: " + str(iseed))
	background_generator.set_render_size(size)
	background_generator.generate_new(iseed)
	_rand_generator.seed = iseed
	_make_system_star()
	_make_planets()


func get_current_settings() -> VisualSettings:
	var current_settings: VisualSettings = VisualSettings.new()
	current_settings.pixel_scale = _pixel_scale
	current_settings.background_color = background_generator.background.color
	current_settings.dust_enabled = background_generator.dust.visible
	current_settings.nebulae_enabled = background_generator.nebulae.visible
	current_settings.background_stars_enabled = background_generator.star_container.visible
	current_settings.planets_enabled = planet_container.visible
	current_settings.planet_lighting_enabled = _lighting_enabled
	current_settings.transparancy_enabled = !background_generator.background.visible
	current_settings.dither_enabled = _dither_enabled
	current_settings.brightness = _brightness
	current_settings.color_mode = color_mode
	return current_settings


func _make_system_star() -> void:
	if _star == null:
		_star = system_star_scene.instantiate()
		add_child(_star)

	_star.hide()
	var rand_size: float = min(size.x, size.y) * _rand_generator.randf_range(0.4, 0.8) * 0.01
	_star.scale = Vector2(1, 1) * rand_size

	var star_radius: float = 0.5 * rand_size * _star.texture.get_height()
	_star.position = Vector2(-0.33 * star_radius, 0.5 * size.y)

	_star.set_values(_rand_generator.randi(), color_mode, color_palette, _pixel_scale)


func _make_planets() -> void:
	for planet: PlanetBase in _planets:
		planet.queue_free()
	_planets = []

	var planet_amount: int = int(_rand_generator.randi() % (PLANET_COUNT_MAX + 1))
	for i: int in range(planet_amount):
		_place_planet(i, planet_amount)


func _place_planet(planet_id: int, planet_amount: int) -> void:
	# choose planet type
	var planet_type: PlanetBase.PlanetType = _rand_generator.randi_range(0, planet_types.size() - 1) as PlanetBase.PlanetType
	var planet: PlanetBase = planet_types[planet_type].instantiate()
	planet_container.add_child(planet)
	_planets.append(planet)

	# planet sprite should be at least 1 pixel after this
	# floor(rand_size * planet_texture_height) > 0
	var rand_size: float = min(size.x, size.y) * _rand_generator.randf_range(0.2, 1.15) * 0.002
	planet.scale = Vector2(1, 1) * rand_size

	# basic idea - divide free space on equal parts and place each planet randomly inside its part
	# global offsets from system start and edge
	var min_limit: float = 0.3
	var max_limit: float = 0.9
	# calculate planet radius relative to generator size and move max and min radiuses to avoid planet intersections
	var planet_rel_rad: float = 0.5 * rand_size * planet.texture.get_height() / size.x
	var radius_low: float = min_limit + (max_limit - min_limit) / planet_amount * planet_id + planet_rel_rad
	var radius_high: float = min_limit + (max_limit - min_limit) / planet_amount * (planet_id + 1) - planet_rel_rad
	var radius: float = _rand_generator.randf_range(radius_low, radius_high)
	planet.position = Vector2(int(radius * size.x), int(0.5 * size.y))

	planet.set_values(planet_id, _rand_generator.randi(), color_mode, color_palette, _pixel_scale)
	planet.set_light_dir((_star.position - planet.position).normalized())

	#make moons here


func _set_default_values() -> void:
	background_generator.color_mode = color_mode
