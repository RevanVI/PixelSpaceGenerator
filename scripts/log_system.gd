class_name Log
extends Node


static func info(object: Object, msg: String) -> void:
	var line: String = "[{time}] {event} {object}: {message}".format(
		{
			"time": Time.get_datetime_string_from_system(),
			"object": object.name,
			"event": "INFO",
			"message": msg,
		},
	)

	print(line)
	if Debug.is_container_registered('LogView:DebugLog.add_log'):
		Debug.update_widget('LogView:DebugLog.add_log', line)


static func warning(object: Object, msg: String) -> void:
	var line: String = "[{time}] {event} {object}: {message}".format(
		{
			"time": Time.get_datetime_string_from_system(),
			"object": object.name,
			"event": "WARNING",
			"message": msg,
		},
	)
	print(line)
	if Debug.is_container_registered('LogView:DebugLog.add_log'):
		Debug.update_widget('LogView:DebugLog.add_log', line)


static func error(object: Object, msg: String) -> void:
	var line: String = "[{time}] {event} {object}: {message}".format(
		{
			"time": Time.get_datetime_string_from_system(),
			"object": object.name,
			"event": "ERROR",
			"message": msg,
		},
	)
	printerr(line)
	if Debug.is_container_registered('LogView:DebugLog.add_log'):
		Debug.update_widget('LogView:DebugLog.add_log', line)
