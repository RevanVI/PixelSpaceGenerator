@abstract
class_name GeneratorBase
extends Control

#planet generator constants
const PLANET_COUNT_MAX: int = 5

@export var color_mode: ColorHelpers.ColorMode = ColorHelpers.ColorMode.DEFINED:
	set(value):
		color_mode = value
		set_color_mode(value)
@export var color_palette: GradientTexture2D

var _rand_generator: RandomNumberGenerator
var _lighting_enabled: bool = true
var _dither_enabled: bool = true
var _pixel_scale: int = 1
var _brightness: float = 1.0
var _rand_colors: PackedColorArray


func _ready() -> void:
	Log.info(self, "_ready")
	_set_default_values()
	_rand_generator = RandomNumberGenerator.new()


func set_render_size(new_size: Vector2) -> void:
	Log.info(self, "set_render_size to " + str(new_size))
	custom_minimum_size = new_size
	size = new_size


@abstract func set_dust_visibility(value: bool) -> void


@abstract func set_stars_visibility(value: bool) -> void


@abstract func set_nebulae_visibility(value: bool) -> void


@abstract func set_planets_visibility(value: bool) -> void


@abstract func set_background_visibility(value: bool) -> void


func set_lighting(value: bool) -> void:
	_lighting_enabled = value


func set_pixelization_scale(value: int) -> void:
	_pixel_scale = value


func set_dither_status(value: bool) -> void:
	_dither_enabled = value


func set_brightness(value: float = 1.0) -> void:
	_brightness = value


func set_color_mode(mode: ColorHelpers.ColorMode) -> void:
	Log.info(self, "set_color_mode " + str(mode))


func update_color_palette(scheme: PackedColorArray) -> void:
	Log.info(self, "update_color_palette")
	color_palette.gradient.colors = scheme.slice(0, 8)
	if color_mode == ColorHelpers.ColorMode.PALETTE:
		set_color_mode(color_mode)


func set_colors(_colors: PackedColorArray) -> void:
	Log.info(self, "set_colors")


@abstract func generate_new(iseed: int) -> void


## Setup default values for generator (visibility for objects and so on)
@abstract func _set_default_values() -> void


## Collects current settings from generator (visibility for objects, brightness, )
@abstract func get_current_settings() -> VisualSettings


func _randomize_colors() -> void:
	return
