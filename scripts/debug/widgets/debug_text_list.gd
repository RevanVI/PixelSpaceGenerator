extends DebugWidget

const WIDGET_KEYWORDS: Dictionary[String, String] = {
	'ADD_LABEL': 'add_label',
	'REMOVE_LABEL': 'remove_label',
}

@onready var list_node: VBoxContainer = $VBoxContainer


func _callback(widget_keyword: String, data) -> void:
	match widget_keyword:
		WIDGET_KEYWORDS.ADD_LABEL:
			add_label(data.name, str(data.value))
		WIDGET_KEYWORDS.REMOVE_LABEL:
			remove_label(data.name)
		_:
			Log.error(self, 'No callback has been defined. (' + widget_keyword + ', ' + data + ')')            


func get_widget_keywords() -> Array[String]:
	return WIDGET_KEYWORDS.values()


func add_label(label_name: String, text: String) -> void:
	var label: Label = _find_child_by_name(label_name)
	if label:
		label.text = text
		return
	
	label = Label.new()
	label.name = label_name
	label.text = text
	list_node.add_child(label)


func remove_label(label_name: String) -> void:
	var label: Label = _find_child_by_name(label_name)
	if label:
		list_node.remove_child(label)


func _find_child_by_name(child_name: String) -> Node:
	for child: Node in list_node.get_children():
		if child.name == child_name:
			return child
	
	return null
