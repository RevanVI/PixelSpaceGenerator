@tool
extends Node2D



@export var linear_gradien_tex: TextureRect
@export var contant_gradien_tex: TextureRect
@export var lightened_contant_gradien_tex: TextureRect
@export var darkened_contant_gradien_tex: TextureRect
@export var shader_linear_tex: TextureRect



@export_category("Input")
@export var a: Color:
	set(new_color):
		a = new_color
		update_colors()

@export var b: Color:
	set(new_color):
		b = new_color
		update_colors()

@export var c: Color:
	set(new_color):
		c = new_color
		update_colors()

@export var d: Color:
	set(new_color):
		d = new_color
		update_colors()

@export_tool_button("Generate random") var generate_action = generate_random_coefs


@export_category("Output")
@export var output_colors: PackedColorArray


func generate_new_colors(count: int) -> PackedColorArray:
	var colors: PackedColorArray = PackedColorArray()

	count = max(count, 1)
	for i: int in range(0, count):
		var modif: float = i / float(max(count - 1.0, 1))
		var x: float =  a.r + b.r * cos(6.28 * (c.r * modif + d.r))
		var y: float =  a.g + b.g * cos(6.28 * (c.g * modif + d.g))
		var z: float =  a.b + b.b * cos(6.28 * (c.b * modif + d.b))
		colors.append(Color(x, y, z))
	
	return colors


func generate_random_coefs() -> void:
	a = Color(0.5, 0.5, 0.5)
	b = Color(0.5, 0.5, 0.5)
	c = Color(randf_range(0.4, 1.6), randf_range(0.4, 1.6), randf_range(0.4, 1.6))
	d = Color(randf_range(0.4, 1.2), randf_range(0.4, 1.2), randf_range(0.4, 1.2))


func update_colors() -> void:
	output_colors = generate_new_colors(6)
	(linear_gradien_tex.texture as GradientTexture1D).gradient.colors = output_colors
	(contant_gradien_tex.texture as GradientTexture1D).gradient.colors = output_colors

	var lightened: PackedColorArray = output_colors.duplicate()
	var darkened: PackedColorArray = output_colors.duplicate()
	for i: int in range(0, lightened.size()):
		lightened[i] = lightened[i].lightened(0.3)
		darkened[i] = darkened[i].darkened(0.3)
	(lightened_contant_gradien_tex.texture as GradientTexture1D).gradient.colors = lightened
	(darkened_contant_gradien_tex.texture as GradientTexture1D).gradient.colors = darkened
	shader_linear_tex.material.set_shader_parameter("a", Vector3(a.r, a.g, a.b))
	shader_linear_tex.material.set_shader_parameter("b", Vector3(b.r, b.g, b.b))
	shader_linear_tex.material.set_shader_parameter("c", Vector3(c.r, c.g, c.b))
	shader_linear_tex.material.set_shader_parameter("d", Vector3(d.r, d.g, d.b))
