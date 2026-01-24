class_name GUIGenerator
extends Control

@export var generator: GeneratorBase

## Size of next generated image
var new_size: Vector2i = Vector2i(200, 200)

@onready var viewport: SubViewport = $SubViewport
@onready var viewport_background: ColorRect = $HBox/RenderControl/ViewportBackground
@onready var export_path: Label = $HBox/OptionsColorRect/SettingsBox/ExportPathLabel
@onready var seed_box: SpinBox = $HBox/OptionsColorRect/SettingsBox/SeedBox/Seed
@onready var color_scheme_container: Node = $HBox/OptionsColorRect/SettingsBox/ColorShemesContainer/ColorSchemesBox
@onready var pixelization_slider: HSlider = $HBox/OptionsColorRect/SettingsBox/PixelScaleSlider
@onready var pixelization_value: Label = $HBox/OptionsColorRect/SettingsBox/PixelScaleBox/PixelScaleValue
@onready var enable_stars_toggle: CheckBox = $HBox/OptionsColorRect/SettingsBox/OptionsGrid/EnableStars
@onready var enable_dust_toggle: CheckBox = $HBox/OptionsColorRect/SettingsBox/OptionsGrid/EnableDust
@onready var enable_nebulae_toggle: CheckBox = $HBox/OptionsColorRect/SettingsBox/OptionsGrid/EnableNebulae
@onready var enable_planets_toggle: CheckBox = $HBox/OptionsColorRect/SettingsBox/OptionsGrid/EnablePlanets
@onready var enable_transparency: CheckBox = $HBox/OptionsColorRect/SettingsBox/OptionsGrid/EnableTransparency
@onready var enable_lighting: CheckBox = $HBox/OptionsColorRect/SettingsBox/OptionsGrid/EnableLighting
@onready var enable_dither: CheckBox = $HBox/OptionsColorRect/SettingsBox/OptionsGrid/EnableDither
@onready var brightness_slider: HSlider = $HBox/OptionsColorRect/SettingsBox/BrightnessSlider
@onready var brightness_value: Label = $HBox/OptionsColorRect/SettingsBox/BrightnessBox/BrightnessValue


func _ready() -> void:
	randomize()
	OS.low_processor_usage_mode = true
	OS.request_permissions()
	set_active_settings()
	for i: SchemeSelectButton in color_scheme_container.get_children():
		i.scheme_selected.connect(select_colorscheme)
	_generate_new()
	export_path.text += SaveSystem.get_save_path()


func set_active_settings() -> void:
	var current_settings: VisualSettings = generator.get_current_settings()
	pixelization_slider.value = current_settings.pixel_scale
	enable_stars_toggle.button_pressed = current_settings.background_stars_enabled
	enable_dust_toggle.button_pressed = current_settings.dust_enabled
	enable_nebulae_toggle.button_pressed = current_settings.nebulae_enabled
	enable_planets_toggle.button_pressed = current_settings.planets_enabled
	enable_transparency.button_pressed = current_settings.transparancy_enabled
	enable_lighting.button_pressed = current_settings.planet_lighting_enabled
	enable_dither.button_pressed = current_settings.dither_enabled
	brightness_slider.value = current_settings.brightness


func select_colorscheme(scheme: PackedColorArray) -> void:
	generator.update_color_palette(scheme)


func _generate_new() -> void:
	viewport.size = new_size
	generator.set_render_size(new_size)
	$SubViewport/Camera1.zoom = Vector2(1.0, 1.0)
	$SubViewport/Camera1.offset = new_size * 0.5

	await get_tree().process_frame
	generator.generate_new(int(seed_box.value))


func _export_image() -> void:
	var img: Image = Image.create(new_size.x, new_size.y, false, Image.FORMAT_RGBA8)
	var viewport_img: Image = viewport.get_texture().get_image()
	img.blit_rect(viewport_img, Rect2(0, 0, new_size.x, new_size.y), Vector2(0, 0))
	SaveSystem.save_image(img, generator.class_name)


func _on_seed_button_pressed() -> void:
	seed_box.value = randi_range(0, 999999)


func _on_reset_button_pressed() -> void:
	_generate_new()


func _on_generate_button_pressed() -> void:
	_on_seed_button_pressed()
	_generate_new()


func _on_pixels_height_value_changed(value: int) -> void:
	value = clamp(value, 100, 5000)
	new_size.y = int(value)


func _on_pixels_width_value_changed(value: int) -> void:
	value = clamp(value, 100, 5000)
	new_size.x = int(value)


func _on_export_button_pressed() -> void:
	$SaveTimer.start()


func _on_save_timer_timeout() -> void:
	_export_image()


func _on_pixelization_slider_value_changed(value: float) -> void:
	generator.set_pixelization_scale(int(value))
	pixelization_value.text = str(value)


func _on_brightness_slider_value_changed(value: float) -> void:
	generator.set_brightness(brightness_slider.value)
	brightness_value.text = str(value)


func _on_enable_lighting_toggled(toggled_on: bool) -> void:
	generator.set_lighting(toggled_on)


func _on_enable_dither_toggled(toggled_on: bool) -> void:
	generator.set_dither_status(toggled_on)


func _on_color_mode_option_button_item_selected(index: int) -> void:
	generator.color_mode = index as ColorHelpers.ColorMode


func _on_enable_stars_toggled(toggled_on: bool) -> void:
	generator.set_stars_visibility(toggled_on)


func _on_enable_dust_toggled(toggled_on: bool) -> void:
	generator.set_dust_visibility(toggled_on)


func _on_enable_nebulae_toggled(toggled_on: bool) -> void:
	generator.set_nebulae_visibility(toggled_on)


func _on_enable_planets_toggled(toggled_on: bool) -> void:
	generator.set_planets_visibility(toggled_on)


func _on_enable_transparency_toggled(toggled_on: bool) -> void:
	generator.set_background_visibility(!toggled_on)
	viewport_background.visible = !toggled_on
