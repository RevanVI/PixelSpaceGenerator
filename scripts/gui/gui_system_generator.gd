extends Control

var new_size: Vector2i = Vector2i(200, 200)

@onready var generator: StarSystemGenerator = $SubViewport/StarSystemGenerator
@onready var viewport: SubViewport = $SubViewport
@onready var export_path: Label = $HBoxContainer/OptionsColorRect/Settings/ExportPathLabel
@onready var seed_box: SpinBox = $HBoxContainer/OptionsColorRect/Settings/HBoxContainer3/Seed
@onready var color_scheme_container: Node = $HBoxContainer/OptionsColorRect/Settings/ColorShemesContainer/ColorSchemesVerticalContainer
@onready var pixelization_slider: HSlider = $HBoxContainer/OptionsColorRect/Settings/PixelizationSlider
@onready var pixelization_value: Label = $HBoxContainer/OptionsColorRect/Settings/HBoxContainer6/PixelizationValue
@onready var enable_stars_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableStars
@onready var enable_dust_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableDust
@onready var enable_nebulae_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableNebulae
@onready var enable_planets_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnablePlanets
@onready var enable_transparency: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableTransparency
@onready var enable_lighting: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableLighting
@onready var enable_dither: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableDither
@onready var brightness_slider: HSlider = $HBoxContainer/OptionsColorRect/Settings/BrightnessSlider
@onready var brightness_value: Label = $HBoxContainer/OptionsColorRect/Settings/HBoxContainer5/BrightnessValue
@onready var viewport_background: ColorRect = $HBoxContainer/RenderControl/ViewportBackground


func _ready() -> void:
	randomize()
	OS.low_processor_usage_mode = true
	OS.request_permissions()
	set_active_settings()
	for i: SchemeSelectButton in color_scheme_container.get_children():
		i.scheme_selected.connect(select_colorscheme)

	_generate_new()
	export_path.text += SaveSystem.GetSavePath()


func set_active_settings() -> void:
	var current_settings: VisualSettings = generator.get_current_settings()
	pixelization_slider.value = current_settings.pixelization_scale
	enable_stars_toggle.button_pressed = current_settings.background_stars_enabled
	enable_dust_toggle.button_pressed = current_settings.dust_enabled
	enable_nebulae_toggle.button_pressed = current_settings.nebulae_enabled
	enable_planets_toggle.button_pressed = current_settings.planets_enabled
	enable_transparency.button_pressed = current_settings.transparancy_enabled
	enable_lighting.button_pressed = current_settings.planet_lighting_enabled
	enable_dither.button_pressed = current_settings.dither_enabled
	brightness_slider.value = current_settings.brightness


func export_image() -> void:
	var img: Image
	img = Image.create(new_size.x, new_size.y, false, Image.FORMAT_RGBA8)
	var viewport_img: Image = viewport.get_texture().get_image()
	img.blit_rect(viewport_img, Rect2(0, 0, new_size.x, new_size.y), Vector2(0, 0))
	SaveSystem.SaveImage(img, "SystemGenerator")


func select_colorscheme(scheme: PackedColorArray) -> void:
	generator.update_color_palette(scheme)


func _generate_new() -> void:
	viewport.size = new_size
	generator.set_render_size(new_size)
	$SubViewport/Camera1.zoom = Vector2(1.0, 1.0)
	$SubViewport/Camera1.offset = new_size * 0.5

	await get_tree().process_frame
	generator.generate_new(int(seed_box.value))


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
	export_image()


func _on_pixelization_slider_value_changed(value: float) -> void:
	generator.set_pixelization_scale(int(value))
	pixelization_value.text = str(value)


func _on_enable_stars_pressed() -> void:
	generator.toggle_background_stars()


func _on_enable_dust_pressed() -> void:
	generator.toggle_dust()


func _on_enable_nebulae_pressed() -> void:
	generator.toggle_nebulae()


func _on_enable_planets_pressed() -> void:
	generator.toggle_planets()


func _on_enable_transparency_pressed() -> void:
	generator.toggle_transparancy()
	viewport_background.visible = !viewport_background.visible


func _on_brightness_slider_value_changed(value: float) -> void:
	generator.set_brightness(brightness_slider.value)
	brightness_value.text = str(value)


func _on_enable_lighting_toggled(toggled_on: bool) -> void:
	generator.toggle_lighting(toggled_on)


func _on_enable_dither_toggled(toggled_on: bool) -> void:
	generator.set_dither_status(toggled_on)


func _on_use_random_colors_toggled(toggled_on: bool) -> void:
	generator.set_use_random_colors(toggled_on)


func _on_color_mode_option_button_item_selected(index: int) -> void:
	generator.color_mode = index as ColorHelpers.COLOR_MODE
