extends Control


@onready var generator : BackgroundGenerator = $SubViewport/BackgroundGenerator
@onready var viewport : SubViewport = $SubViewport
@onready var global_scheme : GradientTexture2D = preload("res://sprites/Colorscheme.tres")
@onready var path : String = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
@onready var export_path: Label = $HBoxContainer/OptionsColorRect/Settings/ExportPathLabel

@onready var enable_stars_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableStars
@onready var enable_dust_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableDust
@onready var enable_nebulae_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableNebulae
@onready var enable_planets_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnablePlanets
@onready var enable_tile_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableTile
@onready var enable_reduce_background_toggle: CheckBox = $HBoxContainer/OptionsColorRect/Settings/OptionsGridContainer/EnableReduceBackground
@onready var enable_transparency: CheckBox = $HBoxContainer/OptionsColorRect/Settings/EnableTransparency

var new_size : Vector2i = Vector2i(200,200)


func _ready() -> void:
	randomize()
	OS.low_processor_usage_mode = true
	OS.request_permissions()

	#setup toggles with defaul values
	enable_stars_toggle.button_pressed = generator.dust.visible
	enable_dust_toggle.button_pressed = generator.dust.visible
	enable_nebulae_toggle.button_pressed = generator.nebulae.visible
	enable_planets_toggle.button_pressed = generator.planetcontainer.visible
	enable_tile_toggle.button_pressed = generator.should_tile
	enable_reduce_background_toggle.button_pressed = generator.reduce_background
	enable_transparency.button_pressed = generator.background.visible

	_generate_new()
	export_path.text += path


func _generate_new() -> void:
	viewport.size = new_size
	generator.custom_minimum_size = new_size
	generator.size = new_size
	$SubViewport/Camera1.zoom = Vector2(1.0, 1.0)
	$SubViewport/Camera1.offset = new_size * 0.5
	
	await get_tree().process_frame
	$HBoxContainer/RenderControl/MarginContainer/SubViewportTextureRect.size = Vector2(600,600)
	generator.generate_new()


func _on_NewButton_pressed() -> void:
	_generate_new()


func _on_ExportButton_pressed() -> void:
	$SaveTimer.start()


func export_image() -> void:
	var img : Image
	img = Image.create(new_size.x, new_size.y, false, Image.FORMAT_RGBA8)
	var viewport_img : Image = viewport.get_texture().get_image()
	img.blit_rect(viewport_img, Rect2(0,0,new_size.x,new_size.y), Vector2(0,0))
	save_image(img)


func save_image(img : Image) -> void:
	var date: String = Time.get_datetime_string_from_system(false, true)
	date = date.replace_chars(" -:", "_".unicode_at(0))
	img.save_png(path + "/SpaceBackground_" + str(date) + ".png")


func _on_SaveTimer_timeout() -> void:
	export_image()


func select_colorscheme(scheme : PackedColorArray) -> void:
	generator.set_background_color(scheme[0])
	global_scheme.gradient.colors = scheme.slice(1,8)


func _on_EnableStars_pressed() -> void:
	generator.toggle_stars()


func _on_EnableDust_pressed() -> void:
	generator.toggle_dust()


func _on_EnableNebulae_pressed() -> void:
	generator.toggle_nebulae()


func _on_EnablePlanets_pressed() -> void:
	generator.toggle_planets()


func _on_EnableReduceBackground_pressed() -> void:
	generator.toggle_reduce_background()


func _on_EnableTile_pressed() -> void:
	generator.toggle_tile()


func _on_PixelsHeight_value_changed(value : int) -> void:
	value = clamp(value, 100, 5000)
	new_size.y = int(value)


func _on_PixelsWidth_value_changed(value : int) -> void:
	value = clamp(value, 100, 5000)
	new_size.x = int(value)


func _on_EnableTransparency_pressed() -> void:
	generator.toggle_transparancy()
	$HBoxContainer/RenderControl/BackgroundColor.visible = !$HBoxContainer/RenderControl/BackgroundColor.visible
