class_name Log
extends Node


static func info(object: Object, msg: String) -> void:
	print(
		"[{time}] {event} {object}: {message}".format(
			{
				"time": Time.get_datetime_string_from_system(),
				"object": object.name,
				"event": "INFO",
				"message": msg,
			},
		),
	)


static func warning(object: Object, msg: String) -> void:
	print(
		"[{time}] {event} {object}: {message}".format(
			{
				"time": Time.get_datetime_string_from_system(),
				"object": object.name,
				"event": "WARNING",
				"message": msg,
			},
		),
	)


static func error(object: Object, msg: String) -> void:
	printerr(
		"[{time}] {event} {object}: {message}".format(
			{
				"time": Time.get_datetime_string_from_system(),
				"object": object.name,
				"event": "ERROR",
				"message": msg,
			},
		),
	)
