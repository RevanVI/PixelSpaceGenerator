extends Control
class_name BackgroundGenerator

@onready var background : ColorRect = $CanvasLayer/Background
@onready var dust : ColorRect = $Dust
@onready var nebulae : ColorRect = $Nebulae
@onready var starcontainer : ObjectPool = $StarContainer
@onready var planetcontainer : ObjectPool = $PlanetContainer
@onready var planet_scene : PackedScene = preload("res://scenes/Planet.tscn")
@onready var big_star_scene : PackedScene = preload("res://scenes/BigStar.tscn")
@export var rand_texture: NoiseTexture2D

@export var rseed: int = 1234567
var random_image: Image = null

@export var colorscheme: GradientTexture2D
var stars : Array[Star] = []
var planets: Array[Planet] = []

var _lighting_enabled: bool = true

#planet generator constants
const PLANET_COUNT_MAX: int = 5
const PLANET_RAND_RANGE: int = 1
const PLANET_RAND_COUNT: int = 0

#per planet indexes
const PLANET_SCALE: int = 0
const PLANET_POS_X: int = 1
const PLANET_POS_Y: int = 2
const PLANET_VALUES_COUNT: int = 3 #count of values calculated per planet

#star generator constants
const STARS_RAND_RANGE: int = 2
const STARS_RAND_COUNT: int = 0

#per star indexes
const STARS_POS_X: int = 0
const STARS_POS_Y: int = 1
const STARS_VALUES_COUNT: int = 2 #count of values calculated per star


func _ready() -> void:
	dust.visible = true
	nebulae.visible = true
	starcontainer.visible = true
	planetcontainer.visible = true
	background.visible = true

	planetcontainer.init(planet_scene, 5)
	starcontainer.init(big_star_scene, calc_stars_count(), ObjectPool.OBJECT_POOL_MODE.GROWING_SIZE)


func generate_new(iseed: int) -> void:
	var aspect: Vector2 = Vector2(1,1)
	if size.x > size.y:
		aspect = Vector2(size.x / size.y, 1.0)
	else:
		aspect = Vector2(1.0, size.y / size.x)
	
	rseed = iseed
	rand_texture.noise.seed = rseed
	await rand_texture.changed
	random_image = rand_texture.get_image()
	dust.material.set_shader_parameter("seed", rseed)
	dust.material.set_shader_parameter("pixels", max(size.x, size.y))
	dust.material.set_shader_parameter("uv_correct", aspect)
	nebulae.material.set_shader_parameter("seed", rseed)
	nebulae.material.set_shader_parameter("pixels", max(size.x, size.y))
	nebulae.material.set_shader_parameter("uv_correct", aspect)
	
	_make_new_planets()
	_make_new_stars()


func _set_new_colors(new_scheme : GradientTexture2D, new_background : Color) -> void:
	colorscheme = new_scheme

	dust.material.set_shader_parameter("colorscheme", colorscheme)
	nebulae.material.set_shader_parameter("colorscheme", colorscheme)
	nebulae.material.set_shader_parameter("background_color", new_background)
	
	for p : Sprite2D in planets:
		p.material.set_shader_parameter("colorscheme", colorscheme)
	for s : Sprite2D in stars:
		s.material.set_shader_parameter("colorscheme", colorscheme)


func _make_new_planets() -> void:
	for planet: Planet in planets:
		planetcontainer.return_object(planet)
	planets = []

	var planet_amount: int = int(random_image.get_pixel(PLANET_RAND_COUNT, PLANET_RAND_RANGE).r * PLANET_COUNT_MAX);
	for i: int in range(planet_amount):
		_place_planet(i)


func _place_planet(planet_id: int) -> void:
	var min_size: int = min(size.x, size.y)
	var random_size: float = random_image.get_pixel(1 + planet_id * PLANET_VALUES_COUNT + PLANET_SCALE, PLANET_RAND_RANGE).r + 0.15	
	var rand_x: float = random_image.get_pixel(1 + planet_id * PLANET_VALUES_COUNT + PLANET_POS_X, PLANET_RAND_RANGE).r
	var rand_y: float = random_image.get_pixel(1 + planet_id * PLANET_VALUES_COUNT + PLANET_POS_Y, PLANET_RAND_RANGE).r

	var _scale: Vector2 = Vector2(1,1)*(0.7 * random_size * min_size * 0.004)
	var pos: Vector2 = Vector2(int(rand_x * size.x), int(rand_y * size.y))
	
	var planet: Planet = planetcontainer.get_object()
	planets.append(planet)
	planet.scale = _scale
	planet.position = pos
	planet.set_random_values(random_image, planet_id, rseed)


func calc_stars_count() -> int:
	var count: int = int(max(size.x, size.y) / 20) #from 0 (below 20px) to 250 (on 5000 px)
	return count


func _make_new_stars() -> void:
	for s: Sprite2D in stars:
		starcontainer.return_object(s)
	stars = []
	
	var star_amount: int = calc_stars_count()
	star_amount = int(star_amount * random_image.get_pixel(STARS_RAND_COUNT, STARS_RAND_RANGE).r)
	for i: int in star_amount:
		_place_big_star(i)


func _place_big_star(star_id: int) -> void:
	var rand_row: int = (star_id * STARS_VALUES_COUNT + STARS_POS_X) / random_image.get_width()
	var rand_col: int = (star_id * STARS_VALUES_COUNT + STARS_POS_X) % random_image.get_width()
	var rand_x: float = random_image.get_pixel(rand_col, rand_row).r

	rand_row = (star_id * STARS_VALUES_COUNT + STARS_POS_Y) / random_image.get_width()
	rand_col = (star_id * STARS_VALUES_COUNT + STARS_POS_Y) % random_image.get_width()
	var rand_y: float = random_image.get_pixel(rand_col, rand_row).r
	var pos: Vector2 = Vector2(int(rand_x * size.x), int(rand_y * size.y))

	var star: Star = starcontainer.get_object()
	stars.append(star)
	star.position = pos
	star.set_random_values(random_image, star_id)
	star.show()
	


func set_background_color(c : Color) -> void:
	background.color = c
	nebulae.material.set_shader_parameter("background_color", c)


func toggle_dust() -> void:
	dust.visible = !dust.visible


func toggle_stars() -> void:
	starcontainer.visible = !starcontainer.visible


func toggle_nebulae() -> void:
	nebulae.visible = !nebulae.visible


func toggle_planets() -> void:
	planetcontainer.visible = !planetcontainer.visible


func toggle_transparancy() -> void:
	background.visible = !background.visible


func toggle_lighting(value: bool) -> void:
	_lighting_enabled = value
	for p: Planet in planets:
		p.set_lighting(_lighting_enabled)


func set_brightness(value: float = 1.0) -> void:
	nebulae.material.set_shader_parameter("brightness", value)
	dust.material.set_shader_parameter("brightness", value)
	for pl: Planet in planets:
		pl.set_brightness(value)
	for st: Star in stars:
		st.set_brightness(value)
