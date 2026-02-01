class_name SchemeSelectButton
extends Button

signal scheme_selected(color_scheme: PackedColorArray)

@export var color_scheme: PackedColorArray

@onready var color_button_scene: PackedScene = preload("res://scenes/gui/color_picker_button.tscn")


func _ready() -> void:
	for i: int in color_scheme.size():
		var b: ColorPickerButton = ColorPickerButton.new()

		b.color = color_scheme[i]
		b.size_flags_horizontal = SIZE_EXPAND_FILL
		b.connect("color_changed", Callable(self, "_on_color_changed").bind(i))
		$HBoxContainer.add_child(b)


func _on_color_changed(color: Color, index: int) -> void:
	color_scheme[index] = color
	scheme_selected.emit(color_scheme)


func _on_button_pressed() -> void:
	scheme_selected.emit(color_scheme)
