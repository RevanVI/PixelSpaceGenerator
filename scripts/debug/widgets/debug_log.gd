extends DebugWidget

const WIDGET_KEYWORDS: Dictionary[String, String] = {
	'ADD_LOG': 'add_log',
	'CLEAR_LOG': 'clear_log',
}

@onready var log_text: TextEdit = $VBoxContainer/LogText


func get_widget_keywords() -> Array[String]:
	return WIDGET_KEYWORDS.values()


func add_log(text: String) -> void:
	log_text.text = log_text.text + "\n" + text
	log_text.scroll_vertical = log_text.get_line_count()


func clear_log() -> void:
	log_text.clear()


func _callback(widget_keyword: String, data) -> void:
	match widget_keyword:
		WIDGET_KEYWORDS.ADD_LOG:
			add_log(str(data))
		WIDGET_KEYWORDS.CLEAR_LOG:
			clear_log()
		_:
			Log.error(self, 'No callback has been defined. (' + widget_keyword + ', ' + data + ')')


func _on_clear_log_pressed() -> void:
	clear_log()
