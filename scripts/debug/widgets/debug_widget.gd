@abstract
class_name DebugWidget
extends MarginContainer

@export var allow_null_data: bool = false


@abstract func get_widget_keywords() -> Array[String]


# Abstract method which must be overridden by the inheriting debug widget.
# Handles the widget's response when one of its keywords has been invoked.
@abstract func _callback(widget_keyword: String, data) -> void


# Called by DebugContainer when one of its widget keywords has been invoked.
func handle_callback(widget_keyword: String, data = null) -> void:
	if data == null and not allow_null_data:
		Log.error(name, "data is null")
		return
	_callback(widget_keyword, data)
