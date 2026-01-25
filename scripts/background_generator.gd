class_name BackgroundGenerator
extends GeneratorBase

@export var star_palette: GradientTexture2D
@export var generate_planets: bool
@export var defined_colors: ColorDataArray

var _stars: Array[BigStar] = []
var _planets: Array[PlanetBase] = []
var _defined_color_ind: int

@onready var background: ColorRect = $CanvasLayer/Background
@onready var dust: ColorRect = $Dust
@onready var nebulae: ColorRect = $Nebulae
@onready var star_container: ObjectPool = $StarContainer
@onready var planet_container: Node = $PlanetContainer
@onready var planet_scene: PackedScene = preload("res://scenes/planets/planet_common.tscn")
@onready var big_star_scene: PackedScene = preload("res://scenes/big_star.tscn")


func _ready() -> void:
	super._ready()
	star_container.init(big_star_scene, _calc_stars_count(), ObjectPool.ObjectPoolMode.GROWING_SIZE)


func set_dust_visibility(value: bool) -> void:
	dust.visible = value


func set_stars_visibility(value: bool) -> void:
	star_container.visible = value


func set_nebulae_visibility(value: bool) -> void:
	nebulae.visible = value


func set_planets_visibility(value: bool) -> void:
	planet_container.visible = value


func set_background_visibility(value: bool) -> void:
	background.visible = value


func set_lighting(value: bool) -> void:
	super.set_lighting(value)
	for p: PlanetBase in _planets:
		p.set_lighting(value)


func set_pixelization_scale(value: int) -> void:
	super.set_pixelization_scale(value)
	nebulae.material.set_shader_parameter("pixel_scale", value)
	dust.material.set_shader_parameter("pixel_scale", value)
	for pl: PlanetBase in _planets:
		pl.set_pixel_scale(value)
	for st: BigStar in _stars:
		st.set_pixel_scale(value)


func set_dither_status(value: bool) -> void:
	super.set_dither_status(value)
	nebulae.material.set_shader_parameter("_dither_enabled", value)
	dust.material.set_shader_parameter("_dither_enabled", value)
	for p: PlanetBase in _planets:
		p.set_dither_status(value)


func set_brightness(value: float = 1.0) -> void:
	super.set_brightness(value)
	nebulae.material.set_shader_parameter("global_brightness", value)
	dust.material.set_shader_parameter("global_brightness", value)
	for pl: PlanetBase in _planets:
		pl.set_brightness(value)
	for st: BigStar in _stars:
		st.set_brightness(value)


func set_color_mode(mode: ColorHelpers.ColorMode) -> void:
	super.set_color_mode(mode)
	if mode == ColorHelpers.ColorMode.PALETTE:
		dust.material.set_shader_parameter("use_defined_colors", false)
		nebulae.material.set_shader_parameter("use_defined_colors", false)
		set_colors(color_palette.gradient.colors)
	elif mode == ColorHelpers.ColorMode.DEFINED:
		dust.material.set_shader_parameter("use_defined_colors", true)
		nebulae.material.set_shader_parameter("use_defined_colors", true)
		# TODO: change this - there is no need to change colors on dust and nebulae objects
		set_colors(defined_colors.get_data(_defined_color_ind).colors_1.gradient.colors)
	else: # mode == ColorHelpers.COLOR_MODE.RANDOM
		dust.material.set_shader_parameter("use_defined_colors", false)
		nebulae.material.set_shader_parameter("use_defined_colors", false)
		set_colors(_rand_colors)

	for pl: PlanetBase in _planets:
		pl.set_color_mode(mode)


func set_colors(colors: PackedColorArray) -> void:
	super.set_colors(colors)
	var tex: GradientTexture2D = dust.material.get_shader_parameter("palette")
	tex.gradient.colors = colors
	tex = nebulae.material.get_shader_parameter("palette")
	tex.gradient.colors = colors
	background.color = colors.slice(0, 1)[0]
	star_palette.gradient.colors = colors.slice(0, 8)


func generate_new(iseed: int) -> void:
	_rand_generator.seed = iseed

	var aspect: Vector2 = Vector2(1, 1)
	if size.x > size.y:
		aspect = Vector2(1.0, size.y / size.x)
	else:
		aspect = Vector2(size.x / size.y, 1.0)
	dust.material.set_shader_parameter("seed", iseed)
	dust.material.set_shader_parameter("pixels", max(size.x, size.y))
	dust.material.set_shader_parameter("uv_correct", aspect)
	nebulae.material.set_shader_parameter("seed", iseed)
	nebulae.material.set_shader_parameter("pixels", max(size.x, size.y))
	nebulae.material.set_shader_parameter("uv_correct", aspect)
	set_pixelization_scale(_pixel_scale)

	_defined_color_ind = _rand_generator.randi_range(0, defined_colors.get_type_count() - 1)
	var defined_colors_data: ColorData = defined_colors.get_data(_defined_color_ind)
	dust.material.set_shader_parameter("defined_colors", defined_colors_data.colors_1)
	nebulae.material.set_shader_parameter("defined_colors", defined_colors_data.colors_1)

	_randomize_colors()
	set_color_mode(color_mode)

	if (generate_planets):
		_make_new_planets()
	_make_new_stars()


func get_current_settings() -> VisualSettings:
	var current_settings: VisualSettings = VisualSettings.new()
	current_settings.pixel_scale = _pixel_scale
	current_settings.background_color = background.color
	current_settings.dust_enabled = dust.visible
	current_settings.nebulae_enabled = nebulae.visible
	current_settings.background_stars_enabled = star_container.visible
	current_settings.planets_enabled = planet_container.visible
	current_settings.planet_lighting_enabled = _lighting_enabled
	current_settings.transparancy_enabled = !background.visible
	current_settings.dither_enabled = _dither_enabled
	current_settings.brightness = _brightness
	return current_settings


func _make_new_planets() -> void:
	for planet: PlanetBase in _planets:
		planet.queue_free()
	_planets = []

	var planet_amount: int = _rand_generator.randi_range(0, PLANET_COUNT_MAX)
	for i: int in range(planet_amount):
		_place_planet(i)


func _place_planet(planet_id: int) -> void:
	var planet: PlanetBase = planet_scene.instantiate()
	planet_container.add_child(planet)
	_planets.append(planet)

	# planet sprite should be at least 1 pixel after this
	# floor(planet_scale * planet_texture_height) > 0
	var rand_size: float = min(size.x, size.y) * _rand_generator.randf_range(0.15, 1) * 0.003
	planet.scale = Vector2(1, 1) * rand_size

	var rand_x: float = _rand_generator.randf()
	var rand_y: float = _rand_generator.randf()
	var pos: Vector2 = Vector2(int(rand_x * size.x), int(rand_y * size.y))
	planet.position = pos

	var pseed: int = _rand_generator.randi()
	planet.set_values(planet_id, pseed, color_mode, color_palette, _pixel_scale)


func _calc_stars_count() -> int:
	var count: int = int(max(size.x, size.y) / 32) #from 0 (below 32px) to 156 (on 5000 px)
	return count


func _make_new_stars() -> void:
	for s: Sprite2D in _stars:
		star_container.return_object(s)
	_stars = []

	var star_amount: int = int(_calc_stars_count() * _rand_generator.randf())
	for i: int in star_amount:
		_place_big_star(i)


func _place_big_star(star_id: int) -> void:
	var star: BigStar = star_container.get_object()
	_stars.append(star)

	var rand_x: float = _rand_generator.randf()
	var rand_y: float = _rand_generator.randf()
	var pos: Vector2 = Vector2(int(rand_x * size.x), int(rand_y * size.y))
	star.position = pos

	# star sprite should be at least 1 pixel after this
	# floor(star_scale * star_texture_height) > 0
	var rand_size: float = min(size.x, size.y) * _rand_generator.randf_range(0.25, 1.0) * 0.003
	star.scale = Vector2(1, 1) * rand_size

	var sseed: int = _rand_generator.randi()
	star.set_values(star_id, sseed, star_palette, _pixel_scale)
	star.show()


func _randomize_colors() -> void:
	super._randomize_colors()
	var colors: PackedColorArray = ColorHelpers.generate_new_colors(8, _rand_generator)

	var new_colors: PackedColorArray = PackedColorArray()
	for i: int in 8:
		var col: Color = colors[0].darkened(0.6)
		col = col.lightened(i / 8.0)
		new_colors.append(col)
	_rand_colors = new_colors


func _set_default_values() -> void:
	dust.visible = true
	nebulae.visible = true
	star_container.visible = true
	planet_container.visible = true
	background.visible = true
