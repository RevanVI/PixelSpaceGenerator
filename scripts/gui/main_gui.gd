class_name MainGUI
extends Control

@onready var modes_control: Control = $VBoxContainer/Modes


func _ready() -> void:
	Log.info(self, "_ready")
	modes_control.get_child(0).visible = true


func _on_option_button_item_selected(index: int) -> void:
	Log.info(self, "mode change: " + str(index))
	var modes: Array[Node] = modes_control.get_children()
	for i: int in range(modes.size()):
		if i == index:
			modes[i].visible = true
		else:
			modes[i].visible = false
