extends Control
class_name StarSystemGenerator


@onready var background_generator: BackgroundGenerator = $BackgroundGenerator
@onready var planetcontainer : ObjectPool = $PlanetContainer
@onready var planet_scene : PackedScene = preload("res://scenes/Planet.tscn")

var planets: Array[Planet] = []
var rand_generator: RandomNumberGenerator

#planet generator constants
const PLANET_COUNT_MAX: int = 5


func _ready() -> void:
	rand_generator = RandomNumberGenerator.new()
	planetcontainer.init(planet_scene, PLANET_COUNT_MAX)


func generate_new(iseed: int) -> void:
	background_generator.generate_new(iseed, false)
	rand_generator.seed = iseed
	_make_system_star(iseed)
	_make_new_planets()


func _make_system_star(iseed: int) -> void:
	pass


func _make_new_planets() -> void:
	for planet: Planet in planets:
		planetcontainer.return_object(planet)
		planets = []

	var planet_amount: int = int(rand_generator.randi() % (PLANET_COUNT_MAX + 1));
	print(planet_amount)
	for i: int in range(planet_amount):
		_place_planet(i, planet_amount)


func _place_planet(planet_id: int, planet_amount: int) -> void:
	var min_size: int = min(size.x, size.y)
	var random_size: float = rand_generator.randf() + 0.15    

	var _scale: Vector2 = Vector2(1,1)*(0.5 * random_size * min_size * 0.004)
	var radius: float = 0.2 + (1.0 - 0.2) / planet_amount * planet_id

	var pos: Vector2 = Vector2(int(radius * size.x), int(0.5 * size.y))
	
	var planet: Planet = planetcontainer.get_object()
	planets.append(planet)
	planet.scale = _scale
	planet.position = pos
	planet.show()

	#make moons here