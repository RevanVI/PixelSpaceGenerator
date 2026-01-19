class_name ColorDataArray
extends Resource

@export var data: Array[ColorData]


func _init() -> void:
	data = []


func get_type_count() -> int:
	return data.size()


func get_data(ind: int) -> ColorData:
	return data[ind]
