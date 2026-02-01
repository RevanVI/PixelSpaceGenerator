class_name DebugContainer
extends MarginContainer

var _widget_keywords: Dictionary = { }


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_register_debug_widgets(self)
	Debug.register_debug_container(self)


func update_widget(widget_path: String, data) -> void:
	var split_widget_path: PackedStringArray = widget_path.split(".")
	if split_widget_path.size() != 2:
		Log.error(name, "incorrect widget_path: " + widget_path)
		return

	var widget_name: String = split_widget_path[0]
	var widget_keyword: String = split_widget_path[1]

	if _widget_keywords.has(widget_name) and _widget_keywords[widget_name].has(widget_keyword):
		_widget_keywords[widget_name][widget_keyword].handle_callback(widget_keyword, data)
	else:
		Log.error(name, "Pair " + widget_name + "." + widget_keyword + " is not found in " + str(_widget_keywords))


func _add_widget_keyword(widget_keyword: String, widget_node: Node) -> void:
	var widget_node_name: String = widget_node.name

	if not _widget_keywords.has(widget_node_name):
		_widget_keywords[widget_node_name] = { }

	if not _widget_keywords[widget_node_name].has(widget_keyword):
		_widget_keywords[widget_node_name][widget_keyword] = widget_node
	else:
		Log.error(name, "Widget keyword " + widget_node_name + "." + widget_keyword + " already exists")


func _register_debug_widgets(node: Node) -> void:
	for child: Node in node.get_children():
		if child is DebugWidget:
			_register_debug_widget(child)
		elif child.get_child_count() > 0:
			_register_debug_widgets(child)


func _register_debug_widget(widget_node: DebugWidget) -> void:
	for widget_keyword: String in widget_node.get_widget_keywords():
		_add_widget_keyword(widget_keyword, widget_node)
