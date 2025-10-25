extends Control
class_name StarSystemGenerator


@onready var background_generator: BackgroundGenerator = $BackgroundGenerator
@onready var planetcontainer : ObjectPool = $PlanetContainer
@onready var planet_scene : PackedScene = preload("res://scenes/Planet.tscn")

var planets: Array[Planet] = []
var star: Planet
var rand_generator: RandomNumberGenerator

#planet generator constants
const PLANET_COUNT_MAX: int = 5


func _ready() -> void:
	rand_generator = RandomNumberGenerator.new()
	planetcontainer.init(planet_scene, PLANET_COUNT_MAX)


func generate_new(iseed: int) -> void:
	background_generator.generate_new(iseed, false)
	rand_generator.seed = iseed
	make_system_star()
	make_new_planets()


func make_system_star() -> void:
	if star != null:
		star.queue_free()
	star = planet_scene.instantiate()
	add_child(star)

	star.position = Vector2(0, 0.5 * size.y)
	var rand_size: float = min(size.x, size.y) * rand_generator.randf_range(0.15, 1.2)
	star.scale = Vector2(1,1)*(rand_size * 0.004)
	star.set_values(6, rand_generator.randi())


func make_new_planets() -> void:
	for planet: Planet in planets:
		planetcontainer.return_object(planet)
		planets = []

	var planet_amount: int = int(rand_generator.randi() % (PLANET_COUNT_MAX + 1));
	print(planet_amount)
	for i: int in range(planet_amount):
		place_planet(i, planet_amount)


func place_planet(planet_id: int, planet_amount: int) -> void:
	var rand_size: float = min(size.x, size.y) * rand_generator.randf_range(0.15, 1.15)
	var planet_scale: Vector2 = Vector2(1,1)*(0.5 * rand_size * 0.004)
	
	var radius: float = 0.3 + (1.0 - 0.2) / planet_amount * planet_id
	var pos: Vector2 = Vector2(int(radius * size.x), int(0.5 * size.y))
	
	var planet: Planet = planetcontainer.get_object()
	planets.append(planet)
	planet.scale = planet_scale
	planet.position = pos
	planet.set_values(planet_id, rand_generator.randi())
	planet.set_light_dir((star.position - planet.position).normalized())

	#make moons here
