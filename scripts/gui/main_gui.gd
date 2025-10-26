extends Control
class_name MainGUI


@onready var modesControl: Control = $VBoxContainer/Modes


func _ready() -> void:
	modesControl.get_child(0).visible = true


func _on_option_button_item_selected(index: int) -> void:
	var modes: Array[Node] = modesControl.get_children()
	for i: int in range(modes.size()):
		if i == index:
			modes[i].visible = true
		else:
			modes[i].visible = false
