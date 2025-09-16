extends Control


@onready var generator : Control = $SubViewport/BackgroundGenerator
@onready var viewport : SubViewport = $SubViewport
@onready var global_scheme : GradientTexture2D = preload("res://sprites/Colorscheme.tres")
@onready var path : String = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
@onready var label_3: Label = $HBoxContainer/ColorRect/Settings/Label3

var new_size : Vector2i = Vector2i(200,200)

func _ready() -> void:
	randomize()
	_generate_new()
	OS.low_processor_usage_mode = true
	OS.request_permissions()
	label_3.text += path

func _generate_new() -> void:
	$SubViewport.size = new_size
	generator.custom_minimum_size = new_size
	generator.size = new_size
	generator.set_mirror_size(new_size)
	$SubViewport/Camera1.zoom = new_size/viewport.size
	$SubViewport/Camera1.offset = new_size * 0.5
	
	var aspect : Vector2 = Vector2.ONE
	if new_size.x > new_size.y:
		aspect = Vector2(new_size.y / new_size.x, 1.0)
	else:
		aspect = Vector2(1.0, new_size.x / new_size.y)
	
	$HBoxContainer/Control/MarginContainer/TextureRect.size = aspect * 600

	await get_tree().process_frame
	$HBoxContainer/Control/MarginContainer/TextureRect.size = Vector2(600,600)
	generator.generate_new()

func _on_NewButton_pressed() -> void:
	_generate_new()

func _on_ExportButton_pressed() -> void:
	$SubViewport/Camera1.enabled = false
	$SubViewport/Camera2.enabled = true
	$SaveTimer.start()

func export_image() -> void:
	var img : Image
	img = Image.create(new_size.x, new_size.y, false, Image.FORMAT_RGBA8)
	var viewport_img : Image = viewport.get_texture().get_image()
	
	img.blit_rect(viewport_img, Rect2(0,0,new_size.x,new_size.y), Vector2(0,0))
	
	save_image(img)

func save_image(img : Image) -> void:
	img.save_png(path + "/Space Background " + str(randi()%100) + ".png")

func _on_SaveTimer_timeout() -> void:
	export_image()
	$SubViewport/Camera1.enabled = true
	$SubViewport/Camera2.enabled = false

func select_colorscheme(scheme : PackedColorArray) -> void:
	$SubViewport/BackgroundGenerator.set_background_color(scheme[0])
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
	$HBoxContainer/Control/ColorRect.visible = !$HBoxContainer/Control/ColorRect.visible
