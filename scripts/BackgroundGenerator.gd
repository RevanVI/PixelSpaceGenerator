extends Control
class_name BackgroundGenerator


@onready var background : ColorRect = $CanvasLayer/Background
@onready var dust : ColorRect = $Dust
@onready var nebulae : ColorRect = $Nebulae
@onready var starcontainer : ObjectPool = $StarContainer
@onready var planetcontainer : ObjectPool = $PlanetContainer
@onready var planet_scene : PackedScene = preload("res://scenes/planets/Planet_common.tscn")
@onready var big_star_scene : PackedScene = preload("res://scenes/BigStar.tscn")

var rand_generator: RandomNumberGenerator

var stars : Array[Star] = []
var planets: Array[PlanetBase] = []

var lighting_enabled: bool = true
var brightness: float = 1.0

# color parameters
@export var color_mode: ColorHelpers.COLOR_MODE = ColorHelpers.COLOR_MODE.DEFINED:
	set(value): 
		color_mode = value
		set_color_mode(value)
@export var color_palette: GradientTexture2D
@export var defined_colors: PackedColorArray
var rand_colors: PackedColorArray
# texture for stars in background. We can have a really many of stars so share it
@export var star_palette: GradientTexture2D

#planet generator constants
const PLANET_COUNT_MAX: int = 5


func _ready() -> void:
	dust.visible = true
	nebulae.visible = true
	starcontainer.visible = true
	planetcontainer.visible = true
	background.visible = true

	planetcontainer.init(planet_scene, 5)
	starcontainer.init(big_star_scene, calc_stars_count(), ObjectPool.OBJECT_POOL_MODE.GROWING_SIZE)
	rand_generator = RandomNumberGenerator.new()


func generate_new(iseed: int, generate_planets: bool = true) -> void:
	var aspect: Vector2 = Vector2(1,1)
	if size.x > size.y:
		aspect = Vector2(size.x / size.y, 1.0)
	else:
		aspect = Vector2(1.0, size.y / size.x)
	
	rand_generator.seed = iseed
	dust.material.set_shader_parameter("seed", iseed)
	dust.material.set_shader_parameter("pixels", max(size.x, size.y))
	dust.material.set_shader_parameter("uv_correct", aspect)
	nebulae.material.set_shader_parameter("seed", iseed)
	nebulae.material.set_shader_parameter("pixels", max(size.x, size.y))
	nebulae.material.set_shader_parameter("uv_correct", aspect)
	
	randomize_colors()
	set_color_mode(color_mode)

	if (generate_planets):
		_make_new_planets()
	_make_new_stars()


func _make_new_planets() -> void:
	for planet: PlanetBase in planets:
		planet.queue_free()
	planets = []

	var planet_amount: int = rand_generator.randi_range(0, PLANET_COUNT_MAX)
	for i: int in range(planet_amount):
		_place_planet(i)


func _place_planet(planet_id: int) -> void:
	var random_size: float = min(size.x, size.y) * rand_generator.randf_range(0.15, 1)
	var planet_scale: Vector2 = Vector2(1,1)*(0.7 * random_size * 0.004)
	var rand_x: float = rand_generator.randf()
	var rand_y: float = rand_generator.randf()
	var pos: Vector2 = Vector2(int(rand_x * size.x), int(rand_y * size.y))
	
	var planet: PlanetBase = planet_scene.instantiate()
	planetcontainer.add_child(planet)
	planets.append(planet)
	planet.scale = planet_scale
	planet.position = pos
	var pseed: int = rand_generator.randi()
	planet.set_values(planet_id, pseed, color_mode, color_palette)


func calc_stars_count() -> int:
	var count: int = int(max(size.x, size.y) / 20) #from 0 (below 20px) to 250 (on 5000 px)
	return count


func _make_new_stars() -> void:
	for s: Sprite2D in stars:
		starcontainer.return_object(s)
	stars = []
	
	var star_amount: int = int(calc_stars_count() * rand_generator.randf())
	for i: int in star_amount:
		_place_big_star(i)


func _place_big_star(star_id: int) -> void:
	var rand_x: float = rand_generator.randf()
	var rand_y: float = rand_generator.randf()
	var pos: Vector2 = Vector2(int(rand_x * size.x), int(rand_y * size.y))

	var star: Star = starcontainer.get_object()
	stars.append(star)
	star.position = pos
	var sseed: int = rand_generator.randi()
	star.set_values(star_id, sseed, star_palette)
	star.show()
	

func set_render_size(new_size: Vector2) -> void:
	custom_minimum_size = new_size
	size = new_size


#visual settings
func get_current_settings() -> VisualSettings:
	var current_settings: VisualSettings = VisualSettings.new()
	current_settings.background_color = background.color
	current_settings.dust_enabled = dust.visible
	current_settings.nebulae_enabled = nebulae.visible
	current_settings.background_stars_enabled = starcontainer.visible
	current_settings.planets_enabled = planetcontainer.visible
	current_settings.planet_lighting_enabled = lighting_enabled
	current_settings.transparancy_enabled = !background.visible
	current_settings.brightness = brightness
	return current_settings


func toggle_dust() -> void:
	dust.visible = !dust.visible


func toggle_background_stars() -> void:
	starcontainer.visible = !starcontainer.visible


func toggle_nebulae() -> void:
	nebulae.visible = !nebulae.visible


func toggle_planets() -> void:
	planetcontainer.visible = !planetcontainer.visible


func toggle_transparancy() -> void:
	background.visible = !background.visible


func toggle_lighting(value: bool) -> void:
	lighting_enabled = value
	for p: PlanetBase in planets:
		p.set_lighting(lighting_enabled)


func set_brightness(value: float = 1.0) -> void:
	brightness = value
	nebulae.material.set_shader_parameter("global_brightness", value)
	dust.material.set_shader_parameter("global_brightness", value)
	for pl: PlanetBase in planets:
		pl.set_brightness(value)
	for st: Star in stars:
		st.set_brightness(value)


# Colors methods
func set_color_mode(mode: ColorHelpers.COLOR_MODE) -> void:
	print("BackgroundGenerator set_color_mode " + str(mode))
	if mode == ColorHelpers.COLOR_MODE.PALETTE:
		set_colors(color_palette.gradient.colors)
	elif mode == ColorHelpers.COLOR_MODE.DEFINED:
		set_colors(defined_colors)
	else: # mode == ColorHelpers.COLOR_MODE.RANDOM
		set_colors(rand_colors)
	
	for pl: PlanetBase in planets:
		pl.set_color_mode(mode)


func update_color_palette(scheme: PackedColorArray) -> void:
	print("BackgroundGenerator update_color_palette")
	color_palette.gradient.colors = scheme.slice(0,8)
	if color_mode == ColorHelpers.COLOR_MODE.PALETTE:
		set_color_mode(color_mode)


func set_colors(colors: PackedColorArray) -> void:
	print("BackgroundGenerator set_colors")
	var tex: GradientTexture2D = dust.material.get_shader_parameter("palette")
	tex.gradient.colors = colors
	tex = nebulae.material.get_shader_parameter("palette")
	tex.gradient.colors = colors
	nebulae.material.set_shader_parameter("background_color", colors.slice(0, 1)[0])
	background.color = colors.slice(0, 1)[0]
	star_palette.gradient.colors = colors.slice(0, 8)


func randomize_colors() -> void:
	print("BackgroundGenerator randomize_colors")
	var colors: PackedColorArray = ColorHelpers.generate_new_colors(8, rand_generator)

	var new_colors: PackedColorArray = PackedColorArray()
	for i: int in 8:
		var col: Color = colors[0].darkened(0.6)
		col = col.lightened(i / 8.0)
		new_colors.append(col)
	rand_colors = new_colors
